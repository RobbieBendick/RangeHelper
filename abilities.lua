local RangeHelper = _G.LibStub("AceAddon-3.0"):NewAddon("RangeHelper", "AceConsole-3.0", "AceEvent-3.0");

RangeHelper.abilities = {
    ["Thunderstorm"] = { 
        ["range"] = 10,
        ["iconPath"] = "Interface\\ICONS\\spell_shaman_thunderstorm",
    },
    ["Psychic Scream"] = {
        ["range"] = 8,
        ["iconPath"] = "Interface\\ICONS\\Spell_Shadow_PsychicScream",
    },
    ["Howl of Terror"] = {
        ["range"] = 10,
        ["iconPath"] = "Interface\\ICONS\\Spell_Shadow_DeathScream",
    },
};

RangeHelper.harmItems = {
    [8] = {
        32321, -- Sparrowhawk Net
    },
    [10] = {
        34368, -- Attuned Crystal Cores
    },
};