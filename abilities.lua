local RangeHelper = _G.LibStub("AceAddon-3.0"):NewAddon("RangeHelper", "AceConsole-3.0", "AceEvent-3.0");

RangeHelper.abilities = {
    ["Psychic Scream"] = {
        ["range"] = 8,
        ["iconPath"] = "Interface\\ICONS\\Spell_Shadow_PsychicScream",
    },
    ["Thunderstorm"] = { 
        ["range"] = 10,
        ["iconPath"] = "Interface\\ICONS\\spell_shaman_thunderstorm",
    },
    ["Howl of Terror"] = {
        ["range"] = 10,
        ["iconPath"] = "Interface\\ICONS\\Spell_Shadow_DeathScream",
    },
    ["Dragon's Breath"] = {
        ["range"] = 10,
        ["iconPath"] = "Interface\\ICONS\\INV_Misc_Head_Dragon_01",
    }
};

RangeHelper.harmItems = {
    [8] = {
        32321, -- Sparrowhawk Net
    },
    [10] = {
        34368, -- Attuned Crystal Cores
    },
};

RangeHelper.classAbilities = {
    ["MAGE"] = "Dragon's Breath",
    ["PRIEST"] = "Psychic Scream",
    ["WARLOCK"] = "Howl of Terror",
    ["SHAMAN"] = "Thunderstorm",
};