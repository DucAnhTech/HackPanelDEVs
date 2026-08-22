--[[
    DEV MASTER ULTIMATE V1 – KẾ THỪA INFINITE YIELD (BỎ FLING, SETTINGS, MISC)
    - Giao diện slider, toggle, dropdown
    - Combat: Aimbot, Triggerbot, Hitbox, No Recoil, v.v.
    - Movement: Fly, Noclip, Speed, Jump, Freecam, v.v.
    - ESP Highlight + Billboard
    - Waypoint, Auto TP
    - FPS Boost, Keybinds
    - Nút tắt toàn bộ script (Kill Switch)
    - Logo toggle menu, chỉ dùng phím K
    - COMPATIBILITY: Hỗ trợ đa executor (Synapse, Krnl, Fluxus, v.v.)
--]]

-- ==========================================================
-- MODULE COMPATIBILITY - Tương thích đa executor
-- ==========================================================

-- Hàm kiểm tra và gán giá trị mặc định
local function missing(typeCheck, func, fallback)
    if type(func) == typeCheck then
        return func
    end
    return fallback
end

-- 1. WRITEFILE / READFILE (Lưu file)
local waxwritefile = writefile
local waxreadfile = readfile

writefile = missing("function", waxwritefile) and function(file, data, safe)
    if safe == true then
        return pcall(waxwritefile, file, data)
    end
    waxwritefile(file, data)
end

readfile = missing("function", waxreadfile) and function(file, safe)
    if safe == true then
        return pcall(waxreadfile, file)
    end
    return waxreadfile(file)
end

isfile = missing("function", isfile, readfile and function(file)
    local success, result = pcall(function()
        return readfile(file)
    end)
    return success and result ~= nil and result ~= ""
end)

makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
listfiles = missing("function", listfiles)

-- 2. HTTPREQUEST
httprequest = missing("function", request or http_request or 
    (syn and syn.request) or 
    (http and http.request) or 
    (fluxus and fluxus.request)
)

-- 3. QUEUE_ON_TELEPORT
queueteleport = missing("function", queue_on_teleport or 
    (syn and syn.queue_on_teleport) or 
    (fluxus and fluxus.queue_on_teleport)
)

-- 4. CLIPBOARD
everyClipboard = missing("function", setclipboard or 
    toclipboard or 
    set_clipboard or 
    (Clipboard and Clipboard.set)
)

-- 5. FIRETOUCHINTEREST
firetouchinterest = missing("function", firetouchinterest)

-- 6. CUSTOM ASSET
waxgetcustomasset = missing("function", getcustomasset or getsynasset)

-- 7. HOOK FUNCTIONS
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure, function(f, ...) return f(...) end)

-- 8. GETGC
getgc = missing("function", getgc or get_gc_objects)

-- 9. SETTHREADIDENTITY
setthreadidentity = missing("function", setthreadidentity or 
    (syn and syn.set_thread_identity) or 
    syn_context_set or 
    setthreadcontext
)

-- 10. REPLICATESIGNAL
replicatesignal = missing("function", replicatesignal)

-- 11. GETCONNECTIONS
getconnections = missing("function", getconnections or get_signal_cons)

-- 12. GETHIDDEN / SETHIDDEN
sethidden = missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden = missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)

-- 13. CLONEREF
cloneref = missing("function", cloneref, function(...) return ... end)

-- 14. IS_SIRHURT_CLOSURE
is_sirhurt_closure = is_sirhurt_closure or false

-- 15. GET_HIDDEN_GUI
get_hidden_gui = get_hidden_gui or gethui or function() 
    return game:GetService("CoreGui") 
end

-- 16. SYN PROTECT_GUI
local syn = syn or {}
syn.protect_gui = syn.protect_gui or function(gui) return gui end

-- Kiểm tra hàm hỗ trợ
local function hasWriteFile() return type(writefile) == "function" end
local function hasReadFile() return type(readfile) == "function" end
local function hasHttpRequest() return type(httprequest) == "function" end
local function hasQueueTeleport() return type(queueteleport) == "function" end
local function hasClipboard() return type(everyClipboard) == "function" end

print("📌 COMPATIBILITY MODULE LOADED")
print("✅ Writefile: " .. tostring(hasWriteFile()))
print("✅ Readfile: " .. tostring(hasReadFile()))
print("✅ HttpRequest: " .. tostring(hasHttpRequest()))
print("✅ QueueTeleport: " .. tostring(hasQueueTeleport()))
print("✅ Clipboard: " .. tostring(hasClipboard()))

-- ==========================================================
-- CONFIGURATION & CONSTANTS
-- ==========================================================
local CONFIG = {
    MINIMUM_FPS = 30,
    ESP_UPDATE_INTERVAL = 0.5,
    STATS_UPDATE_INTERVAL = 0.5,
    NOCLIP_RETRY_DELAY = 0.1,
    ANTI_AFK_CLICK_DELAY = 0.1,
    TOOL_SEARCH_RADIUS = 20,
}

-- ==========================================================
-- SERVICES
-- ==========================================================
local Services = {
    UserInput = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players"),
    Stats = game:GetService("Stats"),
    Teleport = game:GetService("TeleportService"),
    Http = game:GetService("HttpService"),
    Lighting = game:GetService("Lighting"),
    Tween = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    VirtualUser = game:GetService("VirtualUser"),
    Workspace = game:GetService("Workspace"),
}

local player = Services.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Services.Workspace.CurrentCamera
local mouse = player:GetMouse()

-- ==========================================================
-- GLOBAL STATE
-- ==========================================================
_G.stopScript = false
_G.DevMasterUnload = nil

-- Lưu giá trị gốc
local originalLighting = {
    Brightness = Services.Lighting.Brightness,
    ClockTime = Services.Lighting.ClockTime,
    GlobalShadows = Services.Lighting.GlobalShadows,
    FogEnd = Services.Lighting.FogEnd,
    Quality = settings().Rendering.QualityLevel,
}

if _G.DevMasterUnload then _G.DevMasterUnload() end

-- ==========================================================
-- FILE OPERATIONS
-- ==========================================================
local function saveFile(fileName, data)
    if not hasWriteFile() then 
        print("⚠️ Writefile không được hỗ trợ trên executor này")
        return false
    end
    local success, err = pcall(function()
        writefile(fileName, data, true)
    end)
    if not success then
        print("❌ Lỗi khi lưu file: " .. tostring(err))
    end
    return success
end

local function loadFile(fileName)
    if not hasReadFile() then 
        print("⚠️ Readfile không được hỗ trợ trên executor này")
        return nil
    end
    if not isfile(fileName) then
        return nil
    end
    local success, data = pcall(function()
        return readfile(fileName, true)
    end)
    if not success then
        print("❌ Lỗi khi đọc file: " .. tostring(data))
        return nil
    end
    return data
end

-- ==========================================================
-- NOCLIP SYSTEM (HOÀN CHỈNH - GIỐNG IY)
-- ==========================================================
local Clip = true
local Noclipping = nil
local NoclipParts = {}
local floatName = "FloatingPart"

local function toggleNoclip(state)
    if state then
        pcall(function() 
            if Noclipping then 
                Noclipping:Disconnect() 
                Noclipping = nil
            end 
        end)
        Clip = false
        task.wait(0.1)
        NoclipParts = {}
        Noclipping = Services.RunService.Stepped:Connect(function()
            if Clip == false and player.Character ~= nil then
                for _, child in pairs(player.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                        child.CanCollide = false
                        NoclipParts[child] = true
                    end
                end
            end
        end)
        print("✅ Noclip Enabled")
    else
        Clip = true
        if Noclipping then 
            Noclipping:Disconnect() 
            Noclipping = nil
        end
        if player.Character then
            for _, child in pairs(player.Character:GetDescendants()) do
                if child:IsA("BasePart") and NoclipParts[child] then
                    child.CanCollide = true
                end
            end
        end
        NoclipParts = {}
        print("❌ Noclip Disabled")
    end
end

-- ==========================================================
-- FLY SYSTEM (HOÀN CHỈNH)
-- ==========================================================
local flyEnabled = false
local flyVel = nil
local flyGyro = nil
local flyConn = nil

local function toggleFly(state)
    if state then
        if flyEnabled then return end
        flyEnabled = true
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        flyVel = Instance.new("BodyVelocity")
        flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyVel.Velocity = Vector3.new(0, 0, 0)
        flyVel.Parent = root
        
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyGyro.CFrame = root.CFrame
        flyGyro.Parent = root
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
        
        flyConn = Services.RunService.RenderStepped:Connect(function()
            if not flyEnabled or not root or not root.Parent then
                toggleFly(false)
                return
            end
            local moveVector = Vector3.new(0, 0, 0)
            if Services.UserInput:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Vector3.new(1, 0, 0) end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Vector3.new(0, 0, 1) end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
            
            local cameraCF = Services.Workspace.CurrentCamera.CFrame
            flyVel.Velocity = (cameraCF.LookVector * moveVector.X + cameraCF.RightVector * moveVector.Z + cameraCF.UpVector * moveVector.Y) * 50
            flyGyro.CFrame = cameraCF
        end)
        print("✅ Fly Enabled")
    else
        flyEnabled = false
        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                if flyVel then flyVel:Destroy(); flyVel = nil end
                if flyGyro then flyGyro:Destroy(); flyGyro = nil end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        print("❌ Fly Disabled")
    end
end

-- ==========================================================
-- KILL SWITCH
-- ==========================================================
local function createKillSwitch()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KillSwitch"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    syn.protect_gui(gui)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(1, -220, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.85
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0.05, 0)
    status.BackgroundTransparency = 1
    status.Text = "🟢 Đang chạy"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.TextSize = 12
    status.Font = Enum.Font.GothamBold
    status.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0.4, 0)
    btn.Position = UDim2.new(0.1, 0, 0.4, 0)
    btn.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = "🔴 TẮT HẲN"
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(220, 30, 30) end)
    btn.MouseButton1Click:Connect(function()
        _G.stopScript = true
        if _G.DevMasterUnload then _G.DevMasterUnload() end
        gui:Destroy()
        error("Script đã bị tắt hẳn bởi Kill Switch")
    end)

    -- Draggable
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    Services.UserInput.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return gui
end

-- ==========================================================
-- UI HELPERS
-- ==========================================================
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    Services.UserInput.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

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
        val = math.clamp(val, minVal, maxVal)
        local percent = (val - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7)
        valueBox.Text = tostring(math.round(val * 100) / 100)
        if callback then callback(val) end
    end

    local function updateSliderFromInput(input)
        local pos = input.Position.X
        local relX = pos - track.AbsolutePosition.X
        local percent = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
        local val = math.round((minVal + (maxVal - minVal) * percent) * 100) / 100
        updateSlider(val)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSliderFromInput(input)
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then updateSliderFromInput(input) end
    end)
    Services.UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSliderFromInput(input)
        end
    end)

    valueBox.FocusLost:Connect(function()
        local num = tonumber(valueBox.Text)
        if num then
            updateSlider(math.clamp(num, minVal, maxVal))
        else
            local currentPercent = fill.Size.X.Scale
            valueBox.Text = tostring(math.round((minVal + (maxVal - minVal) * currentPercent) * 100) / 100)
        end
    end)

    return { frame = frame, fill = fill, knob = knob, valueBox = valueBox, update = updateSlider }
end

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

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0.75, 0)
    btn.Position = UDim2.new(0.45, 0, 0.12, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = options[defaultIndex or 1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local currentIndex = defaultIndex or 1
    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        btn.Text = options[currentIndex]
        if callback then callback(options[currentIndex], currentIndex) end
    end)

    return {
        frame = frame,
        btn = btn,
        setValue = function(value)
            for i, opt in ipairs(options) do
                if opt == value then
                    currentIndex = i
                    btn.Text = value
                    if callback then callback(value, i) end
                    break
                end
            end
        end
    }
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

local function updateToggle(btn, state)
    btn.Text = state and "BẬT" or "TẮT"
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(200, 50, 60)
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

-- ==========================================================
-- CREATE MAIN GUI
-- ==========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevMasterUltimateV1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
syn.protect_gui(screenGui)

-- Logo
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
title.Text = "⚡ DEV MASTER ULTIMATE V1"
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

-- Confirm Modal
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

-- ==========================================================
-- TAB SYSTEM
-- ==========================================================
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

-- Create all tabs (ĐÃ XÓA TAB MISC VÀ SETTINGS)
local tabMain = createTab("Trạng Thái", "📊")
local tabCombat = createTab("Combat", "⚔️")
local tabMove = createTab("Di Chuyển", "🏃")
local tabWaypoint = createTab("Waypoint", "📍")
local tabVisual = createTab("ESP & Khác", "👁️")
local tabBooster = createTab("FPS Boost", "🚀")
local tabKeybinds = createTab("Phím Tắt", "⌨️")

pages["Trạng Thái"].Page.Visible = true
pages["Trạng Thái"].Button.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
pages["Trạng Thái"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==========================================================
-- STATS PANEL
-- ==========================================================
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
local playersLabel = createStatCard("PLAYERS", "0/" .. tostring(Services.Players.MaxPlayers))
local timeLabel = createStatCard("PLAYTIME", "00:00:00")

-- ==========================================================
-- FEATURE STATES
-- ==========================================================
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
    -- Visual
    espEnabled = false,
    fullbrightEnabled = false,
    antiAfkEnabled = false,
    freecamEnabled = false,
    invisibilityEnabled = false,
    -- Misc (giữ lại cho waypoint)
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

-- ==========================================================
-- SLIDERS & DROPDOWNS REGISTRY
-- ==========================================================
local sliders = {}
local dropdowns = {}

local function addSlider(name, obj) sliders[name] = obj end
local function addDropdown(name, obj) dropdowns[name] = obj end

-- ==========================================================
-- HITBOX SYSTEM
-- ==========================================================
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

-- ==========================================================
-- BUILD UI COMPONENTS
-- ==========================================================
-- Combat tab
local aimbotToggleBtn = createToggle(tabCombat, "Aimbot (Giữ Chuột Phải)")
local triggerbotToggleBtn = createToggle(tabCombat, "Triggerbot (Tự bắn)")
local fovToggleBtn = createToggle(tabCombat, "Hiện Vòng FOV")
local wallCheckBtn = createToggle(tabCombat, "Wall Check")
local hitboxToggleBtn = createToggle(tabCombat, "Hitbox Expander")

local aimPartDropdown = createDropdown(tabCombat, "Bộ Phận Nhắm", {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, 1, function(value) aimTarget = value end)
addDropdown("aimTarget", aimPartDropdown)

local fovSlider = createSlider(tabCombat, "Bán Kính FOV", 20, 300, 120, function(val) fovRadius = val end)
addSlider("fovRadius", fovSlider)

local aimSmoothSlider = createSlider(tabCombat, "Độ Mượt (Smooth)", 0.01, 1, 0.2, function(val) aimSmoothness = val end)
addSlider("aimSmoothness", aimSmoothSlider)

local hitboxSlider = createSlider(tabCombat, "Kích Thước Hitbox", 1, 50, 5, function(val) hitboxSize = val end)
addSlider("hitboxSize", hitboxSlider)

local noRecoilBtn = createToggle(tabCombat, "No Recoil")
local infiniteAmmoBtn = createToggle(tabCombat, "Infinite Ammo")
local rapidFireBtn = createToggle(tabCombat, "Rapid Fire")

-- Movement tab
local godmodeBtn = createToggle(tabMain, "Godmode")
local freecamSpeedSlider = createSlider(tabMove, "Freecam Speed", 0.1, 10, 1, function(val) freecamSpeedMultiplier = val end)
addSlider("freecamSpeedMultiplier", freecamSpeedSlider)
local freecamBtn = createToggle(tabMove, "Freecam (Bật/Tắt)")

local clickTpBtn = createToggle(tabMove, "Click TP (Ctrl+Click)")
local infJumpBtn = createToggle(tabMove, "Nhảy Vô Hạn")
local autoJumpBtn = createToggle(tabMove, "Auto Jump")
local autoSprintBtn = createToggle(tabMove, "Auto Sprint")
local noclipBtn = createToggle(tabMove, "Noclip")

local walkSpeedSlider = createSlider(tabMove, "Tốc Độ Chạy", 16, 200, 50, function(val) customWalkSpeed = val end)
addSlider("customWalkSpeed", walkSpeedSlider)
local walkSpeedBtn = createToggle(tabMove, "Bật Tốc Độ")

local jumpPowerSlider = createSlider(tabMove, "Jump Power", 50, 300, 100, function(val) customJumpPower = val end)
addSlider("customJumpPower", jumpPowerSlider)
local jumpPowerBtn = createToggle(tabMove, "Bật Jump Power")

local flySpeedSlider = createSlider(tabMove, "Fly Speed", 10, 200, 50, function(val) flySpeed = val end)
addSlider("flySpeed", flySpeedSlider)
local flyBtn = createToggle(tabMove, "Bay (Fly)")

-- ==========================================================
-- WAYPOINT SYSTEM
-- ==========================================================
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

local autoTpSlider = createSlider(tabWaypoint, "Auto TP (s)", 1, 30, 3, function(val) autoTpInterval = val end)
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
    if not hasWriteFile() then 
        saveFileBtn.Text = "❌ Không hỗ trợ"
        task.wait(1.5)
        saveFileBtn.Text = "💾 Lưu File"
        return 
    end
    local exportData = {}
    for _, wp in ipairs(waypointsList) do
        table.insert(exportData, {Name = wp.Name, Pos = {wp.CFrame.X, wp.CFrame.Y, wp.CFrame.Z}})
    end
    local success = saveFile(fileName, Services.Http:JSONEncode(exportData))
    saveFileBtn.Text = success and "✓ Lưu!" or "❌ Lỗi!"
    task.wait(1.5)
    saveFileBtn.Text = "💾 Lưu File"
end)

loadFileBtn.MouseButton1Click:Connect(function()
    if not hasReadFile() then
        loadFileBtn.Text = "❌ Không hỗ trợ"
        task.wait(1.5)
        loadFileBtn.Text = "📂 Tải File"
        return
    end
    local data = loadFile(fileName)
    if data then
        local success, decoded = pcall(function() return Services.Http:JSONDecode(data) end)
        if success and decoded then
            for _, item in ipairs(wpListContainer:GetChildren()) do if item:IsA("Frame") then item:Destroy() end end
            waypointsList = {}
            for _, wpData in ipairs(decoded) do
                local cf = CFrame.new(wpData.Pos[1], wpData.Pos[2], wpData.Pos[3])
                addWaypointUI(wpData.Name, cf)
            end
            loadFileBtn.Text = "✓ Tải!"
        else
            loadFileBtn.Text = "❌ Lỗi dữ liệu"
        end
    else
        loadFileBtn.Text = "❌ Không tìm thấy"
    end
    task.wait(1.5)
    loadFileBtn.Text = "📂 Tải File"
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

-- ==========================================================
-- VISUAL TAB
-- ==========================================================
local espBtn = createToggle(tabVisual, "ESP Người Chơi")
local fullbrightBtn = createToggle(tabVisual, "Fullbright")
local antiAfkBtn = createToggle(tabVisual, "Anti-AFK")
local invisibilityBtn = createToggle(tabVisual, "Tàng Hình (Invisible)")
local visibilityBtn = createToggle(tabVisual, "Hiện Hình (Visible)")

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
    Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

serverHopBtn.MouseButton1Click:Connect(function()
    if not hasHttpRequest() then
        serverHopBtn.Text = "❌ Không hỗ trợ"
        task.wait(1.5)
        serverHopBtn.Text = "🌐 Server Hop"
        return
    end
    serverHopBtn.Text = "Đang tìm..."
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    task.spawn(function()
        local success, result = pcall(function() 
            return Services.Http:JSONDecode(game:HttpGet(url)) 
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    Services.Teleport:TeleportToPlaceInstance(placeId, server.id, player)
                    return
                end
            end
        end
        serverHopBtn.Text = "Thử lại"
        task.wait(2)
        serverHopBtn.Text = "🌐 Server Hop"
    end)
end)

-- ==========================================================
-- ESP SYSTEM
-- ==========================================================
local espCache = {}

local function updateESP()
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p == player then continue end
        local char = p.Character
        if not char then 
            if espCache[p] then
                if espCache[p].hl then espCache[p].hl:Destroy() end
                if espCache[p].bb then espCache[p].bb:Destroy() end
                espCache[p] = nil
            end
            continue 
        end
        
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum then 
            if espCache[p] then
                if espCache[p].hl then espCache[p].hl:Destroy() end
                if espCache[p].bb then espCache[p].bb:Destroy() end
                espCache[p] = nil
            end
            continue 
        end

        if not espCache[p] then espCache[p] = {} end
        local data = espCache[p]

        if featureStates.espEnabled then
            if not data.hl then
                data.hl = Instance.new("Highlight")
                data.hl.Name = "DevESPHighlight"
                data.hl.Adornee = char
                data.hl.FillColor = Color3.fromRGB(0, 230, 255)
                data.hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                data.hl.Parent = char
            end
            data.hl.Enabled = true

            if not data.bb then
                data.bb = Instance.new("BillboardGui")
                data.bb.Name = "DevESPBillboard"
                data.bb.Size = UDim2.new(0, 220, 0, 70)
                data.bb.StudsOffset = Vector3.new(0, 2.8, 0)
                data.bb.AlwaysOnTop = true
                data.bb.Adornee = head

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "NameLabel"
                nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
                nameLabel.Position = UDim2.new(0, 0, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(0, 230, 150)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
                nameLabel.Parent = data.bb

                local healthBg = Instance.new("Frame")
                healthBg.Name = "HealthBg"
                healthBg.Size = UDim2.new(0.85, 0, 0.25, 0)
                healthBg.Position = UDim2.new(0.075, 0, 0.5, 0)
                healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                healthBg.BorderSizePixel = 0
                healthBg.Parent = data.bb
                Instance.new("UICorner", healthBg).CornerRadius = UDim.new(0, 4)

                local healthBar = Instance.new("Frame")
                healthBar.Name = "HealthBar"
                healthBar.Size = UDim2.new(1, 0, 1, 0)
                healthBar.BackgroundColor3 = Color3.fromRGB(0, 230, 0)
                healthBar.BorderSizePixel = 0
                healthBar.Parent = healthBg
                Instance.new("UICorner", healthBar).CornerRadius = UDim.new(0, 4)

                data.bb.Parent = char
            end

            local nameLabel = data.bb:FindFirstChild("NameLabel")
            local healthBg = data.bb:FindFirstChild("HealthBg")
            local healthBar = healthBg and healthBg:FindFirstChild("HealthBar")
            if nameLabel and healthBar and healthBg then
                local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local targetHrp = char:FindFirstChild("HumanoidRootPart")
                local dist = (myHrp and targetHrp) and math.floor((myHrp.Position - targetHrp.Position).Magnitude) or 0
                nameLabel.Text = p.DisplayName .. " [" .. tostring(dist) .. "m]"
                local hp = hum.Health / hum.MaxHealth
                healthBar.Size = UDim2.new(math.clamp(hp, 0, 1), 0, 1, 0)
                healthBar.BackgroundColor3 = hp > 0.5 and Color3.fromRGB(0, 230, 0) or hp > 0.25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 0, 0)
            end
        else
            if data.hl then data.hl.Enabled = false end
            if data.bb then data.bb:Destroy() data.bb = nil end
        end
    end
end

Services.Players.PlayerRemoving:Connect(function(p)
    if espCache[p] then
        if espCache[p].hl then espCache[p].hl:Destroy() end
        if espCache[p].bb then espCache[p].bb:Destroy() end
        espCache[p] = nil
    end
end)

-- ==========================================================
-- INVISIBILITY SYSTEM
-- ==========================================================
local function setInvisibility(state)
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if state then
                part.Transparency = 1
                part.CanCollide = false
            else
                part.Transparency = 0
                part.CanCollide = true
            end
        end
        if part:IsA("Accessory") or part:IsA("Hat") then
            if part.Handle then
                part.Handle.Transparency = state and 1 or 0
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.HealthDisplayDistance = state and 0 or 100
    end
end

-- ==========================================================
-- FPS BOOST TAB
-- ==========================================================
local boostFpsBtn = createActionButton(tabBooster, "🚀 Tối Ưu Đồ Họa (FPS)", Color3.fromRGB(0, 180, 120))
local removeTexturesBtn = createActionButton(tabBooster, "🗑️ Xóa Textures & Decals", Color3.fromRGB(200, 140, 0))
local removeEffectsBtn = createActionButton(tabBooster, "✨ Tắt Hiệu Ứng (Particle/Fire)", Color3.fromRGB(120, 60, 200))
local resetGraphicsBtn = createActionButton(tabBooster, "🔄 Khôi Phục Đồ Họa", Color3.fromRGB(200, 50, 60))

boostFpsBtn.MouseButton1Click:Connect(function()
    Services.Lighting.GlobalShadows = false
    Services.Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
        end
    end
    boostFpsBtn.Text = "✓ Đã Tối Ưu!"
    task.wait(1.5)
    boostFpsBtn.Text = "🚀 Tối Ưu Đồ Họa (FPS)"
end)

removeTexturesBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
    removeTexturesBtn.Text = "✓ Đã Xóa!"
    task.wait(1.5)
    removeTexturesBtn.Text = "🗑️ Xóa Textures & Decals"
end)

removeEffectsBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    removeEffectsBtn.Text = "✓ Đã Ẩn!"
    task.wait(1.5)
    removeEffectsBtn.Text = "✨ Tắt Hiệu Ứng (Particle/Fire)"
end)

resetGraphicsBtn.MouseButton1Click:Connect(function()
    Services.Lighting.GlobalShadows = originalLighting.GlobalShadows
    Services.Lighting.FogEnd = originalLighting.FogEnd
    settings().Rendering.QualityLevel = originalLighting.Quality
    resetGraphicsBtn.Text = "✓ Đã Khôi Phục!"
    task.wait(1.5)
    resetGraphicsBtn.Text = "🔄 Khôi Phục Đồ Họa"
end)

-- ==========================================================
-- KEYBINDS TAB
-- ==========================================================
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
    Services.UserInput.InputBegan:Connect(function(input, gpe)
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

-- ==========================================================
-- STATS UPDATE
-- ==========================================================
local startTime = os.time()
local frameCount = 0
local fpsTimer = 0

Services.RunService.RenderStepped:Connect(function(deltaTime)
    if _G.stopScript then return end
    frameCount = frameCount + 1
    fpsTimer = fpsTimer + deltaTime
    if fpsTimer >= 1 then
        local currentFps = math.floor(frameCount / fpsTimer)
        fpsLabel.Text = tostring(currentFps) .. " FPS"
        fpsLabel.TextColor3 = currentFps >= 50 and Color3.fromRGB(0, 230, 150) or currentFps >= 30 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 60, 60)
        frameCount = 0
        fpsTimer = 0
    end
end)

task.spawn(function()
    while screenGui.Parent do
        if _G.stopScript then return end
        local ping = 0
        local success, result = pcall(function()
            return math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if success and result then ping = result end
        pingLabel.Text = tostring(ping) .. " ms"
        playersLabel.Text = tostring(#Services.Players:GetPlayers()) .. "/" .. tostring(Services.Players.MaxPlayers)
        local elapsed = os.time() - startTime
        local hours = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        timeLabel.Text = string.format("%02d:%02d:%02d", hours, mins, secs)
        task.wait(CONFIG.STATS_UPDATE_INTERVAL)
    end
end)

-- ==========================================================
-- COMBAT LOGIC
-- ==========================================================
local fovCircle
if Drawing ~= nil then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.Color = Color3.fromRGB(0, 230, 255)
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Visible = false
end

local function isPartVisible(part)
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character, part.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    return Services.Workspace:Raycast(origin, direction, params) == nil
end

local function getClosestPlayer()
    local closestPart = nil
    local shortestDistance = fovRadius
    for _, targetPlayer in ipairs(Services.Players:GetPlayers()) do
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
            if featureStates.wallCheckEnabled and not isPartVisible(targetPart) then continue end
            shortestDistance = dist
            closestPart = targetPart
        end
    end
    return closestPart
end

-- ==========================================================
-- TOGGLE CONNECTIONS
-- ==========================================================
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
    toggleNoclip(featureStates.noclipEnabled)
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
        Services.Lighting.Brightness = originalLighting.Brightness
        Services.Lighting.ClockTime = originalLighting.ClockTime
    end
end)

antiAfkBtn.MouseButton1Click:Connect(function()
    featureStates.antiAfkEnabled = not featureStates.antiAfkEnabled
    updateToggle(antiAfkBtn, featureStates.antiAfkEnabled)
end)

espBtn.MouseButton1Click:Connect(function()
    featureStates.espEnabled = not featureStates.espEnabled
    updateToggle(espBtn, featureStates.espEnabled)
    updateESP()
end)

flyBtn.MouseButton1Click:Connect(function()
    featureStates.flyEnabled = not featureStates.flyEnabled
    updateToggle(flyBtn, featureStates.flyEnabled)
    toggleFly(featureStates.flyEnabled)
end)

invisibilityBtn.MouseButton1Click:Connect(function()
    featureStates.invisibilityEnabled = not featureStates.invisibilityEnabled
    updateToggle(invisibilityBtn, featureStates.invisibilityEnabled)
    setInvisibility(featureStates.invisibilityEnabled)
end)

visibilityBtn.MouseButton1Click:Connect(function()
    if featureStates.invisibilityEnabled then
        featureStates.invisibilityEnabled = false
        updateToggle(invisibilityBtn, false)
        setInvisibility(false)
        visibilityBtn.Text = "👁️ Đã Hiện"
        task.wait(1)
        visibilityBtn.Text = "👁️ Hiện Hình"
    end
end)

-- ==========================================================
-- FREECAM
-- ==========================================================
local freecamState = {
    enabled = false,
    cframe = CFrame.new(),
    yaw = 0,
    pitch = 0,
    connection = nil,
}

local function toggleFreecam()
    freecamState.enabled = not freecamState.enabled
    updateToggle(freecamBtn, freecamState.enabled)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if freecamState.enabled then
        camera.CameraType = Enum.CameraType.Scriptable
        freecamState.cframe = camera.CFrame
        local rx, ry, rz = freecamState.cframe:ToOrientation()
        freecamState.yaw = ry
        freecamState.pitch = rx
        if hrp then hrp.Anchored = true end
        if freecamState.connection then freecamState.connection:Disconnect() end
        freecamState.connection = Services.RunService.RenderStepped:Connect(function(dt)
            if _G.stopScript then toggleFreecam() return end
            if Services.UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local delta = Services.UserInput:GetMouseDelta()
                freecamState.yaw = freecamState.yaw - delta.X * 0.004
                freecamState.pitch = math.clamp(freecamState.pitch - delta.Y * 0.004, -math.rad(89), math.rad(89))
            end
            local rotCF = CFrame.Angles(0, freecamState.yaw, 0) * CFrame.Angles(freecamState.pitch, 0, 0)
            local moveVector = Vector3.zero
            if Services.UserInput:IsKeyDown(Enum.KeyCode.W) then moveVector += rotCF.LookVector end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.S) then moveVector -= rotCF.LookVector end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.A) then moveVector -= rotCF.RightVector end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.D) then moveVector += rotCF.RightVector end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.E) then moveVector += Vector3.new(0, 1, 0) end
            if Services.UserInput:IsKeyDown(Enum.KeyCode.Q) then moveVector -= Vector3.new(0, 1, 0) end
            local speed = 50 * freecamSpeedMultiplier * dt
            freecamState.cframe = CFrame.new(freecamState.cframe.Position + moveVector * speed) * rotCF
            camera.CFrame = freecamState.cframe
        end)
    else
        if freecamState.connection then
            freecamState.connection:Disconnect()
            freecamState.connection = nil
        end
        if hrp then hrp.Anchored = false end
        camera.CameraType = Enum.CameraType.Custom
        if hum then camera.CameraSubject = hum end
    end
end

freecamBtn.MouseButton1Click:Connect(toggleFreecam)

-- ==========================================================
-- SPECTATE
-- ==========================================================
local isSpectating = false
local spectateConnection = nil

local function stopSpectate()
    isSpectating = false
    if spectateConnection then
        spectateConnection:Disconnect()
        spectateConnection = nil
    end
    spectateBtn.Text = "Spectate"
    spectateBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    local myHum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if myHum then camera.CameraSubject = myHum end
end

spectateBtn.MouseButton1Click:Connect(function()
    if isSpectating then stopSpectate() return end
    local search = string.lower(tpBox.Text)
    if search == "" then return end
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= player and (string.lower(p.Name):find(search) or string.lower(p.DisplayName):find(search)) then
            local targetHum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if targetHum then
                camera.CameraSubject = targetHum
                isSpectating = true
                spectateBtn.Text = "Hủy xem"
                spectateBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
                spectateConnection = targetHum.Died:Connect(stopSpectate)
                break
            end
        end
    end
end)

-- ==========================================================
-- INPUT HANDLING
-- ==========================================================
Services.UserInput.InputBegan:Connect(function(input, gameProcessed)
    if _G.stopScript or gameProcessed then return end
    local key = input.KeyCode

    if key == Enum.KeyCode.K then
        mainFrame.Visible = not mainFrame.Visible
    elseif key == keybinds.Freecam then
        toggleFreecam()
    elseif key == keybinds.Fly then
        featureStates.flyEnabled = not featureStates.flyEnabled
        updateToggle(flyBtn, featureStates.flyEnabled)
        toggleFly(featureStates.flyEnabled)
    elseif key == keybinds.Noclip then
        featureStates.noclipEnabled = not featureStates.noclipEnabled
        updateToggle(noclipBtn, featureStates.noclipEnabled)
        toggleNoclip(featureStates.noclipEnabled)
    elseif key == keybinds.ClickTP then
        featureStates.clickTpEnabled = not featureStates.clickTpEnabled
        updateToggle(clickTpBtn, featureStates.clickTpEnabled)
    elseif key == keybinds.InfJump then
        featureStates.infJumpEnabled = not featureStates.infJumpEnabled
        updateToggle(infJumpBtn, featureStates.infJumpEnabled)
    elseif key == keybinds.ESP then
        featureStates.espEnabled = not featureStates.espEnabled
        updateToggle(espBtn, featureStates.espEnabled)
        updateESP()
    elseif key == keybinds.Aimbot then
        featureStates.aimbotEnabled = not featureStates.aimbotEnabled
        updateToggle(aimbotToggleBtn, featureStates.aimbotEnabled)
    end

    for i = 1, 9 do
        if key == Enum.KeyCode["Key" .. i] and #waypointsList >= i then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = waypointsList[i].CFrame end
            break
        end
    end
end)

-- Click TP
Services.UserInput.InputBegan:Connect(function(input, gameProcessed)
    if _G.stopScript or gameProcessed then return end
    if featureStates.clickTpEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Services.UserInput:IsKeyDown(Enum.KeyCode.LeftControl) or Services.UserInput:IsKeyDown(Enum.KeyCode.RightControl) then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and mouse.Hit then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Jump Request
Services.UserInput.JumpRequest:Connect(function()
    if _G.stopScript then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if featureStates.infJumpEnabled and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-AFK
player.Idled:Connect(function()
    if _G.stopScript then return end
    if featureStates.antiAfkEnabled then
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ==========================================================
-- MAIN RENDER LOOP
-- ==========================================================
local lastSafeCFrame = nil

Services.RunService.RenderStepped:Connect(function()
    if _G.stopScript then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- Fullbright
    if featureStates.fullbrightEnabled then
        Services.Lighting.Brightness = 2
        Services.Lighting.ClockTime = 14
    end

    -- Hitbox
    if featureStates.hitboxEnabled then
        for _, p in ipairs(Services.Players:GetPlayers()) do
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
    if featureStates.aimbotEnabled and Services.UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
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
            Services.VirtualUser:CaptureController()
            Services.VirtualUser:ClickButton1(Vector2.new())
            task.wait(0.05)
        end
    end
end)

-- ==========================================================
-- MAIN STEP LOOP
-- ==========================================================
Services.RunService.Stepped:Connect(function()
    if _G.stopScript then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hum then return end

    -- Godmode
    if featureStates.godmodeEnabled then
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if hrp and hrp.Position.Y > Services.Workspace.FallenPartsDestroyHeight + 20 then
            if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                lastSafeCFrame = hrp.CFrame
            end
        end
        if hrp and lastSafeCFrame and hrp.Position.Y <= Services.Workspace.FallenPartsDestroyHeight + 10 then
            hrp.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- Walk Speed
    if featureStates.walkSpeedEnabled then
        hum.WalkSpeed = customWalkSpeed
    end

    -- Jump Power
    if featureStates.jumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = customJumpPower
    end

    -- Auto Jump
    if featureStates.autoJumpEnabled and hum:GetState() == Enum.HumanoidStateType.Running then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Auto Sprint
    if featureStates.autoSprintEnabled then
        hum.AutoRotate = false
        hum.WalkSpeed = customWalkSpeed
    end

    -- No Recoil
    if featureStates.noRecoilEnabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
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
        if tool and Services.UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            task.spawn(function()
                while Services.UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and featureStates.rapidFireEnabled and not _G.stopScript do
                    Services.VirtualUser:CaptureController()
                    Services.VirtualUser:ClickButton1(Vector2.new())
                    task.wait(0.05)
                end
            end)
        end
    end
end)

-- ESP update loop
task.spawn(function()
    while screenGui.Parent do
        if _G.stopScript then return end
        if featureStates.espEnabled then updateESP() end
        task.wait(CONFIG.ESP_UPDATE_INTERVAL)
    end
end)

-- ==========================================================
-- MINIMIZE & CLOSE
-- ==========================================================
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
confirmYesBtn.MouseButton1Click:Connect(function() 
    _G.stopScript = true
    unloadAllFeatures() 
end)
confirmNoBtn.MouseButton1Click:Connect(function() confirmModal.Visible = false end)

logoBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ==========================================================
-- UNLOAD FUNCTION
-- ==========================================================
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
    featureStates.invisibilityEnabled = false

    -- Tắt Fly
    if flyEnabled then
        toggleFly(false)
    end
    
    -- Tắt Noclip
    if not Clip then
        toggleNoclip(false)
    end
    
    -- Reset invisibility
    setInvisibility(false)

    resetHitboxes()
    if fovCircle then fovCircle:Remove() end
    if freecamState.enabled then toggleFreecam() end
    stopSpectate()

    Services.Lighting.Brightness = originalLighting.Brightness
    Services.Lighting.ClockTime = originalLighting.ClockTime
    Services.Lighting.GlobalShadows = originalLighting.GlobalShadows
    Services.Lighting.FogEnd = originalLighting.FogEnd

    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.UseJumpPower = true
        hum.JumpPower = 50
    end

    for _, p in ipairs(Services.Players:GetPlayers()) do
        if espCache[p] then
            if espCache[p].hl then espCache[p].hl:Destroy() end
            if espCache[p].bb then espCache[p].bb:Destroy() end
            espCache[p] = nil
        end
    end

    screenGui:Destroy()
end

_G.DevMasterUnload = unloadAllFeatures

-- ==========================================================
-- INIT
-- ==========================================================
createKillSwitch()

print("✅ DEV MASTER ULTIMATE V1 LOADED! (ĐÃ BỎ FLING, SETTINGS, MISC)")
print("📌 Bấm K để mở menu")
print("📌 Logo bấm toggle menu")
print("📌 Phím F để bật/tắt bay (Fly)")
print("📌 Phím N để bật/tắt Noclip")

-- Keep script alive
while not _G.stopScript do
    task.wait(0.1)
end

if _G.DevMasterUnload then
    _G.DevMasterUnload()
end
print("Script đã kết thúc hoàn toàn")
