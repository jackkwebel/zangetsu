-- Zangetsu Hub by deivid (modified)

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Zangetsu Hub",
	Footer = "AOT:R",
	Icon = 95816097006870, -- placeholder, update with crescent moon asset ID
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Main     = Window:AddTab("Main",     "user"),
	Utility  = Window:AddTab("Utility",  "wrench"),
	Global   = Window:AddTab("Global",   "globe"),
	Settings = Window:AddTab("Settings", "settings"),
}

-- ========================
--        MAIN TAB
-- ========================

-- Map objectives lookup
local MapObjectives = {
	["Shiganshina"] = { "Skirmish", "Breach" },
	["Trost"]       = { "Skirmish", "Protect" },
	["Outskirts"]   = { "Skirmish", "Protect" },
	["Forest"]      = { "Skirmish", "Guard" },
	["Stohess"]     = { "Skirmish" },
	["Chapel"]      = { "Skirmish" },
}

-- LEFT SIDE: Misc
local MiscGroup = Tabs.Main:AddLeftGroupbox("Misc", "layout-grid")

MiscGroup:AddButton({
	Text = "Return to Lobby",
	Func = function()
		-- functionality later
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

-- LEFT SIDE: Automation
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

-- RIGHT SIDE: Movement
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

-- RIGHT SIDE: Auto Start
local AutoStartGroup = Tabs.Main:AddRightGroupbox("Auto Start", "play")

-- Data tables
local MissionMaps       = { "Shiganshina", "Trost", "Outskirts", "Forest", "Stohess", "Chapel" }
local RaidMaps          = { "Trost", "Shiganshina", "Stohess", "Colossal" }
local DifficultyOptions = { "Easy", "Normal", "Hard", "Severe", "Aberrant", "Hardest" }
local ModifierOptions   = { "No Skills", "No Talents", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Canon", "Time Trial", "Boring", "Simple" }
local RAID_TITAN_TEXT   = "Trost: Attack Titan\nShiganshina: Armored Titan\nStohess: Female Titan\nColossal: Colossal Titan"

-- Titan label reference (set after AddLabel call below)
local RaidTitanLabel = nil

-- Type dropdown
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

-- Map dropdown
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

-- Objective dropdown (label updated dynamically via Type callback)
AutoStartGroup:AddDropdown("AutoStartObjective", {
	Values = MapObjectives["Shiganshina"],
	Default = 1,
	Multi = false,
	Text = "Objective",
	Callback = function(Value)
		-- functionality later
	end,
})

-- Difficulty dropdown (label updated dynamically via Type callback)
AutoStartGroup:AddDropdown("AutoStartDifficulty", {
	Values = DifficultyOptions,
	Default = 1,
	Multi = false,
	Text = "Difficulty",
	Callback = function(Value)
		-- functionality later
	end,
})

-- Titan info label — hidden by default, shown when Raids is selected
RaidTitanLabel = AutoStartGroup:AddLabel("", true)

AutoStartGroup:AddDivider()

-- Modifiers dropdown
AutoStartGroup:AddDropdown("AutoStartModifiers", {
	Values = ModifierOptions,
	Default = 1,
	Multi = true,
	Text = "Modifiers",
	Callback = function(Value)
		-- functionality later
	end,
})

-- Max Reward Modifier toggle
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
--    UTILITY TAB (empty)
-- ========================

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

-- Auto Execute
local HUB_SCRIPT_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/ZangetsuHub.lua" -- replace with your raw script URL
local AUTOEXEC_PATH  = "autoexec/ZangetsuHub.lua"
local LOADER         = 'loadstring(game:HttpGet("' .. HUB_SCRIPT_URL .. '"))()'

local AutoExecGroup = Tabs.Settings:AddLeftGroupbox("Auto Execute", "play-circle")

local function isEnabled()
	local ok, val = pcall(readfile, AUTOEXEC_PATH)
	return ok and val == LOADER
end

local function enable()
	if not isfolder("autoexec") then makefolder("autoexec") end
	writefile(AUTOEXEC_PATH, LOADER)
end

local function disable()
	if isfile(AUTOEXEC_PATH) then deletefile(AUTOEXEC_PATH) end
end

AutoExecGroup:AddToggle("AutoExecEnabled", {
	Text = "Auto Execute",
	Tooltip = "Writes a loader to your executor autoexec folder so the hub runs on every launch automatically.",
	Default = isEnabled(),
	Callback = function(Value)
		if Value then
			enable()
			Library:Notify({
				Title = "Auto Execute",
				Description = "Enabled! Hub will now run automatically on every launch.",
				Time = 4,
			})
		else
			disable()
			Library:Notify({
				Title = "Auto Execute",
				Description = "Disabled.",
				Time = 3,
			})
		end
	end,
})

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
	print("Unloaded!")
end)

-- Addons
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("ZangetsuHub")
SaveManager:SetFolder("ZangetsuHub/AOT-R")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()