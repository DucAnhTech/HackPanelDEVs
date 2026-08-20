local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- 1. TẠO GIAO DIỆN CHÍNH (GUI)
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombinedDevPanelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 520)
frame.Position = UDim2.new(0, 20, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Tiêu đề Menu
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Dev Master Panel (K: Ẩn/Hiện)"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Nút Thu gọn / Mở rộng Menu
local collapseBtn = Instance.new("TextButton")
collapseBtn.Name = "CollapseButton"
collapseBtn.Size = UDim2.new(0, 22, 0, 22)
collapseBtn.Position = UDim2.new(1, -26, 0, 4)
collapseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
collapseBtn.Text = "-"
collapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collapseBtn.Font = Enum.Font.SourceSansBold
collapseBtn.TextSize = 16
collapseBtn.Parent = frame

local collapseCorner = Instance.new("UICorner")
collapseCorner.CornerRadius = UDim.new(0, 4)
collapseCorner.Parent = collapseBtn

-- Danh sách nút bấm & Ô nhập liệu
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(0.9, 0, 0.90, 0)
container.Position = UDim2.new(0.05, 0, 0.08, 0)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 4
container.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = container

-- Hàm hỗ trợ tạo Nút bấm
local function createButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 30)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

-- Hàm hỗ trợ tạo Ô nhập liệu
local function createTextBox(placeholder, defaultText)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -6, 0, 30)
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.PlaceholderText = placeholder
	box.Text = defaultText or ""
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.SourceSans
	box.TextSize = 12
	box.Parent = container
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	return box
end

-- Tạo các thành phần trên UI
local godmodeBtn = createButton("Godmode (Xóa Neck): [TẮT]", Color3.fromRGB(180, 50, 50))
local antiSlapBtn = createButton("Anti Slap / Knockback: [TẮT]", Color3.fromRGB(180, 50, 50))
local jumpBtn = createButton("Nhảy vô hạn: [TẮT]", Color3.fromRGB(180, 50, 50))
local noclipBtn = createButton("Xuyên tường: [TẮT]", Color3.fromRGB(180, 50, 50))

local walkSpeedBox = createTextBox("Nhập tốc độ chạy...", "50")
local walkSpeedBtn = createButton("Bật tốc độ chạy: [TẮT]", Color3.fromRGB(180, 50, 50))

local flyBtn = createButton("Chế độ Bay: [TẮT]", Color3.fromRGB(180, 50, 50))
local speedBox = createTextBox("Nhập tốc độ bay...", "50")

local espBtn = createButton("Chế độ ESP: [TẮT]", Color3.fromRGB(180, 50, 50))
local tpBox = createTextBox("Nhập tên người chơi...", "")
local tpBtn = createButton("Dịch chuyển đến người chơi", Color3.fromRGB(0, 120, 215))

local unloadBtn = createButton("HỦY BỎ SCRIPT (UNLOAD)", Color3.fromRGB(120, 20, 20))

---------------------------------------------------------
-- 2. CÁC BIẾN VÀ SỰ KIỆN ĐIỀU KHIỂN
---------------------------------------------------------
local godmodeEnabled = false
local antiSlapEnabled = false
local infJumpEnabled = false
local noclipEnabled = false
local walkSpeedEnabled = false
local flyEnabled = false
local espEnabled = false
local isCollapsed = false

local customWalkSpeed = 50
local flySpeed = 50

-- Phím K để Ẩn/Hiện Menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K then
		frame.Visible = not frame.Visible
	end
end)

-- Xử lý Thu gọn / Mở rộng Menu
collapseBtn.MouseButton1Click:Connect(function()
	isCollapsed = not isCollapsed
	if isCollapsed then
		frame.Size = UDim2.new(0, 220, 0, 30)
		container.Visible = false
		collapseBtn.Text = "+"
	else
		frame.Size = UDim2.new(0, 220, 0, 520)
		container.Visible = true
		collapseBtn.Text = "-"
	end
end)

-- Cập nhật tốc độ Chạy
walkSpeedBox.FocusLost:Connect(function()
	local num = tonumber(walkSpeedBox.Text)
	if num then
		customWalkSpeed = num
	else
		walkSpeedBox.Text = tostring(customWalkSpeed)
	end
end)

-- Cập nhật tốc độ Bay
speedBox.FocusLost:Connect(function()
	local num = tonumber(speedBox.Text)
	if num then
		flySpeed = num
	else
		speedBox.Text = tostring(flySpeed)
	end
end)

---------------------------------------------------------
-- 3. LOGIC XỬ LÝ CHỨC NĂNG
---------------------------------------------------------

-- A. Bất Tử (Godmode)
local function applyGodmode()
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if head then
		local neck = head:FindFirstChild("Neck")
		if neck then
			neck:Destroy()
		end
	end
end

godmodeBtn.MouseButton1Click:Connect(function()
	godmodeEnabled = not godmodeEnabled
	godmodeBtn.Text = godmodeEnabled and "Godmode: [BẬT]" or "Godmode: [TẮT]"
	godmodeBtn.BackgroundColor3 = godmodeEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)

	if godmodeEnabled then
		applyGodmode()
	end
end)

-- B. Anti Slap / Knockback
antiSlapBtn.MouseButton1Click:Connect(function()
	antiSlapEnabled = not antiSlapEnabled
	antiSlapBtn.Text = antiSlapEnabled and "Anti Slap / Knockback: [BẬT]" or "Anti Slap / Knockback: [TẮT]"
	antiSlapBtn.BackgroundColor3 = antiSlapEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)
end)

-- C. Nhảy Vô Hạn
jumpBtn.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	jumpBtn.Text = infJumpEnabled and "Nhảy vô hạn: [BẬT]" or "Nhảy vô hạn: [TẮT]"
	jumpBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- D. Xuyên Tường (Noclip)
noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = noclipEnabled and "Xuyên tường: [BẬT]" or "Xuyên tường: [TẮT]"
	noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)
end)

-- E. Tốc độ di chuyển (WalkSpeed)
walkSpeedBtn.MouseButton1Click:Connect(function()
	walkSpeedEnabled = not walkSpeedEnabled
	walkSpeedBtn.Text = walkSpeedEnabled and "Tốc độ chạy: [BẬT]" or "Tốc độ chạy: [TẮT]"
	walkSpeedBtn.BackgroundColor3 = walkSpeedEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)

	if not walkSpeedEnabled then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
end)

-- Loop duy trì Godmode, Anti-Slap, Noclip và WalkSpeed
RunService.Stepped:Connect(function()
	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")

	-- Godmode
	if godmodeEnabled and hum then
		hum.Health = hum.MaxHealth
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanTouch = false
			end
		end
	end

	-- Anti Slap / Knockback
	if antiSlapEnabled then
		if hum then
			hum.PlatformStand = false
			hum.Sit = false
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		end

		for _, child in ipairs(char:GetDescendants()) do
			if child:IsA("BodyVelocity") or child:IsA("BodyAngularVelocity") or child:IsA("BodyThrust") or child:IsA("LinearVelocity") or child:IsA("VectorForce") then
				if not (flyEnabled and (child == bodyVelocity or child == bodyGyro)) then
					child:Destroy()
				end
			end
		end
	end

	-- Noclip
	if noclipEnabled then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end

	-- WalkSpeed
	if walkSpeedEnabled and hum then
		hum.WalkSpeed = customWalkSpeed
	end
end)

-- F. Chế Độ Bay (Fly)
local bodyVelocity, bodyGyro

local function stopFlying()
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyBtn.Text = flyEnabled and "Chế độ Bay: [BẬT]" or "Chế độ Bay: [TẮT]"
	flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)

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

		if moveDir.Magnitude > 0 then
			bodyVelocity.Velocity = moveDir.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.zero
		end
	end
end)

-- G. Định vị Người chơi (ESP)
local function applyESP(targetPlayer)
	if targetPlayer == player then return end
	local function setupChar(char)
		local highlight = char:FindFirstChild("DevESPHighlight") or Instance.new("Highlight")
		highlight.Name = "DevESPHighlight"
		highlight.Adornee = char
		highlight.FillColor = Color3.fromRGB(0, 255, 150)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.Enabled = espEnabled
		highlight.Parent = char
	end

	targetPlayer.CharacterAdded:Connect(setupChar)
	if targetPlayer.Character then setupChar(targetPlayer.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "Chế độ ESP: [BẬT]" or "Chế độ ESP: [TẮT]"
	espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 50, 50)

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local hl = p.Character:FindFirstChild("DevESPHighlight")
			if hl then hl.Enabled = espEnabled end
		end
	end
end)

-- H. Dịch chuyển (Teleport)
tpBtn.MouseButton1Click:Connect(function()
	local searchText = string.lower(tpBox.Text)
	if searchText == "" then return end

	local myChar = player.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			local matchName = string.lower(p.Name):find(searchText)
			local matchDisplay = string.lower(p.DisplayName):find(searchText)

			if matchName or matchDisplay then
				local targetChar = p.Character
				local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
				if targetHRP then
					myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
					break
				end
			end
		end
	end
end)

-- I. Dọn dẹp / Reset
player.CharacterAdded:Connect(function()
	flyEnabled = false
	godmodeEnabled = false
	antiSlapEnabled = false
	walkSpeedEnabled = false
	godmodeBtn.Text = "Godmode: [TẮT]"
	godmodeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	antiSlapBtn.Text = "Anti Slap / Knockback: [TẮT]"
	antiSlapBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	walkSpeedBtn.Text = "Tốc độ chạy: [TẮT]"
	walkSpeedBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	flyBtn.Text = "Chế độ Bay: [TẮT]"
	flyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	stopFlying()
end)

unloadBtn.MouseButton1Click:Connect(function()
	godmodeEnabled = false
	antiSlapEnabled = false
	walkSpeedEnabled = false
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = 16 end

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local hl = p.Character:FindFirstChild("DevESPHighlight")
			if hl then hl:Destroy() end
		end
	end
	stopFlying()
	screenGui:Destroy()
end)
