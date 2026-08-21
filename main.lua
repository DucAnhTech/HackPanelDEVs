-- [[ DEV MOVEMENT + SPECTATE V14 (AIMBOT & FPS BOOSTER ENHANCED) ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

---------------------------------------------------------
-- 0. TỰ DỌN DẸP SCRIPT CŨ
---------------------------------------------------------
if _G.DevMasterUnload then
	_G.DevMasterUnload()
end

---------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------
local function createTween(instance, info, properties)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

local function makeDraggable(gui)
	local dragging, dragInput, dragStart, startPos
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			createTween(gui, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			})
		end
	end)
end

---------------------------------------------------------
-- 1. KHỞI TẠO GUI CHÍNH
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevWindowGui_V14"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local logoBtn = Instance.new("TextButton")
logoBtn.Name = "LogoButton"
logoBtn.Size = UDim2.new(0, 50, 0, 50)
logoBtn.Position = UDim2.new(0, 15, 0.4, 0)
logoBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
logoBtn.Text = "⚡"
logoBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
logoBtn.TextSize = 24
logoBtn.Font = Enum.Font.GothamBold
logoBtn.Parent = screenGui
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)
makeDraggable(logoBtn)

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(0, 230, 255)
logoStroke.Thickness = 2
logoStroke.Parent = logoBtn

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 390)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -195)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
makeDraggable(mainFrame)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(35, 35, 45)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DEV MASTER V14 PRO (AIMBOT & BOOST)"
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -68, 0, 6)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Parent = topBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -48)
sidebar.Position = UDim2.new(0, 6, 0, 44)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 6)
sidebarPadding.PaddingLeft = UDim.new(0, 6)
sidebarPadding.PaddingRight = UDim.new(0, 6)
sidebarPadding.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -148, 1, -48)
contentArea.Position = UDim2.new(0, 142, 0, 44)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

---------------------------------------------------------
-- 2. HỘP THOẠI XÁC NHẬN TẮT
---------------------------------------------------------
local confirmModal = Instance.new("Frame")
confirmModal.Size = UDim2.new(0, 300, 0, 130)
confirmModal.Position = UDim2.new(0.5, -150, 0.5, -65)
confirmModal.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
confirmModal.Visible = false
confirmModal.ZIndex = 10
confirmModal.Parent = screenGui
Instance.new("UICorner", confirmModal).CornerRadius = UDim.new(0, 8)

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(220, 50, 70)
modalStroke.Thickness = 1.5
modalStroke.Parent = confirmModal

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -20, 0, 45)
modalTitle.Position = UDim2.new(0, 10, 0, 10)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "Xác nhận tắt hoàn toàn Script?"
modalTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 13
modalTitle.ZIndex = 11
modalTitle.Parent = confirmModal

local confirmYesBtn = Instance.new("TextButton")
confirmYesBtn.Size = UDim2.new(0, 125, 0, 32)
confirmYesBtn.Position = UDim2.new(0, 15, 1, -42)
confirmYesBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
confirmYesBtn.Text = "ĐỒNG Ý"
confirmYesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmYesBtn.Font = Enum.Font.GothamBold
confirmYesBtn.TextSize = 12
confirmYesBtn.ZIndex = 11
confirmYesBtn.Parent = confirmModal
Instance.new("UICorner", confirmYesBtn).CornerRadius = UDim.new(0, 6)

local confirmNoBtn = Instance.new("TextButton")
confirmNoBtn.Size = UDim2.new(0, 125, 0, 32)
confirmNoBtn.Position = UDim2.new(1, -140, 1, -42)
confirmNoBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
confirmNoBtn.Text = "HỦY BỎ"
confirmNoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmNoBtn.Font = Enum.Font.GothamBold
confirmNoBtn.TextSize = 12
confirmNoBtn.ZIndex = 11
confirmNoBtn.Parent = confirmModal
Instance.new("UICorner", confirmNoBtn).CornerRadius = UDim.new(0, 6)

---------------------------------------------------------
-- 3. TẠO TAB & UI COMPONENTS
---------------------------------------------------------
local pages = {}

local function createTab(name)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1, 0, 0, 28)
	tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	tabBtn.Text = name
	tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 11
	tabBtn.Parent = sidebar
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 255)
	page.Visible = false
	page.Parent = contentArea

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = page

	pages[name] = {Button = tabBtn, Page = page}

	tabBtn.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do
			p.Page.Visible = false
			createTween(p.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 36), TextColor3 = Color3.fromRGB(160, 160, 180)})
		end
		page.Visible = true
		createTween(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 240), TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)

	return page
end

local tabMain = createTab("Trạng Thái")
local tabAimbot = createTab("Aimbot Pro")
local tabMove = createTab("Di Chuyển")
local tabWaypoint = createTab("Waypoint")
local tabVisual = createTab("ESP & Khác")
local tabBooster = createTab("Giảm Lag FPS")
local tabKeybinds = createTab("Phím Tắt")

pages["Trạng Thái"].Page.Visible = true
pages["Trạng Thái"].Button.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
pages["Trạng Thái"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

---------------------------------------------------------
-- STATS PANEL
---------------------------------------------------------
local statsContainer = Instance.new("Frame")
statsContainer.Size = UDim2.new(1, -6, 0, 95)
statsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
statsContainer.Parent = tabMain
Instance.new("UICorner", statsContainer).CornerRadius = UDim.new(0, 6)

local statsGrid = Instance.new("UIGridLayout")
statsGrid.CellSize = UDim2.new(0.48, 0, 0.43, 0)
statsGrid.CellPadding = UDim2.new(0.03, 0, 0.08, 0)
statsGrid.Parent = statsContainer

local function createStatCard(titleText, defaultVal)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	card.Parent = statsContainer
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, 0, 0.4, 0)
	titleLbl.Position = UDim2.new(0, 0, 0.08, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = titleText
	titleLbl.TextColor3 = Color3.fromRGB(130, 130, 150)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 10
	titleLbl.Parent = card

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(1, 0, 0.5, 0)
	valLbl.Position = UDim2.new(0, 0, 0.45, 0)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = defaultVal
	valLbl.TextColor3 = Color3.fromRGB(0, 230, 150)
	valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 13
	valLbl.Parent = card

	return valLbl
end

local fpsLabel = createStatCard("FPS", "60")
local pingLabel = createStatCard("PING", "0 ms")
local playersLabel = createStatCard("PLAYERS", "0/" .. tostring(Players.MaxPlayers))
local timeLabel = createStatCard("PLAYTIME", "00:00:00")

---------------------------------------------------------
-- UI BUILDERS
---------------------------------------------------------
local function createToggle(parent, text)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -6, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.28, 0, 0.72, 0)
	btn.Position = UDim2.new(0.69, 0, 0.14, 0)
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
	btn.Text = "TẮT"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	return btn
end

local function createInputGroup(parent, text, defaultVal)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -6, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.42, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.24, 0, 0.72, 0)
	box.Position = UDim2.new(0.43, 0, 0.14, 0)
	box.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
	box.Text = defaultVal
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.GothamMedium
	box.TextSize = 11
	box.Parent = frame
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.28, 0, 0.72, 0)
	btn.Position = UDim2.new(0.69, 0, 0.14, 0)
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
	btn.Text = "TẮT"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	return box, btn
end

local function createActionButton(parent, text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 34)
	btn.BackgroundColor3 = color or Color3.fromRGB(0, 140, 240)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

---------------------------------------------------------
-- 4. TÍNH NĂNG AIMBOT PRO
---------------------------------------------------------
local aimbotToggleBtn = createToggle(tabAimbot, "Aimbot (Giữ Chuột Phải)")
local aimPartBox, _ = createInputGroup(tabAimbot, "Bộ Phận Nhắm", "Head")
local fovToggleBtn = createToggle(tabAimbot, "Hiện Vòng FOV")
local fovRadiusBox, _ = createInputGroup(tabAimbot, "Bán Kính FOV", "120")
local aimSmoothBox, _ = createInputGroup(tabAimbot, "Độ Mượt (Smooth 0.1-1)", "0.2")
local wallCheckBtn = createToggle(tabAimbot, "Wall Check (Kiểm Tra Tường)")

local aimbotEnabled = false
local fovCircleEnabled = false
local wallCheckEnabled = false
local aimTargetPart = "Head"
local fovRadius = 120
local aimSmoothness = 0.2

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(0, 230, 255)
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Visible = false

local function isPartVisible(part)
	if not wallCheckEnabled then return true end
	local origin = camera.CFrame.Position
	local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character, part.Parent}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(origin, direction, raycastParams)
	return result == nil
end

local function getClosestPlayerToCursor()
	local closestPlayer = nil
	local shortestDistance = fovRadius

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player and targetPlayer.Character then
			local targetChar = targetPlayer.Character
			local targetPart = targetChar:FindFirstChild(aimTargetPart) or targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

			if targetPart and targetHum and targetHum.Health > 0 then
				local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local mousePos = Vector2.new(mouse.X, mouse.Y)
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

					if dist < shortestDistance and isPartVisible(targetPart) then
						shortestDistance = dist
						closestPlayer = targetPart
					end
				end
			end
		end
	end
	return closestPlayer
end

fovRadiusBox.FocusLost:Connect(function()
	local num = tonumber(fovRadiusBox.Text)
	if num then fovRadius = num else fovRadiusBox.Text = tostring(fovRadius) end
end)

aimSmoothBox.FocusLost:Connect(function()
	local num = tonumber(aimSmoothBox.Text)
	if num then aimSmoothness = math.clamp(num, 0.01, 1) else aimSmoothBox.Text = tostring(aimSmoothness) end
end)

aimPartBox.FocusLost:Connect(function()
	if aimPartBox.Text ~= "" then aimTargetPart = aimPartBox.Text end
end)

aimbotToggleBtn.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	updateButtonState(aimbotToggleBtn, aimbotEnabled)
end)

fovToggleBtn.MouseButton1Click:Connect(function()
	fovCircleEnabled = not fovCircleEnabled
	updateButtonState(fovToggleBtn, fovCircleEnabled)
	fovCircle.Visible = fovCircleEnabled
end)

wallCheckBtn.MouseButton1Click:Connect(function()
	wallCheckEnabled = not wallCheckEnabled
	updateButtonState(wallCheckBtn, wallCheckEnabled)
end)

---------------------------------------------------------
-- 5. GIẢM LAG / FPS BOOSTER
---------------------------------------------------------
local boostFpsBtn = createActionButton(tabBooster, "🚀 Tối Ưu Đồ Họa (Siêu Mượt FPS)", Color3.fromRGB(0, 180, 120))
local removeTexturesBtn = createActionButton(tabBooster, "🗑️ Xóa Vật Liệu Nặng (Clear Textures)", Color3.fromRGB(200, 140, 0))
local removeEffectsBtn = createActionButton(tabBooster, "✨ Tắt Hiệu Ứng Hạt / Khoảng Khói", Color3.fromRGB(120, 60, 200))

boostFpsBtn.MouseButton1Click:Connect(function()
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v:IsA("MeshPart") then
			v.Material = Enum.Material.SmoothPlastic
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v:Destroy()
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
			v.Enabled = false
		end
	end
	boostFpsBtn.Text = "✓ Đã Tối Ưu FPS!"
	task.wait(1.5)
	boostFpsBtn.Text = "🚀 Tối Ưu Đồ Họa (Siêu Mượt FPS)"
end)

removeTexturesBtn.MouseButton1Click:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Decal") or v:IsA("Texture") then
			v:Destroy()
		end
	end
	removeTexturesBtn.Text = "✓ Đã Xóa Kết Cấu!"
	task.wait(1.5)
	removeTexturesBtn.Text = "🗑️ Xóa Vật Liệu Nặng (Clear Textures)"
end)

removeEffectsBtn.MouseButton1Click:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
			v.Enabled = false
		end
	end
	removeEffectsBtn.Text = "✓ Đã Ẩn Hiệu Ứng!"
	task.wait(1.5)
	removeEffectsBtn.Text = "✨ Tắt Hiệu Ứng Hạt / Khoảng Khói"
end)

---------------------------------------------------------
-- 6. TÍNH NĂNG VÀ NÚT BẤM DI CHUYỂN
---------------------------------------------------------
local godmodeBtn = createToggle(tabMain, "Godmode (An Toàn)")

local freecamSpeedBox, freecamBtn = createInputGroup(tabMove, "Freecam (WASD + E/Q)", "1")
local clickTpBtn = createToggle(tabMove, "Click TP (Ctrl + Click)")
local infJumpBtn = createToggle(tabMove, "Nhảy vô hạn")
local noclipBtn = createToggle(tabMove, "Xuyên tường (Noclip)")
local walkSpeedBox, walkSpeedBtn = createInputGroup(tabMove, "Tốc độ chạy", "50")
local jumpPowerBox, jumpPowerBtn = createInputGroup(tabMove, "Độ cao nhảy", "100")
local longJumpBox, longJumpBtn = createInputGroup(tabMove, "Độ xa nhảy", "100")
local flySpeedBox, flyBtn = createInputGroup(tabMove, "Bay (Fly V2)", "50")

---------------------------------------------------------
-- 7. WAYPOINT SYSTEM
---------------------------------------------------------
local fileName = "DevWaypoints_" .. tostring(game.PlaceId) .. ".json"

local wpInputFrame = Instance.new("Frame")
wpInputFrame.Size = UDim2.new(1, -6, 0, 34)
wpInputFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
wpInputFrame.Parent = tabWaypoint
Instance.new("UICorner", wpInputFrame).CornerRadius = UDim.new(0, 6)

local wpNameBox = Instance.new("TextBox")
wpNameBox.Size = UDim2.new(0.62, 0, 0.72, 0)
wpNameBox.Position = UDim2.new(0.02, 0, 0.14, 0)
wpNameBox.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
wpNameBox.PlaceholderText = "Nhập tên điểm..."
wpNameBox.Text = ""
wpNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
wpNameBox.Font = Enum.Font.GothamMedium
wpNameBox.TextSize = 11
wpNameBox.Parent = wpInputFrame
Instance.new("UICorner", wpNameBox).CornerRadius = UDim.new(0, 4)

local wpSaveBtn = Instance.new("TextButton")
wpSaveBtn.Size = UDim2.new(0.32, 0, 0.72, 0)
wpSaveBtn.Position = UDim2.new(0.66, 0, 0.14, 0)
wpSaveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
wpSaveBtn.Text = "+ Lưu Điểm"
wpSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wpSaveBtn.Font = Enum.Font.GothamBold
wpSaveBtn.TextSize = 10
wpSaveBtn.Parent = wpInputFrame
Instance.new("UICorner", wpSaveBtn).CornerRadius = UDim.new(0, 4)

local fileControlFrame = Instance.new("Frame")
fileControlFrame.Size = UDim2.new(1, -6, 0, 34)
fileControlFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
fileControlFrame.Parent = tabWaypoint
Instance.new("UICorner", fileControlFrame).CornerRadius = UDim.new(0, 6)

local saveFileBtn = Instance.new("TextButton")
saveFileBtn.Size = UDim2.new(0.48, 0, 0.72, 0)
saveFileBtn.Position = UDim2.new(0.01, 0, 0.14, 0)
saveFileBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
saveFileBtn.Text = "💾 Lưu File"
saveFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveFileBtn.Font = Enum.Font.GothamBold
saveFileBtn.TextSize = 10
saveFileBtn.Parent = fileControlFrame
Instance.new("UICorner", saveFileBtn).CornerRadius = UDim.new(0, 4)

local loadFileBtn = Instance.new("TextButton")
loadFileBtn.Size = UDim2.new(0.48, 0, 0.72, 0)
loadFileBtn.Position = UDim2.new(0.51, 0, 0.14, 0)
loadFileBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
loadFileBtn.Text = "📂 Tải File"
loadFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadFileBtn.Font = Enum.Font.GothamBold
loadFileBtn.TextSize = 10
loadFileBtn.Parent = fileControlFrame
Instance.new("UICorner", loadFileBtn).CornerRadius = UDim.new(0, 4)

local autoTpIntervalBox, autoTpToggleBtn = createInputGroup(tabWaypoint, "Auto TP Loop (s)", "3")

local wpListContainer = Instance.new("Frame")
wpListContainer.Size = UDim2.new(1, -6, 1, -125)
wpListContainer.BackgroundTransparency = 1
wpListContainer.Parent = tabWaypoint

local wpListLayout = Instance.new("UIListLayout")
wpListLayout.Padding = UDim.new(0, 5)
wpListLayout.Parent = wpListContainer

---------------------------------------------------------
-- 8. VISUAL / ESP / SPECTATE
---------------------------------------------------------
local espBtn = createToggle(tabVisual, "Chế độ ESP Người Chơi")
local fullbrightBtn = createToggle(tabVisual, "Fullbright (Sáng đêm)")
local antiAfkBtn = createToggle(tabVisual, "Anti-AFK (Chống Kick)")

local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(1, -6, 0, 34)
tpFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
tpFrame.Parent = tabVisual
Instance.new("UICorner", tpFrame).CornerRadius = UDim.new(0, 6)

local tpBox = Instance.new("TextBox")
tpBox.Size = UDim2.new(0.4, 0, 0.72, 0)
tpBox.Position = UDim2.new(0.02, 0, 0.14, 0)
tpBox.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
tpBox.PlaceholderText = "Tên người chơi..."
tpBox.Text = ""
tpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBox.Font = Enum.Font.GothamMedium
tpBox.TextSize = 10
tpBox.Parent = tpFrame
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0, 4)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.26, 0, 0.72, 0)
tpBtn.Position = UDim2.new(0.44, 0, 0.14, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
tpBtn.Text = "Teleport"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 10
tpBtn.Parent = tpFrame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)

local spectateBtn = Instance.new("TextButton")
spectateBtn.Size = UDim2.new(0.26, 0, 0.72, 0)
spectateBtn.Position = UDim2.new(0.72, 0, 0.14, 0)
spectateBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
spectateBtn.Text = "Spectate"
spectateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spectateBtn.Font = Enum.Font.GothamBold
spectateBtn.TextSize = 10
spectateBtn.Parent = tpFrame
Instance.new("UICorner", spectateBtn).CornerRadius = UDim.new(0, 4)

local serverControlFrame = Instance.new("Frame")
serverControlFrame.Size = UDim2.new(1, -6, 0, 34)
serverControlFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
serverControlFrame.Parent = tabVisual
Instance.new("UICorner", serverControlFrame).CornerRadius = UDim.new(0, 6)

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.48, 0, 0.72, 0)
rejoinBtn.Position = UDim2.new(0.01, 0, 0.14, 0)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
rejoinBtn.Text = "↻ Rejoin Server"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.TextSize = 10
rejoinBtn.Parent = serverControlFrame
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 4)

local serverHopBtn = Instance.new("TextButton")
serverHopBtn.Size = UDim2.new(0.48, 0, 0.72, 0)
serverHopBtn.Position = UDim2.new(0.51, 0, 0.14, 0)
serverHopBtn.BackgroundColor3 = Color3.fromRGB(220, 110, 0)
serverHopBtn.Text = "🌐 Server Hop"
serverHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
serverHopBtn.Font = Enum.Font.GothamBold
serverHopBtn.TextSize = 10
serverHopBtn.Parent = serverControlFrame
Instance.new("UICorner", serverHopBtn).CornerRadius = UDim.new(0, 4)

---------------------------------------------------------
-- 9. REJOIN & SERVER HOP LOGIC
---------------------------------------------------------
rejoinBtn.MouseButton1Click:Connect(function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

serverHopBtn.MouseButton1Click:Connect(function()
	serverHopBtn.Text = "Đang tìm..."
	local placeId = game.PlaceId
	local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"

	task.spawn(function()
		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and result and result.data then
			for _, server in ipairs(result.data) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
					return
				end
			end
		end
		serverHopBtn.Text = "Thử lại sau"
		task.wait(2)
		serverHopBtn.Text = "🌐 Server Hop"
	end)
end)

---------------------------------------------------------
-- 10. THỐNG KÊ REAL-TIME
---------------------------------------------------------
local startTime = os.time()
local frameCount = 0
local fpsTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)
	frameCount += 1
	fpsTimer += deltaTime

	if fpsTimer >= 1 then
		local currentFps = math.floor(frameCount / fpsTimer)
		fpsLabel.Text = tostring(currentFps) .. " FPS"
		
		if currentFps >= 50 then
			fpsLabel.TextColor3 = Color3.fromRGB(0, 230, 150)
		elseif currentFps >= 30 then
			fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		else
			fpsLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
		end

		frameCount = 0
		fpsTimer = 0
	end
end)

task.spawn(function()
	while screenGui.Parent do
		local ping = 0
		local success, result = pcall(function()
			return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)
		if success and result then ping = result end
		pingLabel.Text = tostring(ping) .. " ms"

		playersLabel.Text = tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers)

		local elapsed = os.time() - startTime
		local hours = math.floor(elapsed / 3600)
		local mins = math.floor((elapsed % 3600) / 60)
		local secs = elapsed % 60
		timeLabel.Text = string.format("%02d:%02d:%02d", hours, mins, secs)

		task.wait(0.5)
	end
end)

---------------------------------------------------------
-- 11. LOGIC WAYPOINT
---------------------------------------------------------
local waypointsList = {}
local autoTpEnabled = false
local autoTpInterval = 3
local autoTpThread = nil

local function updateButtonState(btn, state)
	btn.Text = state and "BẬT" or "TẮT"
	createTween(btn, TweenInfo.new(0.2), {
		BackgroundColor3 = state and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(200, 50, 60)
	})
end

local function addWaypointUI(name, cframe)
	local itemData = {Name = name, CFrame = cframe}
	table.insert(waypointsList, itemData)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 32)
	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	frame.Parent = wpListContainer
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.48, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local tpWpBtn = Instance.new("TextButton")
	tpWpBtn.Size = UDim2.new(0, 50, 0.7, 0)
	tpWpBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
	tpWpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
	tpWpBtn.Text = "Đến"
	tpWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tpWpBtn.Font = Enum.Font.GothamBold
	tpWpBtn.TextSize = 10
	tpWpBtn.Parent = frame
	Instance.new("UICorner", tpWpBtn).CornerRadius = UDim.new(0, 4)

	local delWpBtn = Instance.new("TextButton")
	delWpBtn.Size = UDim2.new(0, 50, 0.7, 0)
	delWpBtn.Position = UDim2.new(0.76, 0, 0.15, 0)
	delWpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
	delWpBtn.Text = "Xóa"
	delWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	delWpBtn.Font = Enum.Font.GothamBold
	delWpBtn.TextSize = 10
	delWpBtn.Parent = frame
	Instance.new("UICorner", delWpBtn).CornerRadius = UDim.new(0, 4)

	tpWpBtn.MouseButton1Click:Connect(function()
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = cframe end
	end)

	delWpBtn.MouseButton1Click:Connect(function()
		for i, v in ipairs(waypointsList) do
			if v == itemData then
				table.remove(waypointsList, i)
				break
			end
		end
		frame:Destroy()
	end)
end

wpSaveBtn.MouseButton1Click:Connect(function()
	local name = wpNameBox.Text
	if name == "" then name = "Point " .. tostring(#waypointsList + 1) end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		addWaypointUI(name, hrp.CFrame)
		wpNameBox.Text = ""
	end
end)

saveFileBtn.MouseButton1Click:Connect(function()
	if not writefile then return end
	local exportData = {}
	for _, wp in ipairs(waypointsList) do
		table.insert(exportData, {
			Name = wp.Name,
			Pos = {wp.CFrame.X, wp.CFrame.Y, wp.CFrame.Z}
		})
	end
	writefile(fileName, HttpService:JSONEncode(exportData))
	saveFileBtn.Text = "✓ Đã Lưu!"
	task.wait(1.5)
	saveFileBtn.Text = "💾 Lưu File"
end)

loadFileBtn.MouseButton1Click:Connect(function()
	if not readfile or not isfile or not isfile(fileName) then return end
	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(fileName))
	end)
	if success and data then
		for _, item in ipairs(wpListContainer:GetChildren()) do
			if item:IsA("Frame") then item:Destroy() end
		end
		waypointsList = {}
		for _, wpData in ipairs(data) do
			local cf = CFrame.new(wpData.Pos[1], wpData.Pos[2], wpData.Pos[3])
			addWaypointUI(wpData.Name, cf)
		end
		loadFileBtn.Text = "✓ Đã Tải!"
		task.wait(1.5)
		loadFileBtn.Text = "📂 Tải File"
	end
end)

autoTpIntervalBox.FocusLost:Connect(function()
	local num = tonumber(autoTpIntervalBox.Text)
	if num and num > 0 then autoTpInterval = num else autoTpIntervalBox.Text = tostring(autoTpInterval) end
end)

autoTpToggleBtn.MouseButton1Click:Connect(function()
	autoTpEnabled = not autoTpEnabled
	updateButtonState(autoTpToggleBtn, autoTpEnabled)

	if autoTpEnabled then
		autoTpThread = task.spawn(function()
			local currentIndex = 1
			while autoTpEnabled do
				if #waypointsList > 0 then
					if currentIndex > #waypointsList then currentIndex = 1 end
					local targetWp = waypointsList[currentIndex]
					local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if hrp and targetWp then hrp.CFrame = targetWp.CFrame end
					currentIndex += 1
				end
				task.wait(autoTpInterval)
			end
		end)
	else
		if autoTpThread then task.cancel(autoTpThread) autoTpThread = nil end
	end
end)

---------------------------------------------------------
-- 12. FREECAM & MOVEMENT LOGIC
---------------------------------------------------------
local godmodeEnabled = false
local clickTpEnabled, infJumpEnabled, noclipEnabled, walkSpeedEnabled = false, false, false, false
local jumpPowerEnabled, longJumpEnabled, flyEnabled, espEnabled = false, false, false, false
local fullbrightEnabled, antiAfkEnabled = false, false
local freecamEnabled = false
local isSpectating = false
local isMinimized = false

local customWalkSpeed, customJumpPower, customLongJump, flySpeed = 50, 100, 100, 50
local freecamSpeedMultiplier = 1
local flyAlign, flyVel, flyAttachment
local origBrightness, origClockTime = Lighting.Brightness, Lighting.ClockTime
local spectateConnection = nil
local lastSafeCFrame = nil

-- FREECAM SMOOTH CAMERA SYSTEM (WASD + E/Q + MOUSE2 ROTATION)
local freecamCFrame = CFrame.new()
local freecamYaw = 0
local freecamPitch = 0
local freecamConn = nil

local function toggleFreecam()
	freecamEnabled = not freecamEnabled
	updateButtonState(freecamBtn, freecamEnabled)

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if freecamEnabled then
		camera.CameraType = Enum.CameraType.Scriptable
		freecamCFrame = camera.CFrame
		
		local rx, ry, rz = freecamCFrame:ToOrientation()
		freecamYaw = ry
		freecamPitch = rx

		if hrp then hrp.Anchored = true end

		freecamConn = RunService.RenderStepped:Connect(function(dt)
			if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				local delta = UserInputService:GetMouseDelta()
				freecamYaw = freecamYaw - delta.X * 0.004
				freecamPitch = math.clamp(freecamPitch - delta.Y * 0.004, -math.rad(89), math.rad(89))
			end

			local rotCF = CFrame.Angles(0, freecamYaw, 0) * CFrame.Angles(freecamPitch, 0, 0)
			local moveVector = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += rotCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector -= rotCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector -= rotCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += rotCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector -= Vector3.new(0, 1, 0) end

			local speed = 50 * freecamSpeedMultiplier * dt
			freecamCFrame = CFrame.new(freecamCFrame.Position + moveVector * speed) * rotCF
			camera.CFrame = freecamCFrame
		end)
	else
		if freecamConn then freecamConn:Disconnect() freecamConn = nil end
		if hrp then hrp.Anchored = false end
		camera.CameraType = Enum.CameraType.Custom
		if hum then camera.CameraSubject = hum end
	end
end

local function startFlying()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	flyAttachment = Instance.new("Attachment", hrp)
	
	flyVel = Instance.new("LinearVelocity")
	flyVel.MaxForce = math.huge
	flyVel.VectorVelocity = Vector3.zero
	flyVel.Attachment0 = flyAttachment
	flyVel.RelativeTo = Enum.ActuatorRelativeTo.World
	flyVel.Parent = hrp

	flyAlign = Instance.new("AlignOrientation")
	flyAlign.MaxTorque = math.huge
	flyAlign.Responsiveness = 200
	flyAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
	flyAlign.Attachment0 = flyAttachment
	flyAlign.Parent = hrp
end

local function stopFlying()
	if flyVel then flyVel:Destroy() flyVel = nil end
	if flyAlign then flyAlign:Destroy() flyAlign = nil end
	if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

local function toggleFly()
	flyEnabled = not flyEnabled
	updateButtonState(flyBtn, flyEnabled)
	if flyEnabled then startFlying() else stopFlying() end
end

local function stopSpectate()
	isSpectating = false
	if spectateConnection then spectateConnection:Disconnect() spectateConnection = nil end
	spectateBtn.Text = "Spectate"
	spectateBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
	local myHum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if myHum then camera.CameraSubject = myHum end
end

---------------------------------------------------------
-- 13. KEYBINDS SYSTEM
---------------------------------------------------------
local keybinds = {
	Fly = Enum.KeyCode.F,
	Noclip = Enum.KeyCode.N,
	ClickTP = Enum.KeyCode.T,
	InfJump = Enum.KeyCode.J,
	ESP = Enum.KeyCode.E,
	Freecam = Enum.KeyCode.P
}

local function createKeybindRow(parent, labelText, actionKey)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -6, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.35, 0, 0.72, 0)
	btn.Position = UDim2.new(0.62, 0, 0.14, 0)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	btn.Text = keybinds[actionKey].Name
	btn.TextColor3 = Color3.fromRGB(0, 230, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local binding = false
	btn.MouseButton1Click:Connect(function()
		binding = true
		btn.Text = "..."
		btn.TextColor3 = Color3.fromRGB(255, 200, 0)
	end)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if binding and input.UserInputType == Enum.UserInputType.Keyboard then
			keybinds[actionKey] = input.KeyCode
			btn.Text = input.KeyCode.Name
			btn.TextColor3 = Color3.fromRGB(0, 230, 255)
			binding = false
		end
	end)
end

createKeybindRow(tabKeybinds, "Freecam Camera", "Freecam")
createKeybindRow(tabKeybinds, "Phím Tắt Bay (Fly)", "Fly")
createKeybindRow(tabKeybinds, "Phím Tắt Noclip", "Noclip")
createKeybindRow(tabKeybinds, "Phím Tắt Click TP", "ClickTP")
createKeybindRow(tabKeybinds, "Phím Tắt Nhảy Vô Hạn", "InfJump")
createKeybindRow(tabKeybinds, "Phím Tắt ESP Người Chơi", "ESP")

---------------------------------------------------------
-- UNLOAD SCRIPT
---------------------------------------------------------
local function unloadAllFeatures()
	autoTpEnabled = false
	if autoTpThread then task.cancel(autoTpThread) end

	godmodeEnabled = false
	clickTpEnabled, infJumpEnabled, noclipEnabled, walkSpeedEnabled = false, false, false, false
	jumpPowerEnabled, longJumpEnabled, flyEnabled, espEnabled = false, false, false, false
	fullbrightEnabled, antiAfkEnabled = false, false
	aimbotEnabled, fovCircleEnabled = false, false

	if fovCircle then fovCircle:Remove() end
	if freecamEnabled then toggleFreecam() end
	stopFlying()
	stopSpectate()

	Lighting.Brightness = origBrightness
	Lighting.ClockTime = origClockTime

	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 16
		hum.UseJumpPower = true
		hum.JumpPower = 50
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			if p.Character:FindFirstChild("DevESPHighlight") then p.Character.DevESPHighlight:Destroy() end
			if p.Character:FindFirstChild("DevESPBillboard") then p.Character.DevESPBillboard:Destroy() end
		end
	end

	screenGui:Destroy()
end

_G.DevMasterUnload = unloadAllFeatures

logoBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K then 
		mainFrame.Visible = not mainFrame.Visible 
	elseif input.KeyCode == keybinds.Freecam then
		toggleFreecam()
	elseif input.KeyCode == keybinds.Fly then
		toggleFly()
	elseif input.KeyCode == keybinds.Noclip then
		noclipEnabled = not noclipEnabled
		updateButtonState(noclipBtn, noclipEnabled)
	elseif input.KeyCode == keybinds.ClickTP then
		clickTpEnabled = not clickTpEnabled
		updateButtonState(clickTpBtn, clickTpEnabled)
	elseif input.KeyCode == keybinds.InfJump then
		infJumpEnabled = not infJumpEnabled
		updateButtonState(infJumpBtn, infJumpEnabled)
	elseif input.KeyCode == keybinds.ESP then
		espEnabled = not espEnabled
		updateButtonState(espBtn, espEnabled)
		updateESP()
	end
end)

minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		createTween(mainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 260, 0, 40)})
		sidebar.Visible = false
		contentArea.Visible = false
		minimizeBtn.Text = "+"
	else
		createTween(mainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 520, 0, 390)})
		task.wait(0.15)
		sidebar.Visible = true
		contentArea.Visible = true
		minimizeBtn.Text = "-"
	end
end)

closeBtn.MouseButton1Click:Connect(function() confirmModal.Visible = true end)
confirmYesBtn.MouseButton1Click:Connect(function() unloadAllFeatures() end)
confirmNoBtn.MouseButton1Click:Connect(function() confirmModal.Visible = false end)

freecamSpeedBox.FocusLost:Connect(function()
	local num = tonumber(freecamSpeedBox.Text)
	if num then freecamSpeedMultiplier = num else freecamSpeedBox.Text = tostring(freecamSpeedMultiplier) end
end)

freecamBtn.MouseButton1Click:Connect(function()
	toggleFreecam()
end)

walkSpeedBox.FocusLost:Connect(function()
	local num = tonumber(walkSpeedBox.Text)
	if num then customWalkSpeed = num else walkSpeedBox.Text = tostring(customWalkSpeed) end
end)

jumpPowerBox.FocusLost:Connect(function()
	local num = tonumber(jumpPowerBox.Text)
	if num then customJumpPower = num else jumpPowerBox.Text = tostring(customJumpPower) end
end)

longJumpBox.FocusLost:Connect(function()
	local num = tonumber(longJumpBox.Text)
	if num then customLongJump = num else longJumpBox.Text = tostring(customLongJump) end
end)

flySpeedBox.FocusLost:Connect(function()
	local num = tonumber(flySpeedBox.Text)
	if num then flySpeed = num else flySpeedBox.Text = tostring(flySpeed) end
end)

godmodeBtn.MouseButton1Click:Connect(function()
	godmodeEnabled = not godmodeEnabled
	updateButtonState(godmodeBtn, godmodeEnabled)
	if godmodeEnabled then
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then lastSafeCFrame = hrp.CFrame end
	end
end)

clickTpBtn.MouseButton1Click:Connect(function()
	clickTpEnabled = not clickTpEnabled
	updateButtonState(clickTpBtn, clickTpEnabled)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if clickTpEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
			local mousePos = player:GetMouse()
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if hrp and mousePos.Hit then
				hrp.CFrame = CFrame.new(mousePos.Hit.Position + Vector3.new(0, 3, 0))
			end
		end
	end
end)

infJumpBtn.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	updateButtonState(infJumpBtn, infJumpEnabled)
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	updateButtonState(noclipBtn, noclipEnabled)
end)

walkSpeedBtn.MouseButton1Click:Connect(function()
	walkSpeedEnabled = not walkSpeedEnabled
	updateButtonState(walkSpeedBtn, walkSpeedEnabled)
	if not walkSpeedEnabled then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
end)

jumpPowerBtn.MouseButton1Click:Connect(function()
	jumpPowerEnabled = not jumpPowerEnabled
	updateButtonState(jumpPowerBtn, jumpPowerEnabled)
	if not jumpPowerEnabled then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.UseJumpPower = true hum.JumpPower = 50 end
	end
end)

longJumpBtn.MouseButton1Click:Connect(function()
	longJumpEnabled = not longJumpEnabled
	updateButtonState(longJumpBtn, longJumpEnabled)
end)

UserInputService.JumpRequest:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if infJumpEnabled and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	if longJumpEnabled and hrp then
		local moveDir = hum and hum.MoveDirection or Vector3.zero
		if moveDir.Magnitude > 0 then
			hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * customLongJump, hrp.AssemblyLinearVelocity.Y, moveDir.Z * customLongJump)
		end
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	toggleFly()
end)

fullbrightBtn.MouseButton1Click:Connect(function()
	fullbrightEnabled = not fullbrightEnabled
	updateButtonState(fullbrightBtn, fullbrightEnabled)
	if not fullbrightEnabled then
		Lighting.Brightness = origBrightness
		Lighting.ClockTime = origClockTime
	end
end)

antiAfkBtn.MouseButton1Click:Connect(function()
	antiAfkEnabled = not antiAfkEnabled
	updateButtonState(antiAfkBtn, antiAfkEnabled)
end)

player.Idled:Connect(function()
	if antiAfkEnabled then
		local VirtualUser = game:GetService("VirtualUser")
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

-- Render Loops
RunService.RenderStepped:Connect(function()
	if fullbrightEnabled then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
	end

	-- AIMBOT LOOP
	if fovCircleEnabled and fovCircle then
		fovCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
		fovCircle.Radius = fovRadius
	end

	if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local targetPart = getClosestPlayerToCursor()
		if targetPart then
			local targetCFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
			camera.CFrame = camera.CFrame:Lerp(targetCFrame, aimSmoothness)
		end
	end

	if flyEnabled and flyVel and flyAlign then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = true end

		flyAlign.CFrame = camera.CFrame
		local moveDir = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

		flyVel.VectorVelocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.zero
	end
end)

RunService.Stepped:Connect(function()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")

	if godmodeEnabled and hum then
		if hum.Health < hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

		if hrp then
			if hrp.Position.Y > workspace.FallenPartsDestroyHeight + 20 then
				if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
					lastSafeCFrame = hrp.CFrame
				end
			else
				if lastSafeCFrame then
					hrp.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
					hrp.AssemblyLinearVelocity = Vector3.zero
				end
			end
		end
	end

	if noclipEnabled then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	if walkSpeedEnabled and hum then hum.WalkSpeed = customWalkSpeed end
	if jumpPowerEnabled and hum then hum.UseJumpPower = true hum.JumpPower = customJumpPower end
end)

---------------------------------------------------------
-- 14. ESP SYSTEM
---------------------------------------------------------
local function updateESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local char = p.Character
			local head = char:FindFirstChild("Head")

			local hl = char:FindFirstChild("DevESPHighlight")
			local bb = char:FindFirstChild("DevESPBillboard")

			if espEnabled then
				if not hl then
					hl = Instance.new("Highlight")
					hl.Name = "DevESPHighlight"
					hl.Adornee = char
					hl.FillColor = Color3.fromRGB(0, 230, 255)
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.Parent = char
				end
				hl.Enabled = true

				if head and not bb then
					bb = Instance.new("BillboardGui")
					bb.Name = "DevESPBillboard"
					bb.Size = UDim2.new(0, 150, 0, 30)
					bb.StudsOffset = Vector3.new(0, 2.5, 0)
					bb.AlwaysOnTop = true
					bb.Adornee = head

					local espText = Instance.new("TextLabel")
					espText.Name = "ESPLabel"
					espText.Size = UDim2.new(1, 0, 1, 0)
					espText.BackgroundTransparency = 1
					espText.TextColor3 = Color3.fromRGB(0, 230, 150)
					espText.Font = Enum.Font.GothamBold
					espText.TextSize = 11
					espText.Parent = bb
					bb.Parent = char
				end

				if bb and bb:FindFirstChild("ESPLabel") then
					local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					local targetHrp = char:FindFirstChild("HumanoidRootPart")
					local dist = (myHrp and targetHrp) and math.floor((myHrp.Position - targetHrp.Position).Magnitude) or 0
					bb.ESPLabel.Text = p.DisplayName .. " [" .. tostring(dist) .. "m]"
				end
			else
				if hl then hl.Enabled = false end
				if bb then bb:Destroy() end
			end
		end
	end
end

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if leavingPlayer.Character then
		local hl = leavingPlayer.Character:FindFirstChild("DevESPHighlight")
		local bb = leavingPlayer.Character:FindFirstChild("DevESPBillboard")
		if hl then hl:Destroy() end
		if bb then bb:Destroy() end
	end
end)

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	updateButtonState(espBtn, espEnabled)
	updateESP()
end)

task.spawn(function()
	while screenGui.Parent do
		if espEnabled then updateESP() end
		task.wait(0.5)
	end
end)

tpBtn.MouseButton1Click:Connect(function()
	local search = string.lower(tpBox.Text)
	if search == "" then return end
	local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and (string.lower(p.Name):find(search) or string.lower(p.DisplayName):find(search)) then
			local targetHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if targetHRP then
				myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
				break
			end
		end
	end
end)

spectateBtn.MouseButton1Click:Connect(function()
	if isSpectating then
		stopSpectate()
		return
	end

	local search = string.lower(tpBox.Text)
	if search == "" then return end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and (string.lower(p.Name):find(search) or string.lower(p.DisplayName):find(search)) then
			local targetHum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
			if targetHum then
				camera.CameraSubject = targetHum
				isSpectating = true
				spectateBtn.Text = "Hủy xem"
				spectateBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)

				spectateConnection = targetHum.Died:Connect(function()
					stopSpectate()
				end)
				break
			end
		end
	end
end)
