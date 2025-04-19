-- ========================
-- Herald Observer Addon
-- ========================

-- === SavedVariables ===
HeraldObserverDB = HeraldObserverDB or {}
local db = HeraldObserverDB

-- === Defaults (on first load) ===
db.selectedChoice = db.selectedChoice or "self"
db.clampToScreen = db.clampToScreen ~= false -- default to true if nil
db.framePos = db.framePos or { point = "RIGHT", relativeTo = "UIParent", relativePoint = "RIGHT", x = -50, y = 0 }

local heraldSelectedChoice = db.selectedChoice
local isClamped = db.clampToScreen
local heraldObserverFrame

-- === Utility Functions ===

local function getChatType()
    if heraldSelectedChoice == "target" then return "WHISPER"
    elseif heraldSelectedChoice == "party" then return "PARTY"
    elseif heraldSelectedChoice == "raid" then return "RAID"
    else return "SAY" end
end

local function getGearValidity(itemLink)
    local ilvl = GetDetailedItemLevelInfo(itemLink)
    local expac = select(15, GetItemInfo(itemLink))
    local ilvlOk = ilvl and ilvl <= 107
    local expacOk = not (expac and expac > 2)
    return ilvlOk, expacOk
end

local function sendGearValidationMessage(playerName, itemLink, reason)
    local message = string.format("%s ==> %s (%s)", playerName, itemLink, reason)
    if heraldSelectedChoice:lower() == "self" then
        print("[HeraldObserver] " .. message)
    else
        local chatType = getChatType()
        if chatType == "WHISPER" then
            SendChatMessage(message, chatType, nil, playerName)
        else
            SendChatMessage(message, chatType)
        end
    end
end

local function scanCharacterSheet()
    local playerName = UnitName("target")
    if not playerName then
        print("[HeraldObserver] No target selected.")
        return
    end

    local gearOK = true
    for slotID = 1, 19 do
        local itemLink = GetInventoryItemLink("target", slotID)
        if itemLink then
            local ilvlOk, expacOk = getGearValidity(itemLink)
            if not (ilvlOk and expacOk) then
                gearOK = false
                local reason = "reason:"
                if not ilvlOk then reason = reason .. " ilvl" end
                if not expacOk then reason = reason .. " expac" end
                sendGearValidationMessage(playerName, itemLink, reason)
            end
        end
    end

    if gearOK then
        local chatType = getChatType()
        local message = playerName .. " Gear OK"
        if heraldSelectedChoice == "self" then
            print("[HeraldObserver] " .. message)
        else
            SendChatMessage(message, chatType, nil, chatType == "WHISPER" and playerName or nil)
        end
    end
end

-- === UI Functions ===

local function toggleHeraldObserverFrame()
    if heraldObserverFrame:IsShown() then
        heraldObserverFrame:Hide()
    else
        heraldObserverFrame:Show()
    end
end

local function toggleClampToScreen(self)
    local isChecked = self:GetChecked()
    isClamped = isChecked
    db.clampToScreen = isChecked
    heraldObserverFrame:SetClampedToScreen(isChecked)
end

-- === Initialization ===

print("[HeraldObserver] Addon loaded successfully.")

heraldObserverFrame = CreateFrame("Frame", "HeraldObserverFrame", UIParent, "BasicFrameTemplate")
heraldObserverFrame:SetMovable(true)
heraldObserverFrame:EnableMouse(true)
heraldObserverFrame:RegisterForDrag("LeftButton")
heraldObserverFrame:SetScript("OnDragStart", heraldObserverFrame.StartMoving)
heraldObserverFrame:SetScript("OnDragStop", function()
    heraldObserverFrame:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = heraldObserverFrame:GetPoint()
    db.framePos = {
        point = point,
        relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
        relativePoint = relativePoint,
        x = xOfs,
        y = yOfs
    }
end)
heraldObserverFrame:SetPoint(
    db.framePos.point,
    _G[db.framePos.relativeTo],
    db.framePos.relativePoint,
    db.framePos.x,
    db.framePos.y
)
heraldObserverFrame:SetSize(310, 270)
heraldObserverFrame:SetResizeBounds(310, 175, 600, 400)
heraldObserverFrame:SetClampedToScreen(isClamped)
C_Timer.After(1, toggleHeraldObserverFrame)

-- Title
local title = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", heraldObserverFrame, "TOP", 0, -5)
title:SetText("Herald Observer")

-- Instructions
local instructions = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
instructions:SetPoint("TOP", heraldObserverFrame, "TOP", 0, -150)
instructions:SetWidth(280)
instructions:SetJustifyH("CENTER")
instructions:SetText("To check the gear of any player, target said player and click on Observe")

-- Dropdown
local dropdown = CreateFrame("Frame", "HeraldObserverDropdown", heraldObserverFrame, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", 20, -70)
UIDropDownMenu_SetWidth(dropdown, 150)

local label = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 5)
label:SetText("Send herald info to:")

local choices = {"self", "target", "party", "raid"}

local function dropdownOnClick(self)
    UIDropDownMenu_SetSelectedValue(dropdown, self.value)
    heraldSelectedChoice = self.value
    db.selectedChoice = self.value
end

UIDropDownMenu_Initialize(dropdown, function()
    for _, choice in ipairs(choices) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = choice
        info.value = choice
        info.func = dropdownOnClick
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_SetSelectedValue(dropdown, heraldSelectedChoice)

-- Checkbox
local clampCheckbox = CreateFrame("CheckButton", "HeraldObserverClampCheckbox", heraldObserverFrame, "UICheckButtonTemplate")
clampCheckbox:SetSize(24, 24)
clampCheckbox:SetPoint("LEFT", 0, 0)
clampCheckbox:SetChecked(isClamped)
clampCheckbox:SetScript("OnClick", toggleClampToScreen)

local clampLabel = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
clampLabel:SetPoint("LEFT", clampCheckbox, "RIGHT", 5, 0)
clampLabel:SetText("Clamp To Screen")

-- Button
local observeButton = CreateFrame("Button", "HeraldObserverHeraldButton", heraldObserverFrame, "UIPanelButtonTemplate")
observeButton:SetPoint("BOTTOMLEFT", heraldObserverFrame, "BOTTOMLEFT", 10, 10)
observeButton:SetSize(290, 50)
observeButton:SetText("Observe")
observeButton:SetScript("OnClick", function()
    scanCharacterSheet()
end)

-- Slash command
SLASH_HERALD1 = "/herald"
SlashCmdList["HERALD"] = toggleHeraldObserverFrame

-- Optional global
function hoshow()
    toggleHeraldObserverFrame()
end