local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeminiMessageEvent = ReplicatedStorage:WaitForChild("GeminiMessageEvent")

local PromptBuilder = require(game.ServerScriptService.AI.PromptBuilder)
local GeminiActions = require(game.ServerScriptService.AI.GeminiActions)
local EventLogger = require(game.ServerScriptService.DB.EventLogger)

local Gemini = {}

local API_KEY = ""
local keySuccess = false

repeat
	print("Attempting to get secret...")
	keySuccess, API_KEY = pcall(function()
		return HttpService:GetSecret("GEMINI_API_KEY")
	end)
	print("Got secret:", keySuccess, API_KEY)
	if not keySuccess or not API_KEY then
		return "Error: Failed to get API key - " .. (API_KEY or "Unknown error")
	end
	task.wait(2) -- Prevent rapid secret retrieval
until API_KEY ~= ""
	
function Gemini.queryFullJSON(prompt)
	-- API endpoint for Gemini 2.0 Flash
	local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
	local payload = {
		contents = {
			{
				parts = {
					{ text = prompt }
				}
			}
		}
	}
	local requestOptions = {
		Url = url,
		Method = "POST",
		Headers = {
			["x-goog-api-key"] = API_KEY,
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(payload)
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync(requestOptions)
	end)

	if success and response.Success then
		return response
	else
		return "Error: HTTP request failed - " .. (response and response.StatusMessage or "Unknown error")
	end
end

function Gemini.query(prompt)
	local response = Gemini.queryFullJSON(prompt)
	if response.Success then
		local data = HttpService:JSONDecode(response.Body)
		local content = data.candidates and data.candidates[1] and data.candidates[1].content and data.candidates[1].content.parts and data.candidates[1].content.parts[1] and data.candidates[1].content.parts[1].text
		if content then
			return content
		else
			warn("Error: No valid response from Gemini API")
			return "[ERROR]"
		end
	else
		warn("Error: HTTP request failed - " .. (response and response.StatusMessage or "Unknown error"))
		return "[ERROR]"
	end
end

function Gemini.getActions(prompt)
	local rawResponse = Gemini.query(prompt)
	local success, decoded = pcall(function()
		return HttpService:JSONDecode(string.sub(rawResponse, 8, #rawResponse - 3))
	end)
	if not success then
		warn("[Gemini] Failed to decode JSON: ", decoded)
	end

	return decoded.actions, decoded.chat_message
end

function Gemini.sendMessage(msg)
	for _, player in ipairs(game.Players:GetPlayers()) do
		GeminiMessageEvent:FireClient(player, msg)
	end
	table.insert(EventLogger.log, {
		type = "chat",
		player = "[??] Gemini",
		message = msg,
		time = os.time()
	})
end

-- Helper function to count request parameters
local function countKeys(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count += 1
	end
	return count
end

function Gemini.handleActionRequest(request)
	local requestParamNum = countKeys(request.parameters)
	for _, action in ipairs(GeminiActions.catalog) do
		if action.action_id == request.action_id then
			if #action.parameters ~= requestParamNum then
				table.insert(EventLogger.log, {
					type = "action_error",
					action_id = request.action_id,
					errorMessage = string.format("incorrect number of parameters: expected %d, got %d", #action.parameters, requestParamNum),
					time = os.time()
				})
				return
			end
			
			for r_param_name, val in pairs(request.parameters) do
				local foundParam = false
				for _, a_param in ipairs(action.parameters) do
					if a_param.name == r_param_name then
						foundParam = true
					end
				end
				if not foundParam then
					table.insert(EventLogger.log, {
						type = "action_error",
						action_id = request.action_id,
						errorMessage = "at least one incorrectly labeled parameter",
						time = os.time()
					})
					EventLogger.newEvent = true
					return 
				end
			end
			
			-- Retrieve name of param, index hashmap for value
			local function p(i) return request.parameters[action.parameters[i].name] end
			local executionSwitch = {
				[1] = function() action.actionFunction(p(1)) end,
				[2] = function() action.actionFunction(p(1), p(2)) end,
				[3] = function() action.actionFunction(p(1), p(2), p(3)) end,
				[4] = function() action.actionFunction(p(1), p(2), p(3), p(4)) end,
				[5] = function() action.actionFunction(p(1), p(2), p(3), p(4), p(5)) end
			}
			
			if pcall(executionSwitch[requestParamNum]) then
				table.insert(EventLogger.log, {
					type = "action_success",
					action_id = request.action_id,
					time = os.time()
				})
			else 
				table.insert(EventLogger.log, {
					type = "action_error",
					action_id = request.action_id,
					errorMessage = "unknown error",
					time = os.time()
				})
			end
			EventLogger.newEvent = true
			return
		end
	end
end

return Gemini