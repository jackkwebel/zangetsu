-- Zangetsu Hub by deivid (modified) — Rayfield Edition with Custom Themes

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
	Discord = {
		Enabled = false,
		Invite = "",
		RememberJoins = true
	},
	KeySystem = false,
	KeySettings = {}
})

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ========================
--   THEME SYSTEM
-- ========================

local Themes = {
	Default = {
		Background = Color3.fromRGB(25, 25, 25),
		Topbar = Color3.fromRGB(34, 34, 34),
		Shadow = Color3.fromRGB(20, 20, 20),
		NotificationBackground = Color3.fromRGB(25, 25, 25),
		NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
		TabBackground = Color3.fromRGB(80, 80, 80),
		TabStroke = Color3.fromRGB(85, 85, 85),
		TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
		TabTextColor = Color3.fromRGB(240, 240, 240),
		SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
		ElementBackground = Color3.fromRGB(35, 35, 35),
		ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
		SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
		ElementStroke = Color3.fromRGB(50, 50, 50),
		SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
		SliderBackground = Color3.fromRGB(50, 138, 220),
		SliderProgress = Color3.fromRGB(50, 138, 220),
		SliderStroke = Color3.fromRGB(58, 163, 255),
		ToggleBackground = Color3.fromRGB(30, 30, 30),
		ToggleEnabled = Color3.fromRGB(0, 146, 214),
		ToggleDisabled = Color3.fromRGB(100, 100, 100),
		ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
		ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
		ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
		ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
		DropdownSelected = Color3.fromRGB(40, 40, 40),
		DropdownUnselected = Color3.fromRGB(30, 30, 30),
		InputBackground = Color3.fromRGB(30, 30, 30),
		InputStroke = Color3.fromRGB(65, 65, 65),
		PlaceholderColor = Color3.fromRGB(178, 178, 178)
	},
	DarkRed = {
		Background = Color3.fromRGB(20, 20, 20),
		Topbar = Color3.fromRGB(30, 20, 20),
		Shadow = Color3.fromRGB(15, 10, 10),
		NotificationBackground = Color3.fromRGB(25, 20, 20),
		NotificationActionsBackground = Color3.fromRGB(230, 200, 200),
		TabBackground = Color3.fromRGB(80, 50, 50),
		TabStroke = Color3.fromRGB(100, 60, 60),
		TabBackgroundSelected = Color3.fromRGB(220, 100, 100),
		TabTextColor = Color3.fromRGB(240, 220, 220),
		SelectedTabTextColor = Color3.fromRGB(50, 20, 20),
		ElementBackground = Color3.fromRGB(35, 25, 25),
		ElementBackgroundHover = Color3.fromRGB(45, 30, 30),
		SecondaryElementBackground = Color3.fromRGB(25, 18, 18),
		ElementStroke = Color3.fromRGB(70, 45, 45),
		SecondaryElementStroke = Color3.fromRGB(55, 35, 35),
		SliderBackground = Color3.fromRGB(200, 50, 50),
		SliderProgress = Color3.fromRGB(220, 60, 60),
		SliderStroke = Color3.fromRGB(255, 80, 80),
		ToggleBackground = Color3.fromRGB(30, 20, 20),
		ToggleEnabled = Color3.fromRGB(200, 50, 50),
		ToggleDisabled = Color3.fromRGB(100, 70, 70),
		ToggleEnabledStroke = Color3.fromRGB(255, 70, 70),
		ToggleDisabledStroke = Color3.fromRGB(130, 90, 90),
		ToggleEnabledOuterStroke = Color3.fromRGB(100, 70, 70),
		ToggleDisabledOuterStroke = Color3.fromRGB(65, 45, 45),
		DropdownSelected = Color3.fromRGB(45, 30, 30),
		DropdownUnselected = Color3.fromRGB(35, 22, 22),
		InputBackground = Color3.fromRGB(30, 20, 20),
		InputStroke = Color3.fromRGB(80, 50, 50),
		PlaceholderColor = Color3.fromRGB(200, 160, 160)
	},
	Ocean = {
		Background = Color3.fromRGB(15, 25, 35),
		Topbar = Color3.fromRGB(20, 35, 50),
		Shadow = Color3.fromRGB(10, 18, 28),
		NotificationBackground = Color3.fromRGB(18, 30, 45),
		NotificationActionsBackground = Color3.fromRGB(200, 230, 255),
		TabBackground = Color3.fromRGB(40, 70, 100),
		TabStroke = Color3.fromRGB(50, 90, 130),
		TabBackgroundSelected = Color3.fromRGB(80, 180, 255),
		TabTextColor = Color3.fromRGB(220, 240, 255),
		SelectedTabTextColor = Color3.fromRGB(10, 30, 50),
		ElementBackground = Color3.fromRGB(22, 38, 55),
		ElementBackgroundHover = Color3.fromRGB(28, 50, 75),
		SecondaryElementBackground = Color3.fromRGB(15, 28, 42),
		ElementStroke = Color3.fromRGB(35, 65, 95),
		SecondaryElementStroke = Color3.fromRGB(28, 50, 75),
		SliderBackground = Color3.fromRGB(0, 170, 255),
		SliderProgress = Color3.fromRGB(50, 200, 255),
		SliderStroke = Color3.fromRGB(100, 230, 255),
		ToggleBackground = Color3.fromRGB(20, 35, 50),
		ToggleEnabled = Color3.fromRGB(0, 170, 255),
		ToggleDisabled = Color3.fromRGB(60, 90, 120),
		ToggleEnabledStroke = Color3.fromRGB(50, 200, 255),
		ToggleDisabledStroke = Color3.fromRGB(80, 120, 160),
		ToggleEnabledOuterStroke = Color3.fromRGB(60, 100, 140),
		ToggleDisabledOuterStroke = Color3.fromRGB(35, 55, 75),
		DropdownSelected = Color3.fromRGB(28, 50, 75),
		DropdownUnselected = Color3.fromRGB(20, 35, 55),
		InputBackground = Color3.fromRGB(20, 35, 50),
		InputStroke = Color3.fromRGB(50, 85, 120),
		PlaceholderColor = Color3.fromRGB(160, 200, 230)
	},
	Midnight = {
		Background = Color3.fromRGB(10, 10, 25),
		Topbar = Color3.fromRGB(15, 15, 40),
		Shadow = Color3.fromRGB(8, 8, 20),
		NotificationBackground = Color3.fromRGB(12, 12, 30),
		NotificationActionsBackground = Color3.fromRGB(200, 200, 255),
		TabBackground = Color3.fromRGB(50, 50, 90),
		TabStroke = Color3.fromRGB(70, 70, 120),
		TabBackgroundSelected = Color3.fromRGB(120, 100, 255),
		TabTextColor = Color3.fromRGB(220, 220, 255),
		SelectedTabTextColor = Color3.fromRGB(30, 20, 60),
		ElementBackground = Color3.fromRGB(20, 20, 45),
		ElementBackgroundHover = Color3.fromRGB(28, 28, 60),
		SecondaryElementBackground = Color3.fromRGB(12, 12, 30),
		ElementStroke = Color3.fromRGB(40, 40, 80),
		SecondaryElementStroke = Color3.fromRGB(30, 30, 65),
		SliderBackground = Color3.fromRGB(130, 100, 255),
		SliderProgress = Color3.fromRGB(150, 120, 255),
		SliderStroke = Color3.fromRGB(180, 160, 255),
		ToggleBackground = Color3.fromRGB(18, 18, 40),
		ToggleEnabled = Color3.fromRGB(130, 100, 255),
		ToggleDisabled = Color3.fromRGB(70, 70, 110),
		ToggleEnabledStroke = Color3.fromRGB(160, 140, 255),
		ToggleDisabledStroke = Color3.fromRGB(90, 90, 140),
		ToggleEnabledOuterStroke = Color3.fromRGB(70, 70, 120),
		ToggleDisabledOuterStroke = Color3.fromRGB(40, 40, 70),
		DropdownSelected = Color3.fromRGB(28, 28, 60),
		DropdownUnselected = Color3.fromRGB(18, 18, 45),
		InputBackground = Color3.fromRGB(18, 18, 40),
		InputStroke = Color3.fromRGB(50, 50, 100),
		PlaceholderColor = Color3.fromRGB(170, 170, 220)
	},
	Forest = {
		Background = Color3.fromRGB(18, 28, 18),
		Topbar = Color3.fromRGB(25, 40, 25),
		Shadow = Color3.fromRGB(12, 20, 12),
		NotificationBackground = Color3.fromRGB(20, 32, 20),
		NotificationActionsBackground = Color3.fromRGB(200, 255, 200),
		TabBackground = Color3.fromRGB(50, 80, 50),
		TabStroke = Color3.fromRGB(65, 105, 65),
		TabBackgroundSelected = Color3.fromRGB(100, 220, 100),
		TabTextColor = Color3.fromRGB(220, 255, 220),
		SelectedTabTextColor = Color3.fromRGB(15, 40, 15),
		ElementBackground = Color3.fromRGB(25, 40, 25),
		ElementBackgroundHover = Color3.fromRGB(32, 52, 32),
		SecondaryElementBackground = Color3.fromRGB(18, 30, 18),
		ElementStroke = Color3.fromRGB(45, 75, 45),
		SecondaryElementStroke = Color3.fromRGB(35, 60, 35),
		SliderBackground = Color3.fromRGB(60, 200, 60),
		SliderProgress = Color3.fromRGB(80, 230, 80),
		SliderStroke = Color3.fromRGB(120, 255, 120),
		ToggleBackground = Color3.fromRGB(22, 38, 22),
		ToggleEnabled = Color3.fromRGB(60, 200, 60),
		ToggleDisabled = Color3.fromRGB(70, 100, 70),
		ToggleEnabledStroke = Color3.fromRGB(90, 240, 90),
		ToggleDisabledStroke = Color3.fromRGB(90, 130, 90),
		ToggleEnabledOuterStroke = Color3.fromRGB(70, 110, 70),
		ToggleDisabledOuterStroke = Color3.fromRGB(40, 65, 40),
		DropdownSelected = Color3.fromRGB(32, 52, 32),
		DropdownUnselected = Color3.fromRGB(22, 38, 22),
		InputBackground = Color3.fromRGB(22, 38, 22),
		InputStroke = Color3.fromRGB(55, 90, 55),
		PlaceholderColor = Color3.fromRGB(160, 210, 160)
	},
	Sunset = {
		Background = Color3.fromRGB(30, 20, 18),
		Topbar = Color3.fromRGB(45, 28, 22),
		Shadow = Color3.fromRGB(22, 14, 12),
		NotificationBackground = Color3.fromRGB(35, 22, 18),
		NotificationActionsBackground = Color3.fromRGB(255, 220, 200),
		TabBackground = Color3.fromRGB(100, 65, 45),
		TabStroke = Color3.fromRGB(130, 85, 60),
		TabBackgroundSelected = Color3.fromRGB(255, 160, 80),
		TabTextColor = Color3.fromRGB(255, 235, 220),
		SelectedTabTextColor = Color3.fromRGB(60, 30, 15),
		ElementBackground = Color3.fromRGB(40, 25, 20),
		ElementBackgroundHover = Color3.fromRGB(55, 32, 25),
		SecondaryElementBackground = Color3.fromRGB(30, 18, 14),
		ElementStroke = Color3.fromRGB(75, 45, 35),
		SecondaryElementStroke = Color3.fromRGB(60, 35, 28),
		SliderBackground = Color3.fromRGB(255, 140, 50),
		SliderProgress = Color3.fromRGB(255, 170, 70),
		SliderStroke = Color3.fromRGB(255, 200, 100),
		ToggleBackground = Color3.fromRGB(35, 22, 18),
		ToggleEnabled = Color3.fromRGB(255, 130, 40),
		ToggleDisabled = Color3.fromRGB(120, 80, 60),
		ToggleEnabledStroke = Color3.fromRGB(255, 160, 60),
		ToggleDisabledStroke = Color3.fromRGB(150, 100, 75),
		ToggleEnabledOuterStroke = Color3.fromRGB(130, 85, 60),
		ToggleDisabledOuterStroke = Color3.fromRGB(70, 45, 35),
		DropdownSelected = Color3.fromRGB(55, 32, 25),
		DropdownUnselected = Color3.fromRGB(38, 22, 18),
		InputBackground = Color3.fromRGB(35, 22, 18),
		InputStroke = Color3.fromRGB(85, 55, 40),
		PlaceholderColor = Color3.fromRGB(220, 180, 160)
	},
	["AOT Green"] = {
		Background = Color3.fromRGB(12, 18, 12),
		Topbar = Color3.fromRGB(18, 28, 18),
		Shadow = Color3.fromRGB(8, 14, 8),
		NotificationBackground = Color3.fromRGB(15, 24, 15),
		NotificationActionsBackground = Color3.fromRGB(180, 255, 180),
		TabBackground = Color3.fromRGB(40, 70, 40),
		TabStroke = Color3.fromRGB(55, 95, 55),
		TabBackgroundSelected = Color3.fromRGB(80, 200, 80),
		TabTextColor = Color3.fromRGB(210, 255, 210),
		SelectedTabTextColor = Color3.fromRGB(10, 35, 10),
		ElementBackground = Color3.fromRGB(20, 35, 20),
		ElementBackgroundHover = Color3.fromRGB(28, 48, 28),
		SecondaryElementBackground = Color3.fromRGB(14, 24, 14),
		ElementStroke = Color3.fromRGB(35, 65, 35),
		SecondaryElementStroke = Color3.fromRGB(28, 50, 28),
		SliderBackground = Color3.fromRGB(50, 180, 50),
		SliderProgress = Color3.fromRGB(70, 210, 70),
		SliderStroke = Color3.fromRGB(100, 240, 100),
		ToggleBackground = Color3.fromRGB(18, 32, 18),
		ToggleEnabled = Color3.fromRGB(50, 180, 50),
		ToggleDisabled = Color3.fromRGB(60, 95, 60),
		ToggleEnabledStroke = Color3.fromRGB(80, 220, 80),
		ToggleDisabledStroke = Color3.fromRGB(80, 120, 80),
		ToggleEnabledOuterStroke = Color3.fromRGB(60, 100, 60),
		ToggleDisabledOuterStroke = Color3.fromRGB(35, 60, 35),
		DropdownSelected = Color3.fromRGB(28, 48, 28),
		DropdownUnselected = Color3.fromRGB(18, 32, 18),
		InputBackground = Color3.fromRGB(18, 32, 18),
		InputStroke = Color3.fromRGB(50, 85, 50),
		PlaceholderColor = Color3.fromRGB(150, 210, 150)
	}
}

local function SetRayfieldTheme(themeName)
	local theme = Themes[themeName]
	if not theme then return end

	local success = pcall(function()
		local main = game:GetService("CoreGui"):FindFirstChild("Rayfield")
		if not main then return end

		-- Main background
		local bg = main:FindFirstChild("Main") and main.Main:FindFirstChild("Background")
		if bg then
			bg.ImageColor3 = theme.Background
		end

		-- Topbar
		local topbar = main:FindFirstChild("Main") and main.Main:FindFirstChild("Topbar")
		if topbar then
			topbar.BackgroundColor3 = theme.Topbar
		end

		-- Tabs
		local tabsList = main:FindFirstChild("Main") and main.Main:FindFirstChild("Elements") and main.Main.Elements:FindFirstChild("TabList")
		if tabsList then
			for _, tab in ipairs(tabsList:GetDescendants()) do
				if tab:IsA("Frame") and tab.Name == "TabButton" then
					local isSelected = tab:FindFirstChild("TabTitle") and tab.TabTitle.TextColor3.R < 0.5
					tab.BackgroundColor3 = isSelected and theme.TabBackgroundSelected or theme.TabBackground
					if tab:FindFirstChild("UIStroke") then
						tab.UIStroke.Color = theme.TabStroke
					end
					if tab:FindFirstChild("TabTitle") then
						tab.TabTitle.TextColor3 = isSelected and theme.SelectedTabTextColor or theme.TabTextColor
					end
				end
			end
		end

		-- Elements (toggles, sliders, etc.)
		local content = main:FindFirstChild("Main") and main.Main:FindFirstChild("Elements") and main.Main.Elements:FindFirstChild("Content")
		if content then
			for _, section in ipairs(content:GetDescendants()) do
				if section:IsA("Frame") then
					-- Section backgrounds
					if section.Name == "Section" or section.Name == "SectionContainer" then
						section.BackgroundColor3 = theme.ElementBackground
					end
					-- Element backgrounds
					if section.Name == "Element" or section.Name == "Toggle" or section.Name == "Slider" or section.Name == "Dropdown" or section.Name == "Input" then
						section.BackgroundColor3 = theme.ElementBackground
						if section:FindFirstChild("UIStroke") then
							section.UIStroke.Color = theme.ElementStroke
						end
					end
					-- Toggles
					if section.Name == "Toggle" then
						local toggleBtn = section:FindFirstChild("ToggleFrame") and section.ToggleFrame:FindFirstChild("ToggleCircle")
						if toggleBtn then
							local isEnabled = toggleBtn.Position.X.Scale > 0.5
							toggleBtn.BackgroundColor3 = isEnabled and theme.ToggleEnabled or theme.ToggleDisabled
						end
					end
					-- Sliders
					if section.Name == "Slider" then
						local sliderProg = section:FindFirstChild("SliderFrame") and section.SliderFrame:FindFirstChild("SliderProgress")
						if sliderProg then
							sliderProg.BackgroundColor3 = theme.SliderProgress
						end
					end
				end
			end
		end

		-- Notifications
		local notifHolder = main:FindFirstChild("Notifications")
		if notifHolder then
			for _, notif in ipairs(notifHolder:GetDescendants()) do
				if notif:IsA("Frame") and notif.Name == "Notification" then
					notif.BackgroundColor3 = theme.NotificationBackground
				end
			end
		end
	end)

	if success then
		Rayfield:Notify({
			Title = "Theme Changed",
			Content = "Applied theme: " .. themeName,
			Duration = 3
		})
	end
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
				if returnRemote:IsA("RemoteEvent") then
					returnRemote:FireServer()
				else
					returnRemote:InvokeServer()
				end
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
		if lower:find("ban") or lower:find("shadow") or lower:find("mute") or lower:find("gift") or lower:find("trade") or lower:find("party") then
			if attrValue == true or attrValue == "true" or attrValue == 1 or attrValue == "1" then
				isBanned = true
				table.insert(reasons, "Attr: " .. attrName)
			end
		end
	end

	local banValues = { "ShadowBanned", "Banned", "IsBanned", "CanGift", "CanTrade", "CanJoinParty", "CanInvite", "SocialBanned" }
	for _, valName in ipairs(banValues) do
		local obj = LocalPlayer:FindFirstChild(valName)
		if obj then
			if obj:IsA("BoolValue") and obj.Value == true then
				isBanned = true
				table.insert(reasons, "Player." .. valName)
			elseif obj:IsA("IntValue") and obj.Value ~= 0 then
				isBanned = true
				table.insert(reasons, "Player." .. valName)
			elseif obj:IsA("StringValue") and (obj.Value:lower():find("ban") or obj.Value:lower():find("true")) then
				isBanned = true
				table.insert(reasons, "Player." .. valName)
			end
		end
	end

	local function ScanFolder(folder, path)
		for _, child in ipairs(folder:GetChildren()) do
			local childPath = path .. "/" .. child.Name
			
			if child.Name == LocalPlayer.Name or child.Name == tostring(LocalPlayer.UserId) then
				for _, valName in ipairs(banValues) do
					local dataVal = child:FindFirstChild(valName)
					if dataVal and dataVal:IsA("BoolValue") and dataVal.Value == true then
						isBanned = true
						table.insert(reasons, childPath .. "." .. valName)
					end
				end
				
				for attrName, attrValue in pairs(child:GetAttributes()) do
					local lower = attrName:lower()
					if lower:find("ban") or lower:find("shadow") or lower:find("mute") then
						if attrValue == true or attrValue == "true" or attrValue == 1 then
							isBanned = true
							table.insert(reasons, childPath .. " attr:" .. attrName)
						end
					end
				end
			end
			
			local lowerName = child.Name:lower()
			if lowerName:find("ban") or lowerName:find("shadow") or lowerName:find("moderation") or lowerName:find("punish") then
				if child:IsA("Folder") or child:IsA("Configuration") then
					if child:FindFirstChild(LocalPlayer.Name) or child:FindFirstChild(tostring(LocalPlayer.UserId)) then
						isBanned = true
						table.insert(reasons, "BanList:" .. child.Name)
					end
				end
			end
			
			if (child:IsA("Folder") or child:IsA("Configuration") or child:IsA("Model")) and #path < 50 then
				ScanFolder(child, childPath)
			end
		end
	end
	
	pcall(function()
		ScanFolder(ReplicatedStorage, "RS")
	end)

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		for _, gui in ipairs(playerGui:GetDescendants()) do
			if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
				local text = gui.Text:lower()
				if (text:find("shadowban") or text:find("shadow ban") or text:find("banned") or text:find("restricted") or text:find("suspended")) and gui.Visible then
					isBanned = true
					table.insert(reasons, "GUI warning")
					break
				end
			end
		end
	end

	if isBanned then
		local reasonStr = table.concat(reasons, ", ")
		if #reasonStr > 100 then
			reasonStr = reasonStr:sub(1, 97) .. "..."
		end
		
		Rayfield:Notify({
			Title = "⚠️ Shadowban Checker",
			Content = "SHADOW BANNED detected!\nYou cannot gift, join lobbies, or play with friends.\nFlags: " .. reasonStr,
			Duration = 10,
		})
	else
		Rayfield:Notify({
			Title = "✅ Shadowban Checker",
			Content = "No shadow ban detected.\nGifting, lobbies, and friends should work normally.",
			Duration = 4,
		})
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
				Rayfield:Notify({
					Title = "Failsafe Triggered",
					Content = "Idle for " .. tostring(Options.FailsafeTimeout.CurrentValue) .. " min. Returning to lobby...",
					Duration = 5,
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
	if Options.Failsafe.CurrentValue then ResetIdleTimer() end
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

	Rayfield:Notify({
		Title = "Delete Map",
		Content = "Map hidden. Humans, titans & UI kept.",
		Duration = 3,
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

	Rayfield:Notify({
		Title = "Delete Map",
		Content = "Map restored (" .. tostring(restoredCount) .. " objects).",
		Duration = 3,
	})
end

-- ========================
--   3D RENDERING SYSTEM
-- ========================

local renderConnection = nil
local blackoutPart = nil

local function Disable3DRendering()
	pcall(function()
		RunService:Set3dRenderingEnabled(false)
	end)

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

	Rayfield:Notify({
		Title = "3D Rendering",
		Content = "Disabled. Screen blacked out.",
		Duration = 3,
	})
end

local function Enable3DRendering()
	pcall(function()
		RunService:Set3dRenderingEnabled(true)
	end)

	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	if blackoutPart then
		blackoutPart:Destroy()
		blackoutPart = nil
	end

	Rayfield:Notify({ Title = "3D Rendering", Content = "Restored.", Duration = 3 })
end

-- ========================
--        TABS
-- ========================

local Tabs = {
	Main     = Window:CreateTab("Main", "user"),
	Utility  = Window:CreateTab("Utility", "wrench"),
	Global   = Window:CreateTab("Global", "globe"),
	Settings = Window:CreateTab("Settings", "settings"),
}

local Options = {}

-- ========================
--   CONFIG MANAGER ENGINE  (BULLETPROOF)
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
	-- Aggressive trim: spaces, newlines, BOM, null bytes
	name = tostring(name or "")
	name = name:gsub("%s+", "")           -- remove ALL whitespace
	name = name:gsub("%z", "")             -- remove null bytes
	name = name:gsub("\239\187\191", "")   -- remove UTF-8 BOM
	return name
end

function ConfigSystem:FindFileExact(name)
	-- Returns the EXACT path as reported by listfiles, or nil
	name = self:CleanName(name)
	if name == "" then return nil end

	local ok, files = pcall(listfiles, self.Folder)
	if not ok or type(files) ~= "table" then return nil end

	for _, filepath in ipairs(files) do
		if type(filepath) == "string" then
			-- Match basename from either / or \ separated paths
			local basename = filepath:match("([^/\\]+)%.json$")
			if basename and basename:lower() == name:lower() then
				return filepath  -- return exact path from listfiles
			end
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
		if option and option.CurrentValue ~= nil then
			data[flag] = option.CurrentValue
		end
	end

	local path = self.Folder .. "/" .. name .. ".json"
	local ok, err = pcall(function()
		writefile(path, HttpService:JSONEncode(data))
	end)
	if not ok then
		return false, "Write failed: " .. tostring(err)
	end
	return true
end

function ConfigSystem:Load(name, silent)
	name = self:CleanName(name)
	if name == "" then return false, "Empty name" end

	-- HUNT: find the exact file path via listfiles
	local exactPath = self:FindFileExact(name)
	if not exactPath then
		local allFiles = table.concat(self:List(), ", ")
		if allFiles == "" then allFiles = "(folder empty or missing)" end
		return false, "File '" .. name .. ".json' not found in folder. Found: " .. allFiles
	end

	-- Read using the EXACT path returned by listfiles
	local readOk, content = pcall(function()
		return readfile(exactPath)
	end)
	if not readOk then
		return false, "readfile() failed on '" .. exactPath .. "': " .. tostring(content)
	end

	local decodeOk, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not decodeOk then
		return false, "JSON decode failed: " .. tostring(data)
	end
	if type(data) ~= "table" then
		return false, "Decoded data is not a table"
	end

	local loadedCount = 0
	local failCount = 0
	for flag, value in pairs(data) do
		local option = Options[flag]
		if option and option.Set then
			local setOk = pcall(function()
				option:Set(value)
			end)
			if setOk then
				loadedCount = loadedCount + 1
			else
				failCount = failCount + 1
			end
		else
			failCount = failCount + 1
		end
	end

	if not silent then
		return true, loadedCount, failCount
	end
	return true, loadedCount
end

function ConfigSystem:Delete(name)
	name = self:CleanName(name)
	local exactPath = self:FindFileExact(name)
	if exactPath then
		pcall(function() delfile(exactPath) end)
	end
end

function ConfigSystem:SetAutoload(name)
	name = self:CleanName(name)
	pcall(function()
		if not isfolder("ZangetsuHub") then makefolder("ZangetsuHub") end
		writefile(self.AutoloadFile, name)
	end)
end

function ConfigSystem:GetAutoload()
	local ok, content = pcall(function()
		return readfile(self.AutoloadFile)
	end)
	if ok and type(content) == "string" then
		return self:CleanName(content)
	end
	return nil
end

function ConfigSystem:ResetAutoload()
	pcall(function()
		if isfile(self.AutoloadFile) then delfile(self.AutoloadFile) end
	end)
end

-- Config UI elements (declared here, created after all Options are defined)
local ConfigNameInput, ConfigLoadDropdown, ConfigAutoloadDropdown



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

Tabs.Main:CreateSection("Misc")

Tabs.Main:CreateButton({
	Name = "Return to Lobby",
	Callback = function() ReturnToLobby() end
})

Tabs.Main:CreateButton({
	Name = "Shadowban Checker",
	Callback = function() CheckShadowBan() end
})

Tabs.Main:CreateButton({
	Name = "Join Discord",
	Callback = function() end
})

Tabs.Main:CreateSection("Automation")

Options.AutoFarm = Tabs.Main:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Flag = "AutoFarm",
	Callback = function() end
})

Options.AutoFarmRaids = Tabs.Main:CreateToggle({
	Name = "Auto Farm Raids",
	CurrentValue = false,
	Flag = "AutoFarmRaids",
	Callback = function() end
})

Options.AutoRetry = Tabs.Main:CreateToggle({
	Name = "Auto Retry",
	CurrentValue = false,
	Flag = "AutoRetry",
	Callback = function() end
})

Options.SoloOnly = Tabs.Main:CreateToggle({
	Name = "Solo Only",
	CurrentValue = false,
	Flag = "SoloOnly",
	Callback = function() end
})

Options.AutoReturnToLobby = Tabs.Main:CreateToggle({
	Name = "Auto Return to Lobby",
	CurrentValue = false,
	Flag = "AutoReturnToLobby",
	Callback = function() end
})

Options.ReturnAfterXGames = Tabs.Main:CreateSlider({
	Name = "Return to lobby after x games",
	Range = {1, 250},
	Increment = 1,
	Suffix = "",
	CurrentValue = 10,
	Flag = "ReturnAfterXGames",
	Callback = function() end
})

Options.AutoStartToggle = Tabs.Main:CreateToggle({
	Name = "Auto Start",
	CurrentValue = false,
	Flag = "AutoStartToggle",
	Callback = function() end
})

Options.StartAfterXSeconds = Tabs.Main:CreateSlider({
	Name = "Start after x seconds",
	Range = {0, 500},
	Increment = 1,
	Suffix = "",
	CurrentValue = 0,
	Flag = "StartAfterXSeconds",
	Callback = function() end
})

Tabs.Main:CreateSection("Movement")

Options.MovementMode = Tabs.Main:CreateDropdown({
	Name = "Movement Mode",
	Options = {"Teleport", "Hover"},
	CurrentOption = {"Teleport"},
	MultipleOptions = false,
	Flag = "MovementMode",
	Callback = function() end
})

Options.HoverSpeed = Tabs.Main:CreateSlider({
	Name = "Hover Speed",
	Range = {0, 500},
	Increment = 1,
	Suffix = "",
	CurrentValue = 400,
	Flag = "HoverSpeed",
	Callback = function() end
})

Options.FloatHeight = Tabs.Main:CreateSlider({
	Name = "Float Height",
	Range = {0, 300},
	Increment = 1,
	Suffix = "",
	CurrentValue = 300,
	Flag = "FloatHeight",
	Callback = function() end
})

Tabs.Main:CreateSection("Auto Start")

local MissionMaps       = { "Shiganshina", "Trost", "Outskirts", "Forest", "Stohess", "Chapel" }
local RaidMaps          = { "Trost", "Shiganshina", "Stohess", "Colossal" }
local DifficultyOptions = { "Easy", "Normal", "Hard", "Severe", "Aberrant", "Hardest" }
local ModifierOptions   = { "No Skills", "No Talents", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Canon", "Time Trial", "Boring", "Simple" }
local RAID_TITAN_TEXT   = "Trost: Attack Titan\nShiganshina: Armored Titan\nStohess: Female Titan\nColossal: Colossal Titan"
local RaidTitanLabel    = nil

Options.AutoStartType = Tabs.Main:CreateDropdown({
	Name = "Type",
	Options = {"Missions", "Raids"},
	CurrentOption = {"Missions"},
	MultipleOptions = false,
	Flag = "AutoStartType",
	Callback = function(Value)
		local selected = Value[1]
		if selected == "Missions" then
			Options.AutoStartMap:Refresh(MissionMaps)
			Options.AutoStartMap:Set({MissionMaps[1]})
			Options.AutoStartObjective:Refresh(MapObjectives[MissionMaps[1]] or {"Skirmish"})
			Options.AutoStartObjective:Set({(MapObjectives[MissionMaps[1]] or {"Skirmish"})[1]})
			if RaidTitanLabel then pcall(function() RaidTitanLabel:Set({Content = ""}) end) end
		else
			Options.AutoStartMap:Refresh(RaidMaps)
			Options.AutoStartMap:Set({RaidMaps[1]})
			Options.AutoStartObjective:Refresh(MapObjectives[RaidMaps[1]] or {"Skirmish"})
			Options.AutoStartObjective:Set({(MapObjectives[RaidMaps[1]] or {"Skirmish"})[1]})
			if RaidTitanLabel then pcall(function() RaidTitanLabel:Set({Content = RAID_TITAN_TEXT}) end) end
		end
	end
})

Options.AutoStartMap = Tabs.Main:CreateDropdown({
	Name = "Map",
	Options = MissionMaps,
	CurrentOption = {MissionMaps[1]},
	MultipleOptions = false,
	Flag = "AutoStartMap",
	Callback = function(Value)
		local selected = Value[1]
		local objectives = MapObjectives[selected] or {"Skirmish"}
		Options.AutoStartObjective:Refresh(objectives)
		Options.AutoStartObjective:Set({objectives[1]})
	end
})

Options.AutoStartObjective = Tabs.Main:CreateDropdown({
	Name = "Objective",
	Options = MapObjectives["Shiganshina"],
	CurrentOption = {MapObjectives["Shiganshina"][1]},
	MultipleOptions = false,
	Flag = "AutoStartObjective",
	Callback = function() end
})

Options.AutoStartDifficulty = Tabs.Main:CreateDropdown({
	Name = "Difficulty",
	Options = DifficultyOptions,
	CurrentOption = {DifficultyOptions[1]},
	MultipleOptions = false,
	Flag = "AutoStartDifficulty",
	Callback = function() end
})

RaidTitanLabel = Tabs.Main:CreateParagraph({Title = "", Content = ""})

Options.AutoStartModifiers = Tabs.Main:CreateDropdown({
	Name = "Modifiers",
	Options = ModifierOptions,
	CurrentOption = {},
	MultipleOptions = true,
	Flag = "AutoStartModifiers",
	Callback = function() end
})

Options.MaxRewardModifier = Tabs.Main:CreateToggle({
	Name = "Max Reward Modifier",
	CurrentValue = false,
	Flag = "MaxRewardModifier",
	Callback = function(Value)
		if Value then
			Options.AutoStartModifiers:Set({
				"No Skills", "No Talents", "Nightmare",
				"Oddball", "Injury Prone", "Chronic Injuries",
				"Fog", "Glass Canon", "Time Trial"
			})
		else
			Options.AutoStartModifiers:Set({})
		end
	end
})

-- ========================
--      UTILITY TAB
-- ========================

Tabs.Utility:CreateSection("Combat Settings")

Options.AutoRefill = Tabs.Utility:CreateToggle({
	Name = "Auto Reload/Refill",
	CurrentValue = false,
	Flag = "AutoRefill",
	Callback = function() end
})

Options.AutoEscape = Tabs.Utility:CreateToggle({
	Name = "Auto Escape",
	CurrentValue = false,
	Flag = "AutoEscape",
	Callback = function() end
})

Options.MultiHit = Tabs.Utility:CreateToggle({
	Name = "Multi Hit",
	CurrentValue = false,
	Flag = "MultiHit",
	Callback = function() end
})

Options.TitansPerHit = Tabs.Utility:CreateSlider({
	Name = "Titans per hit",
	Range = {1, 20},
	Increment = 1,
	Suffix = "",
	CurrentValue = 3,
	Flag = "TitansPerHit",
	Callback = function() end
})

Tabs.Utility:CreateSection("Security")

Options.Failsafe = Tabs.Utility:CreateToggle({
	Name = "Failsafe",
	CurrentValue = false,
	Flag = "Failsafe",
	Callback = function(Value)
		if Value then
			StartFailsafe()
			Rayfield:Notify({
				Title = "Failsafe",
				Content = "Enabled! Will return to lobby after " .. Options.FailsafeTimeout.CurrentValue .. " min of idle time.",
				Duration = 4
			})
		else
			StopFailsafe()
			Rayfield:Notify({Title = "Failsafe", Content = "Disabled.", Duration = 3})
		end
	end
})

Options.FailsafeTimeout = Tabs.Utility:CreateSlider({
	Name = "Timeout",
	Range = {1, 20},
	Increment = 1,
	Suffix = " min",
	CurrentValue = 10,
	Flag = "FailsafeTimeout",
	Callback = function(Value)
		if Options.Failsafe.CurrentValue then
			ResetIdleTimer()
			Rayfield:Notify({Title = "Failsafe", Content = "Timeout updated to " .. Value .. " min. Timer reset.", Duration = 3})
		end
	end
})

Tabs.Utility:CreateSection("Mastery Farm")

Options.TitanMasteryFarm = Tabs.Utility:CreateToggle({
	Name = "Titan Mastery Farm",
	CurrentValue = false,
	Flag = "TitanMasteryFarm",
	Callback = function() end
})

Options.MasteryMode = Tabs.Utility:CreateDropdown({
	Name = "Mastery Mode",
	Options = {"Both", "ODM", "Titan"},
	CurrentOption = {"Both"},
	MultipleOptions = false,
	Flag = "MasteryMode",
	Callback = function() end
})

Tabs.Utility:CreateSection("Extras")

Options.AutoSkipCutscenes = Tabs.Utility:CreateToggle({
	Name = "Auto Skip Cutscenes",
	CurrentValue = false,
	Flag = "AutoSkipCutscenes",
	Callback = function() end
})

Options.DieAtStreak = Tabs.Utility:CreateToggle({
	Name = "Die at Streak",
	CurrentValue = false,
	Flag = "DieAtStreak",
	Callback = function() end
})

Options.DieAtXStreak = Tabs.Utility:CreateSlider({
	Name = "Die at x streak",
	Range = {5000, 100000},
	Increment = 1,
	Suffix = "",
	CurrentValue = 10000,
	Flag = "DieAtXStreak",
	Callback = function() end
})

Options.AutoOpenChests = Tabs.Utility:CreateToggle({
	Name = "Auto Open Chests",
	CurrentValue = false,
	Flag = "AutoOpenChests",
	Callback = function() end
})

Options.AutoOpen2ndChest = Tabs.Utility:CreateToggle({
	Name = "Auto Open 2nd Chest",
	CurrentValue = false,
	Flag = "AutoOpen2ndChest",
	Callback = function() end
})

Options.DeleteMap = Tabs.Utility:CreateToggle({
	Name = "Delete Map (FPS Boost)",
	CurrentValue = false,
	Flag = "DeleteMap",
	Callback = function(Value)
		if Value then
			DeleteMap()
		else
			RestoreMap()
		end
	end
})

-- ========================
--      GLOBAL TAB
-- ========================

Tabs.Global:CreateSection("Family Roll")

Options.AutoRoll = Tabs.Global:CreateToggle({
	Name = "Auto Roll",
	CurrentValue = false,
	Flag = "AutoRoll",
	Callback = function(Value)
		-- functionality later
	end
})

Options.SelectFamilies = Tabs.Global:CreateDropdown({
	Name = "Select Families",
	Options = {"Yeager", "Ackerman", "Reiss", "Helos", "Fritz", "Shiki"},
	CurrentOption = {},
	MultipleOptions = true,
	Flag = "SelectFamilies",
	Callback = function(Value)
		-- functionality later
	end
})

Options.StopAt = Tabs.Global:CreateDropdown({
	Name = "Stop At",
	Options = {"Legendary", "Mythic", "Secret"},
	CurrentOption = {},
	MultipleOptions = true,
	Flag = "StopAt",
	Callback = function(Value)
		-- functionality later
	end
})

Tabs.Global:CreateSection("AddOns")

Options.AutoHideGui = Tabs.Global:CreateToggle({
	Name = "Auto Hide Gui",
	CurrentValue = false,
	Flag = "AutoHideGui",
	Callback = function(Value)
		-- functionality later
	end
})

Options.AutoClaimAchievements = Tabs.Global:CreateToggle({
	Name = "Auto Claim Achievements",
	CurrentValue = false,
	Flag = "AutoClaimAchievements",
	Callback = function(Value)
		-- functionality later
	end
})

Options.Disable3DRendering = Tabs.Global:CreateToggle({
	Name = "Disable 3D Rendering",
	CurrentValue = false,
	Flag = "Disable3DRendering",
	Callback = function(Value)
		if Value then
			Disable3DRendering()
		else
			Enable3DRendering()
		end
	end
})

Tabs.Global:CreateSection("Webhook")

Options.RewardWebhook = Tabs.Global:CreateToggle({
	Name = "Reward Webhook",
	CurrentValue = false,
	Flag = "RewardWebhook",
	Callback = function(Value)
		-- functionality later
	end
})

Options.MythicFamilyWebhook = Tabs.Global:CreateToggle({
	Name = "Mythic Family Webhook",
	CurrentValue = false,
	Flag = "MythicFamilyWebhook",
	Callback = function(Value)
		-- functionality later
	end
})

Options.WebhookURL = Tabs.Global:CreateInput({
	Name = "Webhook URL",
	CurrentValue = "",
	PlaceholderText = "https://discord.com/api/webhooks/...",
	RemoveTextAfterFocusLost = false,
	Flag = "WebhookURL",
	Callback = function(Value)
		-- functionality later
	end
})

Tabs.Global:CreateSection("Level")

Options.AutoPrestige = Tabs.Global:CreateToggle({
	Name = "Auto Prestige",
	CurrentValue = false,
	Flag = "AutoPrestige",
	Callback = function(Value)
		-- functionality later
	end
})

Options.PrestigeAt = Tabs.Global:CreateSlider({
	Name = "Prestige at (millions)",
	Range = {1, 1000},
	Increment = 1,
	Suffix = "M",
	CurrentValue = 100,
	Flag = "PrestigeAt",
	Callback = function(Value)
		-- functionality later
	end
})

-- ========================
--      SETTINGS TAB
-- ========================

Tabs.Settings:CreateSection("Menu")

Tabs.Settings:CreateKeybind({
	Name = "Menu bind",
	CurrentKeybind = "RightShift",
	HoldToInteract = false,
	Flag = "MenuKeybind",
	Callback = function(Keybind) end
})

Tabs.Settings:CreateButton({
	Name = "Unload",
	Callback = function()
		StopFailsafe()
		if Options.DeleteMap and Options.DeleteMap.CurrentValue then
			RestoreMap()
		end
		Enable3DRendering()
		for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
			if gui.Name == "Rayfield" then
				gui:Destroy()
			end
		end
		print("Unloaded!")
	end
})

Tabs.Settings:CreateSection("Auto Execute")

Options.AutoExecEnabled = Tabs.Settings:CreateToggle({
	Name = "Auto Execute",
	CurrentValue = false,
	Flag = "AutoExecEnabled",
	Callback = function(Value)
		if Value then
			-- Build the script string that should re-run after teleport
			local scriptString = string.format(
				'loadstring(game:HttpGet("%s"))()',
				HUB_SCRIPT_URL
			)

			-- Try multiple executor APIs
			local ok, err = pcall(function()
				if type(queue_on_teleport) == "function" then
					queue_on_teleport(scriptString)
				elseif type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
					syn.queue_on_teleport(scriptString)
				elseif type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" then
					fluxus.queue_on_teleport(scriptString)
				elseif type(getgenv().queue_on_teleport) == "function" then
					getgenv().queue_on_teleport(scriptString)
				else
					error("Executor does not support queue_on_teleport")
				end
			end)

			if ok then
				Rayfield:Notify({
					Title = "Auto Execute",
					Content = "Enabled! Hub will reload on next teleport.",
					Duration = 4
				})
			else
				Rayfield:Notify({
					Title = "Auto Execute Error",
					Content = "Your executor doesn't support queue_on_teleport.",
					Duration = 4
				})
				-- Turn the toggle back off safely
				task.delay(0.1, function()
					Options.AutoExecEnabled:Set(false)
				end)
			end
		else
			Rayfield:Notify({Title = "Auto Execute", Content = "Disabled.", Duration = 3})
		end
	end
})

Tabs.Settings:CreateSection("Theme")

Options.ThemeSelector = Tabs.Settings:CreateDropdown({
	Name = "UI Theme",
	Options = {"Default", "DarkRed", "Ocean", "Midnight", "Forest", "Sunset", "AOT Green"},
	CurrentOption = {"Default"},
	MultipleOptions = false,
	Flag = "ThemeSelector",
	Callback = function(Value)
		local selected = Value[1]
		SetRayfieldTheme(selected)
	end
})

Tabs.Settings:CreateSection("Config Manager")

ConfigNameInput = Tabs.Settings:CreateInput({
	Name = "Config Name",
	CurrentValue = "",
	PlaceholderText = "Enter name...",
	RemoveTextAfterFocusLost = false,
	Flag = "ConfigNameInput",
	Callback = function() end
})

Tabs.Settings:CreateButton({
	Name = "💾 Save Config",
	Callback = function()
		local name = ConfigNameInput.CurrentValue
		if not name or ConfigSystem:CleanName(name) == "" then
			Rayfield:Notify({Title = "Config Manager", Content = "Enter a config name first!", Duration = 3})
			return
		end
		local ok, err = ConfigSystem:Save(name)
		if ok then
			Rayfield:Notify({Title = "Config Saved", Content = '"' .. ConfigSystem:CleanName(name) .. '" saved!', Duration = 3})
		else
			Rayfield:Notify({Title = "Save Failed", Content = tostring(err), Duration = 4})
		end

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
			if selected and selected[1] then
				name = selected[1]
			else
				Rayfield:Notify({Title = "Config Manager", Content = "Enter a name or select from Load Config!", Duration = 3})
				return
			end
		end
		local clean = ConfigSystem:CleanName(name)
		local exactPath = ConfigSystem:FindFileExact(clean)
		if not exactPath then
			Rayfield:Notify({Title = "Config Manager", Content = '"' .. clean .. '" does not exist. Use Save first.', Duration = 3})
			return
		end
		local ok, err = ConfigSystem:Save(clean)
		if ok then
			Rayfield:Notify({Title = "Config Overwritten", Content = '"' .. clean .. '" updated!', Duration = 3})
		else
			Rayfield:Notify({Title = "Overwrite Failed", Content = tostring(err), Duration = 4})
		end

		local list = ConfigSystem:List()
		ConfigLoadDropdown:Refresh(list)
		ConfigAutoloadDropdown:Refresh(list)
	end
})

ConfigLoadDropdown = Tabs.Settings:CreateDropdown({
	Name = "📂 Load Config",
	Options = ConfigSystem:List(),
	CurrentOption = {},
	MultipleOptions = false,
	Flag = "ConfigLoadDropdown",
	Callback = function(Value)
		local name = Value[1]
		if name then
			local ok, loaded, failed = ConfigSystem:Load(name)
			if ok then
				Rayfield:Notify({Title = "Config Loaded", Content = '"' .. name .. '" loaded! (' .. tostring(loaded) .. ' settings)', Duration = 3})
			else
				Rayfield:Notify({Title = "Config Error", Content = tostring(loaded), Duration = 8})
			end
		end
	end
})

ConfigAutoloadDropdown = Tabs.Settings:CreateDropdown({
	Name = "🔄 Autoload Config",
	Options = ConfigSystem:List(),
	CurrentOption = {},
	MultipleOptions = false,
	Flag = "ConfigAutoloadDropdown",
	Callback = function(Value)
		local name = Value[1]
		if name then
			ConfigSystem:SetAutoload(name)
			Rayfield:Notify({Title = "Autoload Set", Content = '"' .. name .. '" will autoload next time.', Duration = 3})
		end
	end
})

Tabs.Settings:CreateButton({
	Name = "❌ Reset Autoload",
	Callback = function()
		ConfigSystem:ResetAutoload()
		pcall(function() ConfigAutoloadDropdown:Set({}) end)
		Rayfield:Notify({Title = "Autoload", Content = "Autoload has been reset.", Duration = 3})
	end
})

Tabs.Settings:CreateButton({
	Name = "🗑️ Delete Config",
	Callback = function()
		local name = ConfigNameInput.CurrentValue
		if not name or ConfigSystem:CleanName(name) == "" then
			Rayfield:Notify({Title = "Config Manager", Content = "Enter the config name to delete!", Duration = 3})
			return
		end
		ConfigSystem:Delete(name)
		Rayfield:Notify({Title = "Config Deleted", Content = '"' .. ConfigSystem:CleanName(name) .. '" deleted.', Duration = 3})

		local list = ConfigSystem:List()
		ConfigLoadDropdown:Refresh(list)
		ConfigAutoloadDropdown:Refresh(list)
	end
})

-- ========================
--   CLEANUP & LOAD
-- ========================

-- Apply saved theme on load
task.delay(1, function()
	local savedTheme = Options.ThemeSelector and Options.ThemeSelector.CurrentValue
	if savedTheme and savedTheme[1] and savedTheme[1] ~= "Default" then
		SetRayfieldTheme(savedTheme[1])
	end
end)

-- ROBUST AUTOLOAD (runs exactly once)
local hasAutoloaded = false

task.spawn(function()
	-- Wait until Rayfield has built all Options
	local ready = false
	for i = 1, 60 do
		local count = 0
		for _ in pairs(Options) do count = count + 1 end
		if count >= 10 then ready = true; break end
		task.wait(0.5)
	end
	if not ready then
		warn("[ZangetsuHub] Autoload timeout.")
		return
	end

	-- Prevent double-loading
	if hasAutoloaded then return end
	hasAutoloaded = true

	local autoload = ConfigSystem:GetAutoload()
	if not autoload then return end

	local ok, loaded, failed = ConfigSystem:Load(autoload)
	if ok then
		-- Force UI refresh only for elements that need it (avoid re-triggering callbacks)
		for flag, option in pairs(Options) do
			if option and option.CurrentValue ~= nil and option.Set then
				pcall(function()
					-- Only call Set if the value actually changed from default
					-- This prevents cascading callbacks from re-firing
					option:Set(option.CurrentValue)
				end)
			end
		end
		
		Rayfield:Notify({
			Title = "✅ Config Autoloaded",
			Content = '"' .. autoload .. '" loaded! (' .. tostring(loaded) .. ' settings)',
			Duration = 5
		})
		
		-- Update dropdown visuals without triggering their Callbacks
		pcall(function()
			if ConfigLoadDropdown then
				ConfigLoadDropdown.CurrentOption = {autoload}
			end
			if ConfigAutoloadDropdown then
				ConfigAutoloadDropdown.CurrentOption = {autoload}
			end
		end)
	else
		Rayfield:Notify({
			Title = "❌ Autoload Failed",
			Content = tostring(loaded),
			Duration = 10
		})
	end
end)

Rayfield:Notify({
	Title = "Zangetsu Hub",
	Content = "Rayfield UI loaded successfully!",
	Duration = 5
})
