local RangeHelper = LibStub("AceAddon-3.0"):GetAddon("RangeHelper");
local LibDBIcon = LibStub("LibDBIcon-1.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local RHConfig;
local _, playerClass = UnitClass("player");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
RangeHelper.framesWithinRange = {};
RangeHelper.specIndex = nil;

local defaults = {
    profile = {
        selectedAbility = RangeHelper.classAbilities[playerClass] or "Thunderstorm",
        swapBetweenDBAndCoC = false,
        showInArena = true,
        showInWorld = false,
        showInBG = false,
        showInPVE = false,
        hideIconOnCD = false,
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
    for abilityName, data in pairs(self.abilities) do
        abilities[abilityName] = ("|T%s:16|t %s (%dyd)"):format(data.iconPath, abilityName, data.range);
    end

    local version = GetAddOnMetadata(RHConfig.name, "Version") or "Unknown";
    local author = GetAddOnMetadata(RHConfig.name, "Author") or "Mageiden";
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
                            self.db.profile.selectedAbility = value;
                            self:UpdateAbilitySettingsOptions();
                        end,
                        get = function(info)
                            return self.db.profile.selectedAbility;
                        end,
                        width = 1.1,
                    },
                    spacer = {
                        order = 2,
                        type = "description",
                        name = " ",
                        width = "full",
                    },
                    hideIconOnCD = {
                        order = 3,
                        type = "toggle",
                        name = "Hide Icon While On CD",
                        desc = "Hide the icon when the selected ability is on cooldown.",
                        set = function(info, value)
                            self.db.profile.hideIconOnCD = value;
                        end,
                        get = function(info)
                            return self.db.profile.hideIconOnCD;
                        end,
                        width = 1,
                    },
                    spacer = {
                        order = 4,
                        type = "description",
                        name = " ",
                        width = "full",
                    },
                    swapBetweenDBAndCoC = {
                        order = 5,
                        type = "toggle",
                        name = "Swap between DB & CoC",
                        desc = "When you swap to Fire from Frost and you have Cone of Cold as your selected ability, switch to Dragon's Breath and vice versa.",
                        set = function(info, value)
                            self.db.profile.swapBetweenDBAndCoC = value;
                        end,
                        get = function(info)
                            return self.db.profile.swapBetweenDBAndCoC;
                        end,
                        hidden = function(info)
                            return playerClass ~= "MAGE" or (self.db.profile.selectedAbility ~= "Dragon's Breath" and self.db.profile.selectedAbility ~= "Cone of Cold");
                        end,
                        width = 2,
                    },
                },
            },
            showInCategory = {
                order = 3,
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
                            self.db.profile.showInArena = value;
                        end,
                        get = function(info)
                            return self.db.profile.showInArena;
                        end,
                    },
                    showInBG = {
                        order = 2,
                        width = 0.57,
                        type = "toggle",
                        name = "Show In BG",
                        desc = "Show in BG.",
                        set = function(info, value)
                            self.db.profile.showInBG = value;
                        end,
                        get = function(info)
                            return self.db.profile.showInBG;
                        end,
                    },
                    showInWorld = {
                        order = 3,
                        width = 0.67,
                        type = "toggle",
                        name = "Show In World",
                        desc = "Show in world.",
                        set = function(info, value)
                            self.db.profile.showInWorld = value;
                        end,
                        get = function(info)
                            return self.db.profile.showInWorld;
                        end,
                    },
                    showInPVE = {
                        order = 4,
                        width = 0.67,
                        type = "toggle",
                        name = "Show In PVE",
                        desc = "Show in PVE.",
                        set = function(info, value)
                            self.db.profile.showInPVE = value;
                        end,
                        get = function(info)
                            return self.db.profile.showInPVE;
                        end,
                    },
                },
            },
            icon = {
                order = 4,
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
                            self.db.profile.icon.size = value;
                        end,
                        get = function(info)
                            return self.db.profile.icon.size;
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
                            self.db.profile.icon.opacity = value;
                        end,
                        get = function(info)
                            return self.db.profile.icon.opacity;
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
                                    self.db.profile.icon.coordinates.x = value;
                                end,
                                get = function(info)
                                    return self.db.profile.icon.coordinates.x;
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
                                    self.db.profile.icon.coordinates.y = value;
                                end,
                                get = function(info)
                                    return self.db.profile.icon.coordinates.y;
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
    LibStub("AceConfig-3.0"):RegisterOptionsTable(RHConfig.name, options);

    -- add addon to the Blizzard options panel
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(RHConfig.name, RHConfig.name);

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
    if not self.classAbilities[playerClass] then
        return self:Print("No abilities available to track for your class.");
    end

    -- initialize saved variables with defaults
    self.db = LibStub("AceDB-3.0"):New("RangeHelperDB", defaults, true);

    -- events
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "HandleLogin");
    self:RegisterEvent("PLAYER_LOGIN", "HandleLogin");
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "HandleActiveTalentGroupChange");

    -- setting updates
    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateTracking");
    self.db.RegisterCallback(self, "OnProfileCopied", "UpdateTracking");
    self.db.RegisterCallback(self, "OnProfileReset", "UpdateTracking");

    -- load config stuff
    self:CreateMenu();
    AceConfigRegistry:NotifyChange("RangeHelper");

    self:LoadStaticDialogs();

    self.frame = CreateFrame("Frame");

    self:Print("Type /rh to change the ability/icon/range of the tracker.");
end

function RangeHelper:SetSpecIndex()
    for i=1, 3 do
        if select(5, GetTalentTabInfo(i)) > 25 then
            RangeHelper.specIndex = i;
        end
    end
end

function RangeHelper:HandleActiveTalentGroupChange()
    local prevSpec = self.specIndex;
    self:SetSpecIndex();

    if prevSpec == 3 and self.specIndex == 2 and self.db.profile.selectedAbility == "Cone of Cold" then
        self.db.profile.selectedAbility = "Dragon's Breath";
    elseif prevSpec == 2 and self.specIndex == 3 and self.db.profile.selectedAbility == "Dragon's Breath" then
        self.db.profile.selectedAbility = "Cone of Cold";
    end
end

function RangeHelper:HandleLogin()
    self:UpdateTracking();
    self:SetSpecIndex();
end

function RangeHelper:ShouldLoad()
    local _, instanceType = IsInInstance();
    if (instanceType == "arena" and self.db.profile.showInArena) or
       (instanceType == "none" and self.db.profile.showInWorld) or 
       (instanceType == "pvp" and self.db.profile.showInBG) then
        return true;
    end
    return false;
end

function RangeHelper:HandleUpdate()
    for frame in pairs(RangeHelper.framesWithinRange) do
        if not UnitExists(frame.unit) then 
            RangeHelper.framesWithinRange[frame] = nil;
            RangeHelper:UpdateIcon(frame);
        else
            RangeHelper.framesWithinRange[frame] = RangeHelper:IsWithinAbilityRange(frame.unit);
            RangeHelper:UpdateIcon(frame);
        end
    end
end

function RangeHelper:UpdateTracking()
    if not self.classAbilities[playerClass] then return end
    self.framesWithinRange = {};
    if self:ShouldLoad() then
        self.frame:SetScript("OnUpdate", self.HandleUpdate);
    else
        self.frame:SetScript("OnUpdate", nil);
    end
end
