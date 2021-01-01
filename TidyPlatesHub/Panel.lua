local addonName, Internal = ...


--! Stuff that probably shouldn't be locals
local font = "Interface\\Addons\\TidyPlates\\Media\\DefaultFont.ttf"
local divider = "Interface\\Addons\\TidyPlatesHub\\shared\\ThinBlackLine"

--* Helpers
local debugMsg = Internal.Helpers.debugMsg

local L = Internal.L

local Position = {
    colIndex,
    indent,
    xOffset,
    yOffset,
    alignWith
}
local posDefaults = {
    colIndex = 1,
    indent = 0,
    xOffset = 0,
    yOffset = 0,
    alignWith = nil
}
local function unpackPos(pos)
    local ret = {}
    for i, key in ipairs(Position) do
        if pos[i] and pos[key] then
            debugMsg("overspecified position", "", "unpackPos", pos[i], pos[key], key)
        end
        if pos[key] then
            ret[i] = pos[key]
        elseif pos[i] then
            ret[i] = pos[i]
        else
            ret[i] = posDefaults[key]
        end
    end

    return unpack(ret, 1, #Position)
end

local function colorify(r, g, b, a)
    if type (r) == "table" then
        return r.g, r.b, r.b, r.a
    else
        return {
            r = r,
            g = g,
            b = b,
            a = a
        }
    end
end

local function colorPickerCallback(frame)
    local function f(cancel)
        if cancel then
            frame:SetBackdropColor(unpack(cancel))
        else
            local a = OpacitySliderFrame:GetValue()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            frame:SetBackdropColor(r, g, b, 1 - a)
            frame:OnValueChanged()
        end
    end
    return f
end

local function ShowColorPicker(frame)
    local r, g, b, a = frame:GetBackdropColor()
    local f = colorPickerCallback(frame)
    ColorPickerFrame.func = f
    ColorPickerFrame.opacityFunc = f
    ColorPickerFrame.cancelFunc = f

    ColorPickerFrame.previousValues = {r,g,b,a}
    ColorPickerFrame:SetColorRGB(r,g,b);
    ColorPickerFrame.hasOpacity = true
    ColorPickerFrame.opacity = 1 - a

    ColorPickerFrame:SetFrameStrata(frame:GetFrameStrata())
    ColorPickerFrame:SetFrameLevel(frame:GetFrameLevel()+1)
    ColorPickerFrame:Hide() -- Need to activate the OnShow handler
    ColorPickerFrame:Show()
end

local function SetSliderMechanics(self, value, minimum, maximum, increment)
    self:SetMinMaxValues(minimum, maximum)
    self:SetValueStep(increment)
    self:SetValue(value)
end

--* Dropdown
local ShowDropdownMenu, HideDropdownMenu
do
    local DropDownMenuFrame = CreateFrame("Frame", nil, nil)
    local MaxDropdownItems = 25

    DropDownMenuFrame:SetSize(100, 100)
    DropDownMenuFrame:SetFrameStrata("TOOLTIP");
    DropDownMenuFrame:Hide()

    local Border = CreateFrame("Frame", nil, DropDownMenuFrame, "BackdropTemplate")
    Border:SetBackdrop{
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
    Border:SetBackdropColor(0,0,0,1)
    Border:SetPoint("TOPLEFT", DropDownMenuFrame, "TOPLEFT")

    for i = 1, MaxDropdownItems do
        local button = CreateFrame("Button", addonName.."DropdownMenuButton"..i, DropDownMenuFrame)
        DropDownMenuFrame["Button"..i] = button

        button:SetHeight(15)
        button:SetPoint("RIGHT", DropDownMenuFrame, "RIGHT")
        button:SetText("Button")

        button.index = i

        if i > 1 then
            button:SetPoint("TOPLEFT", DropDownMenuFrame["Button"..i-1], "BOTTOMLEFT")
        else
            button:SetPoint("TOPLEFT", DropDownMenuFrame, "TOPLEFT", 10, -8)
        end

        local region = select(1, button:GetRegions())
        region:SetJustifyH("LEFT")
        region:SetPoint("LEFT", button, "LEFT")
        region:SetPoint("RIGHT", button, "RIGHT")

        button:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight")
        button:SetNormalFontObject("GameFontHighlightSmallLeft")
        button:SetHighlightFontObject("GameFontNormalSmallLeft")
        button:Show()
    end

    function HideDropdownMenu()
        DropDownMenuFrame:Hide()
    end

    function ShowDropdownMenu(sourceFrame, menu, clickScript)
        if DropDownMenuFrame:IsShown() and DropDownMenuFrame.sourceFrame == sourceFrame then
            HideDropdownMenu()
            return
        end

        DropDownMenuFrame.sourceFrame = sourceFrame
        local currentSelection = sourceFrame:GetValue()
        local numOfItems = 0
        local maxWidth = 0

        for i = 1, MaxDropdownItems do
            local item = menu[i]
            local button = DropDownMenuFrame["Button"..i]

            if item then
                local itemText = item.text
                local region1 = button:GetRegions()

                maxWidth = max(maxWidth, button:GetTextWidth())
                numOfItems = numOfItems + 1

                if currentSelection == i or itemText == currentSelection then
                    region1:SetTextColor(1, .8, 0)
                    region1:SetFont(1, .8, 0)
                else
                    region1:SetTextColor(1, 1, 1)
                end
                

                button:SetText(itemText)
                button.Value = item.value
                button.sourceFrame = sourceFrame
                button:SetScript("OnClick", clickScript)
                button:Show()
            else
                button:Hide()
            end

        end

        DropDownMenuFrame:SetWidth(maxWidth + 20)
        Border:SetPoint("BOTTOMRIGHT", DropDownMenuFrame["Button"..numOfItems], "BOTTOMRIGHT", 10, -12)
        DropDownMenuFrame:SetPoint("TOPLEFT", sourceFrame, "BOTTOM")
        DropDownMenuFrame:Show()
        DropDownMenuFrame:Raise()

        -- Make sure the menu stays visible when displayed
        local LowerBound = Border:GetBottom() or 0
        if 0 > LowerBound then
            DropDownMenuFrame:SetPoint("TOPLEFT", sourceFrame, "BOTTOM", 0, LowerBound * -1)
        end
    end
end

DropdownMixin = {}

function DropdownMixin:OnClick()
    local sourceFrame = self:GetParent()
    PlaySound(856)
    ShowDropdownMenu(sourceFrame, sourceFrame.menu, self.OnClickItem)
end

function DropdownMixin:OnHide()
    HideDropdownMenu()
end

function DropdownMixin:OnClickItem()
    local sourceFrame = self.sourceFrame
    sourceFrame:SetValue(sourceFrame.menu[self.index] or self.index)
    sourceFrame:OnValueChanged()
    PlaySound(856)
    HideDropdownMenu()
end

function DropdownMixin:SetValue(value)
    local itemText
    local menu = self.menu

    if menu[value] then
        itemText = menu[value].text
    else
        for i, v in pairs(menu) do
            if v.value == value then
                itemText = v.text
                break
            end
        end
    end

    self.Text:SetText(itemText)
    self.value = value
end

function DropdownMixin:GetValue()
    return self.value
end

--* Element
local ElementMixin = {
    name = "",
    colIndex = 0,
    index = 0,
    Margins = {},
    Label = {},
}

function ElementMixin:SetValue(val)
    debugMsg("this should be overwritten", self.name, "SetValue")
end

function ElementMixin:GetValue()
    debugMsg("this should be overwritten", self.name, "GetValue")
end

function ElementMixin:SetVar()
    -- this should probably be something different
    local varSet = self:GetParent():GetParent().varSet
    varSet[self.name] = self:GetValue()
end

function ElementMixin:GetVar()
    -- this should probably be something different
    local varSet = self:GetParent():GetParent().varSet
    return varSet[self.name]
end

--* Column
local ColumnMixin = {
    index = 0,
    elements = {},
}

function ColumnMixin:SetColumnPosition(index, width)
    index = index or (self.index)
    width = width or ((self:GetParent():GetWidth()) / (#self:GetParent().columns))

    col:ClearAllPoints()
    col:SetPoint("TOPLEFT", 12 + (i-1) * width, 0)
    col:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 12 + i * width, 0)
end

function ColumnMixin:Init(index, width)
    self.index = index
    self.elements = {}
    self:SetColumnPosition(index, width)
end

--* Section
local SectionMixin = {
    name = "",
    panel = {},
    index = 0,
    columns = {},
    elements = {},
}

function SectionMixin:OnSizeChanged(width)
    local colWidth = width / #self.columns
    for i, col in ipairs(self.columns) do
        col:SetColumnPosition(i, colWidth)
    end
    self:AdjustSize()
end

function SectionMixin:AdjustSize()
    local minDist
    for i, col in ipairs(self.columns) do
        if #col.elements > 0 then
            local bottomElem = col.elements[#col.elements]
            minDist = min(minDist, bottomElem:GetBottom() - bottomElem.Margins.Bottom)
        end
    end
    self:SetHeight(minDist and (self:GetBottom() - minDist) or 1)
end

-- positions element within section
function SectionMixin:InsertElement(element, pos)
    local colIndex, indent, xOffset, yOffset, alignWith = unpackPos(pos)

    local col = self.columns[colIndex]
    self.elements[element.name] = element
    table.insert(col.elements, element)
    element.index = #col.elements
    element.colIndex = colIndex

    element:ClearAllPoints()
    element:SetPoint(
        "LEFT",
        col,
        "LEFT",
        element.Margins.Left + (indent * 16) + xOffset,
        0
    )

    if alignWith then
        element:SetPoint(
            "TOP",
            alignWith,
            "TOP",
            0,
            -(element.Margins.Top + yOffset)
        )
    elseif element.index == 1 then
        element:SetPoint(
            "TOP",
            col,
            "TOP",
            0,
            -(element.Margins.Top + yOffset)
        )
    else
        element:SetPoint(
            "TOP",
            col.elements[element.index - 1],
            "BOTTOM",
            0,
            -(element.Margins.Top + yOffset)
        )
    end

    self:AdjustSize()
end

-- functions that create various types of option selectors
function SectionMixin:AddCheckButton(name, pos)
    local frame = CreateFrame("CheckButton", addonName..name.."Frame", self, "InterfaceOptionsCheckButtonTemplate")
    Mixin(frame, ElementMixin)
    frame.name = name
    frame.Label = _G[addonName..name.."FrameText"]
    frame.Label:SetText(L[name])

    frame.Margins = {Left = 2, Right = 100, Top = 0, Bottom = 0}
    frame:HookScript("OnClick", self.SetVar)
    frame.GetValue = frame.GetChecked
    frame.SetValue = frame.SetChecked

    self:InsertElement(frame, pos)

    return frame
end

function SectionMixin:AddSlider(name, pos, val, minVal, maxVal, step, mode)
    local frame = CreateFrame("Slider", addonName..name.."Frame", self, "OptionsSliderTemplate")
    Mixin(frame, ElementMixin)
    frame.name = name
    frame.Margins = {Left = 12, Right = 8, Top = 20, Bottom = 13}
    frame.SetSliderMechanics = SetSliderMechanics
    frame:SetSize(250, 15)
    frame:SetMinMaxValues(minVal or 0, maxVal or 1)
    frame:SetValueStep(step or .1)
    frame:SetValue(val or .5)
    frame:SetOrientation("HORIZONTAL")
    frame:Enable()
    frame:HookScript("OnMouseUp", self.SetVar)

    frame.Label = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    frame.Label:SetPoint("TOPLEFT", -5, 18)
    frame.Label:SetText(L[name] or "")
    frame.Low = _G[addonName..name.."FrameLow"]
    frame.High = _G[addonName..name.."FrameHigh"]

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

    self:InsertElement(frame, pos)

    return frame
end

function SectionMixin:AddPercentSlider(name, pos)
    return self:AddSlider(name, pos, 0.5, 0, 1, 0.1)
end

function SectionMixin:AddEditBox(name, pos)
    local frame = CreateFrame("ScrollFrame", addonName..name.."Frame", columnFrame, "UIPanelScrollFrameTemplate")
    Mixin(frame, ElementMixin)
    frame:SetSize(165, 125)
    frame.name = name
    frame.Margins = {Left = 4, Right = 24, Top = 8, Bottom = 8}
    frame.GetValue = EditBox.GetText
    frame.SetValue = EditBox.SetText
    
    frame.BorderFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.BorderFrame:SetPoint("TOPLEFT", 0, 5)
    frame.BorderFrame:SetPoint("BOTTOMRIGHT", 3, -5)
    frame.BorderFrame:SetBackdrop{
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
    frame.BorderFrame:SetBackdropColor(0.05, 0.05, 0.05, 0)
    frame.BorderFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    local EditBox = CreateFrame("EditBox", nil, frame)
    frame.EditBox = EditBox
    EditBox:SetPoint("TOPLEFT")
    EditBox:SetPoint("BOTTOMLEFT")
    EditBox:SetSize(150, 100)
    EditBox:SetMultiLine(true)
    EditBox:SetFrameLevel(frame:GetFrameLevel()-1)
    EditBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "NONE")
    EditBox:SetText("")
    EditBox:SetAutoFocus(false)
    EditBox:SetTextInsets(9, 6, 2, 2)
    EditBox:HookScript("OnEnterPressed", self.SetVar)
    EditBox:HookScript("OnEditFocusLost", self.SetVar)

    frame.Label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.Label:SetSize(165, 15)
    frame.Label:ClearAllPoints()
    frame.Label:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
    frame.Label:SetText(L[name])
    frame.Label:SetJustifyH("LEFT")
    frame.Label:SetJustifyV("BOTTOM")

    frame:SetScrollChild(EditBox)
    frame._SetWidth = frame.SetWidth
    function frame:SetWidth(value)
        frame:_SetWidth(value)
        EditBox:SetWidth(value)
    end

    self:InsertElement(frame, pos)

    return frame
end

function SectionMixin:AddColorBox(name, pos)
    local frame = CreateFrame("Button", reference, parent, "BackdropTemplate")
    Mixin(frame, ElementMixin)
    frame.name = name
    frame:SetSize(24, 24)
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
    frame.Label:SetText(L[name])

    frame.Margins = {Left = 5, Right = 100, Top = 3, Bottom = 2}
    function frame:GetValue()
        return colorify(self:GetBackdropColor())
    end
    function frame:SetValue(color)
        self:SetBackdropColor(colorify(color))
    end
    frame.OnValueChanged = self.SetVar

    self:InsertElement(frame, pos)

    return frame
end

-- menu :: [{text :: String, value :: String}]
-- default :: Index | value
function SectionMixin:AddDropdown(name, pos, menu, default)
    local frame = CreateFrame("Frame", addonName..name.."Frame", self, "TidyPlatesDropdownDrawerTemplate")
    Mixin(frame, ElementMixin)
    frame.Text = _G[addonName..name.."FrameText"]
    frame.Button = _G[addonName..name.."FrameButton"]
    frame:SetWidth(120)

    frame.Label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.Label:SetPoint("TOPLEFT", 18, 18)
    frame.Label:SetText(L[name])

    frame.Text:SetWidth(100)
    fame.value = default
    frame.menu = menu
    frame.name = name
    frame.Margins = {Left = -12, Right = 2, Top = 22, Bottom = 0}
    frame.OnValueChanged = self.SetVar

    Mixin(frame, DropdownMixin)

    frame.Button:SetScript("OnClick", frame.OnClick)
    frame.Button:SetScript("OnHide", frame.OnHide)
    frame:SetValue(default)

    self:InsertElement(frame, pos)

    return frame
end

-- functions that create standalone labels
function SectionMixin:AddHeadline(name, pos)
    local frame = CreateFrame("Frame", addonName..name.."Frame", self)
    Mixin(frame, ElementMixin)
    frame:SetSize(500, 26)
    frame.Margins = {Left = 6, Right = 2, Top = 12, Bottom = 2}

    function frame:GetValue() end
    function frame:SetValue(val) end

    frame.Text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.Text:SetFont(font, 26)
    frame.Text:SetTextColor(255/255, 105/255, 6/255)
    frame.Text:SetAllPoints()
    frame.Text:SetText(L[name])
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetJustifyV("BOTTOM")

    self:InsertElement(frame, pos)

    return frame
end

function SectionMixin:AddHeading(name, pos)
    local frame = self:AddHeadline(name, pos)

    frame.DividerLine = frame:CreateTexture(nil, 'ARTWORK')
    frame.DividerLine:SetTexture(divider)
    frame.DividerLine:SetSize(500, 12)
    frame.DividerLine:SetPoint("BOTTOMLEFT", frame.Text, "TOPLEFT", 0, 5)

    local bookmark = CreateFrame("Frame", nil, self)
    bookmark:SetPoint("TOPLEFT", self, "TOPLEFT")
    bookmark:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    table.insert(self:GetParent().headings, {label = L[name], bookmark = bookmark})

    return frame
end

function SectionMixin:AddLabel(name, pos)
    local frame = CreateFrame("Frame", addonName..name.."Frame", self)
    Mixin(frame, ElementMixin)
    frame:SetSize(500, 15)
    frame.Margins = {Left = 6, Right = 2, Top = 2, Bottom = 2}

    function frame:GetValue() end
    function frame:SetValue(val) end

    frame.Text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.Text:SetAllPoints()
    frame.Text:SetText(L[name])
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetJustifyV("BOTTOM")

    self:InsertElement(frame, pos)

    return frame
end

--* Panel
local PanelMixin = {
    name = "",
    sections = {},
    headings = {},
}

function PanelMixin:AddSection(name, numColumns, isHeader, headingXOffset, headingYOffset)
    local frame = CreateFrame("Frame", addonName..name.."Frame", self)
    Mixin(frame, SectionMixin)
    frame.name = name
    frame.panel = self
    frame.columns = {}
    frame.elements = {}
    frame:SetHeight(1)

    if isHeader then
        frame:SetPoint("TOPLEFT", self, "TOPLEFT")
        frame:SetPoint("TOPRIGHT", self, "TOPRIGHT")
        frame.index = 0
    else
        if #self.sections == 0 then
            frame:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT")
            frame:SetPoint("TOPRIGHT", self.scrollFrame, "TOPRIGHT")
        else
            local prevSection = self.sections[#self.sections]
            frame:SetPoint("TOPLEFT", prevSection, "BOTTOMLEFT")
            frame:SetPoint("TOPRIGHT", prevSection, "BOTTOMRIGHT")
        end
        table.insert(self.sections, frame)
        frame.inex = #self.sections
    end

    frame.columns = {}
    local colWidth = frame:GetWidth() / numColumns
    for i = 1, numColumns, 1 do
        local col = CreateFrame("Frame", addonName..name.."FrameColumn"..i, frame)
        frame.columns[i] = col
        Mixin(col, ColumnMixin)
        col:Init(i, colWidth)
    end
    frame:HookScript("OnSizeChanged", frame.OnSizeChanged)

    frame:AddHeading(name.."Heading", nil, nil, headingXOffset, headingYOffset)

    return frame
end

function Internal.CreatePanel(name, parentFrameName)
    local panel = CreateFrame("Frame", addonName..name.."InterfaceOptionPanel", UIParent, "BackdropTemplate")
    Mixin(panel, PanelMixin)
    panel:SetBackdrop{
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    }
    panel:SetBackdropColor(.1, .1, .1, .6)
    panel:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    panel.name = name
    panel.headings = {}
    panel.sections = {}

    panel.TitleSection = panel:AddSection(name.."TitleSection", 5, true, 16, 8)

    --* Warnings
    panel.WarningFrame = CreateFrame("Frame", addonName..name.."WarningFrame", panel, "BackdropTemplate")
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