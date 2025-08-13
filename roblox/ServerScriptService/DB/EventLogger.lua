local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local logEvent = ReplicatedStorage:WaitForChild("LogChatEvent")

local EventLogger = {}

EventLogger.log = {}
EventLogger.shortTermSummary = ""
EventLogger.longTermSummary = ""
EventLogger.newEvent = false

function EventLogger.getPlayerInfo()
	local playerListStr = ""
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoid then
				local name = player.DisplayName
				local currentHealth = humanoid.Health
				local maxHealth = humanoid.MaxHealth
				local position = rootPart.Position
				playerListStr = playerListStr .. string.format("\t- Name: %s | Health: %d/%d | Position: (%.2f, %.2f, %.2f)\n", name, currentHealth, maxHealth, position.X, position.Y, position.Z)
			else
				playerListStr = playerListStr .. string.format("\t- %s does not have a Humanoid.\n", player.DisplayName)
			end
		else
			playerListStr = playerListStr .. string.format("\t- %s does not have a Character loaded.\n", player.DisplayName)
		end
	end
	return playerListStr
end

local function logChat(player, message)
	table.insert(EventLogger.log, {
		type = "chat",
		player = player.DisplayName,
		message = message,
		time = os.time()
	})
	EventLogger.newEvent = true
end

logEvent.OnServerEvent:Connect(logChat)

-- Fires when a player joins
Players.PlayerAdded:Connect(function(player)
	table.insert(EventLogger.log, {
		type = "join",
		player = player.DisplayName,
		time = os.time()
	})
	EventLogger.newEvent = true

	-- Track when the player's character loads
	player.CharacterAdded:Connect(function(character)

		-- Track when they die
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			table.insert(EventLogger.log, {
				type = "death",
				player = player.DisplayName,
				time = os.time()
			})
		end)
		EventLogger.newEvent = true
	end)
end)

-- Fires when a player leaves
Players.PlayerRemoving:Connect(function(player)
	table.insert(EventLogger.log, {
		type = "leave",
		player = player.DisplayName,
		time = os.time()
	})
	EventLogger.newEvent = true
	if #Players:GetPlayers() == 1 then
		table.insert(EventLogger.log, {
			type = "session_end",
			time = os.time()
		})
	end
end)

function EventLogger.buildEventLogString()
	local logString = ""
	for _, event in ipairs(EventLogger.log) do
		local timestamp = os.date("%X", event.time)
		if event.type == "chat" then
			logString ..= string.format("[%s] %s: %s\n", timestamp, event.player, event.message)
		elseif event.type == "action_success" then
			logString ..= string.format("[%s] Action `%s` executed successfully.\n", timestamp, event.action_id)
		elseif event.type == "action_error" then
			EventLogger.newEvent = true
			logString ..= string.format("[%s] Action `%s` failed: %s.\n", timestamp, event.action_id, event.errorMessage)
		elseif event.type == "kill" then
			logString ..= string.format("[%s] %s killed %s\n.", timestamp, event.killer, event.victim)
		elseif event.type == "death" then
			logString ..= string.format("[%s] %s died.\n", timestamp, event.player)
		elseif event.type == "join" then
			logString ..= string.format("[%s] %s joined the game.\n", timestamp, event.player)
		elseif event.type == "leave" then
			logString ..= string.format("[%s] %s left the game.\n", timestamp, event.player)
		elseif event.type == "session_start" then
			logString ..= string.format("[%s] Server started.\n", timestamp)
		elseif event.type == "session_end" then
			logString ..= string.format("[%s] Server close.\n", timestamp)
		end
	end

	return logString
end

return EventLogger