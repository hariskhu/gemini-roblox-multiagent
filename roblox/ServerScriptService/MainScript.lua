local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local PromptBuilder = require(game.ServerScriptService.AI.PromptBuilder)
local Gemini = require(game.ServerScriptService.AI.GeminiModule)
local EventLogger = require(game.ServerScriptService.DB.EventLogger)
local LogDB = require(game.ServerScriptService.DB.LogDB)

EventLogger.shortTermSummary = ""
EventLogger.longTermSummary = "[NO LONG-TERM SUMMARY]"

-- Will kick everyone from the server if the DB API isn't ready
local guid = HttpService:GenerateGUID(false)
local DBAwake = LogDB.waitForAPI()
local sessionId = LogDB.newSession(guid)

while DBAwake do
	if EventLogger.newEvent then
		local mainPrompt = PromptBuilder.buildMainPrompt()
		local geminiActions, geminiChatMessage = Gemini.getActions(mainPrompt)
		
		if geminiActions ~= nil and geminiChatMessage ~= nil then
			Gemini.sendMessage(geminiChatMessage)
			
			for _, request in ipairs(geminiActions) do
				Gemini.handleActionRequest(request)
			end
			
			if #EventLogger.shortTermSummary > 3000 then
				local ltsPrompt = PromptBuilder.buildLtsPrompt()
				local ltsResponse = Gemini.query(ltsPrompt)
				if ltsResponse ~= "[ERROR]" then
					EventLogger.longTermSummary = ltsResponse
					EventLogger.shortTermSummary = ""
					LogDB.addEvent(sessionId, {
						type = "new_lts",
						summary = EventLogger.longTermSummary,
						time = os.time()
					})
				end
			end
			
			EventLogger.newEvent = false
			local stsPrompt = PromptBuilder.buildStsPrompt()
			local stsResponse = Gemini.query(stsPrompt)
			if stsResponse ~= "[ERROR]" then
				EventLogger.shortTermSummary ..= "- " .. stsResponse
				LogDB.addLog(sessionId, EventLogger.log)
				EventLogger.log = {}
				LogDB.addEvent(sessionId, {
					type = "new_sts",
					summary = EventLogger.shortTermSummary,
					time = os.time()
				})
			end
		end
	end
	task.wait(15)
end