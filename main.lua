local addonPrefix = "typingindicator"

if C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix) then
    print("To enable/disable WoW Typing Indicator, type /wowtypingindicator or /wti.")
else
    print("WTI Addon prefix not registered properly.")
end

-- set up party members
local wtiPartyFrame = CreateFrame("Frame")
local wtiGroupMembers = {}
wtiPartyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
wtiPartyFrame:SetScript("OnEvent", function()
    for i = 1, GetNumGroupMembers() - 1 do
        -- this is because msgSender and unitfullname are formatted differently
        formattedUnitName = string.gsub(UnitFullName("party" .. i), " ", "-")
        wtiGroupMembers[formattedUnitName] = i

        -- visuals
        wtiIndividualIndicator = CreateFrame("Frame", formattedUnitName .. "Frame", UIParent)
        wtiIndividualIndicator:Hide()
        wtiIndividualIndicator:SetPoint("LEFT", _G["PartyFrame"]["MemberFrame" .. i], "RIGHT")
        wtiIndividualIndicator:SetSize(48, 48)
        wtiIndividualIndicator.tex = wtiIndividualIndicator:CreateTexture()
        wtiIndividualIndicator.tex:SetAllPoints(wtiIndividualIndicator)
        wtiIndividualIndicator.tex:SetTexture("interface/icons/ACHIEVEMENT_GUILDPERK_GMAIL")

        -- event
        wtiIndividualIndicator:RegisterEvent("CHAT_MSG_ADDON")
        wtiIndividualIndicator:SetScript("OnEvent", function(self, event, msgPrefix, msgText, msgChannel, msgSender)
        if msgSender == formattedUnitName then
            if msgText == "1" then
                wtiIndividualIndicator:Show()
            else
                wtiIndividualIndicator:Hide()
            end
        end
        end)
    end
end)

local function toggleIndicator()
    if timerVar ~= nil and not timerVar:IsCancelled() then
        timerVar:Cancel()
        print("not tracking typing")
    else
        prevText = ""
        print("starting to track typing")
        timerVar = C_Timer.NewTicker(1, function()
            if ACTIVE_CHAT_EDIT_BOX ~= nil then
                if ACTIVE_CHAT_EDIT_BOX:GetText() ~= "" and ACTIVE_CHAT_EDIT_BOX:GetText() ~= prevText then
                    C_ChatInfo.SendAddonMessage(addonPrefix, "1", "INSTANCE_CHAT")
                    print("sent 1")
                else
                    C_ChatInfo.SendAddonMessage(addonPrefix, "0", "INSTANCE_CHAT")
                    print("sent 0")
                end
                prevText = ACTIVE_CHAT_EDIT_BOX:GetText()
            else
                C_ChatInfo.SendAddonMessage(addonPrefix, "0", "INSTANCE_CHAT")
                print("sent 0")
            end
        end)
    end
end

-- slash commands
SLASH_WOWTYPINGINDICATOR1, SLASH_WOWTYPINGINDICATOR2 = "/wowtypingindicator", "/wti";
SlashCmdList["WOWTYPINGINDICATOR"] = function()
    toggleIndicator()
end