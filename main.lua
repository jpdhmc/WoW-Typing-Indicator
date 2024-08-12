local addonPrefix = "typingindicator"

if C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix) then
    print("To enable/disable WoW Typing Indicator tracking your typing, type /wowtypingindicator or /wti. Disabled by default.")
else
    print("WTI Addon prefix not registered properly.")
end

-- set up party members + individual indicators
local wtiPartyFrame = CreateFrame("Frame")
wtiPartyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
wtiPartyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
wtiPartyFrame:SetScript("OnEvent", function()
    local wtiGroupMembers = {}
    local wtiIndividualIndicators = {}
    for i = 1, GetNumGroupMembers() - 1 do
        -- this is because msgSender and unitfullname are formatted differently
        formattedUnitName = string.gsub(UnitFullName("party" .. i), " ", "-")
        wtiGroupMembers[i] = formattedUnitName

        -- visuals
        wtiIndividualIndicators[i] = CreateFrame("Frame", formattedUnitName .. "Frame", UIParent)
        wtiIndividualIndicators[i]:Hide()
        wtiIndividualIndicators[i]:SetPoint("LEFT", _G["PartyFrame"]["MemberFrame" .. i], "RIGHT")
        wtiIndividualIndicators[i]:SetSize(48, 48)
        wtiIndividualIndicators[i].tex = wtiIndividualIndicators[i]:CreateTexture()
        wtiIndividualIndicators[i].tex:SetAllPoints(wtiIndividualIndicators[i])
        wtiIndividualIndicators[i].tex:SetTexture("interface/icons/ACHIEVEMENT_GUILDPERK_GMAIL")

        -- event
        wtiIndividualIndicators[i]:RegisterEvent("CHAT_MSG_ADDON")
        wtiIndividualIndicators[i]:SetScript("OnEvent", function(self, event, msgPrefix, msgText, msgChannel, msgSender)
            if msgSender == wtiGroupMembers[i] then
                if msgText == "1" then
                    wtiIndividualIndicators[i]:Show()
                else
                    wtiIndividualIndicators[i]:Hide()
                end
            end
        end)
    end
end)

-- display element above chatbox
local wtiMessageFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
local wtiText = wtiMessageFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
local wtiConcText = ""
wtiMessageFrame:SetPoint("BOTTOM", GeneralDockManager, "TOP")
wtiMessageFrame:SetSize(430, 30)
wtiMessageFrame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
wtiText:SetPoint("CENTER")
wtiMessageFrame:RegisterEvent("CHAT_MSG_ADDON")
wtiMessageFrame:SetScript("OnEvent", function(self, event, msgPrefix, msgText, msgChannel, msgSender)
    wtiSenderName = string.gsub(msgSender, "-.*", "... ")
    if msgText == "1" then
        if not string.match(wtiConcText, wtiSenderName) then
            wtiConcText = wtiConcText .. wtiSenderName
            wtiText:SetText(wtiConcText)
        end
    elseif msgText == "0" then
        if string.match(wtiConcText, wtiSenderName) then
            wtiConcText = string.gsub(wtiConcText, wtiSenderName, "")
            wtiText:SetText(wtiConcText)
        end
    end
end)

-- start sending player's typing info
local function toggleIndicator()
    if timerVar ~= nil and not timerVar:IsCancelled() then
        timerVar:Cancel()
        print("No longer sending typing status.")
    else
        --prevText = ""
        print("You are now sending your typing status.")
        timerVar = C_Timer.NewTicker(0.1, function()
            if ACTIVE_CHAT_EDIT_BOX ~= nil then
                --if ACTIVE_CHAT_EDIT_BOX:GetText() ~= "" and ACTIVE_CHAT_EDIT_BOX:GetText() ~= prevText then
                if ACTIVE_CHAT_EDIT_BOX:GetText() ~= "" then
                    C_ChatInfo.SendAddonMessage(addonPrefix, "1", "INSTANCE_CHAT")
                else
                    C_ChatInfo.SendAddonMessage(addonPrefix, "0", "INSTANCE_CHAT")
                end
                --prevText = ACTIVE_CHAT_EDIT_BOX:GetText()
            else
                C_ChatInfo.SendAddonMessage(addonPrefix, "0", "INSTANCE_CHAT")
            end
        end)
    end
end

-- slash commands
SLASH_WOWTYPINGINDICATOR1, SLASH_WOWTYPINGINDICATOR2 = "/wowtypingindicator", "/wti";
SlashCmdList["WOWTYPINGINDICATOR"] = function()
    toggleIndicator()
end