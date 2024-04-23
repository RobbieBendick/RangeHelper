local RangeHelper = LibStub("AceAddon-3.0"):GetAddon("RangeHelper");
local playersWithinRange = {};
local iconSize = 40;
local nameplateToArenaNumberMap = {};

function RangeHelper:IsWithinAbilityRange(unit)
    local spellRange = RangeHelper.abilities[RangeHelper.db.profile.selectedAbility].range;
    local rangeItemId = RangeHelper.harmItems[spellRange][1];

    if not rangeItemId then return print("No item found with the spell range selected.") end

    return IsItemInRange(rangeItemId, unit);
end

function RangeHelper:GetKeyByValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k;
        end
    end
    return nil;
end

function RangeHelper:UpdateIcon(arenaUnit)
    if not arenaUnit or not UnitIsEnemy("player", arenaUnit) then return end
    local nameplateUnit = RangeHelper:GetKeyByValue(nameplateToArenaNumberMap, arenaUnit);
    if not nameplateUnit then return end
    local frame = C_NamePlate.GetNamePlateForUnit(nameplateUnit, true);
    if not frame then return end
    if not frame.icon then
        frame.icon = frame:CreateTexture(nil, "OVERLAY");
        frame.icon:SetSize(40, 40);
        frame.icon:SetPoint("CENTER", frame, "CENTER", 0, 25);
    end
    frame.icon:SetTexture(RangeHelper.abilities[RangeHelper.db.profile.selectedAbility].iconPath);
    
    if playersWithinRange[arenaUnit] then
        frame.icon:Show();
    else
        frame.icon:Hide();
    end
end

function RangeHelper:HandleUpdate()
    for i = 1, 5 do
        local unit = "arena"..i;
        if not UnitExists(unit) then 
            if playersWithinRange[unit] then
                playersWithinRange[unit] = nil;
                RangeHelper:UpdateIcon(unit);
            end
            break;
        end

        --  check if unit is in range
        if RangeHelper:IsWithinAbilityRange(unit) then
            playersWithinRange[unit] = true;
        else
            playersWithinRange[unit] = false;
        end
        RangeHelper:UpdateIcon(unit);
    end
end

function RangeHelper:UpdateArenaNumberTable()
    for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
        for k,v in pairs(frame) do
            if k == 'UnitFrame' then
                for j,l in pairs(v) do
                    if type(l) == "string" and l:find("^nameplate") then
                        for i = 1, 5 do
                            if not UnitExists("arena"..i) then break end
                            if UnitIsUnit(l, "arena"..i) then
                                nameplateToArenaNumberMap[l] = "arena"..i;
                            end
                        end
                    end
                end
            end
        end
    end
end

hooksecurefunc("CompactUnitFrame_SetUnit", function(frame)
    local _, instanceType = IsInInstance();
    if instanceType ~= "arena" then return end 
    RangeHelper:UpdateArenaNumberTable();
end);

local frame = CreateFrame("Frame");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
frame:RegisterEvent("PLAYER_LOGIN");

frame:SetScript("OnEvent", function(self, event, ...)
    local _, playerClass = UnitClass("player");
    if not RangeHelper.classAbilities[playerClass] then return end
    local _, instanceType = IsInInstance();
    if event == "ZONE_CHANGED_NEW_AREA" then
        if instanceType == "arena" then
            self:SetScript("OnUpdate", RangeHelper.HandleUpdate);
        else
            playersWithinRange = {};
            self:SetScript("OnUpdate", nil);
        end
    elseif event == "PLAYER_LOGIN" then
        if instanceType == "arena" then
            self:SetScript("OnUpdate", RangeHelper.HandleUpdate);
        else
            playersWithinRange = {};
            self:SetScript("OnUpdate", nil);
        end
    end
end);
