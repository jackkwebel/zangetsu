-- ========================
--   AUTO START SYSTEM
-- ========================

local function TriggerGameStart()
	local success, err = pcall(function()
		-- Get selected values
		local gameType = Options.AutoStartType.CurrentValue[1] or "Missions"
		local map = Options.AutoStartMap.CurrentValue[1]
		local objective = Options.AutoStartObjective.CurrentValue[1]
		local difficulty = Options.AutoStartDifficulty.CurrentValue[1]
		local modifiers = Options.AutoStartModifiers.CurrentValue or {}
		
		if not map or not objective or not difficulty then
			Rayfield:Notify({
				Title = "Auto Start",
				Content = "Missing required settings! Select Type, Map, Objective, and Difficulty.",
				Duration = 4
			})
			return
		end

		-- Find and trigger the remote that starts the game
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if not remotes then
			error("Remotes folder not found")
		end

		-- Look for game start related remotes
		local startRemote = remotes:FindFirstChild("StartGame")
			or remotes:FindFirstChild("Start")
			or remotes:FindFirstChild("PlayGame")
			or remotes:FindFirstChild("BeginMatch")
			or remotes:FindFirstChild("SelectGameMode")

		if not startRemote then
			error("Start remote not found")
		end

		-- Build the game configuration
		local gameConfig = {
			Type = gameType,
			Map = map,
			Objective = objective,
			Difficulty = difficulty,
			Modifiers = modifiers
		}

		-- Fire the remote with the configuration
		if startRemote:IsA("RemoteEvent") then
			startRemote:FireServer(gameConfig)
		elseif startRemote:IsA("RemoteFunction") then
			startRemote:InvokeServer(gameConfig)
		else
			error("Remote is not a valid type")
		end

		Rayfield:Notify({
			Title = "Auto Start",
			Content = "Starting " .. gameType .. " - " .. map .. " (" .. difficulty .. ")",
			Duration = 3
		})
	end)

	if not success then
		Rayfield:Notify({
			Title = "Auto Start Error",
			Content = "Failed to start game: " .. tostring(err),
			Duration = 4
		})
	end
end

local autoStartActive = false

local function StartAutoStart()
	if autoStartActive then return end
	autoStartActive = true

	local delaySeconds = Options.StartAfterXSeconds.CurrentValue or 0

	task.spawn(function()
		while autoStartActive and Options.AutoStartToggle.CurrentValue do
			if delaySeconds > 0 then
				task.wait(delaySeconds)
			end

			if autoStartActive and Options.AutoStartToggle.CurrentValue then
				TriggerGameStart()
			end
			break
		end
	end)
end

local function StopAutoStart()
	autoStartActive = false
end
