local addonName, Internal = ...

Internal.L = setmetatable({}, {
    __index = function(tbl, key)
        return key
    end
})

local L = Internal.L

