-- === Whitelist Loader (Global Table Expected) ===
if not validItemIDs then
    print("[HeraldObserver] Failed to load whitelist (validItemIDs not defined).")
    validItemIDs = {}
end

print("[HeraldObserver] Whitelist loaded. Sample:", validItemIDs[28257], validItemIDs[28260], validItemIDs[28301])

-- === SavedVariables ===
HeraldObserverDB = HeraldObserverDB or {}
local db = HeraldObserverDB

-- === Defaults ===
db.selectedChoice = db.selectedChoice or "self"
db.clampToScreen = db.clampToScreen ~= false
db.showMinimapButton = db.showMinimapButton ~= false
db.framePos = db.framePos or {
    point = "RIGHT",
    relativeTo = "UIParent",
    relativePoint = "RIGHT",
    x = -50,
    y = 0
}

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
    local quality = select(3, GetItemInfo(itemLink)) -- 7 = Heirloom
    local isHeirloom = quality == 7

    local ilvlOk = ilvl and ilvl <= 107
    local expacOk = not (expac and expac > 2)
    local heirloomOk = not isHeirloom

    return ilvlOk, expacOk, heirloomOk
end

local function sendGearValidationMessage(playerName, itemLink, reason)
    local message = string.format("%s ==> %s (%s)", playerName, itemLink, reason)
    if heraldSelectedChoice == "self" then
        print("[HeraldObserver] " .. message)
    else
        local chatType = getChatType()
        SendChatMessage(message, chatType, nil, chatType == "WHISPER" and playerName or nil)
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
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            local inWhitelist = itemID and validItemIDs[itemID]
            local ilvlOk, expacOk, heirloomOk = getGearValidity(itemLink)

            if not inWhitelist or not ilvlOk or not expacOk or not heirloomOk then
                gearOK = false
                local reason = ""
                if not inWhitelist then reason = "not in whitelist" end
                if not ilvlOk then reason = reason .. (reason ~= "" and ", " or "") .. "ilvl" end
                if not expacOk then reason = reason .. (reason ~= "" and ", " or "") .. "expac" end
                if not heirloomOk then reason = reason .. (reason ~= "" and ", " or "") .. "heirloom" end
                sendGearValidationMessage(playerName, itemLink, reason)
            end
        end
    end

    if gearOK then
        local message = playerName .. " Gear OK"
        if heraldSelectedChoice == "self" then
            print("[HeraldObserver] " .. message)
        else
            SendChatMessage(message, getChatType(), nil, getChatType() == "WHISPER" and playerName or nil)
        end
    end
end

-- === UI Setup ===
print("[HeraldObserver] Addon loaded successfully.")

heraldObserverFrame = CreateFrame("Frame", "HeraldObserverFrame", UIParent, "BasicFrameTemplate")
heraldObserverFrame:SetMovable(true)
heraldObserverFrame:EnableMouse(true)
heraldObserverFrame:RegisterForDrag("LeftButton")
heraldObserverFrame:SetScript("OnDragStart", heraldObserverFrame.StartMoving)
heraldObserverFrame:SetScript("OnDragStop", function()
    heraldObserverFrame:StopMovingOrSizing()
    local point, relativeTo, relativePoint, x, y = heraldObserverFrame:GetPoint()
    db.framePos = {
        point = point,
        relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
        relativePoint = relativePoint,
        x = x,
        y = y
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
C_Timer.After(1, function() heraldObserverFrame:Hide() end)

-- Title
local title = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", heraldObserverFrame, "TOP", 0, -5)
title:SetText("Herald Observer")

-- Instructions
local instructions = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
instructions:SetPoint("TOP", heraldObserverFrame, "TOP", 0, -180)
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

-- Clamp to Screen Checkbox
local clampCheckbox = CreateFrame("CheckButton", "HeraldObserverClampCheckbox", heraldObserverFrame, "UICheckButtonTemplate")
clampCheckbox:SetSize(24, 24)
clampCheckbox:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -10)
clampCheckbox:SetChecked(isClamped)
clampCheckbox:SetScript("OnClick", function(self)
    isClamped = self:GetChecked()
    db.clampToScreen = isClamped
    heraldObserverFrame:SetClampedToScreen(isClamped)
end)

local clampLabel = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
clampLabel:SetPoint("LEFT", clampCheckbox, "RIGHT", 5, 0)
clampLabel:SetText("Clamp To Screen")

-- Minimap Toggle Checkbox
local minimapCheckbox = CreateFrame("CheckButton", "HeraldObserverMinimapCheckbox", heraldObserverFrame, "UICheckButtonTemplate")
minimapCheckbox:SetSize(24, 24)
minimapCheckbox:SetPoint("TOPLEFT", clampCheckbox, "BOTTOMLEFT", 0, -10)
minimapCheckbox:SetChecked(db.showMinimapButton)
minimapCheckbox:SetScript("OnClick", function(self)
    db.showMinimapButton = self:GetChecked()
    if _G.HO_MinimapButton then
        _G.HO_MinimapButton:SetShown(db.showMinimapButton)
    end
end)

local minimapLabel = heraldObserverFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
minimapLabel:SetPoint("LEFT", minimapCheckbox, "RIGHT", 5, 0)
minimapLabel:SetText("Show Minimap Button")

-- Observe Button
local observeButton = CreateFrame("Button", "HeraldObserverHeraldButton", heraldObserverFrame, "UIPanelButtonTemplate")
observeButton:SetPoint("BOTTOMLEFT", heraldObserverFrame, "BOTTOMLEFT", 10, 10)
observeButton:SetSize(290, 50)
observeButton:SetText("Observe")
observeButton:SetScript("OnClick", function()
    scanCharacterSheet()
end)

-- Slash Command
SLASH_HERALD1 = "/herald"
SlashCmdList["HERALD"] = function()
    if heraldObserverFrame:IsShown() then
        heraldObserverFrame:Hide()
    else
        heraldObserverFrame:Show()
    end
end

function hoshow()
    SlashCmdList["HERALD"]()
end
