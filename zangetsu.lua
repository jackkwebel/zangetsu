-- Zangetsu Hub by deivid (modified)

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

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
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Universal queue_on_teleport wrapper
local function QueueOnTeleport(code)
	if syn and syn.queue_on_teleport then
		if pcall(syn.queue_on_teleport, code) then return true end
	end
	if queue_on_teleport then
		if pcall(queue_on_teleport, code) then return true end
	end
	if fluxus and fluxus.queue_on_teleport then
		if pcall(fluxus.queue_on_teleport, code) then return true end
	end
	return false
end

local LOADER = 'loadstring(game:HttpGet("' .. HUB_SCRIPT_URL .. '"))()'

-- ========================
--   RETURN TO LOBBY LOGIC
-- ========================

local function ReturnToLobby()
	local success, err = pcall(function()
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
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end)
	if not success then
		Library:Notify({ Title = "Error", Description = "Failed to return to lobby!", Time = 4 })
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
		if not Toggles.Failsafe.Value then return end
		local currentHRP, currentHumanoid = GetCharacterParts()
		if not currentHRP or not currentHumanoid then return end
		local currentPos = currentHRP.Position
		if (currentPos - lastPosition).Magnitude > 0.5 or currentHumanoid.MoveDirection.Magnitude > 0 then
			ResetIdleTimer()
			lastPosition = currentPos
		end
	end))

	table.insert(failsafeConnections, UserInputService.InputBegan:Connect(function()
		if Toggles.Failsafe.Value then ResetIdleTimer() end
	end))

	task.spawn(function()
		while Toggles.Failsafe.Value do
			task.wait(1)
			if not Toggles.Failsafe.Value then break end
			local timeoutSeconds = (Options.FailsafeTimeout and Options.FailsafeTimeout.Value or 10) * 60
			if tick() - lastActivity >= timeoutSeconds then
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
	for _, conn in ipairs(failsafeConnections) do conn:Disconnect() end
	failsafeConnections = {}
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
	task.wait(0.5)
	local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
	if hrp then lastPosition = hrp.Position end
	if Toggles.Failsafe.Value then ResetIdleTimer() end
end)

-- ========================
--   DELETE MAP SYSTEM
-- ========================

local mapStorage = Instance.new("Folder")
mapStorage.Name = "ZangetsuMapStorage"
mapStorage.Parent = ReplicatedStorage

local savedMapData = {}

local mapKeywords = {
	"wall", "house", "building", "tree", "rock", "ground", "terrain",
	"map", "environment", "world", "decor", "detail", "structure",
	"fence", "roof", "floor", "grass", "road", "path", "bridge",
	"tower", "city", "village", "gate", "door", "window", "brick",
	"concrete", "wood", "stone", "mountain", "hill", "water", "river",
	"sky", "cloud", "fog", "leaf", "bush", "plant", "flower", "trunk",
	"branch", "log", "stump", "crate", "box", "barrel", "container",
	"cart", "wagon", "statue", "monument", "pillar", "column", "beam",
	"support", "scaffold", "debris", "rubble", "ruin", "wreck"
}

local function IsCharacterOrNPC(obj)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and obj:IsDescendantOf(player.Character) then
			return true
		end
	end
	if obj:IsA("Humanoid") then return true end
	if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then return true end

	local current = obj.Parent
	while current and current ~= Workspace and current ~= game do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			return true
		end
		current = current.Parent
	end
	return false
end

local function IsInteractive(obj)
	if obj:FindFirstChildOfClass("ClickDetector") then return true end
	if obj:FindFirstChildOfClass("ProximityPrompt") then return true end
	if obj:FindFirstChildOfClass("SurfaceGui") then return true end
	if obj:FindFirstChildOfClass("BillboardGui") then return true end
	if obj:FindFirstChildOfClass("Script") then return true end
	if obj:FindFirstChildOfClass("LocalScript") then return true end
	if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then return true end
	if obj:IsA("Tool") or obj:IsA("HopperBin") then return true end
	if obj:IsA("Script") or obj:IsA("LocalScript") then return true end
	if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then return true end
	return false
end

local function ShouldDeleteMapObject(obj)
	if IsCharacterOrNPC(obj) then return false end
	if IsInteractive(obj) then return false end
	if obj:IsA("Camera") then return false end
	if obj:IsA("Terrain") then return false end

	local name = obj.Name:lower()
	for _, kw in ipairs(mapKeywords) do
		if name:find(kw) then
			return true
		end
	end

	if obj:IsA("BasePart") and obj.Anchored and obj.Parent == Workspace then
		if obj:FindFirstChildOfClass("Script") or obj:FindFirstChildOfClass("LocalScript") then
			return false
		end
		return true
	end

	if obj:IsA("Model") and obj.Parent == Workspace then
		return true
	end

	return false
end

local function DeleteMap()
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		pcall(function() terrain:Clear() end)
	end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Parent == nil then continue end
		if savedMapData[obj] then continue end

		local ancestorStored = false
		for storedObj, _ in pairs(savedMapData) do
			if obj:IsDescendantOf(storedObj) then
				ancestorStored = true
				break
			end
		end
		if ancestorStored then continue end

		if ShouldDeleteMapObject(obj) then
			savedMapData[obj] = obj.Parent
			pcall(function() obj.Parent = mapStorage end)
		end
	end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Parent == nil then continue end
		if savedMapData[obj] then continue end

		local ancestorStored = false
		for storedObj, _ in pairs(savedMapData) do
			if obj:IsDescendantOf(storedObj) then
				ancestorStored = true
				break
			end
		end
		if ancestorStored then continue end

		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
		   or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
		   or obj:IsA("Decal") or obj:IsA("Texture") then
			if not IsCharacterOrNPC(obj) and not IsInteractive(obj) then
				savedMapData[obj] = obj.Parent
				pcall(function() obj.Parent = mapStorage end)
			end
		end
	end

	Library:Notify({
		Title = "Delete Map",
		Description = "Map hidden. Humans, titans & UI kept.",
		Time = 3,
	})
end

local function RestoreMap()
	local restoredCount = 0
	for obj, originalParent in pairs(savedMapData) do
		if obj and obj.Parent == mapStorage then
			local success = pcall(function()
				if originalParent and originalParent.Parent then
					obj.Parent = originalParent
				else
					obj.Parent = Workspace
				end
			end)
			if success then restoredCount = restoredCount + 1 end
		end
	end

	savedMapData = {}

	Library:Notify({
		Title = "Delete Map",
		Description = "Map restored (" .. tostring(restoredCount) .. " objects).",
		Time = 3,
	})
end

-- ========================
--   3D RENDERING SYSTEM
-- ========================

local renderConnection = nil
local blackoutPart = nil

local function Disable3DRendering()
	-- 1. Native engine disable for actual FPS boost
	pcall(function()
		RunService:Set3dRenderingEnabled(false)
	end)

	-- 2. Visual blackout: massive black part locked in front of camera
	if blackoutPart then blackoutPart:Destroy() end
	if renderConnection then renderConnection:Disconnect() end

	blackoutPart = Instance.new("Part")
	blackoutPart.Name = "ZangetsuBlackout"
	blackoutPart.Size = Vector3.new(500, 500, 1)
	blackoutPart.Anchored = true
	blackoutPart.CanCollide = false
	blackoutPart.CastShadow = false
	blackoutPart.Transparency = 0
	blackoutPart.Color = Color3.new(0, 0, 0)
	blackoutPart.Material = Enum.Material.SmoothPlastic
	blackoutPart.Parent = Workspace

	pcall(function()
		blackoutPart.CanQuery = false
	end)

	renderConnection = RunService.RenderStepped:Connect(function()
		if blackoutPart and blackoutPart.Parent then
			local cam = workspace.CurrentCamera
			if cam then
				blackoutPart.CFrame = cam.CFrame * CFrame.new(0, 0, -10)
			end
		end
	end)

	Library:Notify({
		Title = "3D Rendering",
		Description = "Disabled. Screen blacked out.",
		Time = 3,
	})
end

local function Enable3DRendering()
	-- 1. Restore native rendering
	pcall(function()
		RunService:Set3dRenderingEnabled(true)
	end)

	-- 2. Remove blackout part
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	if blackoutPart then
		blackoutPart:Destroy()
		blackoutPart = nil
	end

	Library:Notify({ Title = "3D Rendering", Description = "Restored.", Time = 3 })
end

-- ========================
--        TABS
-- ========================

local Tabs = {
	Main     = Window:AddTab("Main",     "user"),
	Utility  = Window:AddTab("Utility",  "wrench"),
	Global   = Window:AddTab("Global",   "globe"),
	Settings = Window:AddTab("Settings", "settings"),
}

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

local MiscGroup = Tabs.Main:AddLeftGroupbox("Misc", "layout-grid")

MiscGroup:AddButton({ Text = "Return to Lobby", Func = function() ReturnToLobby() end })
MiscGroup:AddButton({ Text = "Check Shadow Ban (Lobby)", Func = function() end })
MiscGroup:AddButton({ Text = "Join Discord", Func = function() end })

local AutomationGroup = Tabs.Main:AddLeftGroupbox("Automation", "cpu")

AutomationGroup:AddToggle("AutoFarm",          { Text = "Auto Farm",             Default = false, Callback = function() end })
AutomationGroup:AddToggle("AutoFarmRaids",     { Text = "Auto Farm Raids",       Default = false, Callback = function() end })
AutomationGroup:AddToggle("AutoRetry",         { Text = "Auto Retry",            Default = false, Callback = function() end })
AutomationGroup:AddToggle("SoloOnly",          { Text = "Solo Only",             Default = false, Callback = function() end })
AutomationGroup:AddToggle("AutoReturnToLobby", { Text = "Auto Return to Lobby",  Default = false, Callback = function() end })

AutomationGroup:AddSlider("ReturnAfterXGames", {
	Text = "Return to lobby after x games", Default = 10, Min = 1, Max = 250, Rounding = 0,
	Callback = function() end,
})

AutomationGroup:AddToggle("AutoStartToggle", { Text = "Auto Start", Default = false, Callback = function() end })

AutomationGroup:AddSlider("StartAfterXSeconds", {
	Text = "Start after x seconds", Default = 0, Min = 0, Max = 500, Rounding = 0,
	Callback = function() end,
})

local MovementGroup = Tabs.Main:AddRightGroupbox("Movement", "move")

MovementGroup:AddDropdown("MovementMode", {
	Values = { "Teleport", "Hover" }, Default = 1, Multi = false, Text = "Movement Mode",
	Callback = function() end,
})
MovementGroup:AddSlider("HoverSpeed",  { Text = "Hover Speed",  Default = 400, Min = 0, Max = 500, Rounding = 0, Callback = function() end })
MovementGroup:AddSlider("FloatHeight", { Text = "Float Height", Default = 300, Min = 0, Max = 300, Rounding = 0, Callback = function() end })

local AutoStartGroup = Tabs.Main:AddRightGroupbox("Auto Start", "play")

local MissionMaps       = { "Shiganshina", "Trost", "Outskirts", "Forest", "Stohess", "Chapel" }
local RaidMaps          = { "Trost", "Shiganshina", "Stohess", "Colossal" }
local DifficultyOptions = { "Easy", "Normal", "Hard", "Severe", "Aberrant", "Hardest" }
local ModifierOptions   = { "No Skills", "No Talents", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Canon", "Time Trial", "Boring", "Simple" }
local RAID_TITAN_TEXT   = "Trost: Attack Titan\nShiganshina: Armored Titan\nStohess: Female Titan\nColossal: Colossal Titan"
local RaidTitanLabel    = nil

AutoStartGroup:AddDropdown("AutoStartType", {
	Values = { "Missions", "Raids" }, Default = 1, Multi = false, Text = "Type",
	Callback = function(Value)
		if Value == "Missions" then
			Options.AutoStartMap:SetValues(MissionMaps)
			Options.AutoStartMap:SetValue(MissionMaps[1])
			Options.AutoStartObjective:SetValues(MapObjectives[MissionMaps[1]] or { "Skirmish" })
			Options.AutoStartObjective:SetValue((MapObjectives[MissionMaps[1]] or { "Skirmish" })[1])
			if RaidTitanLabel then RaidTitanLabel:SetText("") end
		else
			Options.AutoStartMap:SetValues(RaidMaps)
			Options.AutoStartMap:SetValue(RaidMaps[1])
			Options.AutoStartObjective:SetValues(MapObjectives[RaidMaps[1]] or { "Skirmish" })
			Options.AutoStartObjective:SetValue((MapObjectives[RaidMaps[1]] or { "Skirmish" })[1])
			if RaidTitanLabel then RaidTitanLabel:SetText(RAID_TITAN_TEXT) end
		end
	end,
})

AutoStartGroup:AddDropdown("AutoStartMap", {
	Values = MissionMaps, Default = 1, Multi = false, Text = "Map",
	Callback = function(Value)
		local objectives = MapObjectives[Value] or { "Skirmish" }
		Options.AutoStartObjective:SetValues(objectives)
		Options.AutoStartObjective:SetValue(objectives[1])
	end,
})

AutoStartGroup:AddDropdown("AutoStartObjective", {
	Values = MapObjectives["Shiganshina"], Default = 1, Multi = false, Text = "Objective",
	Callback = function() end,
})

AutoStartGroup:AddDropdown("AutoStartDifficulty", {
	Values = DifficultyOptions, Default = 1, Multi = false, Text = "Difficulty",
	Callback = function() end,
})

RaidTitanLabel = AutoStartGroup:AddLabel("", true)
AutoStartGroup:AddDivider()

AutoStartGroup:AddDropdown("AutoStartModifiers", {
	Values = ModifierOptions, Default = 1, Multi = true, Text = "Modifiers",
	Callback = function() end,
})

AutoStartGroup:AddToggle("MaxRewardModifier", {
	Text = "Max Reward Modifier",
	Tooltip = "Selects all modifiers except Boring and Simple",
	Default = false,
	Callback = function(Value)
		if Value then
			Options.AutoStartModifiers:SetValue({
				["No Skills"] = true, ["No Talents"] = true, ["Nightmare"] = true,
				["Oddball"] = true, ["Injury Prone"] = true, ["Chronic Injuries"] = true,
				["Fog"] = true, ["Glass Canon"] = true, ["Time Trial"] = true,
			})
		else
			Options.AutoStartModifiers:SetValue({})
		end
	end,
})

-- ========================
--      UTILITY TAB
-- ========================

local CombatGroup = Tabs.Utility:AddLeftGroupbox("Combat Settings", "sword")
CombatGroup:AddToggle("AutoRefill", { Text = "Auto Reload/Refill", Default = false, Callback = function() end })
CombatGroup:AddToggle("AutoEscape", { Text = "Auto Escape",        Default = false, Callback = function() end })
CombatGroup:AddToggle("MultiHit",   { Text = "Multi Hit",          Default = false, Callback = function() end })
CombatGroup:AddSlider("TitansPerHit", { Text = "Titans per hit", Default = 3, Min = 1, Max = 20, Rounding = 0, Callback = function() end })

local SecurityGroup = Tabs.Utility:AddLeftGroupbox("Security", "shield")

SecurityGroup:AddToggle("Failsafe", {
	Text = "Failsafe", Default = false,
	Callback = function(Value)
		if Value then
			StartFailsafe()
			Library:Notify({ Title = "Failsafe", Description = "Enabled! Will return to lobby after " .. Options.FailsafeTimeout.Value .. " min of idle time.", Time = 4 })
		else
			StopFailsafe()
			Library:Notify({ Title = "Failsafe", Description = "Disabled.", Time = 3 })
		end
	end,
})

SecurityGroup:AddSlider("FailsafeTimeout", {
	Text = "Timeout", Default = 10, Min = 1, Max = 20, Rounding = 0, Suffix = " min",
	Callback = function(Value)
		if Toggles.Failsafe.Value then
			ResetIdleTimer()
			Library:Notify({ Title = "Failsafe", Description = "Timeout updated to " .. Value .. " min. Timer reset.", Time = 3 })
		end
	end,
})

local MasteryFarmGroup = Tabs.Utility:AddRightGroupbox("Mastery Farm", "zap")
MasteryFarmGroup:AddToggle("TitanMasteryFarm", { Text = "Titan Mastery Farm", Default = false, Callback = function() end })
MasteryFarmGroup:AddDropdown("MasteryMode", { Values = { "Both", "ODM", "Titan" }, Default = 1, Multi = false, Text = "Mastery Mode", Callback = function() end })

local ExtrasGroup = Tabs.Utility:AddRightGroupbox("Extras", "star")
ExtrasGroup:AddToggle("AutoSkipCutscenes", { Text = "Auto Skip Cutscenes",  Default = false, Callback = function() end })
ExtrasGroup:AddToggle("DieAtStreak",       { Text = "Die at Streak",         Default = false, Callback = function() end })
ExtrasGroup:AddSlider("DieAtXStreak",      { Text = "Die at x streak", Default = 10000, Min = 5000, Max = 100000, Rounding = 0, Callback = function() end })
ExtrasGroup:AddToggle("AutoOpenChests",    { Text = "Auto Open Chests",      Default = false, Callback = function() end })
ExtrasGroup:AddToggle("AutoOpen2ndChest",  { Text = "Auto Open 2nd Chest",   Default = false, Callback = function() end })
ExtrasGroup:AddToggle("DeleteMap",         { Text = "Delete Map (FPS Boost)", Default = false, Callback = function(Value)
	if Value then
		DeleteMap()
	else
		RestoreMap()
	end
end })

-- ========================
--      GLOBAL TAB
-- ========================

-- LEFT SIDE: Family Roll
local FamilyRollGroup = Tabs.Global:AddLeftGroupbox("Family Roll", "dice-5")

FamilyRollGroup:AddToggle("AutoRoll", {
	Text = "Auto Roll",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

FamilyRollGroup:AddDropdown("SelectFamilies", {
	Values = { "Yeager", "Ackerman", "Reiss", "Helos", "Fritz", "Shiki" },
	Default = 1,
	Multi = true,
	Text = "Select Families",
	Callback = function(Value)
		-- functionality later
	end,
})

FamilyRollGroup:AddDropdown("StopAt", {
	Values = { "Legendary", "Mythic", "Secret" },
	Default = 1,
	Multi = true,
	Text = "Stop At",
	Callback = function(Value)
		-- functionality later
	end,
})

-- LEFT SIDE: AddOns
local AddOnsGroup = Tabs.Global:AddLeftGroupbox("AddOns", "puzzle")

AddOnsGroup:AddToggle("AutoHideGui", {
	Text = "Auto Hide Gui",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AddOnsGroup:AddToggle("AutoClaimAchievements", {
	Text = "Auto Claim Achievements",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

AddOnsGroup:AddToggle("Disable3DRendering", {
	Text = "Disable 3D Rendering",
	Default = false,
	Callback = function(Value)
		if Value then
			Disable3DRendering()
		else
			Enable3DRendering()
		end
	end,
})

-- RIGHT SIDE: Webhook
local WebhookGroup = Tabs.Global:AddRightGroupbox("Webhook", "webhook")

WebhookGroup:AddToggle("RewardWebhook", {
	Text = "Reward Webhook",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

WebhookGroup:AddToggle("MythicFamilyWebhook", {
	Text = "Mythic Family Webhook",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

WebhookGroup:AddInput("WebhookURL", {
	Text = "Webhook URL",
	Default = "",
	Placeholder = "https://discord.com/api/webhooks/...",
	Numeric = false,
	Finished = true,
	Callback = function(Value)
		-- functionality later
	end,
})

-- RIGHT SIDE: Level
local LevelGroup = Tabs.Global:AddRightGroupbox("Level", "trending-up")

LevelGroup:AddToggle("AutoPrestige", {
	Text = "Auto Prestige",
	Default = false,
	Callback = function(Value)
		-- functionality later
	end,
})

LevelGroup:AddSlider("PrestigeAt", {
	Text = "Prestige at (millions)",
	Default = 100,
	Min = 1,
	Max = 1000,
	Rounding = 0,
	Suffix = "M",
	Callback = function(Value)
		-- functionality later
	end,
})

-- ========================
--      SETTINGS TAB
-- ========================

local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() Library:Unload() end)

local AutoExecGroup = Tabs.Settings:AddLeftGroupbox("Auto Execute", "play-circle")

AutoExecGroup:AddToggle("AutoExecEnabled", {
	Text = "Auto Execute",
	Tooltip = "Automatically re-runs this hub every time you teleport to a new server.",
	Default = false,
	Callback = function(Value)
		if Value then
			local ok = QueueOnTeleport(LOADER)
			Library:Notify({
				Title = "Auto Execute",
				Description = ok and "Enabled! Hub will reload on next teleport." or "Your executor doesn't support queue_on_teleport.",
				Time = 4,
			})
			if not ok then
				task.delay(0.1, function() Toggles.AutoExecEnabled:SetValue(false) end)
			end
		else
			Library:Notify({ Title = "Auto Execute", Description = "Disabled.", Time = 3 })
		end
	end,
})

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
	StopFailsafe()
	if Toggles.DeleteMap and Toggles.DeleteMap.Value then
		RestoreMap()
	end
	Enable3DRendering()
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
