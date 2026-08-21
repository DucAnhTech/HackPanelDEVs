local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- 0. TỰ DỌN DẸP SCRIPT CŨ NẾU MỞ SCRIPT MỚI
---------------------------------------------------------
if _G.DevMasterUnload then
	_G.DevMasterUnload()
end

---------------------------------------------------------
-- 1. KHỞI TẠO NÚT LOGO TRÒN VỚI ICON XÚC XẮC
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevWindowGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local logoBtn = Instance.new("TextButton")
logoBtn.Name = "LogoButton"
logoBtn.Size = UDim2.new(0, 48, 0, 48)
logoBtn.Position = UDim2.new(0, 15, 0.4, 0)
logoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
logoBtn.Text = ""
logoBtn.Active = true
logoBtn.Draggable = true
logoBtn.Parent = screenGui

Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(255, 255, 255)
logoStroke.Thickness = 2
logoStroke.Parent = logoBtn

-- Hàm tạo nút xúc xắc
local function createDiceIcon(parent)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent

	-- Xúc xắc 1
	local dice1 = Instance.new("Frame")
	dice1.Size = UDim2.new(0, 18, 0, 18)
	dice1.Position = UDim2.new(0, 8, 0.5, -9)
	dice1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dice1.BorderSizePixel = 0
	dice1.Parent = container
	Instance.new("UICorner", dice1).CornerRadius = UDim.new(0, 4)

	local dots1 = {UDim2.new(0.2, 0, 0.2, 0), UDim2.new(0.5, 0, 0.5, 0), UDim2.new(0.8, 0, 0.8, 0)}
	for _, pos in ipairs(dots1) do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 3, 0, 3)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = pos
		dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dot.BorderSizePixel = 0
		dot.Parent = dice1
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	end

	-- Xúc xắc 2
	local dice2 = Instance.new("Frame")
	dice2.Size = UDim2.new(0, 18, 0, 18)
	dice2.Position = UDim2.new(0, 22, 0.5, -11)
	dice2.Rotation = 20
	dice2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dice2.BorderSizePixel = 0
	dice2.Parent = container
	Instance.new("UICorner", dice2).CornerRadius = UDim.new(0, 4)

	local dots2 = {
		UDim2.new(0.25, 0, 0.25, 0), UDim2.new(0.75, 0, 0.25, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(0.25, 0, 0.75, 0), UDim2.new(0.75, 0, 0.75, 0)
	}
	for _, pos in ipairs(dots2) do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 3, 0, 3)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = pos
		dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dot.BorderSizePixel = 0
		dot.Parent = dice2
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	end
end

createDiceIcon(logoBtn)

---------------------------------------------------------
-- 2. KHỞI TẠO KHUNG CỬA SỔ CHÍNH (WINDOW UI)
---------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 320)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Thanh Tiêu Đề (Top Bar)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DEV MASTER PANEL V2 - (Bấm Phím 'K' Hoặc Logo)"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Nút Thu Nhỏ GUI
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -60, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = topBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)

-- Nút Đóng GUI (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- Thanh Tab Bên Trái
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -40)
sidebar.Position = UDim2.new(0, 5, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.Parent = sidebar

-- Vùng Nội Dung
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -135, 1, -40)
contentArea.Position = UDim2.new(0, 130, 0, 40)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

---------------------------------------------------------
-- 3. HỘP THOẠI XÁC NHẬN TẮT SCRIPT (CONFIRMATION MODAL)
---------------------------------------------------------
local confirmModal = Instance.new("Frame")
confirmModal.Size = UDim2.new(0, 300, 0, 140)
confirmModal.Position = UDim2.new(0.5, -150, 0.5, -70)
confirmModal.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
confirmModal.BorderSizePixel = 0
confirmModal.Visible = false
confirmModal.ZIndex = 10
confirmModal.Parent = screenGui
Instance.new("UICorner", confirmModal).CornerRadius = UDim.new(0, 8)

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(180, 50, 50)
modalStroke.Thickness = 2
modalStroke.Parent = confirmModal

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -20, 0, 50)
modalTitle.Position = UDim2.new(0, 10, 0, 10)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "Bạn có chắc chắn muốn tắt hoàn toàn Script và ngắt tất cả chức năng?"
modalTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
modalTitle.Font = Enum.Font.SourceSansBold
modalTitle.TextSize = 13
modalTitle.TextWrapped = true
modalTitle.ZIndex = 11
modalTitle.Parent = confirmModal

local confirmYesBtn = Instance.new("TextButton")
confirmYesBtn.Size = UDim2.new(0, 120, 0, 32)
confirmYesBtn.Position = UDim2.new(0, 20, 1, -45)
confirmYesBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
confirmYesBtn.Text = "ĐỒNG Ý TẮT"
confirmYesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmYesBtn.Font = Enum.Font.SourceSansBold
confirmYesBtn.TextSize = 12
confirmYesBtn.ZIndex = 11
confirmYesBtn.Parent = confirmModal
Instance.new("UICorner", confirmYesBtn).CornerRadius = UDim.new(0, 4)

local confirmNoBtn = Instance.new("TextButton")
confirmNoBtn.Size = UDim2.new(0, 120, 0, 32)
confirmNoBtn.Position = UDim2.new(1, -140, 1, -45)
confirmNoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
confirmNoBtn.Text = "HỦY BỎ"
confirmNoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmNoBtn.Font = Enum.Font.SourceSansBold
confirmNoBtn.TextSize = 12
confirmNoBtn.ZIndex = 11
confirmNoBtn.Parent = confirmModal
Instance.new("UICorner", confirmNoBtn).CornerRadius = UDim.new(0, 4)

---------------------------------------------------------
-- 4. HÀM TẠO TABS VÀ CÁC NÚT ĐIỀU KHIỂN
---------------------------------------------------------
local pages = {}

local function createTab(name)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1, 0, 0, 30)
	tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	tabBtn.Text = name
	tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	tabBtn.Font = Enum.Font.SourceSansBold
	tabBtn.TextSize = 12
	tabBtn.Parent = sidebar
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4)

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.Visible = false
	page.Parent = contentArea

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = page

	pages[name] = {Button = tabBtn, Page = page}

	tabBtn.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do
			p.Page.Visible = false
			p.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			p.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		page.Visible = true
		tabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	return page
end

local tabMain = createTab("Trạng Thái")
local tabMove = createTab("Di Chuyển")
local tabVisual = createTab("ESP & Khác")

pages["Trạng Thái"].Page.Visible = true
pages["Trạng Thái"].Button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
pages["Trạng Thái"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

local function createToggle(parent, text)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 32)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.3, 0, 0.7, 0)
	btn.Position = UDim2.new(0.68, 0, 0.15, 0)
	btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	btn.Text = "TẮT"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	return btn
end

local function createInputGroup(parent, text, defaultVal)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 32)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.45, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.22, 0, 0.7, 0)
	box.Position = UDim2.new(0.45, 0, 0.15, 0)
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.Text = defaultVal
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.SourceSans
	box.TextSize = 12
	box.Parent = frame
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.28, 0, 0.7, 0)
	btn.Position = UDim2.new(0.70, 0, 0.15, 0)
	btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	btn.Text = "TẮT"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	return box, btn
end

---------------------------------------------------------
-- 5. TẠO CÁC NÚT ĐIỀU KHIỂN
---------------------------------------------------------
local godmodeBtn = createToggle(tabMain, "Godmode (Xóa Neck)")
local invisibleBtn = createToggle(tabMain, "Tàng hình (Invisible)")
local antiSlapBtn = createToggle(tabMain, "Anti Slap / Knockback")

local infJumpBtn = createToggle(tabMove, "Nhảy vô hạn")
local noclipBtn = createToggle(tabMove, "Xuyên tường (Noclip)")
local walkSpeedBox, walkSpeedBtn = createInputGroup(tabMove, "Tốc độ chạy", "50")
local jumpPowerBox, jumpPowerBtn = createInputGroup(tabMove, "Độ cao nhảy", "100")
local longJumpBox, longJumpBtn = createInputGroup(tabMove, "Độ xa nhảy", "100")
local flySpeedBox, flyBtn = createInputGroup(tabMove, "Chế độ bay", "50")

local espBtn = createToggle(tabVisual, "Chế độ ESP người chơi")

local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(1, -10, 0, 32)
tpFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
tpFrame.Parent = tabVisual
Instance.new("UICorner", tpFrame).CornerRadius = UDim.new(0, 4)

local tpBox = Instance.new("TextBox")
tpBox.Size = UDim2.new(0.6, 0, 0.7, 0)
tpBox.Position = UDim2.new(0.02, 0, 0.15, 0)
tpBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
tpBox.PlaceholderText = "Nhập tên..."
tpBox.Text = ""
tpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBox.Font = Enum.Font.SourceSans
tpBox.TextSize = 12
tpBox.Parent = tpFrame
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0, 4)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.34, 0, 0.7, 0)
tpBtn.Position = UDim2.new(0.64, 0, 0.15, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
tpBtn.Text = "Dịch chuyển"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 11
tpBtn.Parent = tpFrame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)

---------------------------------------------------------
-- 6. LOGIC XỬ LÝ SỰ KIỆN VÀ TẮT TOÀN BỘ CHỨC NĂNG
---------------------------------------------------------
local godmodeEnabled, invisibleEnabled, antiSlapEnabled = false, false, false
local infJumpEnabled, noclipEnabled, walkSpeedEnabled = false, false, false
local jumpPowerEnabled, longJumpEnabled, flyEnabled, espEnabled = false, false, false, false
local isMinimized = false

local customWalkSpeed, customJumpPower, customLongJump, flySpeed = 50, 100, 100, 50

local bodyVelocity, bodyGyro
local function stopFlying()
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

local function applyInvisibleLogic(state)
	local char = player.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = state and 0.99 or 0
			part.LocalTransparencyModifier = state and 0.99 or 0
		elseif part:IsA("Decal") then
			part.Transparency = state and 1 or 0
		end
	end
end

-- Hàm tắt toàn bộ tính năng và dọn dẹp
local function unloadAllFeatures()
	godmodeEnabled, invisibleEnabled, antiSlapEnabled = false, false, false
	infJumpEnabled, noclipEnabled, walkSpeedEnabled = false, false, false
	jumpPowerEnabled, longJumpEnabled, flyEnabled, espEnabled = false, false, false, false

	applyInvisibleLogic(false)
	stopFlying()

	-- Khôi phục nhân vật
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 16
		hum.UseJumpPower = true
		hum.JumpPower = 50
	end

	-- Xóa ESP Highlights
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("DevESPHighlight") then
			p.Character.DevESPHighlight:Destroy()
		end
	end

	screenGui:Destroy()
end

-- Gán hàm dọn dẹp vào biến toàn cục để tự động xóa khi mở script mới
_G.DevMasterUnload = unloadAllFeatures

local function updateButtonState(btn, state)
	btn.Text = state and "BẬT" or "TẮT"
	btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)
end

-- Bấm Logo để Ẩn / Hiện GUI
logoBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Phím K để Ẩn / Hiện GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		mainFrame.Size = UDim2.new(0, 250, 0, 35)
		sidebar.Visible = false
		contentArea.Visible = false
		minimizeBtn.Text = "+"
	else
		mainFrame.Size = UDim2.new(0, 500, 0, 320)
		sidebar.Visible = true
		contentArea.Visible = true
		minimizeBtn.Text = "_"
	end
end)

-- Khi bấm nút X -> Hiện GUI hỏi xác nhận
closeBtn.MouseButton1Click:Connect(function()
	confirmModal.Visible = true
end)

confirmYesBtn.MouseButton1Click:Connect(function()
	unloadAllFeatures()
end)

confirmNoBtn.MouseButton1Click:Connect(function()
	confirmModal.Visible = false
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
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		if head and head:FindFirstChild("Neck") then head.Neck:Destroy() end
	end
end)

invisibleBtn.MouseButton1Click:Connect(function()
	invisibleEnabled = not invisibleEnabled
	updateButtonState(invisibleBtn, invisibleEnabled)
	applyInvisibleLogic(invisibleEnabled)
end)

antiSlapBtn.MouseButton1Click:Connect(function()
	antiSlapEnabled = not antiSlapEnabled
	updateButtonState(antiSlapBtn, antiSlapEnabled)
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
	flyEnabled = not flyEnabled
	updateButtonState(flyBtn, flyEnabled)
	if not flyEnabled then stopFlying() end
end)

RunService.RenderStepped:Connect(function()
	if flyEnabled then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		hum.PlatformStand = true
		if not bodyVelocity then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bodyVelocity.Parent = hrp
		end
		if not bodyGyro then
			bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
			bodyGyro.P = 10000
			bodyGyro.Parent = hrp
		end

		local camera = workspace.CurrentCamera
		bodyGyro.CFrame = camera.CFrame
		local moveDir = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

		bodyVelocity.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.zero
	end
end)

RunService.Stepped:Connect(function()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")

	if godmodeEnabled and hum then
		hum.Health = hum.MaxHealth
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end
	if invisibleEnabled then applyInvisibleLogic(true) end
	if noclipEnabled then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	if walkSpeedEnabled and hum then hum.WalkSpeed = customWalkSpeed end
	if jumpPowerEnabled and hum then hum.UseJumpPower = true hum.JumpPower = customJumpPower end
end)

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	updateButtonState(espBtn, espEnabled)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local hl = p.Character:FindFirstChild("DevESPHighlight") or Instance.new("Highlight")
			hl.Name = "DevESPHighlight"
			hl.Adornee = p.Character
			hl.FillColor = Color3.fromRGB(0, 255, 150)
			hl.Enabled = espEnabled
			hl.Parent = p.Character
		end
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
