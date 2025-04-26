-- minimapButton.lua
print("[HeraldObserver] Minimap button loaded.")

HeraldObserverDB = HeraldObserverDB or {}
local db    = HeraldObserverDB
local angle = db.minimapAngle or 0

if db.showMinimapButton then
    local map   = Minimap
    local size  = 22                               -- button is 22×22
    local mapR  = map:GetWidth() / 2               -- minimap radius
    local btnR  = size / 2                         -- half your button
    local dist  = mapR - btnR                      -- center-to-button-center

    -- create & style
    local btn = CreateFrame("Button", "HO_MinimapButton", map)
    btn:SetSize(size, size)
    btn:SetMovable(true)
    btn:SetFrameLevel(8)

    local tex = "Interface\\AddOns\\HeraldObserver\\images\\logo.png"
    btn:SetNormalTexture(tex)
    btn:SetPushedTexture(tex)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    btn:GetNormalTexture():SetTexCoord(0.08,0.92,0.08,0.92)
    btn:GetPushedTexture():SetTexCoord(0.08,0.92,0.08,0.92)

    local border = btn:CreateTexture(nil, "BORDER")
    border:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    border:SetAllPoints(btn)

    -- position at stored angle
    local function place()
        local rad = math.rad(angle)
        local x = math.cos(rad) * dist
        local y = math.sin(rad) * dist
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", map, "CENTER", x, y)
    end

    -- drag-handling: recalc angle relative to minimap center
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self)
        self:StartMoving()
        self:SetScript("OnUpdate", function()
            local scale = map:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            cx, cy = cx/scale, cy/scale
            local mx, my = map:GetCenter()
            angle = math.deg(math.atan2(cy - my, cx - mx))
            place()
        end)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
        place()
        db.minimapAngle = angle
    end)

    btn:SetScript("OnClick", function()
        if hoshow then hoshow() end
    end)

    place()
    _G.HO_MinimapButton = btn
end
