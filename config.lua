local RangeHelper = LibStub("AceAddon-3.0"):GetAddon("RangeHelper");
local LibDBIcon = LibStub("LibDBIcon-1.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local RHConfig;

local defaults = {
    profile = {
        selectedAbility = "Thunderstorm",
    }
};

function RangeHelper:CreateMenu()
    RHConfig = CreateFrame("Frame", "RangeHelperConfig", UIParent);

    RHConfig.name = "RangeHelper";

    RHConfig.title = RHConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    RHConfig.title:SetParent(RHConfig);
    RHConfig.title:SetPoint("TOPLEFT", 16, -16);
    RHConfig.title:SetText(RHConfig.name);

    local options = {
        name = "RangeHelper",
        type = "group",
        args = {
            chooseAbility = {
                order = 1,
                type = "select",
                name = "Choose Ability",
                desc = "Select an ability.",
                values = {
                    ["Thunderstorm"] = "Thunderstorm",
                    ["Psychic Scream"] = "Psychic Scream",
                    ["Howl of Terror"] = "Howl of Terror",
                    ["Dragon's Breath"] = "Dragon's Breath",
                },
                width = "normal",
                set = function(info, value)
                    RangeHelper.db.profile.selectedAbility = value;
                end,
                get = function(info)
                    return RangeHelper.db.profile.selectedAbility;
                end,
            },
        },
    };

    -- Register options table for the main "RangeHelper" addon
    LibStub("AceConfig-3.0"):RegisterOptionsTable("RangeHelper", options);

    -- Add addon to the Blizzard options panel
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RangeHelper", "RangeHelper");
end

function RangeHelper:OnInitialize()
    -- initialize saved variables with defaults
    RangeHelper.db = LibStub("AceDB-3.0"):New("RangeHelperDB", defaults, true);

    -- handle events later


    -- load config stuff
    RangeHelper:CreateMenu();
end
