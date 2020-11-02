local addonName, Internal = ...

local PanelMixin = {}

function PanelMixin:CreatePanel(name, title, parentFrame)
    local newPanel = CreateFrame( "Frame", addonName..name, UIParent, "BackdropTemplate")

end