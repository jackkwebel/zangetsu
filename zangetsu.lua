-- Zangetsu Hub by deivid (modified) — Rayfield Edition with Custom Themes

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Prevent double-execution if injector fires twice
if getgenv().ZangetsuHubLoaded then return end
getgenv().ZangetsuHubLoaded = true

local HUB_SCRIPT_URL = "https://raw.githubusercontent.com/jackkwebel/zangetsu/main/zangetsu.lua"

local Window = Rayfield:CreateWindow({
	Name = "Zangetsu Hub",
	LoadingTitle = "Zangetsu Hub",
	LoadingSubtitle = "AOT:R",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = "ZangetsuHub",
		FileName = "AOT-R"
	},
	Discord = { Enabled = false, Invite = "", RememberJoins = true },
	KeySystem = false,
	KeySettings = {}
})

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Universal queue_on_teleport wrapper
local function QueueOnTeleport(code)
	if type(queue_on_teleport) == "function" then
		if pcall(queue_on_teleport, code) then return true end
	end
	if type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
		if pcall(syn.queue_on_teleport, code) then return true end
	end
	if type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" then
		if pcall(fluxus.queue_on_teleport, code) then return true end
	end
	if type(getgenv().queue_on_teleport) == "function" then
		if pcall(getgenv().queue_on_teleport, code) then return true end
	end
	return false
end

-- ========================
--   RETURN TO LOBBY LOGIC
-- ========================

local LOBBY_PLACE_ID = 6933311135

local function ReturnToLobby()
	local success, err = pcall(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local returnRemote = remotes:FindFirstChild("ReturnToLobby")
				or remotes:FindFirstChild("Return")
				or remotes:FindFirstChild("BackToLobby")
				or remotes:FindFirstChild("Lobby")
				or remotes:FindFirstChild("ToLobby")
				or remotes:FindFirstChild("TeleportToLobby")
			if returnRemote and (returnRemote:IsA("RemoteEvent") or returnRemote:IsA("RemoteFunction")) then
				if returnRemote:IsA("RemoteEvent") then returnRemote:FireServer()
				else returnRemote:InvokeServer() end
				Rayfield:Notify({ Title = "Return to Lobby", Content = "Teleporting to Town Central...", Duration = 3 })
				return
			end
		end
		Rayfield:Notify({ Title = "Return to Lobby", Content = "Teleporting to Town Central...", Duration = 3 })
		TeleportService:Teleport(LOBBY_PLACE_ID, LocalPlayer)
	end)
	if not success then
		Rayfield:Notify({ Title = "Error", Content = "Failed to return to lobby: " .. tostring(err), Duration = 4 })
	end
end

-- ========================
--   SHADOWBAN CHECKER
-- ========================

local function CheckShadowBan()
	local isBanned = false
	local reasons = {}

	for attrName, attrValue in pairs(LocalPlayer:GetAttributes()) do
		local lower = attrName:lower()
		if lower:find("ban") or lower:find("shadow") or lower:find("mute") then
			if attrValue == true or attrValue == "true" or attrValue == 1 then
				isBanned = true
				table.insert(reasons, "Attr: " .. attrName)
			end
		end
	end

	if isBanned then
		Rayfield:Notify({ Title = "⚠️ Shadowban Checker", Content = "SHADOW BANNED detected! Flags: " .. table.concat(reasons, ", "), Duration = 10 })
	else
		Rayfield:Notify({ Title = "✅ Shadowban Checker", Content = "No shadow ban detected.", Duration = 4 })
	end
end

-- ========================
--   FAILSAFE SYSTEM
-- ========================

local failsafeConnections = {}
local lastActivity = tick()
local lastPosition = Vector3.new()

local function ResetIdleTimer() lastActivity = tick() end

local function GetCharacterParts()
	local char = LocalPlayer.Character
	if not char then return nil, nil end
	return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
end

local function StartFailsafe()
	for _, conn in ipairs(failsafeConnections) do conn:Disconnect() end
	failsafeConnections = {}
	ResetIdleTimer()
	local hrp = GetCharacterParts()
	if hrp then lastPosition = hrp.Position end

	table.insert(failsafeConnections, RunService.Heartbeat:Connect(function()
		if not Options.Failsafe.CurrentValue then return end
		local currentHRP, currentHumanoid = GetCharacterParts()
		if not currentHRP or not currentHumanoid then return end
		local currentPos = currentHRP.Position
		if (currentPos - lastPosition).Magnitude > 0.5 or currentHumanoid.MoveDirection.Magnitude > 0 then
			ResetIdleTimer()
			lastPosition = currentPos
		end
	end))

	table.insert(failsafeConnections, UserInputService.InputBegan:Connect(function()
		if Options.Failsafe.CurrentValue then ResetIdleTimer() end
	end))

	task.spawn(function()
		while Options.Failsafe.CurrentValue do
			task.wait(1)
			if not Options.Failsafe.CurrentValue then break end
			local timeoutSeconds = (Options.FailsafeTimeout and Options.FailsafeTimeout.CurrentValue or 10) * 60
			if tick() - lastActivity >= timeoutSeconds then
				Rayfield:Notify({ Title = "Failsafe Triggered", Content = "Idle for " .. tostring(Options.FailsafeTimeout.CurrentValue) .. " min. Returning to lobby...", Duration = 5 })
				task.wait(2)
				ReturnToLobby()
				break
			end
		end
	end)
end

local function StopFailsafe()
	for _, conn in ipairs(failsafeConnections) do conn:Disconnect() end
	failsafeConnections = {}
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
	task.wait(0.5)
	local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
	if hrp then lastPosition = hrp.Position end
	if Options.Failsafe and Options.Failsafe.CurrentValue then ResetIdleTimer() end
end)

-- ========================
--   DELETE MAP SYSTEM
-- ========================

local mapStorage = Instance.new("Folder")
mapStorage.Name = "ZangetsuMapStorage"
mapStorage.Parent = ReplicatedStorage

local savedMapData = {}

local function IsCharacterOrNPC(obj)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and obj:IsDescendantOf(player.Character) then return true end
	end
	if obj:IsA("Humanoid") then return true end
	if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then return true end
	local current = obj.Parent
	while current and current ~= game.Workspace and current ~= game do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then return true end
		current = current.Parent
	end
	return false
end

local function IsInteractive(obj)
	if obj:FindFirstChildOfClass("ClickDetector") then return true end
	if obj:FindFirstChildOfClass("ProximityPrompt") then return true end
	if obj:IsA("Tool") or obj:IsA("Script") or obj:IsA("LocalScript") then return true end
	return false
end

local function DeleteMap()
	local terrain = game.Workspace:FindFirstChildOfClass("Terrain")
	if terrain then pcall(function() terrain:Clear() end) end
	for _, obj in ipairs(game.Workspace:GetDescendants()) do
		if obj.Parent == nil then continue end
		if not IsCharacterOrNPC(obj) and not IsInteractive(obj) and not obj:IsA("Camera") then
			if (obj:IsA("BasePart") and obj.Anchored) or obj:IsA("Model") then
				savedMapData[obj] = obj.Parent
				pcall(function() obj.Parent = mapStorage end)
			end
		end
	end
	Rayfield:Notify({ Title = "Delete Map", Content = "Map hidden. Humans, titans & UI kept.", Duration = 3 })
end

local function RestoreMap()
	local count = 0
	for obj, originalParent in pairs(savedMapData) do
		if obj and obj.Parent == mapStorage then
			pcall(function()
				obj.Parent = (originalParent and originalParent.Parent) and originalParent or game.Workspace
				count = count + 1
			end)
		end
	end
	savedMapData = {}
	Rayfield:Notify({ Title = "Delete Map", Content = "Map restored (" .. count .. " objects).", Duration = 3 })
end

-- ========================
--   3D RENDERING SYSTEM
-- ========================

local renderConnection = nil
local blackoutPart = nil

local function Disable3DRendering()
	pcall(function() RunService:Set3dRenderingEnabled(false) end)
	if blackoutPart then blackoutPart:Destroy() end
	if renderConnection then renderConnection:Disconnect() end
	blackoutPart = Instance.new("Part")
	blackoutPart.Size = Vector3.new(500, 500, 1)
	blackoutPart.Anchored = true
	blackoutPart.CanCollide = false
	blackoutPart.Transparency = 0
	blackoutPart.Color = Color3.new(0, 0, 0)
	blackoutPart.Parent = game.Workspace
	renderConnection = RunService.RenderStepped:Connect(function()
		if blackoutPart and blackoutPart.Parent then
			local cam = game.Workspace.CurrentCamera
			if cam then blackoutPart.CFrame = cam.CFrame * CFrame.new(0, 0, -10) end
		end
	end)
	Rayfield:Notify({ Title = "3D Rendering", Content = "Disabled.", Duration = 3 })
end

local function Enable3DRendering()
	pcall(function() RunService:Set3dRenderingEnabled(true) end)
	if renderConnection then renderConnection:Disconnect(); renderConnection = nil end
	if blackoutPart then blackoutPart:Destroy(); blackoutPart = nil end
	Rayfield:Notify({ Title = "3D Rendering", Content = "Restored.", Duration = 3 })
end

-- ========================
--        TABS
-- ========================

local Tabs = {
	Main     = Window:CreateTab("Main",     "user"),
	Utility  = Window:CreateTab("Utility",  "wrench"),
	Global   = Window:CreateTab("Global",   "globe"),
	Settings = Window:CreateTab("Settings", "settings"),
}

local Options = {}

-- ========================
--   CONFIG MANAGER ENGINE
-- ========================

local ConfigSystem = {}
ConfigSystem.Folder = "ZangetsuHub/Configs"
ConfigSystem.AutoloadFile = "ZangetsuHub/autoload_config.txt"

function ConfigSystem:EnsureFolder()
	pcall(function()
		if not isfolder("ZangetsuHub") then makefolder("ZangetsuHub") end
		if not isfolder(self.Folder) then makefolder(self.Folder) end
	end)
end

function ConfigSystem:CleanName(name)
	name = tostring(name or "")
	name = name:gsub("%s+", "")
	name = name:gsub("%z", "")
	return name
end

function ConfigSystem:FindFileExact(name)
	name = self:CleanName(name)
	if name == "" then return nil end
	local ok, files = pcall(listfiles, self.Folder)
	if not ok or type(files) ~= "table" then return nil end
	for _, filepath in ipairs(files) do
		if type(filepath) == "string" then
			local basename = filepath:match("([^/\\]+)%.json$")
			if basename and basename:lower() == name:lower() then return filepath end
		end
	end
	return nil
end

function ConfigSystem:List()
	local ok, files = pcall(listfiles, self.Folder)
	if not ok or type(files) ~= "table" then return {} end
	local names = {}
	for _, filepath in ipairs(files) do
		if type(filepath) == "string" then
			local basename = filepath:match("([^/\\]+)%.json$")
			if basename then table.insert(names, basename) end
		end
	end
	return names
end

function ConfigSystem:Save(name)
	self:EnsureFolder()
	name = self:CleanName(name)
	if name == "" then return false, "Empty name" end
	local data = {}
	for flag, option in pairs(Options) do
		if option and option.CurrentValue ~= nil then data[flag] = option.CurrentValue end
	end
	local path = self.Folder .. "/" .. name .. ".json"
	local ok, err = pcall(function() writefile(path, HttpService:JSONEncode(data)) end)
	if not ok then return false, "Write failed: " .. tostring(err) end
	return true
end

function ConfigSystem:Load(name, silent)
	name = self:CleanName(name)
	if name == "" then return false, "Empty name" end
	local exactPath = self:FindFileExact(name)
	if not exactPath then return false, "File '" .. name .. ".json' not found." end
	local readOk, content = pcall(function() return readfile(exactPath) end)
	if not readOk then return false, "readfile() failed: " .. tostring(content) end
	local decodeOk, data = pcall(function() return HttpService:JSONDecode(content) end)
	if not decodeOk then return false, "JSON decode failed: " .. tostring(data) end
	if type(data) ~= "table" then return false, "Decoded data is not a table" end
	local loadedCount, failCount = 0, 0
	for flag, value in pairs(data) do
		local option = Options[flag]
		if option and option.Set then
			if pcall(function() option:Set(value) end) then loadedCount = loadedCount + 1
			else failCount = failCount + 1 end
		end
	end
	return true, loadedCount, failCount
end

function ConfigSystem:Delete(name)
	name = self:CleanName(name)
	local exactPath = self:FindFileExact(name)
	if exactPath then pcall(function() delfile(exactPath) end) end
end

function ConfigSystem:SetAutoload(name)
	name = self:CleanName(name)
	pcall(function()
		if not isfolder("ZangetsuHub") then makefolder("ZangetsuHub") end
		writefile(self.AutoloadFile, name)
	end)
end

function ConfigSystem:GetAutoload()
	local ok, content = pcall(function() return readfile(self.AutoloadFile) end)
	if ok and type(content) == "string" then return self:CleanName(content) end
	return nil
end

function ConfigSystem:ResetAutoload()
	pcall(function() if isfile(self.AutoloadFile) then delfile(self.AutoloadFile) end end)
end

local ConfigNameInput, ConfigLoadDropdown, ConfigAutoloadDropdown

-- ========================
--   AUTO START SYSTEM
-- ========================

local autoStartActive = false

-- Helper: safely read Rayfield dropdown value
local function GetDropdownValue(option)
	if not option then return nil end
	local val = option.CurrentOption
	if type(val) == "table" then return val[1] end
	if type(val) == "string" then return val end
	return nil
end

local function TriggerGameStart()
	-- Read all selected values safely using CurrentOption (Rayfield dropdowns)
	local gameType  = GetDropdownValue(Options.AutoStartType)   or "Missions"
	local map       = GetDropdownValue(Options.AutoStartMap)
	local objective = GetDropdownValue(Options.AutoStartObjective)
	local difficulty= GetDropdownValue(Options.AutoStartDifficulty)
	local modifiers = (Options.AutoStartModifiers and Options.AutoStartModifiers.CurrentOption) or {}

	-- Validate all required fields are selected
	if not map or not objective or not difficulty then
		Rayfield:Notify({
			Title = "Auto Start",
			Content = "Missing settings! Make sure Map, Objective and Difficulty are selected.",
			Duration = 4,
		})
		return
	end

	local modStr = #modifiers > 0 and table.concat(modifiers, ", ") or "None"

	Rayfield:Notify({
		Title = "Auto Start",
		Content = gameType .. " | " .. map .. " | " .. objective .. " | " .. difficulty .. "\nMods: " .. modStr,
		Duration = 5,
	})

	-- Fire via POST remote (AOT:R's generic remote system)
	-- ACTION NAME needs to be confirmed via Remote Spy — update below once found
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local remotesFolder = assets and assets:FindFirstChild("Remotes")
	local POST = remotesFolder and remotesFolder:FindFirstChild("POST")

	if not POST then
		Rayfield:Notify({ Title = "Auto Start", Content = "POST remote not found!", Duration = 3 })
		return
	end

	-- TODO: Replace "StartGame" with the actual action name found via Remote Spy
	pcall(function()
		POST:FireServer("StartGame", {
			Type      = gameType,
			Map       = map,
			Objective = objective,
			Difficulty= difficulty,
			Modifiers = modifiers,
		})
	end)
end

local function StartAutoStart()
	if autoStartActive then return end
	autoStartActive = true
	local delaySeconds = Options.StartAfterXSeconds and Options.StartAfterXSeconds.CurrentValue or 0
	task.spawn(function()
		if delaySeconds > 0 then task.wait(delaySeconds) end
		if autoStartActive and Options.AutoStartToggle and Options.AutoStartToggle.CurrentValue then
			TriggerGameStart()
		end
	end)
end

local function StopAutoStart()
	autoStartActive = false
end

-- ========================
--        MAIN TAB
-- ========================

local MapObjectives = {
	["Shiganshina"] = { "Skirmish", "Breach" },
	["Trost"]       = { "Skirmish", "Protect" },
	["Outskirts"]   = { "Skirmish", "Protect" },
	["Forest"]      = { "Skirmish", "Guard" },
	["Stohess"]     = { "Skirmish" },
	["Chapel"]      = { "Skirmish" },
}

local MissionMaps       = { "Shiganshina", "Trost", "Outskirts", "Forest", "Stohess", "Chapel" }
local RaidMaps          = { "Trost", "Shiganshina", "Stohess", "Colossal" }
local DifficultyOptions = { "Easy", "Normal", "Hard", "Severe", "Aberrant", "Hardest" }
local ModifierOptions   = { "No Skills", "No Talents", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Canon", "Time Trial", "Boring", "Simple" }
local RAID_TITAN_TEXT   = "Trost: Attack Titan\nShiganshina: Armored Titan\nStohess: Female Titan\nColossal: Colossal Titan"
local RaidTitanLabel    = nil

Tabs.Main:CreateSection("Misc")

Tabs.Main:CreateButton({ Name = "Return to Lobby",    Callback = function() ReturnToLobby() end })
Tabs.Main:CreateButton({ Name = "Shadowban Checker",  Callback = function() CheckShadowBan() end })
Tabs.Main:CreateButton({ Name = "Join Discord",        Callback = function() end })

Tabs.Main:CreateSection("Automation")

Options.AutoFarm          = Tabs.Main:CreateToggle({ Name = "Auto Farm",            CurrentValue = false, Flag = "AutoFarm",          Callback = function() end })
Options.AutoFarmRaids     = Tabs.Main:CreateToggle({ Name = "Auto Farm Raids",      CurrentValue = false, Flag = "AutoFarmRaids",     Callback = function() end })
Options.AutoRetry         = Tabs.Main:CreateToggle({ Name = "Auto Retry",           CurrentValue = false, Flag = "AutoRetry",         Callback = function() end })
Options.SoloOnly          = Tabs.Main:CreateToggle({ Name = "Solo Only",            CurrentValue = false, Flag = "SoloOnly",          Callback = function() end })
Options.AutoReturnToLobby = Tabs.Main:CreateToggle({ Name = "Auto Return to Lobby", CurrentValue = false, Flag = "AutoReturnToLobby", Callback = function() end })

Options.ReturnAfterXGames = Tabs.Main:CreateSlider({
	Name = "Return to lobby after x games", Range = {1, 250}, Increment = 1, CurrentValue = 10,
	Flag = "ReturnAfterXGames", Callback = function() end
})

Options.AutoStartToggle = Tabs.Main:CreateToggle({
	Name = "Auto Start", CurrentValue = false, Flag = "AutoStartToggle",
	Callback = function(Value)
		if Value then
			StartAutoStart()
			local delay = Options.StartAfterXSeconds and Options.StartAfterXSeconds.CurrentValue or 0
			Rayfield:Notify({ Title = "Auto Start", Content = "Enabled! Starting in " .. delay .. " seconds.", Duration = 3 })
		else
			StopAutoStart()
			Rayfield:Notify({ Title = "Auto Start", Content = "Disabled.", Duration = 3 })
		end
	end
})

Options.StartAfterXSeconds = Tabs.Main:CreateSlider({
	Name = "Start after x seconds", Range = {0, 500}, Increment = 1, CurrentValue = 0,
	Flag = "StartAfterXSeconds", Callback = function() end
})

Tabs.Main:CreateSection("Movement")

Options.MovementMode = Tabs.Main:CreateDropdown({ Name = "Movement Mode", Options = {"Teleport", "Hover"}, CurrentOption = {"Teleport"}, MultipleOptions = false, Flag = "MovementMode", Callback = function() end })
Options.HoverSpeed   = Tabs.Main:CreateSlider({ Name = "Hover Speed",  Range = {0, 500}, Increment = 1, CurrentValue = 400, Flag = "HoverSpeed",  Callback = function() end })
Options.FloatHeight  = Tabs.Main:CreateSlider({ Name = "Float Height", Range = {0, 300}, Increment = 1, CurrentValue = 300, Flag = "FloatHeight", Callback = function() end })

Tabs.Main:CreateSection("Auto Start")

Options.AutoStartType = Tabs.Main:CreateDropdown({
	Name = "Type", Options = {"Missions", "Raids"}, CurrentOption = {"Missions"}, MultipleOptions = false, Flag = "AutoStartType",
	Callback = function(Value)
		local selected = type(Value) == "table" and Value[1] or Value
		if selected == "Missions" then
			Options.AutoStartMap:Refresh(MissionMaps)
			Options.AutoStartMap:Set({MissionMaps[1]})
			Options.AutoStartObjective:Refresh(MapObjectives[MissionMaps[1]] or {"Skirmish"})
			Options.AutoStartObjective:Set({(MapObjectives[MissionMaps[1]] or {"Skirmish"})[1]})
			if RaidTitanLabel then pcall(function() RaidTitanLabel:Set({Title = "", Content = ""}) end) end
		else
			Options.AutoStartMap:Refresh(RaidMaps)
			Options.AutoStartMap:Set({RaidMaps[1]})
			Options.AutoStartObjective:Refresh(MapObjectives[RaidMaps[1]] or {"Skirmish"})
			Options.AutoStartObjective:Set({(MapObjectives[RaidMaps[1]] or {"Skirmish"})[1]})
			if RaidTitanLabel then pcall(function() RaidTitanLabel:Set({Title = "", Content = RAID_TITAN_TEXT}) end) end
		end
	end
})

Options.AutoStartMap = Tabs.Main:CreateDropdown({
	Name = "Map", Options = MissionMaps, CurrentOption = {MissionMaps[1]}, MultipleOptions = false, Flag = "AutoStartMap",
	Callback = function(Value)
		local selected = type(Value) == "table" and Value[1] or Value
		local objectives = MapObjectives[selected] or {"Skirmish"}
		Options.AutoStartObjective:Refresh(objectives)
		Options.AutoStartObjective:Set({objectives[1]})
	end
})

Options.AutoStartObjective = Tabs.Main:CreateDropdown({
	Name = "Objective", Options = MapObjectives["Shiganshina"], CurrentOption = {MapObjectives["Shiganshina"][1]},
	MultipleOptions = false, Flag = "AutoStartObjective", Callback = function() end
})

Options.AutoStartDifficulty = Tabs.Main:CreateDropdown({
	Name = "Difficulty", Options = DifficultyOptions, CurrentOption = {DifficultyOptions[1]},
	MultipleOptions = false, Flag = "AutoStartDifficulty", Callback = function() end
})

RaidTitanLabel = Tabs.Main:CreateParagraph({Title = "", Content = ""})

Options.AutoStartModifiers = Tabs.Main:CreateDropdown({
	Name = "Modifiers", Options = ModifierOptions, CurrentOption = {}, MultipleOptions = true,
	Flag = "AutoStartModifiers", Callback = function() end
})

Options.MaxRewardModifier = Tabs.Main:CreateToggle({
	Name = "Max Reward Modifier", CurrentValue = false, Flag = "MaxRewardModifier",
	Callback = function(Value)
		if Value then
			Options.AutoStartModifiers:Set({"No Skills","No Talents","Nightmare","Oddball","Injury Prone","Chronic Injuries","Fog","Glass Canon","Time Trial"})
		else
			Options.AutoStartModifiers:Set({})
		end
	end
})

-- ========================
--      UTILITY TAB
-- ========================

Tabs.Utility:CreateSection("Combat Settings")

Options.AutoRefill  = Tabs.Utility:CreateToggle({ Name = "Auto Reload/Refill", CurrentValue = false, Flag = "AutoRefill",  Callback = function() end })
Options.AutoEscape  = Tabs.Utility:CreateToggle({ Name = "Auto Escape",        CurrentValue = false, Flag = "AutoEscape",  Callback = function() end })
Options.MultiHit    = Tabs.Utility:CreateToggle({ Name = "Multi Hit",          CurrentValue = false, Flag = "MultiHit",    Callback = function() end })
Options.TitansPerHit = Tabs.Utility:CreateSlider({ Name = "Titans per hit", Range = {1,20}, Increment = 1, CurrentValue = 3, Flag = "TitansPerHit", Callback = function() end })

Tabs.Utility:CreateSection("Security")

Options.Failsafe = Tabs.Utility:CreateToggle({
	Name = "Failsafe", CurrentValue = false, Flag = "Failsafe",
	Callback = function(Value)
		if Value then
			StartFailsafe()
			Rayfield:Notify({ Title = "Failsafe", Content = "Enabled! Returns to lobby after " .. Options.FailsafeTimeout.CurrentValue .. " min idle.", Duration = 4 })
		else
			StopFailsafe()
			Rayfield:Notify({ Title = "Failsafe", Content = "Disabled.", Duration = 3 })
		end
	end
})

Options.FailsafeTimeout = Tabs.Utility:CreateSlider({
	Name = "Timeout", Range = {1,20}, Increment = 1, Suffix = " min", CurrentValue = 10, Flag = "FailsafeTimeout",
	Callback = function(Value)
		if Options.Failsafe.CurrentValue then
			ResetIdleTimer()
			Rayfield:Notify({ Title = "Failsafe", Content = "Timeout updated to " .. Value .. " min.", Duration = 3 })
		end
	end
})

Tabs.Utility:CreateSection("Mastery Farm")

Options.TitanMasteryFarm = Tabs.Utility:CreateToggle({ Name = "Titan Mastery Farm", CurrentValue = false, Flag = "TitanMasteryFarm", Callback = function() end })
Options.MasteryMode = Tabs.Utility:CreateDropdown({ Name = "Mastery Mode", Options = {"Both","ODM","Titan"}, CurrentOption = {"Both"}, MultipleOptions = false, Flag = "MasteryMode", Callback = function() end })

Tabs.Utility:CreateSection("Extras")

Options.AutoSkipCutscenes = Tabs.Utility:CreateToggle({ Name = "Auto Skip Cutscenes",  CurrentValue = false, Flag = "AutoSkipCutscenes", Callback = function() end })
Options.DieAtStreak       = Tabs.Utility:CreateToggle({ Name = "Die at Streak",         CurrentValue = false, Flag = "DieAtStreak",       Callback = function() end })
Options.DieAtXStreak      = Tabs.Utility:CreateSlider({ Name = "Die at x streak", Range = {5000,100000}, Increment = 1, CurrentValue = 10000, Flag = "DieAtXStreak", Callback = function() end })
Options.AutoOpenChests    = Tabs.Utility:CreateToggle({ Name = "Auto Open Chests",      CurrentValue = false, Flag = "AutoOpenChests",    Callback = function() end })
Options.AutoOpen2ndChest  = Tabs.Utility:CreateToggle({ Name = "Auto Open 2nd Chest",   CurrentValue = false, Flag = "AutoOpen2ndChest",  Callback = function() end })

Options.DeleteMap = Tabs.Utility:CreateToggle({
	Name = "Delete Map (FPS Boost)", CurrentValue = false, Flag = "DeleteMap",
	Callback = function(Value)
		if Value then DeleteMap() else RestoreMap() end
	end
})

-- ========================
--      GLOBAL TAB
-- ========================

Tabs.Global:CreateSection("Family Roll")

Options.AutoRoll = Tabs.Global:CreateToggle({ Name = "Auto Roll", CurrentValue = false, Flag = "AutoRoll", Callback = function() end })
Options.SelectFamilies = Tabs.Global:CreateDropdown({ Name = "Select Families", Options = {"Yeager","Ackerman","Reiss","Helos","Fritz","Shiki"}, CurrentOption = {}, MultipleOptions = true, Flag = "SelectFamilies", Callback = function() end })
Options.StopAt = Tabs.Global:CreateDropdown({ Name = "Stop At", Options = {"Legendary","Mythic","Secret"}, CurrentOption = {}, MultipleOptions = true, Flag = "StopAt", Callback = function() end })

Tabs.Global:CreateSection("AddOns")

Options.AutoHideGui          = Tabs.Global:CreateToggle({ Name = "Auto Hide Gui",           CurrentValue = false, Flag = "AutoHideGui",          Callback = function() end })
Options.AutoClaimAchievements= Tabs.Global:CreateToggle({ Name = "Auto Claim Achievements", CurrentValue = false, Flag = "AutoClaimAchievements", Callback = function() end })

Options.Disable3DRendering = Tabs.Global:CreateToggle({
	Name = "Disable 3D Rendering", CurrentValue = false, Flag = "Disable3DRendering",
	Callback = function(Value)
		if Value then Disable3DRendering() else Enable3DRendering() end
	end
})

Tabs.Global:CreateSection("Webhook")

Options.RewardWebhook      = Tabs.Global:CreateToggle({ Name = "Reward Webhook",       CurrentValue = false, Flag = "RewardWebhook",      Callback = function() end })
Options.MythicFamilyWebhook= Tabs.Global:CreateToggle({ Name = "Mythic Family Webhook",CurrentValue = false, Flag = "MythicFamilyWebhook", Callback = function() end })
Options.WebhookURL         = Tabs.Global:CreateInput({ Name = "Webhook URL", CurrentValue = "", PlaceholderText = "https://discord.com/api/webhooks/...", RemoveTextAfterFocusLost = false, Flag = "WebhookURL", Callback = function() end })

Tabs.Global:CreateSection("Level")

Options.AutoPrestige = Tabs.Global:CreateToggle({ Name = "Auto Prestige", CurrentValue = false, Flag = "AutoPrestige", Callback = function() end })
Options.PrestigeAt   = Tabs.Global:CreateSlider({ Name = "Prestige at (millions)", Range = {1,1000}, Increment = 1, Suffix = "M", CurrentValue = 100, Flag = "PrestigeAt", Callback = function() end })

-- ========================
--      SETTINGS TAB
-- ========================

Tabs.Settings:CreateSection("Menu")

Tabs.Settings:CreateKeybind({ Name = "Menu bind", CurrentKeybind = "RightShift", HoldToInteract = false, Flag = "MenuKeybind", Callback = function() end })

Tabs.Settings:CreateButton({
	Name = "Unload",
	Callback = function()
		StopFailsafe()
		if Options.DeleteMap and Options.DeleteMap.CurrentValue then RestoreMap() end
		Enable3DRendering()
		for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
			if gui.Name == "Rayfield" then gui:Destroy() end
		end
		print("Unloaded!")
	end
})

Tabs.Settings:CreateSection("Auto Execute")

Options.AutoExecEnabled = Tabs.Settings:CreateToggle({
	Name = "Auto Execute", CurrentValue = false, Flag = "AutoExecEnabled",
	Callback = function(Value)
		if Value then
			local ok = QueueOnTeleport('loadstring(game:HttpGet("' .. HUB_SCRIPT_URL .. '"))()')
			Rayfield:Notify({
				Title = "Auto Execute",
				Content = ok and "Enabled! Hub will reload on next teleport." or "Your executor doesn't support queue_on_teleport.",
				Duration = 4
			})
			if not ok then
				task.delay(0.1, function() Options.AutoExecEnabled:Set(false) end)
			end
		else
			Rayfield:Notify({ Title = "Auto Execute", Content = "Disabled.", Duration = 3 })
		end
	end
})

Tabs.Settings:CreateSection("Config Manager")

ConfigNameInput = Tabs.Settings:CreateInput({ Name = "Config Name", CurrentValue = "", PlaceholderText = "Enter name...", RemoveTextAfterFocusLost = false, Flag = "ConfigNameInput", Callback = function() end })

Tabs.Settings:CreateButton({
	Name = "💾 Save Config",
	Callback = function()
		local name = ConfigNameInput.CurrentValue
		if not name or ConfigSystem:CleanName(name) == "" then Rayfield:Notify({Title="Config Manager",Content="Enter a config name first!",Duration=3}) return end
		local ok, err = ConfigSystem:Save(name)
		Rayfield:Notify({ Title = ok and "Config Saved" or "Save Failed", Content = ok and '"'..ConfigSystem:CleanName(name)..'" saved!' or tostring(err), Duration = 3 })
		local list = ConfigSystem:List()
		ConfigLoadDropdown:Refresh(list)
		ConfigAutoloadDropdown:Refresh(list)
	end
})

Tabs.Settings:CreateButton({
	Name = "♻️ Overwrite Config",
	Callback = function()
		local name = ConfigNameInput.CurrentValue
		if not name or ConfigSystem:CleanName(name) == "" then
			local selected = ConfigLoadDropdown.CurrentOption
			if selected and selected[1] then name = selected[1]
			else Rayfield:Notify({Title="Config Manager",Content="Enter a name or select from Load Config!",Duration=3}) return end
		end
		local clean = ConfigSystem:CleanName(name)
		if not ConfigSystem:FindFileExact(clean) then Rayfield:Notify({Title="Config Manager",Content='"'..clean..'" does not exist. Use Save first.',Duration=3}) return end
		local ok, err = ConfigSystem:Save(clean)
		Rayfield:Notify({ Title = ok and "Config Overwritten" or "Overwrite Failed", Content = ok and '"'..clean..'" updated!' or tostring(err), Duration = 3 })
		local list = ConfigSystem:List()
		ConfigLoadDropdown:Refresh(list)
		ConfigAutoloadDropdown:Refresh(list)
	end
})

ConfigLoadDropdown = Tabs.Settings:CreateDropdown({
	Name = "📂 Load Config", Options = ConfigSystem:List(), CurrentOption = {}, MultipleOptions = false, Flag = "ConfigLoadDropdown",
	Callback = function(Value)
		local name = type(Value) == "table" and Value[1] or Value
		if not name then return end
		local ok, loaded, failed = ConfigSystem:Load(name)
		Rayfield:Notify({ Title = ok and "Config Loaded" or "Config Error", Content = ok and '"'..name..'" loaded! ('..tostring(loaded)..' settings)' or tostring(loaded), Duration = ok and 3 or 8 })
	end
})

ConfigAutoloadDropdown = Tabs.Settings:CreateDropdown({
	Name = "🔄 Autoload Config", Options = ConfigSystem:List(), CurrentOption = {}, MultipleOptions = false, Flag = "ConfigAutoloadDropdown",
	Callback = function(Value)
		local name = type(Value) == "table" and Value[1] or Value
		if not name then return end
		ConfigSystem:SetAutoload(name)
		Rayfield:Notify({ Title = "Autoload Set", Content = '"'..name..'" will autoload next time.', Duration = 3 })
	end
})

Tabs.Settings:CreateButton({
	Name = "❌ Reset Autoload",
	Callback = function()
		ConfigSystem:ResetAutoload()
		pcall(function() ConfigAutoloadDropdown:Set({}) end)
		Rayfield:Notify({ Title = "Autoload", Content = "Autoload has been reset.", Duration = 3 })
	end
})

-- Remote Spy using hookmetamethod (proper executor method)
local remoteSpy = false
local spyHook = nil

local POST = ReplicatedStorage:FindFirstChild("Assets")
	and ReplicatedStorage.Assets:FindFirstChild("Remotes")
	and ReplicatedStorage.Assets.Remotes:FindFirstChild("POST")

Tabs.Settings:CreateButton({
	Name = "🔍 Remote Spy (Toggle)",
	Callback = function()
		remoteSpy = not remoteSpy

		if remoteSpy then
			if not hookmetamethod then
				Rayfield:Notify({ Title = "Remote Spy", Content = "hookmetamethod not supported by your executor.", Duration = 4 })
				remoteSpy = false
				return
			end

			spyHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if (method == "FireServer" or method == "InvokeServer") and self == POST then
					local args = {...}
					print("=== ZANGETSU SPY: POST:" .. method .. " ===")
					for i, v in ipairs(args) do
						if type(v) == "table" then
							print("  Arg[" .. i .. "] table:")
							for k, val in pairs(v) do
								print("    " .. tostring(k) .. " = " .. tostring(val))
							end
						else
							print("  Arg[" .. i .. "] = " .. tostring(v))
						end
					end
					print("========================================")
				end
				return spyHook(self, ...)
			end))

			Rayfield:Notify({ Title = "Remote Spy", Content = "ON! Manually start a game now — check console.", Duration = 5 })
		else
			if spyHook then
				hookmetamethod(game, "__namecall", spyHook)
				spyHook = nil
			end
			Rayfield:Notify({ Title = "Remote Spy", Content = "OFF.", Duration = 3 })
		end
	end
})

Tabs.Settings:CreateButton({
	Name = "🗑️ Delete Config",
	Callback = function()
		local name = ConfigNameInput.CurrentValue
		if not name or ConfigSystem:CleanName(name) == "" then Rayfield:Notify({Title="Config Manager",Content="Enter the config name to delete!",Duration=3}) return end
		ConfigSystem:Delete(name)
		Rayfield:Notify({ Title = "Config Deleted", Content = '"'..ConfigSystem:CleanName(name)..'" deleted.', Duration = 3 })
		local list = ConfigSystem:List()
		ConfigLoadDropdown:Refresh(list)
		ConfigAutoloadDropdown:Refresh(list)
	end
})

-- ========================
--   AUTOLOAD ON START
-- ========================

task.spawn(function()
	local ready = false
	for i = 1, 60 do
		local count = 0
		for _ in pairs(Options) do count = count + 1 end
		if count >= 10 then ready = true; break end
		task.wait(0.5)
	end
	if not ready then return end

	local autoload = ConfigSystem:GetAutoload()
	if not autoload then return end

	local ok, loaded = ConfigSystem:Load(autoload)
	if ok then
		Rayfield:Notify({ Title = "✅ Config Autoloaded", Content = '"'..autoload..'" loaded! ('..tostring(loaded)..' settings)', Duration = 5 })
	else
		Rayfield:Notify({ Title = "❌ Autoload Failed", Content = tostring(loaded), Duration = 10 })
	end
end)

Rayfield:Notify({ Title = "Zangetsu Hub", Content = "Loaded successfully!", Duration = 4 })
