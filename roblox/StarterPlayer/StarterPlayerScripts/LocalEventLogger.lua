print("Event logger LocalScript started", script:GetFullName())

local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local logEvent = ReplicatedStorage:WaitForChild("LogChatEvent")
local localPlayer = Players.LocalPlayer

TextChatService.OnIncomingMessage = function(message)
	if message.TextSource and message.TextSource.UserId == localPlayer.UserId then
		if message.Status == Enum.TextChatMessageStatus.Success then
			logEvent:FireServer(message.Text)
		end
	end
end