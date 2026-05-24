-- Zangetsu Hub by deivid (modified)

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- !! YOUR HUB URL - used for auto-execute on teleport !!
local HUB_SCRIPT_URL = "https://raw.githubusercontent.com/jackkwebel/zangetsu/main/zangetsu.lua"

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Zangetsu Hub",
	Footer = "AOT:R",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Universal queue_on_teleport wrapper
local function QueueOnTeleport(code)
	if syn and syn.queue_on_teleport then
		local ok = pcall(syn.queue_on_teleport, code)
		if ok then return true end
	end
	if queue_on_teleport then
		local ok = pcall(queue_on_teleport, code)
		if ok then return true end
	end
	if fluxus and fluxus.queue_on_teleport then
		local ok = pcall(fluxus.queue_on_teleport, code)
		if ok then return true end
	end
	return false
end

-- ========================
--   RETURN TO LOBBY LOGIC
-- ========================

local function ReturnToLobby()
	local success, err = pcall(function()
		-- Try common remote names first
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local returnRemote = remotes:FindFirstChild("ReturnToLobby") 
				or remotes:FindFirstChild("Return") 
				or remotes:FindFirstChild("BackToLobby")
				or remotes:FindFirstChild("Lobby")
			
			if returnRemote and returnRemote:IsA("RemoteEvent") then
				returnRemote:FireServer()
				return
			end
		end
		
		-- Fallback: teleport to start place (lobby)
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end)
	
	if not success then
		warn("[Zangetsu Hub] Return to Lobby failed: " .. tostring(err))
		Library:Notify({
			Title = "Error",
			Description = "Failed to return to lobby!",
			Time = 4,
		})
	end
end

-- ========================
--   FAILSAFE SYSTEM
-- ========================

local failsafeConnections = {}
local lastActivity = tick()
local lastPosition = Vector3.new()

local function ResetIdleTimer()
	lastActivity = tick()
end

local function GetCharacterParts()
	local char = LocalPlayer.Character
	if not char then return nil, nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChild("Humanoid")
	return hrp, humanoid
end

local function StartFailsafe()
	-- Clear old connections
	for _, conn in ipairs(failsafeConnections) do
		conn:Disconnect()
	end
	failsafeConnections = {}
	
	ResetIdleTimer()
	local hrp, humanoid = GetCharacterParts()
	if hrp then lastPosition = hrp.Position end
	
	-- Track movement
	table.insert(failsafeConnections, RunService.Heartbeat:Connect(function()
		if not Toggles.Failsafe.Value then return end
		
		local currentHRP, currentHumanoid = GetCharacterParts()
		if not currentHRP or not currentHumanoid then return end
		
		local currentPos = currentHRP.Position
		local distance = (currentPos - lastPosition).Magnitude
		
		-- Reset if moved significantly or has input direction
		if distance > 0.5 or currentHumanoid.MoveDirection.Magnitude > 0 then
			ResetIdleTimer()
			lastPosition = currentPos
		end
	end))
	
	-- Track input
	table.insert(failsafeConnections, UserInputService.InputBegan:Connect(function()
		if Toggles.Failsafe.Value then
			ResetIdleTimer()
		end
	end))
	
	-- Main timer loop
	task.spawn(function()
		while Toggles.Failsafe.Value do
			task.wait(1)
			if not Toggles.Failsafe.Value then break end
			
			local timeoutSeconds = (Options.FailsafeTimeout and Options.FailsafeTimeout.Value or 10) * 60
			local idleTime = tick() - lastActivity
			
			if idleTime >= timeoutSeconds then
				Library:Notify({
					Title = "Failsafe Triggered",
					Description = "Idle for " .. tostring(Options.FailsafeTimeout.Value) .. " min. Returning to lobby...",
					Time = 5,
				})
				
				task.wait(2)
				ReturnToLobby()
				break
			end
		end
	end)
end

local function StopFailsafe()
	for _, conn in ipairs(failsafeConnections) do
		conn:Disconnect()
	end
	failsafeConnections = {}
end

-- Reset on respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
	task.wait(0.5)
	local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
	if hrp then lastPosition = hrp.Position end
	if Toggles.Failsafe.Value then
		ResetIdleTimer()
	end
end)

-- ========================
--        MAIN TAB
-- ========================

local Tabs = {
	Main     = Window:AddTab("Main",     "user"),
	Utility  = Window:AddTab("Utility",  "wrench"),
	Global   = Window:AddTab("Global",   "globe"),
	Settings = Window:AddTab("Settings", "settings"),
}

local MapObjectives = {
	["Shiganshina"] = { "Skirmish", "Breach" },
	["Trost"]       = { "Skirmish", "Protect" },
	["Outskirts"]   = { "Skirmish", "Protect" },
	["Forest"]      = { "Skirmish", "Guard" },
	["Stohess"]     = { "Skirmish" },
	["Chapel"]      = { "Skirmish" },
}

local MiscGroup = Tabs.Main:AddLeftGroupbox("Misc", "layout-grid")

MiscGroup:AddButton({
	Text = "Return to Lobby",
	Func = function()
		ReturnToLobby()
	end,
})

MiscGroup:AddButton({
	Text = "Check Shadow Ban (Lobby)",
	Func = function()
		-- functionality later
	end,
})

MiscGroup:AddButton({
	Text = "Join Discord",
	Func = function()
		-- functionality later
	end,
})

local AutomationGroup = Tabs.Main:AddLeftGroupbox("Automation", "cpu")

AutomationGroup:AddToggle("AutoFarm", {
	Text = "Auto Farm",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AutomationGroup:AddToggle("AutoFarmRaids", {
	Text = "Auto Farm Raids",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AutomationGroup:AddToggle("AutoRetry", {
	Text = "Auto Retry",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AutomationGroup:AddToggle("SoloOnly", {
	Text = "Solo Only",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AutomationGroup:AddToggle("AutoReturnToLobby", {
	Text = "Auto Return to Lobby",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AutomationGroup:AddSlider("ReturnAfterXGames", {
	Text = "Return to lobby after x games",
	Default = 10,
	Min = 1,
	Max = 250,
	Rounding = 0,
	Callback = function(Value)
		-- functionality later
	end,
})

AutomationGroup:AddToggle("AutoStartToggle", {
	Text = "Auto Start",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AutomationGroup:AddSlider("StartAfterXSeconds", {
	Text = "Start after x seconds",
	Default = 0,
	Min = 0,
	Max = 500,
	Rounding = 0,
	Callback = function(Value)
		-- functionality later
	end,
})

local MovementGroup = Tabs.Main:AddRightGroupbox("Movement", "move")

MovementGroup:AddDropdown("MovementMode", {
	Values = { "Teleport", "Fly" },
	Default = 1,
	Multi = false,
	Text = "Movement Mode",
	Callback = function(Value)
		-- functionality later
	end,
})

MovementGroup:AddSlider("HoverSpeed", {
	Text = "Hover Speed",
	Default = 400,
	Min = 0,
	Max = 500,
	Rounding = 0,
	Callback = function(Value)
		-- functionality later
	end,
})

MovementGroup:AddSlider("FloatHeight", {
	Text = "Float Height",
	Default = 300,
	Min = 0,
	Max = 300,
	Rounding = 0,
	Callback = function(Value)
		-- functionality later
	end,
})

local AutoStartGroup = Tabs.Main:AddRightGroupbox("Auto Start", "play")

local MissionMaps       = { "Shiganshina", "Trost", "Outskirts", "Forest", "Stohess", "Chapel" }
local RaidMaps          = { "Trost", "Shiganshina", "Stohess", "Colossal" }
local DifficultyOptions = { "Easy", "Normal", "Hard", "Severe", "Aberrant", "Hardest" }
local ModifierOptions   = { "No Skills", "No Talents", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Canon", "Time Trial", "Boring", "Simple" }
local RAID_TITAN_TEXT   = "Trost: Attack Titan\nShiganshina: Armored Titan\nStohess: Female Titan\nColossal: Colossal Titan"

local RaidTitanLabel = nil

AutoStartGroup:AddDropdown("AutoStartType", {
	Values = { "Missions", "Raids" },
	Default = 1,
	Multi = false,
	Text = "Type",
	Callback = function(Value)
		if Value == "Missions" then
			Options.AutoStartMap:SetValues(MissionMaps)
			Options.AutoStartMap:SetValue(MissionMaps[1])
			local objectives = MapObjectives[MissionMaps[1]] or { "Skirmish" }
			Options.AutoStartObjective:SetValues(objectives)
			Options.AutoStartObjective:SetValue(objectives[1])
			if RaidTitanLabel then RaidTitanLabel:SetText("") end
		else
			Options.AutoStartMap:SetValues(RaidMaps)
			Options.AutoStartMap:SetValue(RaidMaps[1])
			local objectives = MapObjectives[RaidMaps[1]] or { "Skirmish" }
			Options.AutoStartObjective:SetValues(objectives)
			Options.AutoStartObjective:SetValue(objectives[1])
			if RaidTitanLabel then RaidTitanLabel:SetText(RAID_TITAN_TEXT) end
		end
	end,
})

AutoStartGroup:AddDropdown("AutoStartMap", {
	Values = MissionMaps,
	Default = 1,
	Multi = false,
	Text = "Map",
	Callback = function(Value)
		local objectives = MapObjectives[Value] or { "Skirmish" }
		Options.AutoStartObjective:SetValues(objectives)
		Options.AutoStartObjective:SetValue(objectives[1])
	end,
})

AutoStartGroup:AddDropdown("AutoStartObjective", {
	Values = MapObjectives["Shiganshina"],
	Default = 1,
	Multi = false,
	Text = "Objective",
	Callback = function(Value)
		-- functionality later
	end,
})

AutoStartGroup:AddDropdown("AutoStartDifficulty", {
	Values = DifficultyOptions,
	Default = 1,
	Multi = false,
	Text = "Difficulty",
	Callback = function(Value)
		-- functionality later
	end,
})

RaidTitanLabel = AutoStartGroup:AddLabel("", true)

AutoStartGroup:AddDivider()

AutoStartGroup:AddDropdown("AutoStartModifiers", {
	Values = ModifierOptions,
	Default = 1,
	Multi = true,
	Text = "Modifiers",
	Callback = function(Value)
		-- functionality later
	end,
})

AutoStartGroup:AddToggle("MaxRewardModifier", {
	Text = "Max Reward Modifier",
	Tooltip = "Selects all modifiers except Boring and Simple",
	Default = false,
	Callback = function(Value)
		if Value then
			Options.AutoStartModifiers:SetValue({
				["No Skills"] = true,
				["No Talents"] = true,
				["Nightmare"] = true,
				["Oddball"] = true,
				["Injury Prone"] = true,
				["Chronic Injuries"] = true,
				["Fog"] = true,
				["Glass Canon"] = true,
				["Time Trial"] = true,
			})
		else
			Options.AutoStartModifiers:SetValue({})
		end
	end,
})

-- ========================
--      UTILITY TAB
-- ========================

-- LEFT SIDE: Combat Settings
local CombatGroup = Tabs.Utility:AddLeftGroupbox("Combat Settings", "sword")

CombatGroup:AddToggle("AutoRefill", {
	Text = "Auto Reload/Refill",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

CombatGroup:AddToggle("AutoEscape", {
	Text = "Auto Escape",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

CombatGroup:AddToggle("MultiHit", {
	Text = "Multi Hit",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

CombatGroup:AddSlider("TitansPerHit", {
	Text = "Titans per hit",
	Default = 3,
	Min = 1,
	Max = 20,
	Rounding = 0,
	Callback = function(Value)
		-- functionality later
	end,
})

-- LEFT SIDE: Security
local SecurityGroup = Tabs.Utility:AddLeftGroupbox("Security", "shield")

SecurityGroup:AddToggle("Failsafe", {
	Text = "Failsafe",
	Default = false,
	Callback = function(Value)
		if Value then
			StartFailsafe()
			Library:Notify({
				Title = "Failsafe",
				Description = "Enabled! Will return to lobby after " .. Options.FailsafeTimeout.Value .. " min of idle time.",
				Time = 4,
			})
		else
			StopFailsafe()
			Library:Notify({
				Title = "Failsafe",
				Description = "Disabled.",
				Time = 3,
			})
		end
	end,
})

SecurityGroup:AddSlider("FailsafeTimeout", {
	Text = "Timeout",
	Default = 10,
	Min = 1,
	Max = 20,
	Rounding = 0,
	Suffix = " min",
	Callback = function(Value)
		if Toggles.Failsafe.Value then
			ResetIdleTimer()
			Library:Notify({
				Title = "Failsafe",
				Description = "Timeout updated to " .. Value .. " min. Timer reset.",
				Time = 3,
			})
		end
	end,
})

-- RIGHT SIDE: Mastery Farm
local MasteryFarmGroup = Tabs.Utility:AddRightGroupbox("Mastery Farm", "zap")

MasteryFarmGroup:AddToggle("TitanMasteryFarm", {
	Text = "Titan Mastery Farm",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

MasteryFarmGroup:AddDropdown("MasteryMode", {
	Values = { "Both", "ODM", "Titan" },
	Default = 1,
	Multi = false,
	Text = "Mastery Mode",
	Callback = function(Value)
		-- functionality later
	end,
})

-- RIGHT SIDE: Extras
local ExtrasGroup = Tabs.Utility:AddRightGroupbox("Extras", "star")

ExtrasGroup:AddToggle("AutoSkipCutscenes", {
	Text = "Auto Skip Cutscenes",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

ExtrasGroup:AddToggle("DieAtStreak", {
	Text = "Die at Streak",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

ExtrasGroup:AddSlider("DieAtXStreak", {
	Text = "Die at x streak",
	Default = 10000,
	Min = 5000,
	Max = 100000,
	Rounding = 0,
	Callback = function(Value)
		-- functionality later
	end,
})

ExtrasGroup:AddToggle("AutoOpenChests", {
	Text = "Auto Open Chests",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

ExtrasGroup:AddToggle("AutoOpen2ndChest", {
	Text = "Auto Open 2nd Chest",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

ExtrasGroup:AddToggle("DeleteMap", {
	Text = "Delete Map (FPS Boost)",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

-- ========================
--    GLOBAL TAB (empty)
-- ========================

-- ========================
--      SETTINGS TAB
-- ========================

local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

-- Auto Execute (built-in, no executor autoexec folder needed)
local AutoExecGroup = Tabs.Settings:AddLeftGroupbox("Auto Execute", "play-circle")

AutoExecGroup:AddToggle("AutoExecEnabled", {
	Text = "Auto Execute",
	Tooltip = "Automatically re-runs this hub every time you teleport to a new server. No executor autoexec folder required.",
	Default = false,
	Callback = function(Value)
		if Value then
			local ok = QueueOnTeleport('loadstring(game:HttpGet("' .. HUB_SCRIPT_URL .. '"))()')
			if ok then
				Library:Notify({
					Title = "Auto Execute",
					Description = "Enabled! Hub will auto-run on every teleport.",
					Time = 4,
				})
			else
				Library:Notify({
					Title = "Auto Execute",
					Description = "Your executor doesn't support queue_on_teleport.",
					Time = 4,
				})
				task.delay(0.1, function()
					if Options.AutoExecEnabled then
						Options.AutoExecEnabled:SetValue(false)
					end
				end)
			end
		else
			Library:Notify({
				Title = "Auto Execute",
				Description = "Disabled. Hub will not auto-run on teleport.",
				Time = 3,
			})
		end
	end,
})

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
	StopFailsafe()
	print("Unloaded!")
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("ZangetsuHub")
SaveManager:SetFolder("ZangetsuHub/AOT-R")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

-- If Auto Execute was enabled in saved config, re-queue for next teleport
task.delay(0.5, function()
	if Options.AutoExecEnabled and Options.AutoExecEnabled.Value then
		QueueOnTeleport('loadstring(game:HttpGet("' .. HUB_SCRIPT_URL .. '"))()')
	end
end)
