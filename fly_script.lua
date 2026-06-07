-- Flight Script with UI, No Clip, and Block Collector for Roblox
-- Press E to toggle flight mode
-- Press X to toggle no clip mode
-- Press C to bring all unanchored blocks to you

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local isFlying = false
local isNoclip = false
local flySpeed = 50
local bodyVelocity
local bodyGyro
local noclipConnection

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 250)
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

-- Flight Status Label
local flightStatusLabel = Instance.new("TextLabel")
flightStatusLabel.Name = "FlightStatusLabel"
flightStatusLabel.Size = UDim2.new(1, -20, 0, 20)
flightStatusLabel.Position = UDim2.new(0, 10, 0, 100)
flightStatusLabel.BackgroundTransparency = 1
flightStatusLabel.BorderSizePixel = 0
flightStatusLabel.Text = "Flight: OFF (Press E)"
flightStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
flightStatusLabel.TextSize = 12
flightStatusLabel.Font = Enum.Font.Gotham
flightStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
flightStatusLabel.Parent = mainFrame

-- No Clip Status Label
local noclipStatusLabel = Instance.new("TextLabel")
noclipStatusLabel.Name = "NoclipStatusLabel"
noclipStatusLabel.Size = UDim2.new(1, -20, 0, 20)
noclipStatusLabel.Position = UDim2.new(0, 10, 0, 125)
noclipStatusLabel.BackgroundTransparency = 1
noclipStatusLabel.BorderSizePixel = 0
noclipStatusLabel.Text = "No Clip: OFF (Press X)"
noclipStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
noclipStatusLabel.TextSize = 12
noclipStatusLabel.Font = Enum.Font.Gotham
noclipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
noclipStatusLabel.Parent = mainFrame

-- Block Collector Button
local collectButton = Instance.new("TextButton")
collectButton.Name = "CollectButton"
collectButton.Size = UDim2.new(1, -20, 0, 30)
collectButton.Position = UDim2.new(0, 10, 0, 155)
collectButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
collectButton.BorderSizePixel = 0
collectButton.Text = "Collect Blocks (Press C)"
collectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collectButton.TextSize = 12
collectButton.Font = Enum.Font.Gotham
collectButton.Parent = mainFrame

-- Block Count Label
local blockCountLabel = Instance.new("TextLabel")
blockCountLabel.Name = "BlockCountLabel"
blockCountLabel.Size = UDim2.new(1, -20, 0, 20)
blockCountLabel.Position = UDim2.new(0, 10, 0, 195)
blockCountLabel.BackgroundTransparency = 1
blockCountLabel.BorderSizePixel = 0
blockCountLabel.Text = "Blocks: 0"
blockCountLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
blockCountLabel.TextSize = 11
blockCountLabel.Font = Enum.Font.Gotham
blockCountLabel.TextXAlignment = Enum.TextXAlignment.Left
blockCountLabel.Parent = mainFrame

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
    
    flightStatusLabel.Text = "Flight: ON"
    flightStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
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
    
    flightStatusLabel.Text = "Flight: OFF (Press E)"
    flightStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Function to start no clip
local function startNoclip()
    if isNoclip then return end
    isNoclip = true
    
    noclipStatusLabel.Text = "No Clip: ON"
    noclipStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    noclipConnection = RunService.RenderStepped:Connect(function()
        if not isNoclip or not character.Parent then
            noclipConnection:Disconnect()
            return
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- Function to stop no clip
local function stopNoclip()
    if not isNoclip then return end
    isNoclip = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    
    noclipStatusLabel.Text = "No Clip: OFF (Press X)"
    noclipStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Function to collect all unanchored blocks
local function collectBlocks()
    local blocksCollected = 0
    
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and part.Parent ~= character then
            -- Create attachment points if they don't exist
            if not part:FindFirstChild("BodyVelocity") then
                local bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVel.P = 10000
                bodyVel.Parent = part
                
                -- Move the part to the player
                local direction = (humanoidRootPart.Position - part.Position).Unit
                bodyVel.Velocity = direction * 100
                
                -- Remove the velocity after a short time to let it settle
                game:GetService("Debris"):AddItem(bodyVel, 1)
                
                blocksCollected = blocksCollected + 1
            end
        end
    end
    
    blockCountLabel.Text = "Blocks: " .. blocksCollected
    print("Collected " .. blocksCollected .. " blocks!")
end

-- Button click handler
collectButton.MouseButton1Click:Connect(function()
    collectBlocks()
end)

-- Listen for key presses
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        if isFlying then
            stopFlying()
        else
            startFlying()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.X then
        if isNoclip then
            stopNoclip()
        else
            startNoclip()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.C then
        collectBlocks()
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if isFlying then
        stopFlying()
    end
    if isNoclip then
        stopNoclip()
    end
end)

print("Flight script with UI, No Clip, and Block Collector loaded!")
print("Press E to toggle flight")
print("Press X to toggle no clip")
print("Press C to collect all unanchored blocks")
print("Drag the slider to adjust flight speed (1-200)")
