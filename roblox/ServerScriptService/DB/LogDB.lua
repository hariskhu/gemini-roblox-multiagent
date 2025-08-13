local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeminiMessageEvent = ReplicatedStorage:WaitForChild("GeminiMessageEvent")

local MAX_ATTEMPTS = 10
local DELAY = 6
local API_KEY = ""
local API_URL = "https://gemini-roblox-multiagent.onrender.com"

repeat
	print("Attempting to get DB secret...")
	keySuccess, logApiKey = pcall(function()
		return HttpService:GetSecret("LOG_DB_API_KEY")
	end)
	print("Got secret:", keySuccess, logApiKey)
	if not keySuccess or not logApiKey then
		return "Error: Failed to get DB API key - " .. (logApiKey or "Unknown error")
	end
	task.wait(2) -- Prevent rapid secret retrieval
	API_KEY = logApiKey
until API_KEY ~= ""

local LogDB = {}

function LogDB.waitForAPI()
	for _, player in ipairs(game.Players:GetPlayers()) do
		GeminiMessageEvent:FireClient(player, "Please wait for the logging service to activate before we start our conversation (up to 60 seconds).")
	end
	for attempt = 1, MAX_ATTEMPTS do
		local success, response = pcall(function()
			return HttpService:GetAsync(API_URL)
		end)
		if success and response == '{"message":"Database API is running!"}\n' then
			print("API is awake!")
			return true
		else
			print("Waiting for API... attempt", attempt)
			task.wait(DELAY)
		end
	end
	for _, player in pairs(game.Players:GetPlayers()) do
		-- add log event for DB API "sleepiness"
		player:Kick("Logging service failed to start, please join again.")
	end
	return false
end

-- Logging functions
function LogDB.debugHeaders()
	local url = API_URL .. "/debug_headers"
	local payload = {
		message = "hi"
	}
	local requestOptions = {
		Url = url,
		Method = "POST",
		Headers = {
			["X-Log-Db-Api-Key"] = API_KEY,
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync(requestOptions)
	end)

	if success and response.Success then
		local data = HttpService:JSONDecode(response.Body)
		return data
	else
		return "Error: HTTP request failed - " .. (response and response.StatusMessage or "Unknown error")
	end
end

function LogDB.testSession(new_guid)
	local url = API_URL .. "/create_test_session"
	local payload = {
		guid = new_guid
	}
	local requestOptions = {
		Url = url,
		Method = "POST",
		Headers = {
			["X-Log-Db-Api-Key"] = API_KEY,
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync(requestOptions)
	end)

	if success and response.Success then
		local data = HttpService:JSONDecode(response.Body)
		return data.session_id
	else
		return "Error: HTTP request failed - " .. (response and response.StatusMessage or "Unknown error")
	end
end

function LogDB.newSession(new_guid)
	local url = API_URL .. "/create_session"
	local payload = {
		guid = new_guid
	}
	local requestOptions = {
		Url = url,
		Method = "POST",
		Headers = {
			["X-Log-Db-Api-Key"] = API_KEY,
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync(requestOptions)
	end)

	if success and response.Success then
		local data = HttpService:JSONDecode(response.Body)
		return data.session_id
	else
		return "Error: HTTP request failed - " .. (response and response.StatusMessage or "Unknown error")
	end
end

function LogDB.addEvent(sessionId, event)
	local url = API_URL .. "/add_event/" .. sessionId
	local payload = event
	local requestOptions = {
		Url = url,
		Method = "POST",
		Headers = {
			["X-Log-Db-Api-Key"] = API_KEY,
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync(requestOptions)
	end)

	if success and response.Success then
		local data = HttpService:JSONDecode(response.Body)
		return data
	else
		return "Error: HTTP request failed - " .. (response and response.StatusMessage or "Unknown error")
	end
end

function LogDB.addLog(sessionId, log)
	local url = API_URL .. "/add_log/" .. sessionId
	local payload = log
	local requestOptions = {
		Url = url,
		Method = "POST",
		Headers = {
			["X-Log-Db-Api-Key"] = API_KEY,
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync(requestOptions)
	end)

	if success and response.Success then
		local data = HttpService:JSONDecode(response.Body)
		return data
	else
		return "Error: HTTP request failed - " .. (response and response.StatusMessage or "Unknown error")
	end
end

return LogDB