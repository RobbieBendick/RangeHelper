local RangeHelper = LibStub("AceAddon-3.0"):GetAddon("RangeHelper");
local LibDBIcon = LibStub("LibDBIcon-1.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local RHConfig;
local _, playerClass = UnitClass("player");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local defaults = {
    profile = {
        selectedAbility = RangeHelper.classAbilities[playerClass] or "Thunderstorm",
        showInArena = true,
        showInWorld = false,
        showInBG = false,
        hideIconOnCD = true,
        -- showInDungeon = false,
        -- showInRaid = false,
        icon = {
            ["coordinates"] = {
                x = 0,
                y = 25,
            },
            ["size"] = 40,
            ["opacity"] = 1,
        },
    }
};

function RangeHelper:CreateMenu()
    RHConfig = CreateFrame("Frame", "RangeHelperConfig", UIParent);

    RHConfig.name = "RangeHelper";
 
    local abilities = {};
    for abilityName, data in pairs(RangeHelper.abilities) do
        abilities[abilityName] = ("%s (%dyd)"):format(abilityName, data.range);
    end

    local version = GetAddOnMetadata("RangeHelper", "Version") or "Unknown";
    local author = GetAddOnMetadata("RangeHelper", "Author") or "Unknown";

    local options = {
        name = RHConfig.name,
        type = "group",
        args = {
            info = {
                order = 1,
                type = "description",
                name = "|cffffd700Version|r " .. version .. "\n|cffffd700 Author|r " .. author,
            },
            abilitySettings = {
                order = 2,
                type = "group",
                name = "Ability Settings",
                inline = true,
                args = {
                    chooseAbility = {
                        order = 1,
                        type = "select",
                        name = "Choose Ability",
                        desc = "Select an ability.",
                        values = abilities,
                        set = function(info, value)
                            RangeHelper.db.profile.selectedAbility = value;
                        end,
                        get = function(info)
                            return RangeHelper.db.profile.selectedAbility;
                        end,
                    },
                    spacer = {
                        order = 2,
                        type = "description",
                        name = " ",
                        width = 0.05,
                    },
                    hideIconOnCD = {
                        order = 3,
                        type = "toggle",
                        name = "Hide Icon While On CD",
                        desc = "Hide the icon when the selected ability is on cooldown.",
                        set = function(info, value)
                            RangeHelper.db.profile.hideIconOnCD = value;
                        end,
                        get = function(info)
                            return RangeHelper.db.profile.hideIconOnCD;
                        end,
                    },
                    spacer = {
                        order = 3,
                        type = "description",
                        name = " ",
                        width = 0.05,
                    },
                    showInCategory = {
                        order = 4,
                        type = "group",
                        name = "Visibility Options",
                        inline = true,
                        args = {
                            showInArena = {
                                order = 1,
                                width = 0.67,
                                type = "toggle",
                                name = "Show In Arena",
                                desc = "Show in arena.",
                                set = function(info, value)
                                    RangeHelper.playersWithinRange = {};
                                    RangeHelper.db.profile.showInArena = value;
                                end,
                                get = function(info)
                                    return RangeHelper.db.profile.showInArena;
                                end,
                            },
                            showInBG = {
                                order = 2,
                                width = 0.57,
                                type = "toggle",
                                name = "Show In BG",
                                desc = "Show in BG.",
                                set = function(info, value)
                                    RangeHelper.playersWithinRange = {};
                                    RangeHelper.db.profile.showInBG = value;
                                end,
                                get = function(info)
                                    return RangeHelper.db.profile.showInBG;
                                end,
                            },
                            showInWorld = {
                                order = 3,
                                width = 0.67,
                                type = "toggle",
                                name = "Show In World",
                                desc = "Show in world.",
                                set = function(info, value)
                                    RangeHelper.playersWithinRange = {};
                                    RangeHelper.db.profile.showInWorld = value;
                                end,
                                get = function(info)
                                    return RangeHelper.db.profile.showInWorld;
                                end,
                            },
                        }
                    }
                },
            },
            icon = {
                order = 3,
                type = "group",
                name = "Icon Customization",
                inline = true,
                args = {
                    size = {
                        order = 1,
                        type = "range",
                        name = "Icon Size",
                        desc = "Set the size of the icon.",
                        min = 0,
                        max = 80,
                        step = 1,
                        set = function(info, value)
                            RangeHelper.db.profile.icon.size = value;
                        end,
                        get = function(info)
                            return RangeHelper.db.profile.icon.size;
                        end,
                    },
                    opacity = {
                        order = 2,
                        type = "range",
                        name = "Icon Opacity",
                        desc = "Set the opacity of the icon.",
                        min = 0,
                        max = 1,
                        step = 0.1,
                        set = function(info, value)
                            RangeHelper.db.profile.icon.opacity = value;
                        end,
                        get = function(info)
                            return RangeHelper.db.profile.icon.opacity;
                        end,
                    },
                    coordinates = {
                        type = "group",
                        name = "Coordinates",
                        args = {
                            x = {
                                order = 1,
                                type = "range",
                                name = "X Coordinate",
                                desc = "Set the X coordinate of the icon.",
                                min = -150,
                                max = 150,
                                step = 1,
                                set = function(info, value)
                                    RangeHelper.db.profile.icon.coordinates.x = value;
                                end,
                                get = function(info)
                                    return RangeHelper.db.profile.icon.coordinates.x;
                                end,
                            },
                            y = {
                                order = 2,
                                type = "range",
                                name = "Y Coordinate",
                                desc = "Set the Y coordinate of the icon.",
                                min = -150,
                                max = 150,
                                step = 1,
                                set = function(info, value)
                                    RangeHelper.db.profile.icon.coordinates.y = value;
                                end,
                                get = function(info)
                                    return RangeHelper.db.profile.icon.coordinates.y;
                                end,
                            },
                        },
                    },
                    resetIconSettings = {
                        order = 100,
                        type = "execute",
                        name = "Reset Icon Settings",
                        desc = "Reset all icon settings to default values.",
                        func = function()
                            StaticPopup_Show("RESET_ICON_SETTINGS_CONFIRM");
                        end,
                    },
                },
            },
        },
    };
    
    
    -- register options table for the main "RangeHelper" addon
    LibStub("AceConfig-3.0"):RegisterOptionsTable("RangeHelper", options);

    -- add addon to the Blizzard options panel
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RangeHelper", "RangeHelper");

end

function RangeHelper:LoadStaticDialogs()
    StaticPopupDialogs["RESET_ICON_SETTINGS_CONFIRM"] = {
        text = "Are you sure you want to reset your icon settings?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            self.db.profile.icon.size = defaults.profile.icon.size;
            self.db.profile.icon.opacity = defaults.profile.icon.opacity;
            self.db.profile.icon.coordinates.x = defaults.profile.icon.coordinates.x;
            self.db.profile.icon.coordinates.y = defaults.profile.icon.coordinates.y;
            AceConfigRegistry:NotifyChange("RangeHelper");
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    };
end

function RangeHelper:OnInitialize()
    if not RangeHelper.classAbilities[playerClass] then
        return self:Print("No abilities available to track for your class.");
    end

    -- initialize saved variables with defaults
    RangeHelper.db = LibStub("AceDB-3.0"):New("RangeHelperDB", defaults, true);

    self:Print("Type /rh to change the ability/icon/range of the tracker.");

    -- TODO: handle events

    -- load config stuff
    RangeHelper:CreateMenu();
    AceConfigRegistry:NotifyChange("RangeHelper");


    self:LoadStaticDialogs();
end

