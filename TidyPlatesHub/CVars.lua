local addonName, Internal = ...


local char = "Character"
local acc = "Account"
Internal.EnumCVarScopes = {
    char,
    acc,
}
local num = "number"
local bool = "boolean"
local enum = "enum"
Internal.EnumCVarTypes = {
    num,
    bool,
    enum,
}

local cvarlist = {
    ["nameplateShowFriends"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_FRIENDS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDS,
        type = bool,
        default = false,
        scope = char
    
    },
    ["nameplateShowFriendlyPets"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_FRIENDLY_PETS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDLY_PETS,
        type = bool,
        default = false,
        scope = char
    },
    ["nameplateShowFriendlyGuardians"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_FRIENDLY_GUARDIANS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDLY_GUARDIANS,
        type = bool,
        default = false,
        scope = char
    },
    ["nameplateShowFriendlyTotems"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_FRIENDLY_TOTEMS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDLY_TOTEMS,
        type = bool,
        default = false,
        scope = char
    },
    ["nameplateShowEnemies"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_ENEMIES,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMIES,
        type = bool,
        default = true,
        scope = char
    },
    ["nameplateShowEnemyPets"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_ENEMY_PETS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_PETS,
        type = bool,
        default = false,
        scope = char
    },
    ["nameplateShowEnemyGuardians"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_ENEMY_GUARDIANS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_GUARDIANS,
        type = bool,
        default = true,
        scope = char
    },
    ["nameplateShowEnemyTotems"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_ENEMY_TOTEMS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_TOTEMS,
        type = bool,
        default = true,
        scope = char
    },
    ["nameplateShowEnemyMinus"] = {
        prettyName = UNIT_NAMEPLATES_SHOW_ENEMY_MINUS,
        description = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS,
        type = bool,
        default = true,
        scope = char
    },
    ["ShowClassColorInNameplate"] = {
        prettyName = SHOW_CLASS_COLOR_IN_V_KEY,
        description = OPTION_TOOLTIP_SHOW_CLASS_COLOR_IN_V_KEY,
        type = bool,
        default = true,
        scope = char
    },


    ["nameplateOtherAtBase"] = {
        prettyName = "Nameplate at Base",
        description = "Position other nameplates at the base, rather than overhead. 2=under unit, 0=over unit",
        type = bool,
        default = 0,
        scope = acc
    },
    ["nameplateOverlapH"] = {
        prettyName = "Nameplate Overlap (Horizontal)",
        description = "Percentage amount for horizontal overlap of nameplates",
        type = num,
        default = 0.8,
        scope = acc
    },
    ["nameplateOverlapV"] = {
        prettyName = "Nameplate Overlap (Vertical)",
        description = "Percentage amount for vertical overlap of nameplates",
        type = num,
        default = 1.1,
        scope = acc
    },
    ["nameplateMaxDistance"] = {
        prettyName = "Nameplate Distance",
        description = "The max distance to show nameplates.",
        type = num,
        default = 60,
        scope = char
    },
    ["nameplateTargetBehindMaxDistance"] = {
        prettyName = "Nameplate Target Behind Distance",
        description = "The max distance to show the target nameplate when the target is behind the camera.",
        type = num,
        default = 15,
        scope = char
    },
    ["nameplateGlobalScale"] = {
        prettyName = "Nameplate Global Scale",
        description = "Applies global scaling to non-self nameplates, this is applied AFTER selected, min, and max scale.",
        type = num,
        default = 1,
        scope = char
    },
    ["nameplateMinScale"] = {
        prettyName = "Nameplate Min Scale",
        description = "The minimum scale of nameplates.",
        type = num,
        default = 0.8,
        scope = char
    },
    ["nameplateMaxScale"] = {
        prettyName = "Nameplate Max Scale",
        description = "The max scale of nameplates.",
        type = num,
        default = 1,
        scope = char
    },
    ["nameplateLargerScale"] = {
        prettyName = "Nameplate Larger Scale",
        description = "An additional scale modifier for important monsters.",
        type = num,
        default = 1.2,
        scope = char
    },
    ["nameplateMinScaleDistance"] = {
        prettyName = "Nameplate Min Scale Distance",
        description = "The distance from the max distance that nameplates will reach their minimum scale.",
        type = num,
        default = 10,
        scope = char
    },
    ["nameplateMaxScaleDistance"] = {
        prettyName = "Nameplate Max Scale Distance",
        description = "The distance from the camera that nameplates will reach their maximum scale",
        type = num,
        default = 10,
        scope = char
    },
    ["nameplateMinAlpha"] = {
        prettyName = "Nameplate Min Alpha",
        description = "The minimum alpha of nameplates.",
        type = num,
        default = 0.6,
        scope = char
    },
    ["nameplateMaxAlpha"] = {
        prettyName = "Nameplate Max Alpha",
        description = "The max alpha of nameplates.",
        type = num,
        default = 1,
        scope = char
    },
    ["nameplateMinAlphaDistance"] = {
        prettyName = "Nameplate Min Alpha Distance",
        description = "The distance from the max distance that nameplates will reach their minimum alpha.",
        type = num,
        default = 10,
        scope = char
    },
    ["nameplateMaxAlphaDistance"] = {
        prettyName = "Nameplate Max Alpha Distance",
        description = "The distance from the camera that nameplates will reach their maximum alpha.",
        type = num,
        default = 40,
        scope = char
    },
    ["nameplateSelectedScale"] = {
        prettyName = "Nameplate Selected Scale",
        description = "The scale of the selected nameplate.",
        type = num,
        default = 1.2,
        scope = char
    },
    ["nameplateSelectedAlpha"] = {
        prettyName = "Nameplate Selected Alpha",
        description = "The alpha of the selected nameplate.",
        type = num,
        default = 1,
        scope = char
    },
    ["nameplateSelfScale"] = {
        prettyName = "Nameplate Self Scale",
        description = "The scale of the self nameplate.",
        type = num,
        default = 1,
        scope = char
    },
    ["nameplateSelfAlpha"] = {
        prettyName = "Nameplate Self Alpha",
        description = "The alpha of the self nameplate.",
        type = num,
        default = 0.75,
        scope = char
    },
    ["nameplateSelfBottomInset"] = {
        prettyName = "Nameplate Self Bottom Inset",
        description = "The inset from the bottom (in screen percent) that the self nameplate is clamped to.",
        type = num,
        default = 0.2,
        scope = char
    },
    ["nameplateSelfTopInset"] = {
        prettyName = "Nameplate Self Top Inset",
        description = "The inset from the top (in screen percent) that the self nameplate is clamped to.",
        type = num,
        default = 0.5,
        scope = char
    },
    ["nameplateOtherBottomInset"] = {
        prettyName = "Nameplate Other Bottom Inset",
        description = "The inset from the bottom (in screen percent) that the non-self nameplates are clamped to.",
        type = num,
        default = 0.1,
        scope = char
    },
    ["nameplateOtherTopInset"] = {
        prettyName = "Nameplate Other Top Inset",
        description = "The inset from the top (in screen percent) that the non-self nameplates are clamped to.",
        type = num,
        default = 0.08,
        scope = char
    },
    ["nameplateLargeBottomInset"] = {
        prettyName = "Nameplate Large Bottom Inset",
        description = "The inset from the bottom (in screen percent) that large nameplates are clamped to.",
        type = num,
        default = 0.15,
        scope = char
    },
    ["nameplateLargeTopInset"] = {
        prettyName = "Nameplate Large Top Inset",
        description = "The inset from the top (in screen percent) that large nameplates are clamped to.",
        type = num,
        default = 0.1,
        scope = char
    },
    ["nameplateClassResourceTopInset"] = {
        prettyName = "Nameplate Class Resource Top Inset",
        description = "The inset from the top (in screen percent) that nameplates are clamped to when class resources are being displayed on them.",
        type = num,
        default = 0.03,
        scope = char
    },
    ["NamePlateHorizontalScale"] = {
        prettyName = "Nameplate Horizontal Scale",
        description = "Applied to horizontal size of all nameplates.",
        type = num,
        default = 1,
        scope = char
    },
    ["NamePlateVerticalScale"] = {
        prettyName = "Nameplate Vertical Scale",
        description = "Applied to vertical size of all nameplates.",
        type = num,
        default = 1,
        scope = char
    },
    ["nameplateResourceOnTarget"] = {
        prettyName = "Nameplate Resource On Target",
        description = "Nameplate class resource overlay mode. Disabled shows on player nameplate, enabled on target.",
        type = bool,
        default = false,
        scope = char
    },
    ["nameplateShowSelf"] = {
        prettyName = "Show Nameplate Resource Bar",
        description = "Display class resource bar.",
        type = bool,
        default = true,
        scope = char
    },
    ["nameplateShowAll"] = {
        prettyName = "Always Show Nameplates",
        description = "Show nameplates at all times.",
        type = bool,
        default = false,
        scope = char
    },
}

--[[
NamePlateClassificationScale
NamePlateMaximumClassificationScale
nameplateMotion
nameplateMotionSpeed
nameplateOccludedAlphaMult
NameplatePersonalClickThrough
NameplatePersonalHideDelayAlpha
NameplatePersonalHideDelaySeconds
NameplatePersonalShowAlways
NameplatePersonalShowInCombat
NameplatePersonalShowWithTarget
nameplateShowDebuffsOnFriendly
nameplateShowEnemyMinions
nameplateShowFriendlyMinions
nameplateShowFriendlyNPCs
nameplateShowOnlyNames
nameplateTargetRadialPosition
]]

