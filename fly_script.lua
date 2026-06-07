-- Flight Script with UI for Roblox
-- Press E to toggle flight mode

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local isFlying = false
local flySpeed = 50
local bodyVelocity
local bodyGyro

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.BorderSizePixel = 0
title.Text = "Flight Controls"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 40)
speedLabel.BackgroundTransparency = 1
speedLabel.BorderSizePixel = 0
speedLabel.Text = "Speed: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- Speed Slider
local slider = Instance.new("Frame")
slider.Name = "Slider"
slider.Size = UDim2.new(1, -20, 0, 20)
slider.Position = UDim2.new(0, 10, 0, 70)
slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
slider.BorderSizePixel = 0
slider.Parent = mainFrame

local sliderButton = Instance.new("Frame")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 10, 1, 0)
sliderButton.Position = UDim2.new(0, (flySpeed / 200) * (slider.AbsoluteSize.X - 10), 0, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = slider

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 95)
statusLabel.BackgroundTransparency = 1
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: OFF (Press E)"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Make slider draggable
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
        local mouse = player:GetMouse()
        local sliderX = slider.AbsolutePosition.X
        local sliderWidth = slider.AbsoluteSize.X
        local mouseX = mouse.X
        
        local relativeX = math.max(0, math.min(mouseX - sliderX, sliderWidth))
        local percentage = relativeX / sliderWidth
        
        flySpeed = math.floor(percentage * 200)
        flySpeed = math.max(1, math.min(200, flySpeed))
        
        sliderButton.Position = UDim2.new(0, (percentage * (sliderWidth - 10)), 0, 0)
        speedLabel.Text = "Speed: " .. flySpeed
    end
end)

-- Function to start flying
local function startFlying()
    if isFlying then return end
    isFlying = true
    
    -- Create BodyVelocity for movement
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = humanoidRootPart
    
    -- Create BodyGyro for rotation
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart
    
    statusLabel.Text = "Status: ON"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    -- Handle flight movement
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not isFlying or not humanoidRootPart.Parent then
            connection:Disconnect()
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Get input for movement
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + (camera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - (camera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - (camera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + (camera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Normalize and apply speed
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        bodyVelocity.Velocity = moveDirection * flySpeed
        
        -- Update rotation
        bodyGyro.CFrame = camera.CFrame
    end)
end

-- Function to stop flying
local function stopFlying()
    if not isFlying then return end
    isFlying = false
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    statusLabel.Text = "Status: OFF (Press E)"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Listen for E key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        if isFlying then
            stopFlying()
        else
            startFlying()
        end
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if isFlying then
        stopFlying()
    end
end)

print("Flight script with UI loaded!")
print("Press E to toggle flight")
print("Drag the slider to adjust speed (1-200)")
