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
    [2] = {
        37727, -- Ruby Acorn
    },
    [3] = {
        42732, -- Everfrost Razor
    },
    [5] = {
        8149, -- Voodoo Charm
        136605, -- Solendra's Compassion
        63427, -- Worgsaw
    },
    [8] = {
        34368, -- Attuned Crystal Cores
        33278, -- Burning Torch
    },
    [10] = {
        32321, -- Sparrowhawk Net
        17626, -- Frostwolf Muzzle
    },
    [15] = {
        33069, -- Sturdy Rope
    },
    [20] = {
        10645, -- Gnomish Death Ray
    },
    [25] = {
        24268, -- Netherweave Net
        41509, -- Frostweave Net
        31463, -- Zezzak's Shard
        13289, -- Egan's Blaster
    },
    [30] = {
        835, -- Large Rope Net
        7734, -- Six Demon Bag
        34191, -- Handful of Snowflakes
    },
    [35] = {
        24269, -- Heavy Netherweave Net
        18904, -- Zorbin's Ultra-Shrinker
    },
    [40] = {
       28767, -- The Decapitator
    },
    [45] = {
        --32698, -- Wrangling Rope
      23836, -- Goblin Rocket Launcher
    },
    [60] = {
        32825, -- Soul Cannon
        37887, -- Seeds of Nature's Wrath
    },
    [70] = {
        41265, -- Eyesore Blaster
    },
    [80] = {
        35278, -- Reinforced Net
    },
    [100] = {
        33119, -- Malister's Frost Wand
    },
    [150] = {
        46954, -- Flaming Spears
    },
};

RangeHelper.classAbilities = {
    ["MAGE"] = "Dragon's Breath",
    ["PRIEST"] = "Psychic Scream",
    ["WARLOCK"] = "Howl of Terror",
    ["SHAMAN"] = "Thunderstorm",
};