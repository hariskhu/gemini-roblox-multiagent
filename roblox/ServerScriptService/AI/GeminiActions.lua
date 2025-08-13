local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GeminiActions = {}

local function getPlayerObject(player_id)
	for _, player in pairs(Players:GetPlayers()) do
		if string.lower(player.DisplayName) == string.lower(player_id) then
			return player
		end
	end
end

GeminiActions.catalog = {
	{
		action_id = "fling_player",
		description = "Launches a player into the air with customizable force.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" },
			{ name = "force", type = "number", description = "Force multiplier for the fling (default is 1)" }
		},
		actionFunction = (function(player_id, force)
			local player = getPlayerObject(player_id)
			
			local character = player.Character
			if not character then return false end
			
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end

			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return false end
			
			if humanoid.Sit then
				humanoid.Jump = true
				task.wait(0.1)
			end

			humanoid.Sit = true
			
			-- Create BodyVelocity to apply force
			local bodyVelocity = Instance.new("BodyVelocity")
			force *= 80
			bodyVelocity.Velocity = Vector3.new(
				math.random(-force, force),
				force,
				math.random(-force, force) 
			)
			bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bodyVelocity.P = 1e4 -- Responsiveness
			bodyVelocity.Parent = rootPart

			-- Remove BodyVelocity after a short delay to stop continuous flinging
			game:GetService("Debris"):AddItem(bodyVelocity, 0.3)
			return true
		end)
	},
	{
		action_id = "resize_player",
		description = "Resizes a player. Parameters are multipliers relative to normal dimensions (1 is normal, 0.5 is half, 2 is twice as large).",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" },
			{ name = "height", type = "number", description = "Height multiplier" },
			{ name = "width", type = "number", description = "Width multiplier" },
			{ name = "depth", type = "number", description = "Depth multiplier" },
			{ name = "head_scale", type = "number", description = "Head size multiplier" }
		},
		actionFunction = (function(player_id, height, width, depth, head_scale)
			local player = getPlayerObject(player_id)
			
			if not player.Character or not player.Character:FindFirstChild("Humanoid") then
				return false
			end

			local humanoid = player.Character:FindFirstChild("Humanoid")

			-- Change scale values (must be done through HumanoidDescription for R15 rigs)
			local description = humanoid:WaitForChild("HumanoidDescription"):Clone()

			description.HeightScale = height -- default is 1
			description.WidthScale = width -- default is 1
			description.DepthScale = depth -- default is 1
			description.HeadScale = head_scale -- default is 1

			humanoid:ApplyDescription(description)
			return true
		end)
	},
	{
		action_id = "change_speed",
		description = "Reduces a player's movement speed. If the player's speed is increased, they will be returned to default speed.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" },
			{ name = "speed", type = "number", description = "New speed (default is 16)" }
		},
		actionFunction = (function(player_id, multiplier)
			local player = getPlayerObject(player_id)

			if not player.Character or not player.Character:FindFirstChild("Humanoid") then
				return false
			end

			local humanoid = player.Character:FindFirstChild("Humanoid")
			
			if humanoid.WalkSpeed > 16 then
				humanoid.WalkSpeed = 16
			else
				humanoid.WalkSpeed *= 0.75
			end
			
			return true
		end)
	},
	{
		action_id = "give_blaster",
		description = "Gives a player a laser blaster.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" }
		},
		actionFunction = (function(player_id)
			local player = getPlayerObject(player_id)
			
			if not player.Character or not player.Character:FindFirstChild("Humanoid") then
				return false
			end
			
			local item = ReplicatedStorage:FindFirstChild("Laser Blaster")

			if item and item:IsA("Tool") then
				local character = player.Character or player.CharacterAdded:Wait()
				local backpack = player:WaitForChild("Backpack")

				local newItem = item:Clone()
				newItem.Parent = backpack
				return true
			else
				return false
			end
		end)
	},
	{
		action_id = "give_sword",
		description = "Gives a player a sword.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" }
		},
		actionFunction = (function(player_id)
			local player = getPlayerObject(player_id)

			if not player.Character or not player.Character:FindFirstChild("Humanoid") then
				return false
			end

			local item = ReplicatedStorage:FindFirstChild("Sword")

			if item and item:IsA("Tool") then
				local character = player.Character or player.CharacterAdded:Wait()
				local backpack = player:WaitForChild("Backpack")

				local newItem = item:Clone()
				newItem.Parent = backpack
				return true
			else
				return false
			end
		end)
	},
	{
		action_id = "give_grappling_hook",
		description = "Gives a player a grappling hook.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" }
		},
		actionFunction = (function(player_id)
			local player = getPlayerObject(player_id)

			if not player.Character or not player.Character:FindFirstChild("Humanoid") then
				return false
			end

			local item = ReplicatedStorage:FindFirstChild("Grappling Hook")

			if item and item:IsA("Tool") then
				local character = player.Character or player.CharacterAdded:Wait()
				local backpack = player:WaitForChild("Backpack")

				local newItem = item:Clone()
				newItem.Parent = backpack
				return true
			else
				return false
			end
		end)
	},
	{
		action_id = "give_jetpack",
		description = "Gives a player a jetpack.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" }
		},
		actionFunction = (function(player_id)
			local player = getPlayerObject(player_id)

			if not player.Character or not player.Character:FindFirstChild("Humanoid") then
				return false
			end

			local item = ReplicatedStorage:FindFirstChild("Jetpack")

			if item and item:IsA("Tool") then
				local character = player.Character or player.CharacterAdded:Wait()
				local backpack = player:WaitForChild("Backpack")

				local newItem = item:Clone()
				newItem.Parent = backpack
				return true
			else
				return false
			end
		end)
	},
	{
		action_id = "give_basketball",
		description = "Gives a player a basketball.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" }
		},
		actionFunction = (function(player_id)
			local player = getPlayerObject(player_id)

			if not player.Character or not player.Character:FindFirstChild("Humanoid") then
				return false
			end

			local item = ReplicatedStorage:FindFirstChild("Basketball")

			if item and item:IsA("Tool") then
				local character = player.Character or player.CharacterAdded:Wait()
				local backpack = player:WaitForChild("Backpack")

				local newItem = item:Clone()
				newItem.Parent = backpack
				return true
			else
				return false
			end
		end)
	},
	{
		action_id = "heal_player",
		description = "Heals a player.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player" },
			{ name = "amount", type = "number", description = "Amount of health to restore" }
		},
		actionFunction = (function(player_id, amount)
		local player = getPlayerObject()
			if player and player.Character then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = math.min(humanoid.Health + amount, humanoid.MaxHealth)
					return true
				end
			end
			return false
		end)
	},
	{
		action_id = "spawn_effect",
		description = "Applies a visual effect to a player.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player (optional if location is provided)" },
			{ name = "effect_name", type = "string", description = "Name of the effect ('Sparkles', 'Smoke', 'Fire', 'Magic')" }
		},
		actionFunction = (function(player_id, effect_name)
			local player = getPlayerObject(player_id)
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local root = character.HumanoidRootPart

				-- Remove existing particle effects
				for _, child in ipairs(root:GetChildren()) do
					if child:IsA("ParticleEmitter") then
						child:Destroy()
					end
				end
				
				effect_name = string.lower(effect_name)
				
				-- Create a new ParticleEmitter
				local particle = Instance.new("ParticleEmitter")
				particle.Name = "PlayerParticleEffect"
				particle.Rate = 20 -- Particles per second
				particle.Lifetime = NumberRange.new(1)
				particle.Speed = NumberRange.new(2)
				particle.Parent = root

				-- Customize based on effect type
				if effect_name == "fire" then
					particle.Texture = "rbxassetid://241594419" -- Fire particle texture
					particle.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
					particle.LightEmission = 0.8
					return true

				elseif effect_name == "sparkles" then
					particle.Texture = "rbxassetid://6490035158" -- Sparkle texture
					particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					particle.LightEmission = 1
					return true

				elseif effect_name == "smoke" then
					particle.Texture = "rbxassetid://258128463" -- Smoke texture
					particle.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
					particle.Lifetime = NumberRange.new(2)
					particle.Speed = NumberRange.new(1)
					return true
					
				elseif effect_name == "magic" then
					particle.Texture = "rbxassetid://284205403" -- Magic particle texture
					particle.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255), Color3.fromRGB(0, 255, 255))
					particle.Rate = 50
					particle.LightEmission = 0.5
					return true
					
				else
					warn("Unknown effect type:", effect_name)
					particle:Destroy()
					return false
				end
			end
		end)
	},
	{
		action_id = "change_gravity",
		description = "Changes the gravity for a specific player.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player." },
			{ name = "gravity", type = "number", description = "Gravity multiplier (1 is normal, 0.5 is half, 2 is double)" }
		},
		actionFunction = (function(player_id, gravity)
			local character = getPlayerObject(player_id)
			if character and character:FindFirstChild("HumanoidRootPart") then
				-- Remove existing custom gravity force if any
				local existingForce = character.HumanoidRootPart:FindFirstChild("CustomGravity")
				if existingForce then
					existingForce:Destroy()
				end
				
				local DEFAULT_GRAVITY = -196.2

				-- Create a new VectorForce to simulate custom gravity
				local gravityForce = Instance.new("VectorForce")
				gravityForce.Name = "CustomGravity"
				gravityForce.Force = Vector3.new(0, DEFAULT_GRAVITY * gravity * character.HumanoidRootPart.AssemblyMass, 0)
				gravityForce.RelativeTo = Enum.ActuatorRelativeTo.World
				gravityForce.Attachment0 = Instance.new("Attachment", character.HumanoidRootPart)
				gravityForce.Parent = character.HumanoidRootPart
			end
		end)
	},
	{
		action_id = "kill_player",
		description = "Kills a player.",
		parameters = {
			{ name = "player_id", type = "string", description = "Unique identifier of the target player." }
		},
		actionFunction = (function(player_id)
			local player = getPlayerObject()
			if player and player.Character then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = 0
					return true
				end
			end
			return false
		end)
	}
}

GeminiActions.catalogJSON = [[
[
    {
      "action_id": "fling_player",
      "description": "Launches a player into the air with customizable force.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 },
        { "name": "force", "type": "number", "description": "Force multiplier for the fling (default is 1)", "order": 2 }
      ]
    },
    {
      "action_id": "resize_player",
      "description": "Resizes a player. Parameters are multipliers relative to normal dimensions (1 is normal, 0.5 is half, 2 is twice as large).",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 },
        { "name": "height", "type": "number", "description": "Height multiplier", "order": 2 },
        { "name": "width", "type": "number", "description": "Width multiplier", "order": 3 },
        { "name": "depth", "type": "number", "description": "Depth multiplier", "order": 4 },
        { "name": "head_scale", "type": "number", "description": "Head size multiplier", "order": 5 }
      ]
    },
    {
      "action_id": "change_speed",
      "description": "Changes a player's movement speed (default is 16).",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 },
        { "name": "multiplier", "type": "number", "description": "Speed reduction multiplier (e.g., 0.5 for half speed, default is 0.5)", "order": 2 }
      ]
    },
    {
      "action_id": "give_blaster",
      "description": "Gives a player a laser blaster.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 }
      ]
    },
    {
      "action_id": "give_sword",
      "description": "Gives a player a sword.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 }
      ]
    },
    {
      "action_id": "give_grappling_hook",
      "description": "Gives a player a grappling hook.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 }
      ]
    },
    {
      "action_id": "give_jetpack",
      "description": "Gives a player a jetpack.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 }
      ]
    },
    {
      "action_id": "give_basketball",
      "description": "Gives a player a basketball.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 }
      ]
    },
    {
      "action_id": "heal_player",
      "description": "Heals a player.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 },
        { "name": "amount", "type": "number", "description": "Amount of health to restore", "order": 2 }
      ]
    },
    {
      "action_id": "spawn_effect",
      "description": "Spawns a visual effect at a player's location or specified position.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player", "order": 1 },
        { "name": "effect_name", "type": "string", "description": "Name of the effect ('Sparkles', 'Smoke', 'Fire', 'Magic')", "order": 2 }
      ]
    },
    {
      "action_id": "change_gravity",
      "description": "Changes the gravity for a specific player or the entire map.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player.", "order": 1 },
        { "name": "gravity", "type": "number", "description": "Gravity multiplier (1 is normal, 0.5 is half, 2 is double)", "order": 2 }
      ]
    },
    {
      "action_id": "kill_player",
      "description": "Kills a player.",
      "parameters": [
        { "name": "player_id", "type": "string", "description": "Unique identifier of the target player (optional for global change)", "order": 1 }
      ]
    }
]
]]

return GeminiActions