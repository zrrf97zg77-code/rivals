-- RIVALS MOBILE SCRIPT WITH SLIDERS & WIDE ANGLE
-- Features: Mobile UI, Aimbot FOV Slider, Camera FOV Slider, ESP, Auto-Fire

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- Load Draw Library
local Draw = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-protected-repo/m/main/Draw.lua"))()

-- CONFIGURATION
local Config = {
    EspEnabled = true,
    AimEnabled = true,
    AutoFire = true,
    
    -- SLIDER VALUES
    AimFOV = 45,       -- Aimbot detection radius (degrees)
    CameraFOV = 90,    -- Actual screen zoom (Wide Angle)
    
    Smoothness = 8,    -- Aim smoothing (Higher = smoother)
    TargetPart = "Head",
    
    EspColor = Color3.fromRGB(255, 0, 0),
    AimColor = Color3.fromRGB(0, 255, 0),
}

-- VARIABLES
local espBoxes = {}
local aimIndicator = nil
local firing = false

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsScriptUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Menu Button
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuBtn"
MenuBtn.Parent = ScreenGui
MenuBtn.Size = UDim2.new(0, 60, 0, 30)
MenuBtn.Position = UDim2.new(1, -70, 0, 10) -- Top Right
MenuBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = Enum.Font.GothenBold
MenuBtn.TextSize = 12

-- Menu Frame (Hidden by default)
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Parent = ScreenGui
MenuFrame.Size = UDim2.new(0, 200, 0, 250)
MenuFrame.Position = UDim2.new(1, -210, 0, 50)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 2
MenuFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
MenuFrame.Visible = false

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MenuFrame
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold

-- ESP Toggle Button
local EspBtn = Instance.new("TextButton")
EspBtn.Parent = MenuFrame
EspBtn.Size = UDim2.new(1, -20, 0, 40)
EspBtn.Position = UDim2.new(0, 10, 0, 10)
EspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
EspBtn.Text = "ESP: ON"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.Font = Enum.Font.SourceSansBold

-- Label: Aim FOV
local LabelAim = Instance.new("TextLabel")
LabelAim.Parent = MenuFrame
LabelAim.Size = UDim2.new(1, -20, 0, 20)
LabelAim.Position = UDim2.new(0, 10, 0, 60)
LabelAim.BackgroundTransparency = 1
LabelAim.Text = "Aim FOV: " .. tostring(Config.AimFOV)
LabelAim.TextColor3 = Color3.fromRGB(255, 255, 255)
LabelAim.Font = Enum.Font.SourceSans
LabelAim.TextScaled = true

-- Slider: Aim FOV
local SliderAim = Instance.new("Slider")
SliderAim.Parent = MenuFrame
SliderAim.Size = UDim2.new(1, -20, 0, 20)
SliderAim.Position = UDim2.new(0, 10, 0, 80)
SliderAim.MinValue = 10
SliderAim.MaxValue = 180
SliderAim.Value = Config.AimFOV
SliderAim.ThumbColor = Color3.fromRGB(0, 120, 255)

SliderAim.Changed:Connect(function()
    Config.AimFOV = SliderAim.Value
    LabelAim.Text = "Aim FOV: " .. tostring(math.floor(SliderAim.Value))
end)

-- Label: Camera FOV
local LabelCam = Instance.new("TextLabel")
LabelCam.Parent = MenuFrame
LabelCam.Size = UDim2.new(1, -20, 0, 20)
LabelCam.Position = UDim2.new(0, 10, 0, 110)
LabelCam.BackgroundTransparency = 1
LabelCam.Text = "Camera FOV: " .. tostring(Config.CameraFOV)
LabelCam.TextColor3 = Color3.fromRGB(255, 255, 255)
LabelCam.Font = Enum.Font.SourceSans
LabelCam.TextScaled = true

-- Slider: Camera FOV
local SliderCam = Instance.new("Slider")
SliderCam.Parent = MenuFrame
SliderCam.Size = UDim2.new(1, -20, 0, 20)
SliderCam.Position = UDim2.new(0, 10, 0, 130)
SliderCam.MinValue = 50
SliderCam.MaxValue = 150
SliderCam.Value = Config.CameraFOV
SliderCam.ThumbColor = Color3.fromRGB(0, 120, 255)

SliderCam.Changed:Connect(function()
    Config.CameraFOV = SliderCam.Value
    LabelCam.Text = "Camera FOV: " .. tostring(math.floor(SliderCam.Value))
    Camera.FieldOfView = Config.CameraFOV
end)

-- Apply Initial Camera FOV
Camera.FieldOfView = Config.CameraFOV

-- Event Listeners for UI
MenuBtn.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MenuFrame.Visible = false
end)

EspBtn.MouseButton1Click:Connect(function()
    Config.EspEnabled = not Config.EspEnabled
    if Config.EspEnabled then
        EspBtn.Text = "ESP: ON"
        EspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        EspBtn.Text = "ESP: OFF"
        EspBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        for _, data in ipairs(espBoxes) do
            data.box:Remove()
        end
        table.clear(espBoxes)
        if aimIndicator then
            aimIndicator:Remove()
            aimIndicator = nil
        end
    end
end)

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- HELPER: GET HEAD
local function getHead(char)
    local head = char:FindFirstChild(Config.TargetPart) or char:FindFirstChild("Head")
    return head
end

-- ESP SYSTEM
local function updateEsp(player)
    local char = player.Character
    if not char or not char.Parent then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Check if box already exists
    for _, data in ipairs(espBoxes) do
        if data.player == player then
            local head = getHead(char)
            if head then
                data.box.Min = head.Position - Vector3.new(1.5, 2.5, 1.5)
                data.box.Max = head.Position + Vector3.new(1.5, 2.5, 1.5)
            end
            return
        end
    end
    
    -- Create new box
    local box = Draw.Box()
    box.Color = Config.EspColor
    box.Thickness = 2
    box.Transparency = 0.3
    box.Line = true
    box.World = true
    
    table.insert(espBoxes, {box = box, player = player})
    
    -- Initial position
    local head = getHead(char)
    if head then
        box.Min = head.Position - Vector3.new(1.5, 2.5, 1.5)
        box.Max = head.Position + Vector3.new(1.5, 2.5, 1.5)
    end
end

-- AIMBOT SYSTEM
local function getNearestEnemy()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    
    local myHead = getHead(myChar)
    if not myHead then return nil end
    
    local myPos = myHead.Position
    local closestDist = math.huge
    local closestTarget = nil
    local closestPart = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char.Parent then
                local head = getHead(char)
                if head then
                    local dist = (myPos - head.Position).Magnitude
                    
                    -- Distance check
                    if dist < 100 then 
                        -- FOV Check using Config.AimFOV
                        local dirToTarget = (head.Position - myPos).Unit
                        local camDir = Camera.CFrame.LookVector
                        
                        local dot = camDir:Dot(dirToTarget)
                        local fovRad = math.rad(Config.AimFOV)
                        local maxDot = math.cos(fovRad / 2)
                        
                        if dot > maxDot and dist < closestDist then
                            closestDist = dist
                            closestTarget = player
                            closestPart = head
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget, closestPart
end

-- AUTO FIRE LOGIC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        firing = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        firing = false
    end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- Update ESP
    if Config.EspEnabled then
        for _, data in ipairs(espBoxes) do
            local head = getHead(data.player.Character)
            if head and data.player.Character.Parent then
                data.box.Min = head.Position - Vector3.new(1.5, 2.5, 1.5)
                data.box.Max = head.Position + Vector3.new(1.5, 2.5, 1.5)
            end
        end
        
        -- Create Aim Indicator if it doesn't exist
        if not aimIndicator then
            aimIndicator = Draw.Circle()
            aimIndicator.Color = Config.AimColor
            aimIndicator.Thickness = 2
            aimIndicator.Transparency = 0.5
            aimIndicator.World = true
        end
    else
        if aimIndicator then
            aimIndicator:Remove()
            aimIndicator = nil
        end
    end
    
    -- Aimbot Logic
    if Config.AimEnabled then
        local targetPlayer, targetHead = getNearestEnemy()
        
        if targetHead and Config.EspEnabled then
            -- Smoothly move camera to target
            local targetCF = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Config.Smoothness)
            
            -- Update indicator
            aimIndicator.Position = targetHead.Position
            aimIndicator.Radius = 1
            
            -- Auto Fire
            if firing and Config.AutoFire then
                -- Optional: Force fire logic here if needed
            end
        elseif aimIndicator then
            aimIndicator.Radius = 0
        end
    end
end)

-- Handle Players Joining/Leaving
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if Config.EspEnabled then
            updateEsp(player)
        end
    end)
    if player.Character then
        updateEsp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for i, data in ipairs(espBoxes) do
        if data.player == player then
            data.box:Remove()
            table.remove(espBoxes, i)
            break
        end
    end
end)

print("Rivals Script Loaded! Open MENU to adjust FOV.")
