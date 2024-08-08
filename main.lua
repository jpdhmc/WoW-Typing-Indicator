function toggleIndicator()
    if timerVar ~= nil and not timerVar:IsCancelled() then
        timerVar:Cancel()
        print("not tracking typing")
    else
        prevText = ""
        print("starting to track typing")
        timerVar = C_Timer.NewTicker(1, function()
            if ACTIVE_CHAT_EDIT_BOX ~= nil then
                if ACTIVE_CHAT_EDIT_BOX:GetText() ~= "" and ACTIVE_CHAT_EDIT_BOX:GetText() ~= prevText then
                    print("You are typing: " .. ACTIVE_CHAT_EDIT_BOX:GetText())
                else
                    print("You are not typing.")
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