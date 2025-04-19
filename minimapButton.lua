print("[HeraldObserver] Minimap button loaded.")

HeraldObserverDB = HeraldObserverDB or {}
local db = HeraldObserverDB
local myIconPos = db.minimapAngle or 0

local function getMinimapButtonPosition(angle)
    local x = 52 - (80 * math.cos(angle))
    local y = (80 * math.sin(angle)) - 52
    return x, y
end

local minibtn = CreateFrame("Button", nil, Minimap)
minibtn:SetFrameLevel(8)
minibtn:SetSize(32, 32)
minibtn:SetMovable(true)

local texturePath = "Interface\\AddOns\\HeraldObserver\\images\\logo.png"
minibtn:SetNormalTexture(texturePath)
minibtn:SetPushedTexture(texturePath)
minibtn:SetHighlightTexture(texturePath)

local function updateMapBtn()
    local x, y = GetCursorPosition()
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    x = xmin - x / Minimap:GetEffectiveScale() + 70
    y = y / Minimap:GetEffectiveScale() - ymin - 70
    myIconPos = math.deg(math.atan2(y, x))

    local posX, posY = getMinimapButtonPosition(math.rad(myIconPos))
    minibtn:ClearAllPoints()
    minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", posX, posY)
end

minibtn:RegisterForDrag("LeftButton")
minibtn:SetScript("OnDragStart", function()
    minibtn:StartMoving()
    minibtn:SetScript("OnUpdate", updateMapBtn)
end)

minibtn:SetScript("OnDragStop", function()
    minibtn:StopMovingOrSizing()
    minibtn:SetScript("OnUpdate", nil)
    updateMapBtn()
    db.minimapAngle = myIconPos
end)

local x, y = getMinimapButtonPosition(math.rad(myIconPos))
minibtn:ClearAllPoints()
minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", x, y)

minibtn:SetScript("OnClick", function()
    if hoshow then hoshow() end
end)
