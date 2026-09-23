-- HiddenBonus.UI.lua
-- Hidden Bonus - options window
--
-- Three columns: current raid bosses, current Mythic+ dungeons, and Delves.
-- Checking a box hides the bonus roll prompt for that content.

local ADDON, ns = ...

local COLUMN_WIDTH = 190
local ROW_HEIGHT = 20
local COL_TOP_Y = -76

local frame
local raidChecks, dungeonChecks = {}, {}
local delveCheck

local function MakeColumnHeader(parent, x, text)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, COL_TOP_Y)
    fs:SetText(text)
    return fs
end

local function MakeCheck(parent, x, y, label)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    cb.Text:SetText(label)
    cb.Text:SetWidth(COLUMN_WIDTH - 26)
    cb.Text:SetWordWrap(false)
    cb.Text:SetNonSpaceWrap(false)
    return cb
end

local function BuildFrame()
    frame = CreateFrame("Frame", "HiddenBonusFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(620, 420)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:SetToplevel(true)
    frame:Hide()

    frame.TitleText:SetText("Hidden Bonus")

    local sub = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -32)
    sub:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -32)
    sub:SetJustifyH("LEFT")
    sub:SetText("Check anything you don't want to spend a bonus roll on. The prompt stays hidden for that content until you uncheck it here.")

    local db = ns.GetDB()

    -- Raid bosses
    local raidX = 16
    MakeColumnHeader(frame, raidX, "Raid Bosses")
    local raid = ns.GetRaidEncounters()
    local y = COL_TOP_Y - 18
    for _, boss in ipairs(raid.list) do
        local cb = MakeCheck(frame, raidX, y, boss.name)
        cb:SetScript("OnClick", function(self)
            ns.GetDB().hiddenBosses[boss.id] = self:GetChecked() and true or nil
        end)
        raidChecks[#raidChecks + 1] = { cb = cb, id = boss.id }
        y = y - ROW_HEIGHT
    end
    if #raid.list == 0 then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        fs:SetPoint("TOPLEFT", frame, "TOPLEFT", raidX, y)
        fs:SetText("No current raid found.")
    end

    -- Mythic+ dungeons
    local dungeonX = raidX + COLUMN_WIDTH + 10
    MakeColumnHeader(frame, dungeonX, "Mythic+ Dungeons")
    local dungeons = ns.GetDungeonEncounters()
    y = COL_TOP_Y - 18
    for _, dungeon in ipairs(dungeons.list) do
        local cb = MakeCheck(frame, dungeonX, y, dungeon.name)
        cb:SetScript("OnClick", function(self)
            ns.GetDB().hiddenDungeons[dungeon.mapID] = self:GetChecked() and true or nil
        end)
        dungeonChecks[#dungeonChecks + 1] = { cb = cb, id = dungeon.mapID }
        y = y - ROW_HEIGHT
    end
    if #dungeons.list == 0 then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        fs:SetPoint("TOPLEFT", frame, "TOPLEFT", dungeonX, y)
        fs:SetText("No current season pool found.")
    end

    -- Delves
    local delveX = dungeonX + COLUMN_WIDTH + 10
    MakeColumnHeader(frame, delveX, "Delves")
    delveCheck = MakeCheck(frame, delveX, COL_TOP_Y - 18, "Hide bonus rolls from Delves")
    delveCheck:SetScript("OnClick", function(self)
        ns.GetDB().hideDelves = self:GetChecked() and true or false
    end)

    frame:SetScript("OnShow", function()
        local d = ns.GetDB()
        for _, entry in ipairs(raidChecks) do
            entry.cb:SetChecked(d.hiddenBosses[entry.id] == true)
        end
        for _, entry in ipairs(dungeonChecks) do
            entry.cb:SetChecked(d.hiddenDungeons[entry.id] == true)
        end
        delveCheck:SetChecked(d.hideDelves == true)
    end)

    return frame
end

function ns.ToggleOptions()
    if not frame then
        BuildFrame()
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
