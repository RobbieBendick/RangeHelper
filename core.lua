local RangeHelper = LibStub("AceAddon-3.0"):GetAddon("RangeHelper");
RangeHelper.playersWithinRange = {};
local _, playerClass = UnitClass("player");

function RangeHelper:IsWithinAbilityRange(unit)
    local spellRange = self.abilities[RangeHelper.db.profile.selectedAbility].range;
    local rangeItemId = self.harmItems[spellRange][1];

    if not rangeItemId then
        return print("No item found with the spell range selected.");
    end

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

        local currentAlpha = frame.icon:GetAlpha();
        if currentAlpha ~= tonumber(self.db.profile.icon.opacity) then
            frame.icon:SetAlpha(tonumber(self.db.profile.icon.opacity));
        end
    end
    frame.icon:SetTexture(self.abilities[self.db.profile.selectedAbility].iconPath);
    frame.icon:SetPoint("CENTER", frame, "CENTER", self.db.profile.icon.coordinates.x, self.db.profile.icon.coordinates.y);

    if RangeHelper.playersWithinRange[frame] then
        frame.icon:Show();
    else
        frame.icon:Hide();
    end
end

function RangeHelper:HandleUpdate()
    for frame, inRange in pairs(RangeHelper.playersWithinRange) do
        if not UnitExists(frame.unit) then 
            if RangeHelper.playersWithinRange[frame] then
                RangeHelper.playersWithinRange[frame] = nil;
                self:UpdateIcon(frame);
            end
            break;
        end
        if RangeHelper:IsWithinAbilityRange(frame.unit) then
            RangeHelper.playersWithinRange[frame] = true;
        else
            RangeHelper.playersWithinRange[frame] = false;
        end
        RangeHelper:UpdateIcon(frame);
    end

end

function RangeHelper:UpdatePlayerTable(frame)
    if RangeHelper.playersWithinRange[frame] then return end
    if not UnitIsPlayer(frame.unit) then return end
    RangeHelper.playersWithinRange[frame] = false;
end

hooksecurefunc("CompactUnitFrame_SetUnit", function(frame)
    local _, instanceType = IsInInstance();
    local shouldUpdate = false;
    
    if instanceType == "arena" and RangeHelper.db.profile.showInArena then
        shouldUpdate = true;
    elseif instanceType == "pvp" and RangeHelper.db.profile.showInBG then
        shouldUpdate = true;
    elseif instanceType == "none" and RangeHelper.db.profile.showInWorld then
        shouldUpdate = true;
    end


    if shouldUpdate then
        RangeHelper:UpdatePlayerTable(frame);
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

local frame = CreateFrame("Frame");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
frame:RegisterEvent("PLAYER_LOGIN");

frame:SetScript("OnEvent", function(self, event, ...)
    if not RangeHelper.classAbilities[playerClass] then return end
    local _, instanceType = IsInInstance();
    
    local function updateTracking()
        if (instanceType == "arena" and RangeHelper.db.profile.showInArena) or
           (instanceType == "none" and RangeHelper.db.profile.showInWorld) or 
           (instanceType == "pvp" and RangeHelper.db.profile.showInBG) then
            self:SetScript("OnUpdate", RangeHelper.HandleUpdate);
        else
            RangeHelper.playersWithinRange = {};
            self:SetScript("OnUpdate", nil);
        end
    end

    if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LOGIN" then
        updateTracking();
    end
end);
