local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local GeminiMessageEvent = ReplicatedStorage:WaitForChild("GeminiMessageEvent")

local function displayMessage(text)
	local channel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
	if channel then
		channel:DisplaySystemMessage("[??] Gemini: " .. text)
	else
		warn("Could not find chat channel")
	end
end

GeminiMessageEvent.OnClientEvent:Connect(displayMessage)