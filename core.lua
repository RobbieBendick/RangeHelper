local RangeHelper = LibStub("AceAddon-3.0"):GetAddon("RangeHelper");
RangeHelper.framesWithinRange = {};
local _, playerClass = UnitClass("player");

function RangeHelper:IsWithinAbilityRange(unit)
    local spellRange = self.abilities[RangeHelper.db.profile.selectedAbility].range;
    local rangeItemId = self.harmItems[spellRange][1];

    if not rangeItemId then
        return print("No item found with the spell range selected.");
    end

    return IsItemInRange(rangeItemId, unit) or false;
end

function RangeHelper:IsSpellOnCooldown(spellName)
    local start, duration, enabled = GetSpellCooldown(spellName);
    if enabled == 0 then
        return true;
    end
    if start > 0 and duration > 0 then
        local gcdThreshold = 1.5;
        local margin = 0.1;

        if duration > (gcdThreshold + margin) then
            return true;
        end
    end
    return false;
end

function RangeHelper:ShouldLoad()
    local _, instanceType = IsInInstance();
    if (instanceType == "arena" and RangeHelper.db.profile.showInArena) or
           (instanceType == "none" and RangeHelper.db.profile.showInWorld) or 
           (instanceType == "pvp" and RangeHelper.db.profile.showInBG) then
            return true;
    end
    return false;
end

function RangeHelper:UpdateIcon(frame)
    if not frame then return end
    if not frame.icon then
        frame.icon = frame:CreateTexture(nil, "OVERLAY");
        frame.icon:SetSize(self.db.profile.icon.size, self.db.profile.icon.size);
    else
        local currentWidth, currentHeight = frame.icon:GetSize();
        if currentWidth ~= tonumber(self.db.profile.icon.size) or currentHeight ~= tonumber(self.db.profile.icon.size) then
            frame.icon:SetSize(self.db.profile.icon.size, self.db.profile.icon.size);
        end

        local currentOpacity = frame.icon:GetAlpha();
        if currentOpacity ~= tonumber(self.db.profile.icon.opacity) then
            frame.icon:SetAlpha(tonumber(self.db.profile.icon.opacity));
        end
    end
    frame.icon:SetTexture(self.abilities[self.db.profile.selectedAbility].iconPath);
    frame.icon:SetPoint("CENTER", frame, "CENTER", self.db.profile.icon.coordinates.x, self.db.profile.icon.coordinates.y);
    
    if RangeHelper.framesWithinRange[frame] == true then
        if self.db.profile.hideIconOnCD and RangeHelper:IsSpellOnCooldown(self.db.profile.selectedAbility) then
            frame.icon:Hide();
        else
            frame.icon:Show();
        end
    else
        frame.icon:Hide();
    end
end

function RangeHelper:HandleUpdate()
    for frame in pairs(RangeHelper.framesWithinRange) do
        if not UnitExists(frame.unit) then 
            if RangeHelper.framesWithinRange[frame] then
                RangeHelper.framesWithinRange[frame] = nil;
                RangeHelper:UpdateIcon(frame);
            end
            break;
        end
        if RangeHelper:IsWithinAbilityRange(frame.unit) then
            RangeHelper.framesWithinRange[frame] = true;
        else
            RangeHelper.framesWithinRange[frame] = false;
        end
        RangeHelper:UpdateIcon(frame);
    end
end

function RangeHelper:UpdateWithinRangeTable(frame, unit)
    if not frame or not unit then return end
    if not UnitIsEnemy("player", unit) or not UnitIsPlayer(unit) or UnitIsDead(unit) then
        RangeHelper.framesWithinRange[frame] = nil;
    else
        RangeHelper.framesWithinRange[frame] = false;
    end
end
 
hooksecurefunc("CompactUnitFrame_SetUnit", function(frame, unit)
    if not unit:match("^nameplate") then return end
    RangeHelper:UpdateWithinRangeTable(frame, frame.unit);
end);

hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(self, unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit);
    if frame then
        RangeHelper:UpdateWithinRangeTable(frame, frame.unit);
    end
end);

hooksecurefunc(NamePlateDriverFrame, "OnNamePlateRemoved", function(self, unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit);
    if frame then
        RangeHelper.playersWithinRange[frame] = nil;
    end
end);

local frame = CreateFrame("Frame");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
frame:RegisterEvent("PLAYER_LOGIN");

frame:SetScript("OnEvent", function(self, event, ...)
    if not RangeHelper.classAbilities[playerClass] then return end
    local _, instanceType = IsInInstance();
    
    local function updateTracking()
        if RangeHelper:ShouldLoad() then
            self:SetScript("OnUpdate", RangeHelper.HandleUpdate);
        else
            RangeHelper.framesWithinRange = {};
            self:SetScript("OnUpdate", nil);
        end
    end

    if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LOGIN" then
        updateTracking();
    end
end);

function RangeHelper:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory("RangeHelper");
    InterfaceOptionsFrame_OpenToCategory("RangeHelper");
end

if RangeHelper.classAbilities[playerClass] then
    SLASH_RANGEHELPER1 = "/rh";
    SLASH_RANGEHELPER2 = "/rangehelper";
    
    SlashCmdList["RANGEHELPER"] = RangeHelper.OpenOptions;
end

