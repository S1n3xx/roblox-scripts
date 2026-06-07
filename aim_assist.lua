-- Advanced Aim Assist Script for Roblox with Adjustable Aim Radius & Team Check
-- Press T to toggle aim assist
-- Press V to toggle team check
-- Press Y to toggle aim assist visuals
-- Scroll to adjust aim assist sensitivity
-- Hold U and scroll to adjust aim radius

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local aimAssistEnabled = false
local visualsEnabled = true
local teamCheckEnabled = true
local aimSensitivity = 0.5
local aimRadius = 100
local maxDistance = 500

local targetPlayer = nil
local targetPart = nil

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimAssistUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 390)
mainFrame.Position = UDim2.new(1, -320, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Title Text
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
title.Text = "🎯 AIM ASSIST v5"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- Team Check Status Label
local teamCheckLabel = Instance.new("TextLabel")
teamCheckLabel.Name = "TeamCheckLabel"
teamCheckLabel.Size = UDim2.new(1, -20, 0, 18)
teamCheckLabel.Position = UDim2.new(0, 10, 0, 32)
teamCheckLabel.BackgroundTransparency = 1
teamCheckLabel.BorderSizePixel = 0
teamCheckLabel.Text = "🛡️ Team Check: ON"
teamCheckLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
teamCheckLabel.TextSize = 11
teamCheckLabel.Font = Enum.Font.Gotham
teamCheckLabel.TextXAlignment = Enum.TextXAlignment.Left
teamCheckLabel.Parent = contentFrame

-- Target Info Label
local targetLabel = Instance.new("TextLabel")
targetLabel.Name = "TargetLabel"
targetLabel.Size = UDim2.new(1, -20, 0, 18)
targetLabel.Position = UDim2.new(0, 10, 0, 52)
targetLabel.BackgroundTransparency = 1
targetLabel.BorderSizePixel = 0
targetLabel.Text = "Target: None"
targetLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
targetLabel.TextSize = 11
targetLabel.Font = Enum.Font.Gotham
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = contentFrame

-- Sensitivity Label
local sensitivityLabel = Instance.new("TextLabel")
sensitivityLabel.Name = "SensitivityLabel"
sensitivityLabel.Size = UDim2.new(1, -20, 0, 18)
sensitivityLabel.Position = UDim2.new(0, 10, 0, 72)
sensitivityLabel.BackgroundTransparency = 1
sensitivityLabel.BorderSizePixel = 0
sensitivityLabel.Text = "Sensitivity: 50%"
sensitivityLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
sensitivityLabel.TextSize = 11
sensitivityLabel.Font = Enum.Font.Gotham
sensitivityLabel.TextXAlignment = Enum.TextXAlignment.Left
sensitivityLabel.Parent = contentFrame

-- Sensitivity Slider Background
local sliderBg = Instance.new("Frame")
sliderBg.Name = "SliderBg"
sliderBg.Size = UDim2.new(1, -20, 0, 8)
sliderBg.Position = UDim2.new(0, 10, 0, 93)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = contentFrame
local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(0, 4)
sliderBgCorner.Parent = sliderBg

-- Sensitivity Slider Fill
local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(aimSensitivity, 0, 1, 0)
sliderFill.Position = UDim2.new(0, 0, 0, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 4)
sliderFillCorner.Parent = sliderFill

-- Slider Button
local sliderButton = Instance.new("Frame")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 14, 0, 14)
sliderButton.Position = UDim2.new(aimSensitivity, -7, 0.5, -7)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = sliderBg
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 7)
buttonCorner.Parent = sliderButton

-- Aim Radius Label
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Name = "RadiusLabel"
radiusLabel.Size = UDim2.new(1, -20, 0, 18)
radiusLabel.Position = UDim2.new(0, 10, 0, 113)
radiusLabel.BackgroundTransparency = 1
radiusLabel.BorderSizePixel = 0
radiusLabel.Text = "Aim Radius: 100px (Hold U + Scroll)"
radiusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
radiusLabel.TextSize = 11
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = contentFrame

-- Radius Slider Background
local radiusSliderBg = Instance.new("Frame")
radiusSliderBg.Name = "RadiusSliderBg"
radiusSliderBg.Size = UDim2.new(1, -20, 0, 8)
radiusSliderBg.Position = UDim2.new(0, 10, 0, 134)
radiusSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
radiusSliderBg.BorderSizePixel = 0
radiusSliderBg.Parent = contentFrame
local radiusSliderBgCorner = Instance.new("UICorner")
radiusSliderBgCorner.CornerRadius = UDim.new(0, 4)
radiusSliderBgCorner.Parent = radiusSliderBg

-- Radius Slider Fill
local radiusSliderFill = Instance.new("Frame")
radiusSliderFill.Name = "RadiusSliderFill"
radiusSliderFill.Size = UDim2.new((aimRadius / 400), 0, 1, 0)
radiusSliderFill.Position = UDim2.new(0, 0, 0, 0)
radiusSliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
radiusSliderFill.BorderSizePixel = 0
radiusSliderFill.Parent = radiusSliderBg
local radiusSliderFillCorner = Instance.new("UICorner")
radiusSliderFillCorner.CornerRadius = UDim.new(0, 4)
radiusSliderFillCorner.Parent = radiusSliderFill

-- Distance Label
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Name = "DistanceLabel"
distanceLabel.Size = UDim2.new(1, -20, 0, 18)
distanceLabel.Position = UDim2.new(0, 10, 0, 154)
distanceLabel.BackgroundTransparency = 1
distanceLabel.BorderSizePixel = 0
distanceLabel.Text = "Max Distance: 500 studs"
distanceLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
distanceLabel.TextSize = 11
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = contentFrame

-- Button Container
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -20, 0, 130)
buttonContainer.Position = UDim2.new(0, 10, 0, 180)
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 0
buttonContainer.Parent = contentFrame

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 0, 35)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "🎯 TOGGLE AIM [T]"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 11
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = buttonContainer
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Team Check Button
local teamCheckButton = Instance.new("TextButton")
teamCheckButton.Name = "TeamCheckButton"
teamCheckButton.Size = UDim2.new(1, 0, 0, 35)
teamCheckButton.Position = UDim2.new(0, 0, 0, 40)
teamCheckButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
teamCheckButton.BorderSizePixel = 0
teamCheckButton.Text = "🛡️ TEAM CHECK [V]"
teamCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teamCheckButton.TextSize = 11
teamCheckButton.Font = Enum.Font.GothamBold
teamCheckButton.Parent = buttonContainer
local teamCheckCorner = Instance.new("UICorner")
teamCheckCorner.CornerRadius = UDim.new(0, 8)
teamCheckCorner.Parent = teamCheckButton

-- Visuals Button
local visualsButton = Instance.new("TextButton")
visualsButton.Name = "VisualsButton"
visualsButton.Size = UDim2.new(1, 0, 0, 35)
visualsButton.Position = UDim2.new(0, 0, 0, 80)
visualsButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
visualsButton.BorderSizePixel = 0
visualsButton.Text = "👁️ TOGGLE VISUALS [Y]"
visualsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
visualsButton.TextSize = 11
visualsButton.Font = Enum.Font.GothamBold
visualsButton.Parent = buttonContainer
local visualsCorner = Instance.new("UICorner")
visualsCorner.CornerRadius = UDim.new(0, 8)
visualsCorner.Parent = visualsButton

-- Slider dragging
local dragging = false

sliderButton.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local sliderX = sliderBg.AbsolutePosition.X
        local sliderWidth = sliderBg.AbsoluteSize.X
        local mouseX = mouse.X
        
        local relativeX = math.max(0, math.min(mouseX - sliderX, sliderWidth))
        local percentage = relativeX / sliderWidth
        
        aimSensitivity = math.max(0.1, math.min(1, percentage))
        
        sliderFill.Size = UDim2.new(aimSensitivity, 0, 1, 0)
        sliderButton.Position = UDim2.new(aimSensitivity, -7, 0.5, -7)
        sensitivityLabel.Text = "Sensitivity: " .. math.floor(aimSensitivity * 100) .. "%"
    end
end)

-- Function to check if player is on same team
local function isOnSameTeam(otherPlayer)
    if not teamCheckEnabled then
        return false
    end
    
    if player.Team and otherPlayer.Team then
        return player.Team == otherPlayer.Team
    end
    
    return false
end

-- Function to find closest enemy within aim radius
local function findClosestEnemy()
    local closestPlayer = nil
    local closestDistance = maxDistance
    local screenSize = camera.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            if isOnSameTeam(otherPlayer) then
                continue
            end
            
            local character = otherPlayer.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                local distance = (humanoidRootPart.Position - camera.CFrame.Position).Magnitude
                
                if distance < closestDistance then
                    local screenPos = camera:WorldToScreenPoint(humanoidRootPart.Position)
                    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    if screenDistance <= aimRadius then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Function to get best target part
local function getBestTargetPart(character)
    local head = character:FindFirstChild("Head")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if head then
        return head
    elseif humanoidRootPart then
        return humanoidRootPart
    end
    
    return nil
end

-- Visual elements - Aim radius circle (HIGH ZINDEX)
local aimRadiusCircle = Instance.new("Frame")
aimRadiusCircle.Name = "AimRadiusCircle"
aimRadiusCircle.BackgroundTransparency = 0.7
aimRadiusCircle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
aimRadiusCircle.BorderSizePixel = 2
aimRadiusCircle.BorderColor3 = Color3.fromRGB(0, 200, 255)
aimRadiusCircle.Parent = screenGui
aimRadiusCircle.Visible = false
aimRadiusCircle.ZIndex = 100

local aimRadiusCorner = Instance.new("UICorner")
aimRadiusCorner.CornerRadius = UDim.new(1, 0)
aimRadiusCorner.Parent = aimRadiusCircle

-- Target circle
local targetCircle = Instance.new("Frame")
targetCircle.Name = "TargetCircle"
targetCircle.Size = UDim2.new(0, 40, 0, 40)
targetCircle.BackgroundTransparency = 1
targetCircle.BorderSizePixel = 3
targetCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
targetCircle.Parent = screenGui
targetCircle.Visible = false
targetCircle.ZIndex = 101

local targetCornerRadius = Instance.new("UICorner")
targetCornerRadius.CornerRadius = UDim.new(1, 0)
targetCornerRadius.Parent = targetCircle

-- Crosshair lines
local crosshairTop = Instance.new("Frame")
crosshairTop.Name = "CrosshairTop"
crosshairTop.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
crosshairTop.BorderSizePixel = 0
crosshairTop.Parent = screenGui
crosshairTop.Visible = false
crosshairTop.ZIndex = 101

local crosshairBottom = Instance.new("Frame")
crosshairBottom.Name = "CrosshairBottom"
crosshairBottom.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
crosshairBottom.BorderSizePixel = 0
crosshairBottom.Parent = screenGui
crosshairBottom.Visible = false
crosshairBottom.ZIndex = 101

local crosshairLeft = Instance.new("Frame")
crosshairLeft.Name = "CrosshairLeft"
crosshairLeft.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
crosshairLeft.BorderSizePixel = 0
crosshairLeft.Parent = screenGui
crosshairLeft.Visible = false
crosshairLeft.ZIndex = 101

local crosshairRight = Instance.new("Frame")
crosshairRight.Name = "CrosshairRight"
crosshairRight.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
crosshairRight.BorderSizePixel = 0
crosshairRight.Parent = screenGui
crosshairRight.Visible = false
crosshairRight.ZIndex = 101

-- Main aim assist loop
RunService.RenderStepped:Connect(function()
    if not aimAssistEnabled then
        return
    end
    
    local screenSize = camera.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    
    -- Update aim radius circle
    if visualsEnabled then
        aimRadiusCircle.Visible = true
        aimRadiusCircle.Size = UDim2.new(0, aimRadius * 2, 0, aimRadius * 2)
        aimRadiusCircle.Position = UDim2.new(0, screenCenter.X - aimRadius, 0, screenCenter.Y - aimRadius)
    else
        aimRadiusCircle.Visible = false
    end
    
    targetPlayer = findClosestEnemy()
    
    if targetPlayer and targetPlayer.Character then
        targetPart = getBestTargetPart(targetPlayer.Character)
        
        if targetPart then
            local targetPosition = targetPart.Position
            local screenPosition = camera:WorldToScreenPoint(targetPosition)
            
            if visualsEnabled then
                targetCircle.Visible = true
                targetCircle.Position = UDim2.new(0, screenPosition.X - 20, 0, screenPosition.Y - 20)
                
                local lineLength = 30
                
                crosshairTop.Visible = true
                crosshairTop.Size = UDim2.new(0, 2, 0, lineLength)
                crosshairTop.Position = UDim2.new(0, screenPosition.X - 1, 0, screenPosition.Y - lineLength)
                
                crosshairBottom.Visible = true
                crosshairBottom.Size = UDim2.new(0, 2, 0, lineLength)
                crosshairBottom.Position = UDim2.new(0, screenPosition.X - 1, 0, screenPosition.Y + 20)
                
                crosshairLeft.Visible = true
                crosshairLeft.Size = UDim2.new(0, lineLength, 0, 2)
                crosshairLeft.Position = UDim2.new(0, screenPosition.X - lineLength, 0, screenPosition.Y - 1)
                
                crosshairRight.Visible = true
                crosshairRight.Size = UDim2.new(0, lineLength, 0, 2)
                crosshairRight.Position = UDim2.new(0, screenPosition.X + 20, 0, screenPosition.Y - 1)
            end
            
            -- APPLY AIM ASSIST - DIRECTLY MOVE CAMERA
            local targetCFrame = CFrame.new(camera.CFrame.Position, targetPosition)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, aimSensitivity * 0.2)
            
            targetLabel.Text = "🎯 Target: " .. targetPlayer.Name
            targetLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
        else
            targetLabel.Text = "⭕ Target: In Radius"
            targetLabel.TextColor3 = Color3.fromRGB(200, 200, 0)
            if visualsEnabled then
                targetCircle.Visible = false
                crosshairTop.Visible = false
                crosshairBottom.Visible = false
                crosshairLeft.Visible = false
                crosshairRight.Visible = false
            end
        end
    else
        targetLabel.Text = "❌ Target: None"
        targetLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        if visualsEnabled then
            targetCircle.Visible = false
            crosshairTop.Visible = false
            crosshairBottom.Visible = false
            crosshairLeft.Visible = false
            crosshairRight.Visible = false
        end
    end
end)

-- Toggle aim assist
local function toggleAimAssist()
    aimAssistEnabled = not aimAssistEnabled
    if aimAssistEnabled then
        statusLabel.Text = "Status: ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("✅ Aim Assist ENABLED")
    else
        statusLabel.Text = "Status: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        targetCircle.Visible = false
        crosshairTop.Visible = false
        crosshairBottom.Visible = false
        crosshairLeft.Visible = false
        crosshairRight.Visible = false
        aimRadiusCircle.Visible = false
        print("❌ Aim Assist DISABLED")
    end
end

-- Toggle team check
local function toggleTeamCheck()
    teamCheckEnabled = not teamCheckEnabled
    if teamCheckEnabled then
        teamCheckLabel.Text = "🛡️ Team Check: ON"
        teamCheckLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
        teamCheckButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("✅ Team Check ENABLED")
    else
        teamCheckLabel.Text = "🛡️ Team Check: OFF"
        teamCheckLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        teamCheckButton.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        print("❌ Team Check DISABLED - Will aim at EVERYONE")
    end
end

-- Toggle visuals
local function toggleVisuals()
    visualsEnabled = not visualsEnabled
    if visualsEnabled then
        visualsButton.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        print("✅ Visuals ENABLED")
    else
        visualsButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        targetCircle.Visible = false
        crosshairTop.Visible = false
        crosshairBottom.Visible = false
        crosshairLeft.Visible = false
        crosshairRight.Visible = false
        aimRadiusCircle.Visible = false
        print("❌ Visuals DISABLED")
    end
end

-- Button handlers
toggleButton.MouseButton1Click:Connect(toggleAimAssist)
teamCheckButton.MouseButton1Click:Connect(toggleTeamCheck)
visualsButton.MouseButton1Click:Connect(toggleVisuals)

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        toggleAimAssist()
    elseif input.KeyCode == Enum.KeyCode.V then
        toggleTeamCheck()
    elseif input.KeyCode == Enum.KeyCode.Y then
        toggleVisuals()
    end
end)

-- Mouse wheel for sensitivity and radius adjustment
mouse.WheelMoved:Connect(function(direction)
    if UserInputService:IsKeyDown(Enum.KeyCode.U) then
        if direction > 0 then
            aimRadius = math.min(400, aimRadius + 10)
        else
            aimRadius = math.max(20, aimRadius - 10)
        end
        
        radiusSliderFill.Size = UDim2.new((aimRadius / 400), 0, 1, 0)
        radiusLabel.Text = "Aim Radius: " .. aimRadius .. "px (Hold U + Scroll)"
    else
        if direction > 0 then
            aimSensitivity = math.min(1, aimSensitivity + 0.05)
        else
            aimSensitivity = math.max(0.1, aimSensitivity - 0.05)
        end
        
        sliderFill.Size = UDim2.new(aimSensitivity, 0, 1, 0)
        sliderButton.Position = UDim2.new(aimSensitivity, -7, 0.5, -7)
        sensitivityLabel.Text = "Sensitivity: " .. math.floor(aimSensitivity * 100) .. "%"
    end
end)

print("🎯 Advanced Aim Assist Script v5 LOADED!")
print("Press T to toggle aim assist")
print("Press V to toggle team check")
print("Press Y to toggle visuals")
print("Scroll to change sensitivity")
print("Hold U + Scroll to change aim radius")
