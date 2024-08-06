prevText = ""

local timerVar = C_Timer.NewTicker(1, function()
    if ACTIVE_CHAT_EDIT_BOX ~= nil then
        if ACTIVE_CHAT_EDIT_BOX:GetText() ~= "" and ACTIVE_CHAT_EDIT_BOX:GetText() ~= prevText then
            print("You are typing: " .. ACTIVE_CHAT_EDIT_BOX:GetText())
        else
            print("You are not typing.")
        end
        prevText = ACTIVE_CHAT_EDIT_BOX:GetText()
    end
end)