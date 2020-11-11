local addonName, Internal = ...

--* Helpers

--* Column
local ColumnMixin = {}

function ColumnMixin:SetColumnPosition(index, width)
    index = index or (self.index)
    width = width or ((self:GetParent():GetWidth()) / (#self:GetParent().columns))

    col:ClearAllPoints()
    col:SetPoint("TOPLEFT", 12 + (i-1) * width, 0)
    col:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 12 + i * width, 0)
end

function ColumnMixin:Init(index, width)
    self.index = index
    self.bottomElem = nil
    self:SetColumnPosition(index, width)
end

--* Element

local ElementMixin = {}

function ElementMixin:Init(event, margins, getter, setter)
    if getter then
        self.GetValue = getter
    end
    if setter then
        self.SetValue = setter
    end
    self:HookScript(event, self.SetOption)
    self.Margins = margins
end

function ElementMixin:SetOption()
    local varSet = self:GetParent():GetParent().varSet
    varSet[self.name] = self:GetValue()
end

--* Section
local SectionMixin = {}

function SectionMixin:Init(numColums)

    -- Add Columns
    self.columns = {}
    local colWidth = self.GetWidth() / numColums
    for i = 1, numColums, 1 do
        local col = CreateFrame("Frame", self.name.."Column"..i, self)
        self.columns[i] = col
        Mixin(col, ColumnMixin)
        col:Init(i, colWidth)
    end
    self:HookScript("OnSizeChanged", self.OnSizeChanged)

end

function SectionMixin:OnSizeChanged(width)
    local colWidth = width / #self.columns
    for i, col in ipairs(self.columns) do
        col:SetColumnPosition(i, colWidth)
    end
end

function SectionMixin:AddElement(element, columnIndex, indent, xOffset, yOffset)
    local col = self.columns[columnIndex]
    element:ClearAllPoints()
    element:SetPoint(
        "LEFT",
        col,
        "LEFT",
        element.Margins.Left + (indent * 16) + (xOffset or 0),
        0
    )
    if col.bottomElem then
        element:SetPoint(
            "TOP",
            col.bottomElem,
            "BOTTOM",
            -(col.bottomElem:GetWidth() / 2),
            -(element.Margins.Top + (yOffset or 0))
        )
    else
        element:SetPoint(
            "TOP",
            col,
            "TOP",
            0,
            -(element.Margins.Top + (yOffset or 0))
        )
    end
end

function SectionMixin:AddCheckButton(name, label, columnIndex, indent, xOffset, yOffset)
    local frame = CreateFrame("CheckButton", name, self, "InterfaceOptionsCheckButtonTemplate")
    frame.Label = _G[name.."Text"]
    frame.Label:SetText(label)

    Mixin(frame, ElementMixin)
    frame:Init("OnClick", {Left = 2, Right = 100, Top = 0, Bottom = 0}, frame.GetChecked, frame.SetChecked)

    self:AddElement(frame, columnIndex, indent, xOffset, yOffset)

    return frame
end

function SectionMixin:AddSlider(name, label, columnIndex, indent, xOffset, yOffset,
                                val, minVal, maxVal, step, mode)
    local frame = CreateFrame("Slider", name, self, "OptionsSliderTemplate")
    frame:SetWidth(250)
    frame:SetHeight(15)
    frame:SetMinMaxValues(minVal or 0, maxVal or 1)
    frame:SetValueStep(step or .1)
    frame:SetValue(val or .5)
    frame:SetOrientation("HORIZONTAL")
    frame:Enable()

    frame.Label = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    frame.Label:SetPoint("TOPLEFT", -5, 18)
    frame.Label:SetText(label or "")
    frame.Low = _G[name.."Low"]
    frame.High = _G[name.."High"]

    frame.Value = frame:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
    frame.Value:SetPoint("BOTTOM", 0, -10)
    frame.Value:SetWidth(50)

    if mode == "ACTUAL" then
        frame.Value:SetText(tostring(ceil(val)))
        frame:SetScript("OnValueChanged", function()
            local v = tostring(ceil(frame:GetValue()))
            frame.Value:SetText(v)
        end)
        frame.Low:SetText(ceil(minval or 0))
        frame.High:SetText(ceil(maxval or 1))
    else
        frame.Value:SetText(tostring(ceil(100 * (val or .5))))
        frame:SetScript("OnValueChanged", function()
            frame.Value:SetText(tostring(ceil(100 * frame:GetValue())).."%")
        end)
        frame.Low:SetText(ceil((minval or 0) * 100).."%")
        frame.High:SetText(ceil((maxval or 1) * 100).."%")
    end

    Mixin(frame, ElementMixin)
    frame:Init("OnMouseUp", {Left = 12, Right = 8, Top = 20, Bottom = 13})

    self:AddElement(frame, columnIndex, indent, xOffset, yOffset)

    function frame:SetSliderMechanics(value, minimum, maximum, increment)
        self:SetMinMaxValues(minimum, maximum)
        self:SetValueStep(increment)
        self:SetValue(value)
    end
    
    return frame
end

function SectionMixin:AddPercentSlider(name, label, columnIndex, indent, xOffset, yOffset)
    return self:AddSlider(name, label, columnIndex, indent, xOffset, yOffset,
                          0.5, 0, 1, 0.1)
end

function SectionMixin:AddEditBox(name, label, columnIndex, indent, xOffset, yOffset)
    local frame = CreateFrame("ScrollFrame", name, columnFrame, "UIPanelScrollFrameTemplate")
    frame.BorderFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    local EditBox = CreateFrame("EditBox", nil, frame)

    frame:SetWidth(165)
    frame:SetHeight(125)

    frame.BorderFrame:SetPoint("TOPLEFT", 0, 5)
    frame.BorderFrame:SetPoint("BOTTOMRIGHT", 3, -5)
    frame.BorderFrame:SetBackdrop{
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    frame.BorderFrame:SetBackdropColor(0.05, 0.05, 0.05, 0)
    frame.BorderFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    EditBox:SetPoint("TOPLEFT")
    EditBox:SetPoint("BOTTOMLEFT")
    EditBox:SetHeight(100)
    EditBox:SetWidth(150)
    EditBox:SetMultiLine(true)
    EditBox:SetFrameLevel(frame:GetFrameLevel()-1)
    EditBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "NONE")
    EditBox:SetText("")
    EditBox:SetAutoFocus(false)
    EditBox:SetTextInsets(9, 6, 2, 2)

    frame:SetScrollChild(EditBox)
    frame.EditBox = EditBox
    frame._SetWidth = frame.SetWidth
    function frame:SetWidth(value)
        frame:_SetWidth(value)
        EditBox:SetWidth(value)
    end

    Mixin(frame, ElementMixin)
    frame:Init("", {Left = 4, Right = 24, Top = 8, Bottom = 8}, EditBox.GetText, EditBox.SetText)

    self:AddElement(frame, columnIndex, indent, xOffset, yOffset)

    return frame
end

function SectionMixin:AddColorBox(name, label, columnIndex, indent, xOffset, yOffset)
    local frame = CreateFrame("Button", reference, parent, "BackdropTemplate")
    frame:SetWidth(24)
    frame:SetHeight(24)
    frame:SetBackdrop{
        bgFile = "Interface\\ChatFrame\\ChatFrameColorSwatch",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false, tileSize = 16, edgeSize = 8,
        insets = {left = 1, right = 1, top = 1, bottom = 1},
    }
    frame:SetBackdropColor(r, g, b, a);
    frame:SetScript("OnClick", ShowColorPicker)

    frame.Label = frame:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
    frame.Label:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -7)
    frame.Label:SetText(label)

    frame.GetValue = function() local color = {}; color.r, color.g, color.b, color.a = colorbox:GetBackdropColor(); return color end
    frame.SetValue = function(self, color) colorbox:SetBackdropColor(color.r, color.g, color.b, color.a); end



    Mixin(frame, ElementMixin)
    frame:Init()
end

--* Panel
local PanelMixin = {}

function PanelMixin:Section(name, title)
    
end

function Internal.CreatePanel(objectName, title, parentFrameName)
    local panel = CreateFrame( "Frame", addonName..objectName.."InterfaceOptionPanel", UIParent, "BackdropTemplate")
    panel:SetBackdrop{
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    }
    panel:SetBackdropColor(.1, .1, .1, .6)
    panel:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

    panel.name = title
    panel.objectName = objectName
    if parentFrameName then
        panel.parent = parentFrameName
    end

    --* Panel Header
    panel.MainLabel = CreateQuickHeadingLabel(nil, panelTitle, panel, nil, 16, 8)

    --* Warnings
    panel.WarningFrame = CreateFrame("Frame", objectName.."WarningFrame", panel , "BackdropTemplate")
    panel.WarningFrame:SetPoint("LEFT", 16, 0)
    panel.WarningFrame:SetPoint("TOP", panel.MainLabel, "BOTTOM", 0, -8)
    panel.WarningFrame:SetPoint("RIGHT", -16 , 16)
    panel.WarningFrame:SetHeight(50)
    panel.WarningFrame:SetBackdrop{
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
    panel.WarningFrame:SetBackdropColor(.9, 0.3, 0.2, 1)
    panel.WarningFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    panel.WarningFrame:Hide()
    -- Description
    panel.Warnings = CreateQuickHeadingLabel(nil, "", panel.WarningFrame, nil, 8, -4)
    -- Button
    local WarningFixButton = CreateFrame("Button", objectName.."WarningFixButton", panel.WarningFrame, "TidyPlatesPanelButtonTemplate", "BackdropTemplate")
    WarningFixButton:SetPoint("RIGHT", -10, 0)
    WarningFixButton:SetWidth(150)
        WarningFixButton:SetText("Fix Problem...")
end