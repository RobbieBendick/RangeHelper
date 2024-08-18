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

local function GetFrameNumber(frame)
    if not frame or not frame:GetName() then return nil end
    local frameName = frame:GetName();
    return tonumber(frameName:match("%d+$"));
end

function RangeHelper:UpdateIcon(frame)
    if not frame then return end

    local targetFrame = frame;
    if IsAddOnLoaded("Plater") then
        local frameNumber = GetFrameNumber(frame);
        if frameNumber then
            targetFrame = _G["NamePlate".. frameNumber .. "PlaterUnitFrame"];
        end
    end

    if not targetFrame.icon then
        targetFrame.icon = targetFrame:CreateTexture(nil, "OVERLAY");
        targetFrame.icon:SetSize(self.db.profile.icon.size, self.db.profile.icon.size);
        targetFrame.icon:SetAlpha(tonumber(self.db.profile.icon.opacity));
    else
        local currentWidth, currentHeight = targetFrame.icon:GetSize();
        if currentWidth ~= tonumber(self.db.profile.icon.size) or currentHeight ~= tonumber(self.db.profile.icon.size) then
            targetFrame.icon:SetSize(self.db.profile.icon.size, self.db.profile.icon.size);
        end

        local currentOpacity = targetFrame.icon:GetAlpha();
        if currentOpacity ~= tonumber(self.db.profile.icon.opacity) then
            targetFrame.icon:SetAlpha(tonumber(self.db.profile.icon.opacity));
        end
    end

    targetFrame.icon:SetPoint("CENTER", targetFrame, "CENTER", self.db.profile.icon.coordinates.x, self.db.profile.icon.coordinates.y);
    targetFrame.icon:SetTexture(self.abilities[self.db.profile.selectedAbility].iconPath);

    -- have to explicitly check if true
    if self.framesWithinRange[frame] == true then
        if self.db.profile.hideIconOnCD and self:IsSpellOnCooldown(self.db.profile.selectedAbility) then
            targetFrame.icon:Hide();
        else
            targetFrame.icon:Show();
        end
    else
        targetFrame.icon:Hide();
    end
end


function RangeHelper:UpdateWithinRangeTable(frame, unit)
    if not frame or not unit then return end
    
    local targetFrame = frame;
    if IsAddOnLoaded("Plater") then
        local frameNumber = GetFrameNumber(frame);
        if frameNumber then
            targetFrame = _G["NamePlate".. frameNumber .. "PlaterUnitFrame"];
        end
    end

    if UnitIsDead(unit) or not UnitIsEnemy("player", unit) then
        self.framesWithinRange[targetFrame] = nil;
        return
    end

    if not self.db.profile.showInPVE then
        if UnitIsPlayer(unit) then
            self.framesWithinRange[targetFrame] = false;
        else
            self.framesWithinRange[targetFrame] = nil;
        end
    else
        self.framesWithinRange[targetFrame] = false;
    end
end

hooksecurefunc("CompactUnitFrame_SetUnit", function(frame, unit)
    if not unit or not unit:match("^nameplate") then return end

    local targetFrame = frame;
    if IsAddOnLoaded("Plater") then
        local frameNumber = GetFrameNumber(frame);
        if frameNumber then
            targetFrame = _G["NamePlate".. frameNumber .. "PlaterUnitFrame"];
        end
    end

    RangeHelper:UpdateWithinRangeTable(targetFrame, unit);
end)

hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(self, unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit);

    local targetFrame = frame;
    if IsAddOnLoaded("Plater") then
        local frameNumber = GetFrameNumber(frame);
        if frameNumber then
            targetFrame = _G["NamePlate".. frameNumber .. "PlaterUnitFrame"];
        end
    end

    if targetFrame then
        RangeHelper:UpdateWithinRangeTable(targetFrame, unit);
    end
end)

hooksecurefunc(NamePlateDriverFrame, "OnNamePlateRemoved", function(self, unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit);

    local targetFrame = frame
    if IsAddOnLoaded("Plater") then
        local frameNumber = GetFrameNumber(frame);
        if frameNumber then
            targetFrame = _G["NamePlate".. frameNumber .. "PlaterUnitFrame"];
        end
    end

    if targetFrame then
        RangeHelper.framesWithinRange[targetFrame] = nil
        RangeHelper:UpdateIcon(targetFrame)
    end
end)

function RangeHelper:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory("RangeHelper");
    InterfaceOptionsFrame_OpenToCategory("RangeHelper");
end

if RangeHelper.classAbilities[playerClass] then
    SLASH_RANGEHELPER1 = "/rh";
    SLASH_RANGEHELPER2 = "/rangehelper";
    
    SlashCmdList["RANGEHELPER"] = RangeHelper.OpenOptions;
end
