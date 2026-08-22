--[[
    DEV MASTER ULTIMATE V4 – KẾ THỪA FLING CỦA INFINITE YIELD
    - Giao diện slider, toggle, dropdown
    - Combat: Aimbot, Triggerbot, Hitbox, No Recoil, v.v.
    - Movement: Fly, Noclip, Speed, Jump, Freecam, v.v.
    - Fling: fling, walkfling, flyfling, invisfling (từ IY)
    - ESP Highlight + Billboard
    - Waypoint, Auto TP
    - FPS Boost, Keybinds, Settings, Lưu/Load Config
    - Nút tắt toàn bộ script
    - Logo toggle menu, chỉ dùng phím K
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

if _G.DevMasterUnload then _G.DevMasterUnload() end

---------------------------------------------------------
-- HÀM HỖ TRỢ
---------------------------------------------------------
local function tween(instance, info, props)
    local t = TweenService:Create(instance, info, props)
    t:Play()
    return t
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
            gui.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Tạo slider CÓ Ô NHẬP SỐ
local function createSlider(parent, labelText, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.38, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.28, 0, 0.35, 0)
    track.Position = UDim2.new(0.40, 0, 0.3, 0)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    -- Ô nhập số
    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0.17, 0, 0.75, 0)
    valueBox.Position = UDim2.new(0.81, 0, 0.12, 0)
    valueBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    valueBox.Text = tostring(defaultVal)
    valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueBox.Font = Enum.Font.GothamBold
    valueBox.TextSize = 13
    valueBox.ClearTextOnFocus = false
    valueBox.Parent = frame
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

    local dragging = false
    local function updateSlider(val)
        if val < minVal then val = minVal end
        if val > maxVal then val = maxVal end
        local percent = (val - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7)
        valueBox.Text = tostring(val)
        if callback then callback(val) end
    end

    local function updateSliderFromInput(input)
        local pos = input.Position.X
        local relX = pos - track.AbsolutePosition.X
        local percent = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * percent
        val = math.round(val * 100) / 100
        if val < minVal then val = minVal end
        if val > maxVal then val = maxVal end
        updateSlider(val)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSliderFromInput(input)
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSliderFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSliderFromInput(input)
        end
    end)

    valueBox.FocusLost:Connect(function()
        local num = tonumber(valueBox.Text)
        if num then
            num = math.clamp(num, minVal, maxVal)
            updateSlider(num)
        else
            local currentPercent = fill.Size.X.Scale
            local currentVal = minVal + (maxVal - minVal) * currentPercent
            valueBox.Text = tostring(math.round(currentVal * 100) / 100)
        end
    end)

    return {
        frame = frame,
        fill = fill,
        knob = knob,
        valueBox = valueBox,
        update = updateSlider
    }
end

-- Tạo dropdown
local function createDropdown(parent, labelText, options, defaultIndex, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.4, 0, 0.75, 0)
    dropdownBtn.Position = UDim2.new(0.45, 0, 0.12, 0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    dropdownBtn.Text = options[defaultIndex or 1]
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.Font = Enum.Font.GothamBold
    dropdownBtn.TextSize = 13
    dropdownBtn.Parent = frame
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6)

    local currentIndex = defaultIndex or 1
    dropdownBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        dropdownBtn.Text = options[currentIndex]
        if callback then callback(options[currentIndex], currentIndex) end
    end)

    return {
        frame = frame,
        btn = dropdownBtn,
        setValue = function(value)
            for i, opt in ipairs(options) do
                if opt == value then
                    currentIndex = i
                    dropdownBtn.Text = value
                    if callback then callback(value, i) end
                    break
                end
            end
        end
    }
end

---------------------------------------------------------
-- TẠO GUI CHÍNH
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevMasterUltimateV4"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Logo (toggle menu)
local logoBtn = Instance.new("TextButton")
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

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 650, 0, 500)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
makeDraggable(mainFrame)
local glow = Instance.new("UIStroke")
glow.Color = Color3.fromRGB(0, 180, 255)
glow.Thickness = 2
glow.Transparency = 0.5
glow.Parent = mainFrame

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ DEV MASTER ULTIMATE V4"
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -78, 0, 8)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.Parent = topBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, -52)
sidebar.Position = UDim2.new(0, 8, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 6)
sidebarLayout.Parent = sidebar
local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 8)
sidebarPadding.PaddingLeft = UDim.new(0, 8)
sidebarPadding.PaddingRight = UDim.new(0, 8)
sidebarPadding.Parent = sidebar

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -178, 1, -52)
contentArea.Position = UDim2.new(0, 172, 0, 50)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

---------------------------------------------------------
-- HỘP THOẠI XÁC NHẬN
---------------------------------------------------------
local confirmModal = Instance.new("Frame")
confirmModal.Size = UDim2.new(0, 340, 0, 150)
confirmModal.Position = UDim2.new(0.5, -170, 0.5, -75)
confirmModal.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
confirmModal.Visible = false
confirmModal.ZIndex = 10
confirmModal.Parent = screenGui
Instance.new("UICorner", confirmModal).CornerRadius = UDim.new(0, 12)
local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(220, 50, 70)
modalStroke.Thickness = 2
modalStroke.Parent = confirmModal

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -20, 0, 50)
modalTitle.Position = UDim2.new(0, 10, 0, 10)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "❓ Xác nhận tắt script?"
modalTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 15
modalTitle.ZIndex = 11
modalTitle.Parent = confirmModal

local confirmYesBtn = Instance.new("TextButton")
confirmYesBtn.Size = UDim2.new(0, 140, 0, 36)
confirmYesBtn.Position = UDim2.new(0, 15, 1, -48)
confirmYesBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
confirmYesBtn.Text = "ĐỒNG Ý"
confirmYesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmYesBtn.Font = Enum.Font.GothamBold
confirmYesBtn.TextSize = 14
confirmYesBtn.ZIndex = 11
confirmYesBtn.Parent = confirmModal
Instance.new("UICorner", confirmYesBtn).CornerRadius = UDim.new(0, 8)

local confirmNoBtn = Instance.new("TextButton")
confirmNoBtn.Size = UDim2.new(0, 140, 0, 36)
confirmNoBtn.Position = UDim2.new(1, -155, 1, -48)
confirmNoBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
confirmNoBtn.Text = "HỦY"
confirmNoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmNoBtn.Font = Enum.Font.GothamBold
confirmNoBtn.TextSize = 14
confirmNoBtn.ZIndex = 11
confirmNoBtn.Parent = confirmModal
Instance.new("UICorner", confirmNoBtn).CornerRadius = UDim.new(0, 8)

---------------------------------------------------------
-- HỆ THỐNG TAB
---------------------------------------------------------
local pages = {}
local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 255)
    page.Visible = false
    page.Parent = contentArea

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page

    pages[name] = {Button = btn, Page = page}

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.Page.Visible = false
            p.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            p.Button.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return page
end

-- Tạo các tab
local tabMain = createTab("Trạng Thái", "📊")
local tabCombat = createTab("Combat", "⚔️")
local tabMove = createTab("Di Chuyển", "🏃")
local tabFling = createTab("Fling", "🌀")         -- Tab Fling mới
local tabWaypoint = createTab("Waypoint", "📍")
local tabVisual = createTab("ESP & Khác", "👁️")
local tabMisc = createTab("Misc", "🎮")
local tabBooster = createTab("FPS Boost", "🚀")
local tabKeybinds = createTab("Phím Tắt", "⌨️")
local tabSettings = createTab("Cài Đặt", "⚙️")

pages["Trạng Thái"].Page.Visible = true
pages["Trạng Thái"].Button.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
pages["Trạng Thái"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

---------------------------------------------------------
-- UI BUILDERS
---------------------------------------------------------
local function updateToggle(btn, state)
    btn.Text = state and "BẬT" or "TẮT"
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(200, 50, 60)
    tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = btn.BackgroundColor3})
end

local function createToggle(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0.75, 0)
    btn.Position = UDim2.new(0.72, 0, 0.12, 0)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    btn.Text = "TẮT"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    return btn
end

local function createActionButton(parent, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 42)
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 140, 240)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

---------------------------------------------------------
-- STATS PANEL
---------------------------------------------------------
local statsContainer = Instance.new("Frame")
statsContainer.Size = UDim2.new(1, -6, 0, 120)
statsContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
statsContainer.Parent = tabMain
Instance.new("UICorner", statsContainer).CornerRadius = UDim.new(0, 10)

local statsGrid = Instance.new("UIGridLayout")
statsGrid.CellSize = UDim2.new(0.48, 0, 0.43, 0)
statsGrid.CellPadding = UDim2.new(0.03, 0, 0.06, 0)
statsGrid.Parent = statsContainer

local function createStatCard(titleText, defaultVal)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    card.Parent = statsContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0.4, 0)
    titleLbl.Position = UDim2.new(0, 0, 0.08, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.Parent = card

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, 0, 0.5, 0)
    valLbl.Position = UDim2.new(0, 0, 0.45, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = defaultVal
    valLbl.TextColor3 = Color3.fromRGB(0, 230, 150)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 16
    valLbl.Parent = card

    return valLbl
end

local fpsLabel = createStatCard("FPS", "60")
local pingLabel = createStatCard("PING", "0 ms")
local playersLabel = createStatCard("PLAYERS", "0/" .. tostring(Players.MaxPlayers))
local timeLabel = createStatCard("PLAYTIME", "00:00:00")

---------------------------------------------------------
-- FEATURE STATES & VARIABLES
---------------------------------------------------------
local featureStates = {
    -- Combat
    aimbotEnabled = false,
    triggerbotEnabled = false,
    fovCircleEnabled = false,
    wallCheckEnabled = false,
    noRecoilEnabled = false,
    infiniteAmmoEnabled = false,
    rapidFireEnabled = false,
    hitboxEnabled = false,
    -- Movement
    godmodeEnabled = false,
    clickTpEnabled = false,
    infJumpEnabled = false,
    noclipEnabled = false,
    walkSpeedEnabled = false,
    jumpPowerEnabled = false,
    flyEnabled = false,
    autoJumpEnabled = false,
    autoSprintEnabled = false,
    -- Fling
    flingEnabled = false,
    walkflingEnabled = false,
    flyflingEnabled = false,
    invisflingEnabled = false,
    -- Visual
    espEnabled = false,
    fullbrightEnabled = false,
    antiAfkEnabled = false,
    freecamEnabled = false,
    -- Misc
    autoClickEnabled = false,
    autoCollectEnabled = false,
    autoTpEnabled = false,
}

local aimTarget = "Head"
local aimSmoothness = 0.2
local fovRadius = 120
local hitboxSize = 5
local customWalkSpeed = 50
local customJumpPower = 100
local flySpeed = 50
local freecamSpeedMultiplier = 1
local autoTpInterval = 3
local autoClickDelay = 0.1
local autoCollectRadius = 20
local rapidFireDelay = 0.05

-- Biến cho fling
local flingRunning = false
local walkflingRunning = false
local flyflingRunning = false
local invisflingRunning = false
local flingDied = nil
local walkflingLoop = nil
local flyflingLoop = nil
local invisflingLoop = nil

-- Lưu slider
local sliders = {}
local dropdowns = {}

local function addSlider(name, obj)
    sliders[name] = obj
end

local function addDropdown(name, obj)
    dropdowns[name] = obj
end

-- Hitbox original sizes
local originalSizes = {}
local function resetHitboxes()
    for rootPart, size in pairs(originalSizes) do
        if rootPart and rootPart.Parent then
            rootPart.Size = size
            rootPart.Transparency = 1
            rootPart.CanCollide = true
            rootPart.Color = Color3.fromRGB(255, 255, 255)
        end
    end
    originalSizes = {}
end

---------------------------------------------------------
-- COMBAT TAB
---------------------------------------------------------
local aimbotToggleBtn = createToggle(tabCombat, "Aimbot (Giữ Chuột Phải)")
local triggerbotToggleBtn = createToggle(tabCombat, "Triggerbot (Tự bắn)")
local fovToggleBtn = createToggle(tabCombat, "Hiện Vòng FOV")
local wallCheckBtn = createToggle(tabCombat, "Wall Check")
local hitboxToggleBtn = createToggle(tabCombat, "Hitbox Expander")

local aimPartDropdown = createDropdown(tabCombat, "Bộ Phận Nhắm", {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, 1, function(value, idx)
    aimTarget = value
end)
addDropdown("aimTarget", aimPartDropdown)

local fovSlider = createSlider(tabCombat, "Bán Kính FOV", 20, 300, 120, function(val)
    fovRadius = val
end)
addSlider("fovRadius", fovSlider)

local aimSmoothSlider = createSlider(tabCombat, "Độ Mượt (Smooth)", 0.01, 1, 0.2, function(val)
    aimSmoothness = val
end)
addSlider("aimSmoothness", aimSmoothSlider)

local hitboxSlider = createSlider(tabCombat, "Kích Thước Hitbox", 1, 50, 5, function(val)
    hitboxSize = val
end)
addSlider("hitboxSize", hitboxSlider)

local noRecoilBtn = createToggle(tabCombat, "No Recoil")
local infiniteAmmoBtn = createToggle(tabCombat, "Infinite Ammo")
local rapidFireBtn = createToggle(tabCombat, "Rapid Fire")
local rapidFireSlider = createSlider(tabCombat, "Rapid Fire Delay (s)", 0.01, 0.5, 0.05, function(val)
    rapidFireDelay = val
end)
addSlider("rapidFireDelay", rapidFireSlider)

---------------------------------------------------------
-- MOVEMENT TAB
---------------------------------------------------------
local godmodeBtn = createToggle(tabMain, "Godmode")
local freecamSpeedSlider = createSlider(tabMove, "Freecam Speed", 0.1, 10, 1, function(val)
    freecamSpeedMultiplier = val
end)
addSlider("freecamSpeedMultiplier", freecamSpeedSlider)
local freecamBtn = createToggle(tabMove, "Freecam (Bật/Tắt)")

local clickTpBtn = createToggle(tabMove, "Click TP (Ctrl+Click)")
local infJumpBtn = createToggle(tabMove, "Nhảy Vô Hạn")
local autoJumpBtn = createToggle(tabMove, "Auto Jump")
local autoSprintBtn = createToggle(tabMove, "Auto Sprint")
local noclipBtn = createToggle(tabMove, "Noclip")

local walkSpeedSlider = createSlider(tabMove, "Tốc Độ Chạy", 16, 200, 50, function(val)
    customWalkSpeed = val
end)
addSlider("customWalkSpeed", walkSpeedSlider)
local walkSpeedBtn = createToggle(tabMove, "Bật Tốc Độ")

local jumpPowerSlider = createSlider(tabMove, "Jump Power", 50, 300, 100, function(val)
    customJumpPower = val
end)
addSlider("customJumpPower", jumpPowerSlider)
local jumpPowerBtn = createToggle(tabMove, "Bật Jump Power")

local flySpeedSlider = createSlider(tabMove, "Fly Speed", 10, 200, 50, function(val)
    flySpeed = val
end)
addSlider("flySpeed", flySpeedSlider)
local flyBtn = createToggle(tabMove, "Bay (Fly)")

---------------------------------------------------------
-- FLING TAB (lấy từ IY)
---------------------------------------------------------
local flingBtn = createToggle(tabFling, "Fling (đẩy cực mạnh)")
local walkflingBtn = createToggle(tabFling, "Walk Fling (chạy đẩy)")
local flyflingBtn = createToggle(tabFling, "Fly Fling (bay đẩy)")
local invisflingBtn = createToggle(tabFling, "Invis Fling (tàng hình + đẩy)")

-- Slider điều chỉnh tốc độ flyfling (nếu cần)
local flyflingSpeedSlider = createSlider(tabFling, "FlyFling Speed", 1, 100, 20, function(val)
    -- Sẽ dùng khi bật flyfling
end)
addSlider("flyflingSpeed", flyflingSpeedSlider)

---------------------------------------------------------
-- WAYPOINT TAB (giữ nguyên từ V3)
---------------------------------------------------------
local fileName = "DevWaypoints_" .. tostring(game.PlaceId) .. ".json"
local waypointsList = {}
local autoTpThread = nil

local wpInputFrame = Instance.new("Frame")
wpInputFrame.Size = UDim2.new(1, -6, 0, 42)
wpInputFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
wpInputFrame.Parent = tabWaypoint
Instance.new("UICorner", wpInputFrame).CornerRadius = UDim.new(0, 8)

local wpNameBox = Instance.new("TextBox")
wpNameBox.Size = UDim2.new(0.62, 0, 0.75, 0)
wpNameBox.Position = UDim2.new(0.02, 0, 0.12, 0)
wpNameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
wpNameBox.PlaceholderText = "Tên điểm..."
wpNameBox.Text = ""
wpNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
wpNameBox.Font = Enum.Font.GothamMedium
wpNameBox.TextSize = 14
wpNameBox.Parent = wpInputFrame
Instance.new("UICorner", wpNameBox).CornerRadius = UDim.new(0, 6)

local wpSaveBtn = Instance.new("TextButton")
wpSaveBtn.Size = UDim2.new(0.32, 0, 0.75, 0)
wpSaveBtn.Position = UDim2.new(0.66, 0, 0.12, 0)
wpSaveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
wpSaveBtn.Text = "+ Lưu"
wpSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wpSaveBtn.Font = Enum.Font.GothamBold
wpSaveBtn.TextSize = 14
wpSaveBtn.Parent = wpInputFrame
Instance.new("UICorner", wpSaveBtn).CornerRadius = UDim.new(0, 6)

local fileControlFrame = Instance.new("Frame")
fileControlFrame.Size = UDim2.new(1, -6, 0, 42)
fileControlFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
fileControlFrame.Parent = tabWaypoint
Instance.new("UICorner", fileControlFrame).CornerRadius = UDim.new(0, 8)

local saveFileBtn = Instance.new("TextButton")
saveFileBtn.Size = UDim2.new(0.48, 0, 0.75, 0)
saveFileBtn.Position = UDim2.new(0.01, 0, 0.12, 0)
saveFileBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
saveFileBtn.Text = "💾 Lưu File"
saveFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveFileBtn.Font = Enum.Font.GothamBold
saveFileBtn.TextSize = 14
saveFileBtn.Parent = fileControlFrame
Instance.new("UICorner", saveFileBtn).CornerRadius = UDim.new(0, 6)

local loadFileBtn = Instance.new("TextButton")
loadFileBtn.Size = UDim2.new(0.48, 0, 0.75, 0)
loadFileBtn.Position = UDim2.new(0.51, 0, 0.12, 0)
loadFileBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
loadFileBtn.Text = "📂 Tải File"
loadFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadFileBtn.Font = Enum.Font.GothamBold
loadFileBtn.TextSize = 14
loadFileBtn.Parent = fileControlFrame
Instance.new("UICorner", loadFileBtn).CornerRadius = UDim.new(0, 6)

local autoTpSlider = createSlider(tabWaypoint, "Auto TP (s)", 1, 30, 3, function(val)
    autoTpInterval = val
end)
addSlider("autoTpInterval", autoTpSlider)
local autoTpToggleBtn = createToggle(tabWaypoint, "Auto TP Loop")

local wpListContainer = Instance.new("Frame")
wpListContainer.Size = UDim2.new(1, -6, 1, -200)
wpListContainer.BackgroundTransparency = 1
wpListContainer.Parent = tabWaypoint
local wpListLayout = Instance.new("UIListLayout")
wpListLayout.Padding = UDim.new(0, 5)
wpListLayout.Parent = wpListContainer

local function addWaypointUI(name, cframe)
    local itemData = {Name = name, CFrame = cframe}
    table.insert(waypointsList, itemData)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    frame.Parent = wpListContainer
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local tpWpBtn = Instance.new("TextButton")
    tpWpBtn.Size = UDim2.new(0, 60, 0.75, 0)
    tpWpBtn.Position = UDim2.new(0.52, 0, 0.12, 0)
    tpWpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
    tpWpBtn.Text = "Đến"
    tpWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpWpBtn.Font = Enum.Font.GothamBold
    tpWpBtn.TextSize = 13
    tpWpBtn.Parent = frame
    Instance.new("UICorner", tpWpBtn).CornerRadius = UDim.new(0, 6)

    local delWpBtn = Instance.new("TextButton")
    delWpBtn.Size = UDim2.new(0, 60, 0.75, 0)
    delWpBtn.Position = UDim2.new(0.75, 0, 0.12, 0)
    delWpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    delWpBtn.Text = "Xóa"
    delWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    delWpBtn.Font = Enum.Font.GothamBold
    delWpBtn.TextSize = 13
    delWpBtn.Parent = frame
    Instance.new("UICorner", delWpBtn).CornerRadius = UDim.new(0, 6)

    tpWpBtn.MouseButton1Click:Connect(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = cframe end
    end)

    delWpBtn.MouseButton1Click:Connect(function()
        for i, v in ipairs(waypointsList) do
            if v == itemData then table.remove(waypointsList, i) break end
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
        table.insert(exportData, {Name = wp.Name, Pos = {wp.CFrame.X, wp.CFrame.Y, wp.CFrame.Z}})
    end
    writefile(fileName, HttpService:JSONEncode(exportData))
    saveFileBtn.Text = "✓ Lưu!"
    task.wait(1.5)
    saveFileBtn.Text = "💾 Lưu File"
end)

loadFileBtn.MouseButton1Click:Connect(function()
    if not readfile or not isfile or not isfile(fileName) then return end
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
    if success and data then
        for _, item in ipairs(wpListContainer:GetChildren()) do if item:IsA("Frame") then item:Destroy() end end
        waypointsList = {}
        for _, wpData in ipairs(data) do
            local cf = CFrame.new(wpData.Pos[1], wpData.Pos[2], wpData.Pos[3])
            addWaypointUI(wpData.Name, cf)
        end
        loadFileBtn.Text = "✓ Tải!"
        task.wait(1.5)
        loadFileBtn.Text = "📂 Tải File"
    end
end)

autoTpToggleBtn.MouseButton1Click:Connect(function()
    featureStates.autoTpEnabled = not featureStates.autoTpEnabled
    updateToggle(autoTpToggleBtn, featureStates.autoTpEnabled)
    if featureStates.autoTpEnabled then
        autoTpThread = task.spawn(function()
            local idx = 1
            while featureStates.autoTpEnabled do
                if #waypointsList > 0 then
                    if idx > #waypointsList then idx = 1 end
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and waypointsList[idx] then hrp.CFrame = waypointsList[idx].CFrame end
                    idx = idx + 1
                end
                task.wait(autoTpInterval)
            end
        end)
    else
        if autoTpThread then task.cancel(autoTpThread) autoTpThread = nil end
    end
end)

---------------------------------------------------------
-- VISUAL TAB (ESP Highlight + Billboard)
---------------------------------------------------------
local espBtn = createToggle(tabVisual, "ESP Người Chơi")
local fullbrightBtn = createToggle(tabVisual, "Fullbright")
local antiAfkBtn = createToggle(tabVisual, "Anti-AFK")

local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(1, -6, 0, 42)
tpFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
tpFrame.Parent = tabVisual
Instance.new("UICorner", tpFrame).CornerRadius = UDim.new(0, 8)

local tpBox = Instance.new("TextBox")
tpBox.Size = UDim2.new(0.4, 0, 0.75, 0)
tpBox.Position = UDim2.new(0.02, 0, 0.12, 0)
tpBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
tpBox.PlaceholderText = "Tên người chơi..."
tpBox.Text = ""
tpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBox.Font = Enum.Font.GothamMedium
tpBox.TextSize = 14
tpBox.Parent = tpFrame
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0, 6)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.26, 0, 0.75, 0)
tpBtn.Position = UDim2.new(0.44, 0, 0.12, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
tpBtn.Text = "Teleport"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 14
tpBtn.Parent = tpFrame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

local spectateBtn = Instance.new("TextButton")
spectateBtn.Size = UDim2.new(0.26, 0, 0.75, 0)
spectateBtn.Position = UDim2.new(0.72, 0, 0.12, 0)
spectateBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
spectateBtn.Text = "Spectate"
spectateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spectateBtn.Font = Enum.Font.GothamBold
spectateBtn.TextSize = 14
spectateBtn.Parent = tpFrame
Instance.new("UICorner", spectateBtn).CornerRadius = UDim.new(0, 6)

local serverControlFrame = Instance.new("Frame")
serverControlFrame.Size = UDim2.new(1, -6, 0, 42)
serverControlFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
serverControlFrame.Parent = tabVisual
Instance.new("UICorner", serverControlFrame).CornerRadius = UDim.new(0, 8)

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.48, 0, 0.75, 0)
rejoinBtn.Position = UDim2.new(0.01, 0, 0.12, 0)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
rejoinBtn.Text = "↻ Rejoin"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.TextSize = 14
rejoinBtn.Parent = serverControlFrame
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 6)

local serverHopBtn = Instance.new("TextButton")
serverHopBtn.Size = UDim2.new(0.48, 0, 0.75, 0)
serverHopBtn.Position = UDim2.new(0.51, 0, 0.12, 0)
serverHopBtn.BackgroundColor3 = Color3.fromRGB(220, 110, 0)
serverHopBtn.Text = "🌐 Server Hop"
serverHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
serverHopBtn.Font = Enum.Font.GothamBold
serverHopBtn.TextSize = 14
serverHopBtn.Parent = serverControlFrame
Instance.new("UICorner", serverHopBtn).CornerRadius = UDim.new(0, 6)

rejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

serverHopBtn.MouseButton1Click:Connect(function()
    serverHopBtn.Text = "Đang tìm..."
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    task.spawn(function()
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                    return
                end
            end
        end
        serverHopBtn.Text = "Thử lại"
        task.wait(2)
        serverHopBtn.Text = "🌐 Server Hop"
    end)
end)

---------------------------------------------------------
-- ESP SYSTEM (Highlight + Billboard)
---------------------------------------------------------
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not head or not hum then continue end

            local hl = char:FindFirstChild("DevESPHighlight")
            local bb = char:FindFirstChild("DevESPBillboard")

            if featureStates.espEnabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "DevESPHighlight"
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(0, 230, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = char
                end
                hl.Enabled = true

                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = "DevESPBillboard"
                    bb.Size = UDim2.new(0, 220, 0, 70)
                    bb.StudsOffset = Vector3.new(0, 2.8, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = head

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Name = "NameLabel"
                    nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
                    nameLabel.Position = UDim2.new(0, 0, 0, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.fromRGB(0, 230, 150)
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 14
                    nameLabel.Parent = bb

                    local healthBg = Instance.new("Frame")
                    healthBg.Name = "HealthBg"
                    healthBg.Size = UDim2.new(0.85, 0, 0.25, 0)
                    healthBg.Position = UDim2.new(0.075, 0, 0.5, 0)
                    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    healthBg.BorderSizePixel = 0
                    healthBg.Parent = bb
                    Instance.new("UICorner", healthBg).CornerRadius = UDim.new(0, 4)

                    local healthBar = Instance.new("Frame")
                    healthBar.Name = "HealthBar"
                    healthBar.Size = UDim2.new(1, 0, 1, 0)
                    healthBar.BackgroundColor3 = Color3.fromRGB(0, 230, 0)
                    healthBar.BorderSizePixel = 0
                    healthBar.Parent = healthBg
                    Instance.new("UICorner", healthBar).CornerRadius = UDim.new(0, 4)

                    bb.Parent = char
                end

                local nameLabel = bb:FindFirstChild("NameLabel")
                local healthBg = bb:FindFirstChild("HealthBg")
                local healthBar = healthBg and healthBg:FindFirstChild("HealthBar")
                if nameLabel and healthBar and healthBg then
                    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local targetHrp = char:FindFirstChild("HumanoidRootPart")
                    local dist = (myHrp and targetHrp) and math.floor((myHrp.Position - targetHrp.Position).Magnitude) or 0
                    nameLabel.Text = p.DisplayName .. " [" .. tostring(dist) .. "m]"
                    local hp = hum.Health / hum.MaxHealth
                    healthBar.Size = UDim2.new(math.clamp(hp, 0, 1), 0, 1, 0)
                    if hp > 0.5 then
                        healthBar.BackgroundColor3 = Color3.fromRGB(0, 230, 0)
                    elseif hp > 0.25 then
                        healthBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                    else
                        healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    end
                end
            else
                if hl then hl.Enabled = false end
                if bb then bb:Destroy() end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p)
    if p.Character then
        local hl = p.Character:FindFirstChild("DevESPHighlight")
        local bb = p.Character:FindFirstChild("DevESPBillboard")
        if hl then hl:Destroy() end
        if bb then bb:Destroy() end
        local rootPart = p.Character:FindFirstChild("HumanoidRootPart")
        if rootPart and originalSizes[rootPart] then originalSizes[rootPart] = nil end
    end
end)

task.spawn(function()
    while screenGui.Parent do
        if featureStates.espEnabled then updateESP() end
        task.wait(0.5)
    end
end)

---------------------------------------------------------
-- MISC TAB
---------------------------------------------------------
local autoClickSlider = createSlider(tabMisc, "Auto Click Delay (s)", 0.05, 1, 0.1, function(val)
    autoClickDelay = val
end)
addSlider("autoClickDelay", autoClickSlider)
local autoClickBtn = createToggle(tabMisc, "Auto Click")

local autoCollectSlider = createSlider(tabMisc, "Auto Collect Radius", 5, 50, 20, function(val)
    autoCollectRadius = val
end)
addSlider("autoCollectRadius", autoCollectSlider)
local autoCollectBtn = createToggle(tabMisc, "Auto Collect (Items)")

---------------------------------------------------------
-- FPS BOOST TAB
---------------------------------------------------------
local boostFpsBtn = createActionButton(tabBooster, "🚀 Tối Ưu Đồ Họa (FPS)", Color3.fromRGB(0, 180, 120))
local removeTexturesBtn = createActionButton(tabBooster, "🗑️ Xóa Textures & Decals", Color3.fromRGB(200, 140, 0))
local removeEffectsBtn = createActionButton(tabBooster, "✨ Tắt Hiệu Ứng (Particle/Fire)", Color3.fromRGB(120, 60, 200))
local resetGraphicsBtn = createActionButton(tabBooster, "🔄 Khôi Phục Đồ Họa", Color3.fromRGB(200, 50, 60))

local originalGlobalShadows = Lighting.GlobalShadows
local originalFogEnd = Lighting.FogEnd
local originalQuality = settings().Rendering.QualityLevel

boostFpsBtn.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
        end
    end
    boostFpsBtn.Text = "✓ Đã Tối Ưu!"
    task.wait(1.5)
    boostFpsBtn.Text = "🚀 Tối Ưu Đồ Họa (FPS)"
end)

removeTexturesBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
    removeTexturesBtn.Text = "✓ Đã Xóa!"
    task.wait(1.5)
    removeTexturesBtn.Text = "🗑️ Xóa Textures & Decals"
end)

removeEffectsBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    removeEffectsBtn.Text = "✓ Đã Ẩn!"
    task.wait(1.5)
    removeEffectsBtn.Text = "✨ Tắt Hiệu Ứng (Particle/Fire)"
end)

resetGraphicsBtn.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = originalGlobalShadows
    Lighting.FogEnd = originalFogEnd
    settings().Rendering.QualityLevel = originalQuality
    resetGraphicsBtn.Text = "✓ Đã Khôi Phục!"
    task.wait(1.5)
    resetGraphicsBtn.Text = "🔄 Khôi Phục Đồ Họa"
end)

---------------------------------------------------------
-- KEYBINDS TAB
---------------------------------------------------------
local keybinds = {
    Freecam = Enum.KeyCode.P,
    Fly = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    ClickTP = Enum.KeyCode.T,
    InfJump = Enum.KeyCode.J,
    ESP = Enum.KeyCode.E,
    Aimbot = Enum.KeyCode.R,
}

local function createKeybindRow(parent, labelText, actionKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0.75, 0)
    btn.Position = UDim2.new(0.65, 0, 0.12, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = keybinds[actionKey].Name
    btn.TextColor3 = Color3.fromRGB(0, 230, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

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

createKeybindRow(tabKeybinds, "Freecam", "Freecam")
createKeybindRow(tabKeybinds, "Fly", "Fly")
createKeybindRow(tabKeybinds, "Noclip", "Noclip")
createKeybindRow(tabKeybinds, "Click TP", "ClickTP")
createKeybindRow(tabKeybinds, "Nhảy Vô Hạn", "InfJump")
createKeybindRow(tabKeybinds, "ESP", "ESP")
createKeybindRow(tabKeybinds, "Aimbot", "Aimbot")

---------------------------------------------------------
-- SETTINGS TAB
---------------------------------------------------------
local configFileName = "DevConfig_UltimateV4_" .. game.PlaceId .. ".json"

local saveConfigBtn = createActionButton(tabSettings, "💾 Lưu Cấu Hình", Color3.fromRGB(0, 140, 240))
local loadConfigBtn = createActionButton(tabSettings, "📂 Tải Cấu Hình", Color3.fromRGB(200, 140, 0))
local resetConfigBtn = createActionButton(tabSettings, "🔄 Reset Cài Đặt", Color3.fromRGB(200, 50, 60))

-- Nút tắt script
local killScriptBtn = createActionButton(tabSettings, "⛔ TẮT TOÀN BỘ SCRIPT", Color3.fromRGB(200, 50, 70))
killScriptBtn.MouseButton1Click:Connect(function()
    confirmModal.Visible = true
end)

local function getCurrentConfig()
    return {
        hitboxSize = hitboxSize,
        aimSmoothness = aimSmoothness,
        fovRadius = fovRadius,
        customWalkSpeed = customWalkSpeed,
        customJumpPower = customJumpPower,
        flySpeed = flySpeed,
        freecamSpeedMultiplier = freecamSpeedMultiplier,
        autoTpInterval = autoTpInterval,
        autoClickDelay = autoClickDelay,
        autoCollectRadius = autoCollectRadius,
        rapidFireDelay = rapidFireDelay,
        aimTarget = aimTarget,
        keybinds = {
            Freecam = keybinds.Freecam.Name,
            Fly = keybinds.Fly.Name,
            Noclip = keybinds.Noclip.Name,
            ClickTP = keybinds.ClickTP.Name,
            InfJump = keybinds.InfJump.Name,
            ESP = keybinds.ESP.Name,
            Aimbot = keybinds.Aimbot.Name,
        },
        toggles = featureStates
    }
end

local function applyConfig(cfg)
    if cfg.hitboxSize then hitboxSize = cfg.hitboxSize if sliders["hitboxSize"] then sliders["hitboxSize"].update(hitboxSize) end end
    if cfg.aimSmoothness then aimSmoothness = cfg.aimSmoothness if sliders["aimSmoothness"] then sliders["aimSmoothness"].update(aimSmoothness) end end
    if cfg.fovRadius then fovRadius = cfg.fovRadius if sliders["fovRadius"] then sliders["fovRadius"].update(fovRadius) end end
    if cfg.customWalkSpeed then customWalkSpeed = cfg.customWalkSpeed if sliders["customWalkSpeed"] then sliders["customWalkSpeed"].update(customWalkSpeed) end end
    if cfg.customJumpPower then customJumpPower = cfg.customJumpPower if sliders["customJumpPower"] then sliders["customJumpPower"].update(customJumpPower) end end
    if cfg.flySpeed then flySpeed = cfg.flySpeed if sliders["flySpeed"] then sliders["flySpeed"].update(flySpeed) end end
    if cfg.freecamSpeedMultiplier then freecamSpeedMultiplier = cfg.freecamSpeedMultiplier if sliders["freecamSpeedMultiplier"] then sliders["freecamSpeedMultiplier"].update(freecamSpeedMultiplier) end end
    if cfg.autoTpInterval then autoTpInterval = cfg.autoTpInterval if sliders["autoTpInterval"] then sliders["autoTpInterval"].update(autoTpInterval) end end
    if cfg.autoClickDelay then autoClickDelay = cfg.autoClickDelay if sliders["autoClickDelay"] then sliders["autoClickDelay"].update(autoClickDelay) end end
    if cfg.autoCollectRadius then autoCollectRadius = cfg.autoCollectRadius if sliders["autoCollectRadius"] then sliders["autoCollectRadius"].update(autoCollectRadius) end end
    if cfg.rapidFireDelay then rapidFireDelay = cfg.rapidFireDelay if sliders["rapidFireDelay"] then sliders["rapidFireDelay"].update(rapidFireDelay) end end
    if cfg.aimTarget then
        aimTarget = cfg.aimTarget
        if dropdowns["aimTarget"] then dropdowns["aimTarget"].setValue(aimTarget) end
    end
    if cfg.keybinds then
        for k, v in pairs(cfg.keybinds) do
            local enum = Enum.KeyCode[v]
            if enum then keybinds[k] = enum end
        end
    end
    if cfg.toggles then
        for k, v in pairs(cfg.toggles) do
            if featureStates[k] ~= nil then featureStates[k] = v end
        end
    end
end

saveConfigBtn.MouseButton1Click:Connect(function()
    if not writefile then return end
    local config = getCurrentConfig()
    local success, err = pcall(function()
        writefile(configFileName, HttpService:JSONEncode(config))
    end)
    if success then
        saveConfigBtn.Text = "✓ Lưu!"
        task.wait(1.5)
        saveConfigBtn.Text = "💾 Lưu Cấu Hình"
    else
        saveConfigBtn.Text = "❌ Lỗi!"
        task.wait(1.5)
        saveConfigBtn.Text = "💾 Lưu Cấu Hình"
    end
end)

loadConfigBtn.MouseButton1Click:Connect(function()
    if not readfile or not isfile or not isfile(configFileName) then return end
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(configFileName)) end)
    if success and data then
        applyConfig(data)
        loadConfigBtn.Text = "✓ Tải!"
        task.wait(1.5)
        loadConfigBtn.Text = "📂 Tải Cấu Hình"
    else
        loadConfigBtn.Text = "❌ Lỗi!"
        task.wait(1.5)
        loadConfigBtn.Text = "📂 Tải Cấu Hình"
    end
end)

resetConfigBtn.MouseButton1Click:Connect(function()
    hitboxSize = 5
    aimSmoothness = 0.2
    fovRadius = 120
    customWalkSpeed = 50
    customJumpPower = 100
    flySpeed = 50
    freecamSpeedMultiplier = 1
    autoTpInterval = 3
    autoClickDelay = 0.1
    autoCollectRadius = 20
    rapidFireDelay = 0.05
    aimTarget = "Head"
    for k in pairs(featureStates) do featureStates[k] = false end
    keybinds = {
        Freecam = Enum.KeyCode.P,
        Fly = Enum.KeyCode.F,
        Noclip = Enum.KeyCode.N,
        ClickTP = Enum.KeyCode.T,
        InfJump = Enum.KeyCode.J,
        ESP = Enum.KeyCode.E,
        Aimbot = Enum.KeyCode.R,
    }
    for name, slider in pairs(sliders) do
        if name == "hitboxSize" then slider.update(hitboxSize)
        elseif name == "aimSmoothness" then slider.update(aimSmoothness)
        elseif name == "fovRadius" then slider.update(fovRadius)
        elseif name == "customWalkSpeed" then slider.update(customWalkSpeed)
        elseif name == "customJumpPower" then slider.update(customJumpPower)
        elseif name == "flySpeed" then slider.update(flySpeed)
        elseif name == "freecamSpeedMultiplier" then slider.update(freecamSpeedMultiplier)
        elseif name == "autoTpInterval" then slider.update(autoTpInterval)
        elseif name == "autoClickDelay" then slider.update(autoClickDelay)
        elseif name == "autoCollectRadius" then slider.update(autoCollectRadius)
        elseif name == "rapidFireDelay" then slider.update(rapidFireDelay)
        end
    end
    if dropdowns["aimTarget"] then dropdowns["aimTarget"].setValue("Head") end
    resetConfigBtn.Text = "✓ Reset!"
    task.wait(1.5)
    resetConfigBtn.Text = "🔄 Reset Cài Đặt"
end)

---------------------------------------------------------
-- STATS UPDATE
---------------------------------------------------------
local startTime = os.time()
local frameCount = 0
local fpsTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)
    frameCount = frameCount + 1
    fpsTimer = fpsTimer + deltaTime
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
-- LOGIC CHÍNH (Aimbot, Triggerbot, No Recoil, v.v.)
---------------------------------------------------------
local function getClosestPlayer()
    local closestPart = nil
    local shortestDistance = fovRadius
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == player then continue end
        local char = targetPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local targetPart = char:FindFirstChild(aimTarget) or char:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
        if dist < shortestDistance then
            if featureStates.wallCheckEnabled then
                if isPartVisible(targetPart) then
                    shortestDistance = dist
                    closestPart = targetPart
                end
            else
                shortestDistance = dist
                closestPart = targetPart
            end
        end
    end
    return closestPart
end

local function isPartVisible(part)
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character, part.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local hasDrawing = Drawing ~= nil
local fovCircle
if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.Color = Color3.fromRGB(0, 230, 255)
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Visible = false
end

fovToggleBtn.MouseButton1Click:Connect(function()
    featureStates.fovCircleEnabled = not featureStates.fovCircleEnabled
    updateToggle(fovToggleBtn, featureStates.fovCircleEnabled)
    if fovCircle then fovCircle.Visible = featureStates.fovCircleEnabled end
end)

hitboxToggleBtn.MouseButton1Click:Connect(function()
    featureStates.hitboxEnabled = not featureStates.hitboxEnabled
    updateToggle(hitboxToggleBtn, featureStates.hitboxEnabled)
    if not featureStates.hitboxEnabled then resetHitboxes() end
end)

-- Combat toggles
aimbotToggleBtn.MouseButton1Click:Connect(function()
    featureStates.aimbotEnabled = not featureStates.aimbotEnabled
    updateToggle(aimbotToggleBtn, featureStates.aimbotEnabled)
end)

triggerbotToggleBtn.MouseButton1Click:Connect(function()
    featureStates.triggerbotEnabled = not featureStates.triggerbotEnabled
    updateToggle(triggerbotToggleBtn, featureStates.triggerbotEnabled)
end)

wallCheckBtn.MouseButton1Click:Connect(function()
    featureStates.wallCheckEnabled = not featureStates.wallCheckEnabled
    updateToggle(wallCheckBtn, featureStates.wallCheckEnabled)
end)

noRecoilBtn.MouseButton1Click:Connect(function()
    featureStates.noRecoilEnabled = not featureStates.noRecoilEnabled
    updateToggle(noRecoilBtn, featureStates.noRecoilEnabled)
end)

infiniteAmmoBtn.MouseButton1Click:Connect(function()
    featureStates.infiniteAmmoEnabled = not featureStates.infiniteAmmoEnabled
    updateToggle(infiniteAmmoBtn, featureStates.infiniteAmmoEnabled)
end)

rapidFireBtn.MouseButton1Click:Connect(function()
    featureStates.rapidFireEnabled = not featureStates.rapidFireEnabled
    updateToggle(rapidFireBtn, featureStates.rapidFireEnabled)
end)

-- Movement toggles
godmodeBtn.MouseButton1Click:Connect(function()
    featureStates.godmodeEnabled = not featureStates.godmodeEnabled
    updateToggle(godmodeBtn, featureStates.godmodeEnabled)
end)

clickTpBtn.MouseButton1Click:Connect(function()
    featureStates.clickTpEnabled = not featureStates.clickTpEnabled
    updateToggle(clickTpBtn, featureStates.clickTpEnabled)
end)

infJumpBtn.MouseButton1Click:Connect(function()
    featureStates.infJumpEnabled = not featureStates.infJumpEnabled
    updateToggle(infJumpBtn, featureStates.infJumpEnabled)
end)

autoJumpBtn.MouseButton1Click:Connect(function()
    featureStates.autoJumpEnabled = not featureStates.autoJumpEnabled
    updateToggle(autoJumpBtn, featureStates.autoJumpEnabled)
end)

autoSprintBtn.MouseButton1Click:Connect(function()
    featureStates.autoSprintEnabled = not featureStates.autoSprintEnabled
    updateToggle(autoSprintBtn, featureStates.autoSprintEnabled)
end)

noclipBtn.MouseButton1Click:Connect(function()
    featureStates.noclipEnabled = not featureStates.noclipEnabled
    updateToggle(noclipBtn, featureStates.noclipEnabled)
end)

walkSpeedBtn.MouseButton1Click:Connect(function()
    featureStates.walkSpeedEnabled = not featureStates.walkSpeedEnabled
    updateToggle(walkSpeedBtn, featureStates.walkSpeedEnabled)
    if not featureStates.walkSpeedEnabled then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

jumpPowerBtn.MouseButton1Click:Connect(function()
    featureStates.jumpPowerEnabled = not featureStates.jumpPowerEnabled
    updateToggle(jumpPowerBtn, featureStates.jumpPowerEnabled)
    if not featureStates.jumpPowerEnabled then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true hum.JumpPower = 50 end
    end
end)

fullbrightBtn.MouseButton1Click:Connect(function()
    featureStates.fullbrightEnabled = not featureStates.fullbrightEnabled
    updateToggle(fullbrightBtn, featureStates.fullbrightEnabled)
    if not featureStates.fullbrightEnabled then
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
    end
end)

antiAfkBtn.MouseButton1Click:Connect(function()
    featureStates.antiAfkEnabled = not featureStates.antiAfkEnabled
    updateToggle(antiAfkBtn, featureStates.antiAfkEnabled)
end)

autoClickBtn.MouseButton1Click:Connect(function()
    featureStates.autoClickEnabled = not featureStates.autoClickEnabled
    updateToggle(autoClickBtn, featureStates.autoClickEnabled)
end)

autoCollectBtn.MouseButton1Click:Connect(function()
    featureStates.autoCollectEnabled = not featureStates.autoCollectEnabled
    updateToggle(autoCollectBtn, featureStates.autoCollectEnabled)
end)

espBtn.MouseButton1Click:Connect(function()
    featureStates.espEnabled = not featureStates.espEnabled
    updateToggle(espBtn, featureStates.espEnabled)
    updateESP()
end)

---------------------------------------------------------
-- FLING LOGIC (lấy từ IY)
---------------------------------------------------------
-- Hàm unfling (tắt fling)
local function unfling()
    flingRunning = false
    if flingDied then flingDied:Disconnect() end
    -- Xóa BodyAngularVelocity
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local root = getRoot(char)
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyAngularVelocity") and v.Name == "IYFlingAngular" then
                    v:Destroy()
                end
            end
            -- Khôi phục các thuộc tính
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    part.Massless = false
                    part.Velocity = Vector3.zero
                end
            end
        end
    end
    -- Tắt noclip nếu đã bật
    if featureStates.noclipEnabled then
        featureStates.noclipEnabled = false
        updateToggle(noclipBtn, false)
        execCmd("unnoclip nonotify")
    end
end

-- Hàm fling chính
local function fling()
    unfling()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local root = getRoot(char)
    if not root then return end

    -- Bật noclip
    if not featureStates.noclipEnabled then
        featureStates.noclipEnabled = true
        updateToggle(noclipBtn, true)
        execCmd("noclip nonotify")
    end

    -- Tăng sức mạnh fling
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
            part.Massless = true
            part.Velocity = Vector3.zero
        end
    end

    -- BodyAngularVelocity để tạo lực xoay
    local angular = Instance.new("BodyAngularVelocity")
    angular.Name = "IYFlingAngular"
    angular.Parent = root
    angular.AngularVelocity = Vector3.new(0, 99999, 0)
    angular.MaxTorque = Vector3.new(0, math.huge, 0)
    angular.P = math.huge

    flingRunning = true
    flingDied = humanoid.Died:Connect(function()
        unfling()
    end)

    -- Vòng lặp duy trì fling
    task.spawn(function()
        while flingRunning do
            if root and root.Parent then
                angular.AngularVelocity = Vector3.new(0, 99999, 0)
            end
            task.wait(0.2)
            if root and root.Parent then
                angular.AngularVelocity = Vector3.new(0, 0, 0)
            end
            task.wait(0.1)
        end
    end)
end

-- Walk Fling (bản sao từ IY, điều chỉnh)
local function walkfling()
    unfling()
    walkflingRunning = true
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Bật noclip
    if not featureStates.noclipEnabled then
        featureStates.noclipEnabled = true
        updateToggle(noclipBtn, true)
        execCmd("noclip nonotify")
    end

    walkflingLoop = RunService.Heartbeat:Connect(function()
        if not walkflingRunning then return end
        local char = player.Character
        local root = char and getRoot(char)
        if root and root.Parent then
            local vel = root.Velocity
            root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            task.wait(0.1)
            if root and root.Parent then
                root.Velocity = vel
            end
            task.wait(0.1)
            if root and root.Parent then
                root.Velocity = vel + Vector3.new(0, 0.1, 0)
            end
        end
    end)

    humanoid.Died:Connect(function()
        unwalkfling()
    end)
end

local function unwalkfling()
    walkflingRunning = false
    if walkflingLoop then walkflingLoop:Disconnect() end
    -- Tắt noclip nếu đã bật
    if featureStates.noclipEnabled then
        featureStates.noclipEnabled = false
        updateToggle(noclipBtn, false)
        execCmd("unnoclip nonotify")
    end
end

-- Fly Fling (kết hợp fly + fling)
local function flyfling()
    unfling()
    flyflingRunning = true
    -- Bật fly
    if not featureStates.flyEnabled then
        featureStates.flyEnabled = true
        updateToggle(flyBtn, true)
        execCmd("fly nonotify")
    end
    -- Bật noclip
    if not featureStates.noclipEnabled then
        featureStates.noclipEnabled = true
        updateToggle(noclipBtn, true)
        execCmd("noclip nonotify")
    end
    -- Điều chỉnh speed (nếu cần)
    flyflingLoop = RunService.Heartbeat:Connect(function()
        if not flyflingRunning then return end
        local char = player.Character
        local root = char and getRoot(char)
        if root and root.Parent then
            root.Velocity = root.Velocity * 1.1 + Vector3.new(0, 10, 0)
        end
    end)
    player.CharacterAdded:Connect(function()
        unflyfling()
    end)
end

local function unflyfling()
    flyflingRunning = false
    if flyflingLoop then flyflingLoop:Disconnect() end
    if featureStates.flyEnabled then
        featureStates.flyEnabled = false
        updateToggle(flyBtn, false)
        execCmd("unfly nonotify")
    end
    if featureStates.noclipEnabled then
        featureStates.noclipEnabled = false
        updateToggle(noclipBtn, false)
        execCmd("unnoclip nonotify")
    end
end

-- Invis Fling (tàng hình + fling)
local function invisfling()
    unfling()
    invisflingRunning = true
    -- Thực hiện tàng hình (cách đơn giản: set transparency)
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    end
    -- Bật fling
    fling()
    player.CharacterAdded:Connect(function()
        uninvisfling()
    end)
end

local function uninvisfling()
    invisflingRunning = false
    unfling()
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end

-- Kết nối các toggle fling
flingBtn.MouseButton1Click:Connect(function()
    featureStates.flingEnabled = not featureStates.flingEnabled
    updateToggle(flingBtn, featureStates.flingEnabled)
    if featureStates.flingEnabled then
        fling()
    else
        unfling()
    end
end)

walkflingBtn.MouseButton1Click:Connect(function()
    featureStates.walkflingEnabled = not featureStates.walkflingEnabled
    updateToggle(walkflingBtn, featureStates.walkflingEnabled)
    if featureStates.walkflingEnabled then
        walkfling()
    else
        unwalkfling()
    end
end)

flyflingBtn.MouseButton1Click:Connect(function()
    featureStates.flyflingEnabled = not featureStates.flyflingEnabled
    updateToggle(flyflingBtn, featureStates.flyflingEnabled)
    if featureStates.flyflingEnabled then
        flyfling()
    else
        unflyfling()
    end
end)

invisflingBtn.MouseButton1Click:Connect(function()
    featureStates.invisflingEnabled = not featureStates.invisflingEnabled
    updateToggle(invisflingBtn, featureStates.invisflingEnabled)
    if featureStates.invisflingEnabled then
        invisfling()
    else
        uninvisfling()
    end
end)

---------------------------------------------------------
-- FREECAM & FLY
---------------------------------------------------------
local freecamCFrame = CFrame.new()
local freecamYaw = 0
local freecamPitch = 0
local freecamConn = nil
local flyVel = nil
local flyAlign = nil
local flyAttachment = nil

local function toggleFreecam()
    featureStates.freecamEnabled = not featureStates.freecamEnabled
    updateToggle(freecamBtn, featureStates.freecamEnabled)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if featureStates.freecamEnabled then
        camera.CameraType = Enum.CameraType.Scriptable
        freecamCFrame = camera.CFrame
        local rx, ry, rz = freecamCFrame:ToOrientation()
        freecamYaw = ry
        freecamPitch = rx
        if hrp then hrp.Anchored = true end
        if freecamConn then freecamConn:Disconnect() end
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
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
end

local function stopFlying()
    if flyVel then flyVel:Destroy() flyVel = nil end
    if flyAlign then flyAlign:Destroy() flyAlign = nil end
    if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function toggleFly()
    featureStates.flyEnabled = not featureStates.flyEnabled
    updateToggle(flyBtn, featureStates.flyEnabled)
    if featureStates.flyEnabled then startFlying() else stopFlying() end
end

freecamBtn.MouseButton1Click:Connect(toggleFreecam)
flyBtn.MouseButton1Click:Connect(toggleFly)

---------------------------------------------------------
-- SPECTATE
---------------------------------------------------------
local isSpectating = false
local spectateConnection = nil

local function stopSpectate()
    isSpectating = false
    if spectateConnection then spectateConnection:Disconnect() spectateConnection = nil end
    spectateBtn.Text = "Spectate"
    spectateBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    local myHum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if myHum then camera.CameraSubject = myHum end
end

spectateBtn.MouseButton1Click:Connect(function()
    if isSpectating then stopSpectate() return end
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
                spectateConnection = targetHum.Died:Connect(function() stopSpectate() end)
                break
            end
        end
    end
end)

---------------------------------------------------------
-- INPUT HANDLING (chỉ K, bỏ RightShift)
---------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        mainFrame.Visible = not mainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        -- Bỏ qua
    elseif input.KeyCode == keybinds.Freecam then
        toggleFreecam()
    elseif input.KeyCode == keybinds.Fly then
        toggleFly()
    elseif input.KeyCode == keybinds.Noclip then
        featureStates.noclipEnabled = not featureStates.noclipEnabled
        updateToggle(noclipBtn, featureStates.noclipEnabled)
    elseif input.KeyCode == keybinds.ClickTP then
        featureStates.clickTpEnabled = not featureStates.clickTpEnabled
        updateToggle(clickTpBtn, featureStates.clickTpEnabled)
    elseif input.KeyCode == keybinds.InfJump then
        featureStates.infJumpEnabled = not featureStates.infJumpEnabled
        updateToggle(infJumpBtn, featureStates.infJumpEnabled)
    elseif input.KeyCode == keybinds.ESP then
        featureStates.espEnabled = not featureStates.espEnabled
        updateToggle(espBtn, featureStates.espEnabled)
        updateESP()
    elseif input.KeyCode == keybinds.Aimbot then
        featureStates.aimbotEnabled = not featureStates.aimbotEnabled
        updateToggle(aimbotToggleBtn, featureStates.aimbotEnabled)
    end

    for i = 1, 9 do
        if input.KeyCode == Enum.KeyCode["Key" .. i] then
            if #waypointsList >= i then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = waypointsList[i].CFrame end
            end
            break
        end
    end
end)

-- Click TP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if featureStates.clickTpEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and mouse.Hit then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Jump Request
UserInputService.JumpRequest:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if featureStates.infJumpEnabled and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-AFK
player.Idled:Connect(function()
    if featureStates.antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

---------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------
local lastSafeCFrame = nil

RunService.RenderStepped:Connect(function()
    -- Fullbright
    if featureStates.fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    end

    -- Hitbox
    if featureStates.hitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
                local rootPart = p.Character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and rootPart then
                    if not originalSizes[rootPart] then
                        originalSizes[rootPart] = rootPart.Size
                    end
                    rootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    rootPart.Transparency = 0.7
                    rootPart.Color = Color3.fromRGB(255, 0, 0)
                    rootPart.Material = Enum.Material.SmoothPlastic
                    rootPart.CanCollide = false
                end
            end
        end
    end

    -- FOV Circle
    if featureStates.fovCircleEnabled and fovCircle then
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
        fovCircle.Radius = fovRadius
    end

    -- Aimbot
    if featureStates.aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPart = getClosestPlayer()
        if targetPart then
            local targetCFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, aimSmoothness)
        end
    end

    -- Triggerbot
    if featureStates.triggerbotEnabled then
        local targetPart = getClosestPlayer()
        if targetPart then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
            task.wait(0.05)
        end
    end

    -- Fly
    if featureStates.flyEnabled and flyVel and flyAlign then
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

    -- Auto Collect
    if featureStates.autoCollectEnabled then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("collect") or obj.Name:lower():find("item") or obj:IsA("Tool")) then
                    local distance = (obj.Position - hrp.Position).Magnitude
                    if distance <= autoCollectRadius then
                        hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- Godmode
    if featureStates.godmodeEnabled and hum then
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if hrp and hrp.Position.Y > workspace.FallenPartsDestroyHeight + 20 then
            if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                lastSafeCFrame = hrp.CFrame
            end
        end
        if hrp and lastSafeCFrame and hrp.Position.Y <= workspace.FallenPartsDestroyHeight + 10 then
            hrp.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- Noclip
    if featureStates.noclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Walk Speed
    if featureStates.walkSpeedEnabled and hum then
        hum.WalkSpeed = customWalkSpeed
    end

    -- Jump Power
    if featureStates.jumpPowerEnabled and hum then
        hum.UseJumpPower = true
        hum.JumpPower = customJumpPower
    end

    -- Auto Jump
    if featureStates.autoJumpEnabled and hum and hum:GetState() == Enum.HumanoidStateType.Running then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Auto Sprint
    if featureStates.autoSprintEnabled and hum then
        hum.AutoRotate = false
        hum.WalkSpeed = customWalkSpeed
    end

    -- No Recoil
    if featureStates.noRecoilEnabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:lower():find("recoil") or v.Name:lower():find("spread")) then
                    v.Value = 0
                end
            end
        end
    end

    -- Infinite Ammo
    if featureStates.infiniteAmmoEnabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("CurrentAmmo") or tool:FindFirstChild("AmmoCount")
            if ammo and ammo:IsA("IntValue") then
                ammo.Value = 999
            end
        end
    end

    -- Rapid Fire
    if featureStates.rapidFireEnabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            task.spawn(function()
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and featureStates.rapidFireEnabled do
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new())
                    task.wait(rapidFireDelay)
                end
            end)
        end
    end
end)

---------------------------------------------------------
-- MINIMIZE & CLOSE
---------------------------------------------------------
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 300, 0, 48)
        sidebar.Visible = false
        contentArea.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 650, 0, 500)
        task.wait(0.15)
        sidebar.Visible = true
        contentArea.Visible = true
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function() confirmModal.Visible = true end)
confirmYesBtn.MouseButton1Click:Connect(function() unloadAllFeatures() end)
confirmNoBtn.MouseButton1Click:Connect(function() confirmModal.Visible = false end)

-- Logo toggle menu
logoBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

---------------------------------------------------------
-- UNLOAD
---------------------------------------------------------
local function unloadAllFeatures()
    featureStates.autoTpEnabled = false
    if autoTpThread then task.cancel(autoTpThread) end
    featureStates.hitboxEnabled = false
    featureStates.aimbotEnabled = false
    featureStates.triggerbotEnabled = false
    featureStates.fovCircleEnabled = false
    featureStates.wallCheckEnabled = false
    featureStates.noRecoilEnabled = false
    featureStates.infiniteAmmoEnabled = false
    featureStates.rapidFireEnabled = false
    featureStates.godmodeEnabled = false
    featureStates.clickTpEnabled = false
    featureStates.infJumpEnabled = false
    featureStates.autoJumpEnabled = false
    featureStates.autoSprintEnabled = false
    featureStates.noclipEnabled = false
    featureStates.walkSpeedEnabled = false
    featureStates.jumpPowerEnabled = false
    featureStates.flyEnabled = false
    featureStates.espEnabled = false
    featureStates.fullbrightEnabled = false
    featureStates.antiAfkEnabled = false
    featureStates.freecamEnabled = false
    featureStates.autoClickEnabled = false
    featureStates.autoCollectEnabled = false
    featureStates.flingEnabled = false
    featureStates.walkflingEnabled = false
    featureStates.flyflingEnabled = false
    featureStates.invisflingEnabled = false

    -- Tắt các fling
    unfling()
    unwalkfling()
    unflyfling()
    uninvisfling()

    resetHitboxes()
    if fovCircle then fovCircle:Remove() end
    if featureStates.freecamEnabled then toggleFreecam() end
    stopFlying()
    stopSpectate()

    Lighting.Brightness = originalBrightness
    Lighting.ClockTime = originalClockTime

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

local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime

print("✅ DEV MASTER ULTIMATE V4 – Fling from IY loaded!")
print("📌 Bấm K để mở menu (RightShift bỏ).")
print("📌 Logo bấm toggle menu.")
print("📌 Tab Fling: fling, walkfling, flyfling, invisfling (đều cực mạnh).")
print("📌 Nút tắt script trong tab Cài Đặt.")
