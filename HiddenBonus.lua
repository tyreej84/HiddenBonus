-- HiddenBonus.lua
-- Hidden Bonus
-- v1.1.0
--
-- Hides the bonus roll prompt for everything by default. Check a raid boss,
-- Mythic+ dungeon, or Delves to keep seeing the prompt for that content;
-- everything left unchecked stays hidden. Boss and dungeon lists are read
-- from the Encounter Journal and the current Mythic+ season pool at runtime,
-- so a new tier or season needs no addon update.
--
-- Commands:
--   /hb, /hiddenbonus  toggle the options window

local ADDON, ns = ...
local ADDON_VERSION = "1.1.0"

-- DifficultyUtil.ID is Blizzard's table; the literals are a fallback.
local D = DifficultyUtil and DifficultyUtil.ID or {}
local DIFF_MYTHIC_PLUS = D.DungeonChallenge or 8
local DIFF_DELVE = 208

--------------------------------------------------------------------------------
-- Saved variables
--------------------------------------------------------------------------------

HiddenBonusDB = HiddenBonusDB or {}

local function GetDB()
    local d = HiddenBonusDB
    if type(d) ~= "table" then
        d = {}
        HiddenBonusDB = d
    end
    if type(d.shownBosses) ~= "table" then d.shownBosses = {} end
    if type(d.shownDungeons) ~= "table" then d.shownDungeons = {} end
    if d.showDelves == nil then d.showDelves = false end
    return d
end
ns.GetDB = GetDB

--------------------------------------------------------------------------------
-- Current-tier raid bosses (Encounter Journal, read live)
--------------------------------------------------------------------------------

local raidCache -- { list = { {id, name, instance}, ... }, byID = { [encounterID] = true } }

local function BuildRaidEncounters()
    local list, byID = {}, {}
    if not (EJ_GetNumTiers and EJ_GetInstanceByIndex and EJ_GetEncounterInfoByIndex) then
        return { list = list, byID = byID }
    end

    local tier = EJ_GetNumTiers() or 0
    if tier < 1 then
        return { list = list, byID = byID }
    end

    local savedTier = EJ_GetCurrentTier and EJ_GetCurrentTier() or nil
    local savedInstance = EJ_GetCurrentInstance and EJ_GetCurrentInstance() or nil

    if pcall(EJ_SelectTier, tier) then
        local i = 1
        while true do
            local instanceID, instanceName, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceByIndex(i, true)
            if not instanceID then break end

            -- dungeonAreaMapID == 0 marks the world-boss pseudo-instance; skip it,
            -- this addon only lists real raid encounters here.
            if dungeonAreaMapID ~= 0 then
                pcall(EJ_SelectInstance, instanceID)
                local j = 1
                while true do
                    local encounterName, _, encounterID = EJ_GetEncounterInfoByIndex(j, instanceID)
                    if not encounterID then break end
                    if encounterName and not byID[encounterID] then
                        byID[encounterID] = true
                        list[#list + 1] = { id = encounterID, name = encounterName, instance = instanceName }
                    end
                    j = j + 1
                end
            end
            i = i + 1
        end
    end

    if savedTier and savedTier > 0 then pcall(EJ_SelectTier, savedTier) end
    if savedInstance and savedInstance > 0 and EJ_SelectInstance then pcall(EJ_SelectInstance, savedInstance) end

    return { list = list, byID = byID }
end

local function GetRaidEncounters()
    if not raidCache then
        raidCache = BuildRaidEncounters()
    end
    return raidCache
end
ns.GetRaidEncounters = GetRaidEncounters

--------------------------------------------------------------------------------
-- Current-season Mythic+ dungeons (Challenge Mode pool, cross-referenced
-- against the Encounter Journal for their boss encounter IDs)
--------------------------------------------------------------------------------

local dungeonCache -- { list = { {mapID, name, encounterIDs = {}}, ... }, encounterToDungeon = { [encounterID] = mapID } }

local function BuildDungeonEncounters()
    local list, encounterToDungeon = {}, {}

    if not (C_ChallengeMode and C_ChallengeMode.GetMapTable and C_ChallengeMode.GetMapUIInfo) then
        return { list = list, encounterToDungeon = encounterToDungeon }
    end
    if not (EJ_GetNumTiers and EJ_GetInstanceByIndex and EJ_GetEncounterInfoByIndex) then
        return { list = list, encounterToDungeon = encounterToDungeon }
    end

    local seasonMaps = C_ChallengeMode.GetMapTable() or {}
    local nameToMapID = {}
    for _, mapID in ipairs(seasonMaps) do
        local name = C_ChallengeMode.GetMapUIInfo(mapID)
        if name then
            nameToMapID[name] = mapID
        end
    end

    local tier = EJ_GetNumTiers() or 0
    if tier < 1 then
        return { list = list, encounterToDungeon = encounterToDungeon }
    end

    local savedTier = EJ_GetCurrentTier and EJ_GetCurrentTier() or nil
    local savedInstance = EJ_GetCurrentInstance and EJ_GetCurrentInstance() or nil

    local byMapID = {}

    if pcall(EJ_SelectTier, tier) then
        local i = 1
        while true do
            local instanceID, instanceName = EJ_GetInstanceByIndex(i, false)
            if not instanceID then break end

            local mapID = instanceName and nameToMapID[instanceName]
            if mapID and not byMapID[mapID] then
                local entry = { mapID = mapID, name = instanceName, encounterIDs = {} }
                byMapID[mapID] = entry
                list[#list + 1] = entry

                pcall(EJ_SelectInstance, instanceID)
                local j = 1
                while true do
                    local _, _, encounterID = EJ_GetEncounterInfoByIndex(j, instanceID)
                    if not encounterID then break end
                    entry.encounterIDs[encounterID] = true
                    encounterToDungeon[encounterID] = mapID
                    j = j + 1
                end
            end
            i = i + 1
        end
    end

    if savedTier and savedTier > 0 then pcall(EJ_SelectTier, savedTier) end
    if savedInstance and savedInstance > 0 and EJ_SelectInstance then pcall(EJ_SelectInstance, savedInstance) end

    table.sort(list, function(a, b) return a.name < b.name end)

    return { list = list, encounterToDungeon = encounterToDungeon }
end

local function GetDungeonEncounters()
    if not dungeonCache then
        dungeonCache = BuildDungeonEncounters()
    end
    return dungeonCache
end
ns.GetDungeonEncounters = GetDungeonEncounters

--------------------------------------------------------------------------------
-- Filtering
--
-- Default-hide: any content this addon recognizes (current-tier raid bosses,
-- current-season Mythic+ dungeons, Delves) is hidden unless explicitly
-- checked to stay visible. Content the addon doesn't recognize is left
-- alone, since there is no control for it to obey.
--------------------------------------------------------------------------------

local function ShouldHide(info)
    local db = GetDB()

    if info.difficultyID == DIFF_DELVE then
        return db.showDelves ~= true
    end

    if info.difficultyID == DIFF_MYTHIC_PLUS then
        if info.encounterID and info.encounterID ~= 0 then
            local dungeons = GetDungeonEncounters()
            local mapID = dungeons.encounterToDungeon[info.encounterID]
            if mapID then
                return db.shownDungeons[mapID] ~= true
            end
        end
        return false
    end

    if info.encounterID and info.encounterID ~= 0 then
        local raid = GetRaidEncounters()
        if raid.byID[info.encounterID] then
            return db.shownBosses[info.encounterID] ~= true
        end
    end

    return false
end

local function HiddenBonus_OnBonusRollShow(frame)
    local info = {
        difficultyID = frame.difficultyID,
        encounterID = frame.encounterID,
    }

    if ShouldHide(info) then
        GroupLootContainer_RemoveFrame(GroupLootContainer, frame)
    end
end

local function HookBonusRollFrame()
    if not BonusRollFrame then
        return
    end
    BonusRollFrame:HookScript("OnShow", HiddenBonus_OnBonusRollShow)
end
HookBonusRollFrame()

--------------------------------------------------------------------------------
-- Slash command
--------------------------------------------------------------------------------

SLASH_HIDDENBONUS1 = "/hiddenbonus"
SLASH_HIDDENBONUS2 = "/hb"
SlashCmdList["HIDDENBONUS"] = function()
    if ns.ToggleOptions then
        ns.ToggleOptions()
    end
end

ns.ADDON_VERSION = ADDON_VERSION
