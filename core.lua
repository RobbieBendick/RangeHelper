local RangeHelper = LibStub("AceAddon-3.0"):GetAddon("RangeHelper");
local _, playerClass = UnitClass("player");

function RangeHelper:IsWithinAbilityRange(unit)
    local spellRange = self.abilities[self.db.profile.selectedAbility].range;
    local rangeItemId = self.harmItems[spellRange][1];

    if not rangeItemId then
        return self:Print("No item found with the spell range selected.");
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

function RangeHelper:UpdateIcon(frame)
    if not frame then return end
    if not frame.icon then
        frame.icon = frame:CreateTexture(nil, "OVERLAY");
        frame.icon:SetSize(self.db.profile.icon.size, self.db.profile.icon.size);
        frame.icon:SetAlpha(tonumber(self.db.profile.icon.opacity));
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
    
    -- have to explicitly check if true
    if self.framesWithinRange[frame] == true then
        if self.db.profile.hideIconOnCD and self:IsSpellOnCooldown(self.db.profile.selectedAbility) then
            frame.icon:Hide();
        else
            frame.icon:Show();
        end
    else
        frame.icon:Hide();
    end
end

function RangeHelper:UpdateWithinRangeTable(frame, unit)
    if not frame or not unit then return end
    
    if UnitIsDead(unit) or not UnitIsEnemy("player", unit) then
        self.framesWithinRange[frame] = nil;
        return;
    end

    if not self.db.profile.showInPVE then
        if UnitIsPlayer(unit) then
            self.framesWithinRange[frame] = false;
        else
            self.framesWithinRange[frame] = nil;
        end
    else
        self.framesWithinRange[frame] = false;
    end
end

hooksecurefunc("CompactUnitFrame_SetUnit", function(frame, unit)
    if not unit or not unit:match("^nameplate") then return end
    RangeHelper:UpdateWithinRangeTable(frame, unit);
end);

hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(self, unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit);
    if frame then
        RangeHelper:UpdateWithinRangeTable(frame, unit);
    end
end);

hooksecurefunc(NamePlateDriverFrame, "OnNamePlateRemoved", function(self, unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit);
    if frame then
        RangeHelper.framesWithinRange[frame] = nil;
        RangeHelper:UpdateIcon(frame);
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
