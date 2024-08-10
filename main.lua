local addonPrefix = "typingindicator"

if C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix) then
    print("To enable WoW Typing Indicator, type /wowtypingindicator or /wti.")
else
    print("WTI Addon prefix not registered properly.")
end

-- party members
local wtiPartyFrame = CreateFrame("Frame")
local wtiGroupMembers = {}
wtiPartyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
wtiPartyFrame:SetScript("OnEvent", function()
    for i = 1, GetNumGroupMembers() - 1 do
        -- this is because msgSender and unitfullname are formatted differently
        formattedUnitName = string.gsub(UnitFullName("party" .. i), " ", "-")
        wtiGroupMembers[formattedUnitName] = i
        print(formattedUnitName)
        print(wtiGroupMembers[formattedUnitName])

        wtiIndividualIndicator = CreateFrame("Frame", formattedUnitName .. "Frame", UIParent)
        wtiIndividualIndicator:SetPoint("LEFT", _G["PartyFrame"]["MemberFrame" .. i], "RIGHT")
        wtiIndividualIndicator:SetSize(64, 64)
        wtiIndividualIndicator.tex = wtiIndividualIndicator:CreateTexture()
        wtiIndividualIndicator.tex:SetAllPoints(wtiIndividualIndicator)
        wtiIndividualIndicator.tex:SetTexture("interface/icons/ACHIEVEMENT_GUILDPERK_GMAIL")
    end
end)

local wtiMessageFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
local wtiText = wtiMessageFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
--wtiMessageFrame:SetPoint("LEFT", _G["PartyFrame"]["MemberFrame1"], "RIGHT")
wtiMessageFrame:SetSize(150, 40)
wtiMessageFrame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
wtiText:SetPoint("CENTER")
wtiMessageFrame:RegisterEvent("CHAT_MSG_ADDON")
wtiMessageFrame:SetScript("OnEvent", function(self, event, msgPrefix, msgText, msgChannel, msgSender)
    if msgText == "1" then
        wtiText:SetText(msgSender)
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
                else
                    C_ChatInfo.SendAddonMessage(addonPrefix, "0", "INSTANCE_CHAT")
                end
                prevText = ACTIVE_CHAT_EDIT_BOX:GetText()
            end
        end)
    end
end

-- slash commands
SLASH_WOWTYPINGINDICATOR1, SLASH_WOWTYPINGINDICATOR2 = "/wowtypingindicator", "/wti";
SlashCmdList["WOWTYPINGINDICATOR"] = function()
    toggleIndicator()
end