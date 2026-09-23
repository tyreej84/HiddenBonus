-- HiddenBonus.UI.lua
-- Hidden Bonus - options window
--
-- Dark, flat, modern-styled panel (no Blizzard stone/parchment templates).
-- Three columns: current raid bosses, current Mythic+ dungeons, and Delves.
-- Everything is hidden by default; checking a box keeps the bonus roll
-- prompt visible for that content.

local ADDON, ns = ...

local COLUMN_WIDTH = 190
local ROW_HEIGHT = 22
local COL_TOP_Y = -84

-- Flat dark palette
local BG = { 0.07, 0.07, 0.09, 0.97 }
local BORDER = { 0.20, 0.20, 0.24, 1 }
local HEADER_BG = { 0.10, 0.10, 0.13, 1 }
local ACCENT = { 0.40, 0.62, 1.00 }
local TEXT = { 0.82, 0.83, 0.86 }
local TEXT_MUTED = { 0.52, 0.53, 0.57 }
local TEXT_HEADER = { 0.95, 0.95, 0.97 }
local CHECK_BG = { 0.12, 0.12, 0.15, 1 }
local CHECK_BORDER = { 0.32, 0.32, 0.37, 1 }

local frame
local raidChecks, dungeonChecks = {}, {}
local delveCheck

local function Flat(parent)
    local f = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    return f
end

local function MakeColumnHeader(parent, x, text)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, COL_TOP_Y)
    fs:SetText(text)
    fs:SetTextColor(unpack(ACCENT))
    return fs
end

local function MakeCheck(parent, x, y, label, onChange)
    local btn = Flat(parent)
    btn:SetSize(16, 16)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    btn:SetBackdropColor(unpack(CHECK_BG))
    btn:SetBackdropBorderColor(unpack(CHECK_BORDER))
    btn:EnableMouse(true)

    local mark = btn:CreateTexture(nil, "OVERLAY")
    mark:SetPoint("TOPLEFT", 3, -3)
    mark:SetPoint("BOTTOMRIGHT", -3, 3)
    mark:SetColorTexture(unpack(ACCENT))
    mark:Hide()
    btn.mark = mark
    btn.checked = false

    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("LEFT", btn, "RIGHT", 7, 0)
    fs:SetWidth(COLUMN_WIDTH - 26)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(false)
    fs:SetText(label)
    fs:SetTextColor(unpack(TEXT))

    function btn:SetChecked(val)
        self.checked = val and true or false
        self.mark:SetShown(self.checked)
    end

    function btn:GetChecked()
        return self.checked
    end

    btn:SetScript("OnMouseUp", function(self)
        self:SetChecked(not self.checked)
        onChange(self.checked)
    end)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(ACCENT))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(CHECK_BORDER))
    end)

    return btn
end

local function BuildFrame()
    frame = CreateFrame("Frame", "HiddenBonusFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetSize(640, 440)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(BG))
    frame:SetBackdropBorderColor(unpack(BORDER))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetToplevel(true)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    -- Title bar
    local titleBar = Flat(frame)
    titleBar:SetPoint("TOPLEFT", 1, -1)
    titleBar:SetPoint("TOPRIGHT", -1, -1)
    titleBar:SetHeight(34)
    titleBar:SetBackdropColor(unpack(HEADER_BG))
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local title = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("LEFT", titleBar, "LEFT", 12, 0)
    title:SetText("Hidden Bonus")
    title:SetTextColor(unpack(TEXT_HEADER))

    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -8, 0)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetAllPoints()
    closeText:SetText("x")
    closeText:SetTextColor(unpack(TEXT_MUTED))
    closeBtn.text = closeText
    closeBtn:SetScript("OnEnter", function(self) self.text:SetTextColor(unpack(ACCENT)) end)
    closeBtn:SetScript("OnLeave", function(self) self.text:SetTextColor(unpack(TEXT_MUTED)) end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    local sub = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -46)
    sub:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -46)
    sub:SetJustifyH("LEFT")
    sub:SetTextColor(unpack(TEXT_MUTED))
    sub:SetText("Everything below is hidden by default. Check anything you still want a bonus roll prompt for.")

    local db = ns.GetDB()

    -- Raid bosses
    local raidX = 16
    MakeColumnHeader(frame, raidX, "RAID BOSSES")
    local raid = ns.GetRaidEncounters()
    local y = COL_TOP_Y - 20
    for _, boss in ipairs(raid.list) do
        local cb = MakeCheck(frame, raidX, y, boss.name, function(checked)
            ns.GetDB().shownBosses[boss.id] = checked or nil
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
    local dungeonX = raidX + COLUMN_WIDTH + 12
    MakeColumnHeader(frame, dungeonX, "MYTHIC+ DUNGEONS")
    local dungeons = ns.GetDungeonEncounters()
    y = COL_TOP_Y - 20
    for _, dungeon in ipairs(dungeons.list) do
        local cb = MakeCheck(frame, dungeonX, y, dungeon.name, function(checked)
            ns.GetDB().shownDungeons[dungeon.mapID] = checked or nil
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
    local delveX = dungeonX + COLUMN_WIDTH + 12
    MakeColumnHeader(frame, delveX, "DELVES")
    delveCheck = MakeCheck(frame, delveX, COL_TOP_Y - 20, "Keep showing bonus rolls from Delves", function(checked)
        ns.GetDB().showDelves = checked
    end)

    frame:SetScript("OnShow", function()
        local d = ns.GetDB()
        for _, entry in ipairs(raidChecks) do
            entry.cb:SetChecked(d.shownBosses[entry.id] == true)
        end
        for _, entry in ipairs(dungeonChecks) do
            entry.cb:SetChecked(d.shownDungeons[entry.id] == true)
        end
        delveCheck:SetChecked(d.showDelves == true)
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
