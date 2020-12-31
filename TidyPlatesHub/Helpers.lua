local addonName, Internal = ...
Internal.Helpers = {}
local Helpers = Internal.Helpers

----------------------------------
-- Helpers
----------------------------------

local debugMsgFormat = "%sTidyPlates|r: Debug message %q from %q in function %q%s"
local debugArgFormat = "%d: %s"
function Helpers.debugMsg(msg, object, func, ...)
    if not TidyPlates.debug then
        return
    end

    local args = nil
    if select("#", ...) > 0 then
        args = debugArgFormat:format(1, (...))
        for i = 2, select("#", ...) do
            args = args..", "..debugArgFormat:format(i, (select(i, ...)))
        end
    end

    print(debugMsgFormat:format(
            RED_FONT_COLOR_CODE,
            msg,
            object,
            func,
            args and " with args "..args or ""))
end

function Helpers.CallForStyleUpdate()

    -- This happens when the Okay button is pressed, or a UI element is used

    --print("CallForStyleUpdate")

    local theme = TidyPlates:GetTheme()
    --print("CallForStyleUpdate, Theme,", theme)

    if theme.ApplyProfileSettings
        then theme:ApplyProfileSettings("From CallForStyleUpdate")
    end

end

function Helpers.GetPanelValues(panel, targetTable)
    -- First, clean up the target table
    -- Not yet implemented

    -- Update with values
    if panel and targetTable then
        for index in pairs(targetTable) do
            if panel[index] then
                targetTable[index] = panel[index]:GetValue()
            end
        end
    end
end

function Helpers.SetPanelValues(panel, sourceTable)
    for index, value in pairs(sourceTable) do
        if panel[index] then
            panel[index]:SetValue(value)
        end
    end
end


function Helpers.MergeProfileValues(target, defaults)
    local i, v
    for i, v in pairs(defaults) do
        if target[i] == nil then
            target[i] = v
        end
    end
end

function Helpers.ListToTable(...)
    local t = {}
    local i = 1
    for index = 1, select("#", ...) do
        local line = select(index, ...)
        if line ~= "" then
            t[i] = line
            i = i + 1
        end
    end
    return t
end

function Helpers.ConvertStringToTable(source, target)
    local temp = ListToTable(strsplit("\n", source))
    target = wipe(target)

    for index = 1, #temp do
        local line = temp[index]
        if line and not line:find("^#") then
            if tonumber(line) then
                target[tonumber(line)] = true
            else
                target[line] = true
            end
        end
    end
end

function Helpers.ConvertDebuffListTable(source, target, order)
    local temp = ListToTable(strsplit("\n", source))
    target = wipe(target)
    if order then order = wipe(order) end

    for index = 1, #temp do
        local str = temp[index]
        local item
        local prefix, suffix

        if str then
            prefix, suffix = select(3, string.find( str, "(%w+)[%s%p]*(.*)"))

            if prefix then
                if TidyPlatesHubPrefixList[prefix] then
                    item = suffix
                    -- CONVERT
                    target[item] = TidyPlatesHubPrefixList[prefix]
                else -- If no prefix is listed, assume 1
                    if suffix and suffix ~= "" then item = prefix.." "..suffix
                    else item = prefix end
                    -- CONVERT
                    target[item] = 1
                end
                if order then order[item] = index end
            end
        end
    end

end

function Helpers.AddHubFunction(functionTable, menuTable, functionPointer, functionDescription, functionKey )
    if functionTable then
        functionTable[functionKey or (#functionTable+1)] = functionPointer
    end

    if menuTable then
        menuTable[#menuTable+1] = { text = functionDescription, value = functionKey }
    end
end