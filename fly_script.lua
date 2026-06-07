-- Flight Script with UI, No Clip, Block Collector, and Cool Features for Roblox
-- Press E to toggle flight mode
-- Press X to toggle no clip mode
-- Press C to bring all unanchored blocks to you
-- Press F to toggle fly speed boost
-- Press R to reset position to spawn

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local spawnPosition = humanoidRootPart.Position

local isFlying = false
local isNoclip = false
local isBoostActive = false
local flySpeed = 50
local bodyVelocity
local bodyGyro
local noclipConnection
local collectedParts = {}
local particles = {}

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame with gradient background
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 500)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Add shadow effect
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 8, 1, 8)
shadow.Position = UDim2.new(0, -4, 0, -4)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BorderSizePixel = 0
shadow.ZIndex = -1
shadow.Parent = mainFrame
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 12)
shadowCorner.Parent = shadow

-- Title Bar with gradient
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
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
title.Text = "✈️ FLIGHT HUB v2"
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

-- Speed Label with icon
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 15)
speedLabel.BackgroundTransparency = 1
speedLabel.BorderSizePixel = 0
speedLabel.Text = "⚡ Flight Speed"
speedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = contentFrame

-- Speed Value Label
local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Name = "SpeedValueLabel"
speedValueLabel.Size = UDim2.new(0, 100, 0, 25)
speedValueLabel.Position = UDim2.new(1, -110, 0, 15)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.BorderSizePixel = 0
speedValueLabel.Text = flySpeed .. " km/h"
speedValueLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
speedValueLabel.TextSize = 13
speedValueLabel.Font = Enum.Font.GothamBold
speedValueLabel.TextXAlignment = Enum.TextXAlignment.Right
speedValueLabel.Parent = contentFrame

-- Speed Slider Background
local sliderBg = Instance.new("Frame")
sliderBg.Name = "SliderBg"
sliderBg.Size = UDim2.new(1, -20, 0, 8)
sliderBg.Position = UDim2.new(0, 10, 0, 45)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = contentFrame
local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(0, 4)
sliderBgCorner.Parent = sliderBg

-- Speed Slider Fill
local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new((flySpeed / 200), 0, 1, 0)
sliderFill.Position = UDim2.new(0, 0, 0, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 4)
sliderFillCorner.Parent = sliderFill

-- Slider Button
local sliderButton = Instance.new("Frame")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 16, 0, 16)
sliderButton.Position = UDim2.new((flySpeed / 200), -8, 0.5, -8)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = sliderBg
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = sliderButton

-- Status Container
local statusContainer = Instance.new("Frame")
statusContainer.Name = "StatusContainer"
statusContainer.Size = UDim2.new(1, -20, 0, 100)
statusContainer.Position = UDim2.new(0, 10, 0, 70)
statusContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
statusContainer.BorderSizePixel = 0
statusContainer.Parent = contentFrame
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusContainer

-- Flight Status
local flightStatusLabel = Instance.new("TextLabel")
flightStatusLabel.Name = "FlightStatusLabel"
flightStatusLabel.Size = UDim2.new(1, -20, 0, 20)
flightStatusLabel.Position = UDim2.new(0, 10, 0, 5)
flightStatusLabel.BackgroundTransparency = 1
flightStatusLabel.BorderSizePixel = 0
flightStatusLabel.Text = "🚁 Flight: OFF"
flightStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
flightStatusLabel.TextSize = 11
flightStatusLabel.Font = Enum.Font.Gotham
flightStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
flightStatusLabel.Parent = statusContainer

-- No Clip Status
local noclipStatusLabel = Instance.new("TextLabel")
noclipStatusLabel.Name = "NoclipStatusLabel"
noclipStatusLabel.Size = UDim2.new(1, -20, 0, 20)
noclipStatusLabel.Position = UDim2.new(0, 10, 0, 25)
noclipStatusLabel.BackgroundTransparency = 1
noclipStatusLabel.BorderSizePixel = 0
noclipStatusLabel.Text = "👻 No Clip: OFF"
noclipStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
noclipStatusLabel.TextSize = 11
noclipStatusLabel.Font = Enum.Font.Gotham
noclipStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
noclipStatusLabel.Parent = statusContainer

-- Boost Status
local boostStatusLabel = Instance.new("TextLabel")
boostStatusLabel.Name = "BoostStatusLabel"
boostStatusLabel.Size = UDim2.new(1, -20, 0, 20)
boostStatusLabel.Position = UDim2.new(0, 10, 0, 45)
boostStatusLabel.BackgroundTransparency = 1
boostStatusLabel.BorderSizePixel = 0
boostStatusLabel.Text = "🔥 Boost: OFF"
boostStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
boostStatusLabel.TextSize = 11
boostStatusLabel.Font = Enum.Font.Gotham
boostStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
boostStatusLabel.Parent = statusContainer

-- Block Count
local blockCountLabel = Instance.new("TextLabel")
blockCountLabel.Name = "BlockCountLabel"
blockCountLabel.Size = UDim2.new(1, -20, 0, 20)
blockCountLabel.Position = UDim2.new(0, 10, 0, 65)
blockCountLabel.BackgroundTransparency = 1
blockCountLabel.BorderSizePixel = 0
blockCountLabel.Text = "📦 Blocks: 0"
blockCountLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
blockCountLabel.TextSize = 11
blockCountLabel.Font = Enum.Font.Gotham
blockCountLabel.TextXAlignment = Enum.TextXAlignment.Left
blockCountLabel.Parent = statusContainer

-- Button Container
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -20, 0, 150)
buttonContainer.Position = UDim2.new(0, 10, 0, 185)
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 0
buttonContainer.Parent = contentFrame

-- Flight Button
local flightButton = Instance.new("TextButton")
flightButton.Name = "FlightButton"
flightButton.Size = UDim2.new(0.5, -5, 0, 40)
flightButton.Position = UDim2.new(0, 0, 0, 0)
flightButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
flightButton.BorderSizePixel = 0
flightButton.Text = "🚁 FLIGHT [E]"
flightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flightButton.TextSize = 11
flightButton.Font = Enum.Font.GothamBold
flightButton.Parent = buttonContainer
local flightButtonCorner = Instance.new("UICorner")
flightButtonCorner.CornerRadius = UDim.new(0, 8)
flightButtonCorner.Parent = flightButton

-- No Clip Button
local noclipButton = Instance.new("TextButton")
noclipButton.Name = "NoclipButton"
noclipButton.Size = UDim2.new(0.5, -5, 0, 40)
noclipButton.Position = UDim2.new(0.5, 5, 0, 0)
noclipButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
noclipButton.BorderSizePixel = 0
noclipButton.Text = "👻 NO CLIP [X]"
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.TextSize = 11
noclipButton.Font = Enum.Font.GothamBold
noclipButton.Parent = buttonContainer
local noclipButtonCorner = Instance.new("UICorner")
noclipButtonCorner.CornerRadius = UDim.new(0, 8)
noclipButtonCorner.Parent = noclipButton

-- Collect Blocks Button
local collectButton = Instance.new("TextButton")
collectButton.Name = "CollectButton"
collectButton.Size = UDim2.new(1, 0, 0, 40)
collectButton.Position = UDim2.new(0, 0, 0, 45)
collectButton.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
collectButton.BorderSizePixel = 0
collectButton.Text = "📦 COLLECT BLOCKS [C]"
collectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collectButton.TextSize = 11
collectButton.Font = Enum.Font.GothamBold
collectButton.Parent = buttonContainer
local collectButtonCorner = Instance.new("UICorner")
collectButtonCorner.CornerRadius = UDim.new(0, 8)
collectButtonCorner.Parent = collectButton

-- Boost Button
local boostButton = Instance.new("TextButton")
boostButton.Name = "BoostButton"
boostButton.Size = UDim2.new(0.5, -5, 0, 40)
boostButton.Position = UDim2.new(0, 0, 0, 90)
boostButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
boostButton.BorderSizePixel = 0
boostButton.Text = "🔥 BOOST [F]"
boostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boostButton.TextSize = 11
boostButton.Font = Enum.Font.GothamBold
boostButton.Parent = buttonContainer
local boostButtonCorner = Instance.new("UICorner")
boostButtonCorner.CornerRadius = UDim.new(0, 8)
boostButtonCorner.Parent = boostButton

-- Reset Position Button
local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.Size = UDim2.new(0.5, -5, 0, 40)
resetButton.Position = UDim2.new(0.5, 5, 0, 90)
resetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
resetButton.BorderSizePixel = 0
resetButton.Text = "🏠 RESET [R]"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 11
resetButton.Font = Enum.Font.GothamBold
resetButton.Parent = buttonContainer
local resetButtonCorner = Instance.new("UICorner")
resetButtonCorner.CornerRadius = UDim.new(0, 8)
resetButtonCorner.Parent = resetButton

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
        local sliderX = sliderBg.AbsolutePosition.X
        local sliderWidth = sliderBg.AbsoluteSize.X
        local mouseX = mouse.X
        
        local relativeX = math.max(0, math.min(mouseX - sliderX, sliderWidth))
        local percentage = relativeX / sliderWidth
        
        flySpeed = math.floor(percentage * 200)
        flySpeed = math.max(1, math.min(200, flySpeed))
        
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
        speedValueLabel.Text = flySpeed .. " km/h"
    end
end)

-- Function to create speed trail particles
local function createSpeedTrail()
    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(0.3, 0.3, 0.3)
    part.BrickColor = BrickColor.new("Cyan")
    part.CanCollide = false
    part.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 5
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = workspace
    
    table.insert(particles, part)
    game:GetService("Debris"):AddItem(part, 0.5)
end

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
    
    flightStatusLabel.Text = "🚁 Flight: ON"
    flightStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    flightButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    
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
        
        local currentSpeed = flySpeed
        if isBoostActive then
            currentSpeed = flySpeed * 2
            if math.random() > 0.7 then
                createSpeedTrail()
            end
        end
        
        bodyVelocity.Velocity = moveDirection * currentSpeed
        
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
    
    flightStatusLabel.Text = "🚁 Flight: OFF"
    flightStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    flightButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
end

-- Function to start no clip
local function startNoclip()
    if isNoclip then return end
    isNoclip = true
    
    noclipStatusLabel.Text = "👻 No Clip: ON"
    noclipStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    noclipButton.BackgroundColor3 = Color3.fromRGB(200, 150, 100)
    
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
    
    noclipStatusLabel.Text = "👻 No Clip: OFF"
    noclipStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    noclipButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
end

-- Function to toggle boost
local function toggleBoost()
    isBoostActive = not isBoostActive
    if isBoostActive then
        boostStatusLabel.Text = "🔥 Boost: ON"
        boostStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        boostButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    else
        boostStatusLabel.Text = "🔥 Boost: OFF"
        boostStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        boostButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    end
end

-- Function to reset position to spawn
local function resetPosition()
    humanoidRootPart.CFrame = CFrame.new(spawnPosition)
    print("Position reset to spawn!")
end

-- Function to collect all unanchored blocks
local function collectBlocks()
    local blocksCollected = 0
    collectedParts = {}
    
    -- Find all unanchored parts in workspace
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and part.Parent ~= character and not part.Parent:FindFirstChild("Humanoid") then
            table.insert(collectedParts, part)
        end
    end
    
    blocksCollected = #collectedParts
    blockCountLabel.Text = "📦 Blocks: " .. blocksCollected
    
    -- Move blocks to player continuously
    local moveConnection
    moveConnection = RunService.RenderStepped:Connect(function()
        local partsToKeep = {}
        
        for _, part in pairs(collectedParts) do
            if part and part.Parent then
                local direction = (humanoidRootPart.Position - part.Position)
                if direction.Magnitude > 5 then
                    part.Velocity = direction.Unit * 50
                    table.insert(partsToKeep, part)
                end
            end
        end
        
        collectedParts = partsToKeep
        
        if #collectedParts == 0 then
            moveConnection:Disconnect()
            blockCountLabel.Text = "📦 Blocks: 0"
        end
    end)
    
    print("Collecting " .. blocksCollected .. " blocks!")
end

-- Button click handlers
flightButton.MouseButton1Click:Connect(function()
    if isFlying then
        stopFlying()
    else
        startFlying()
    end
end)

noclipButton.MouseButton1Click:Connect(function()
    if isNoclip then
        stopNoclip()
    else
        startNoclip()
    end
end)

collectButton.MouseButton1Click:Connect(function()
    collectBlocks()
end)

boostButton.MouseButton1Click:Connect(function()
    toggleBoost()
end)

resetButton.MouseButton1Click:Connect(function()
    resetPosition()
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
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleBoost()
    end
    
    if input.KeyCode == Enum.KeyCode.R then
        resetPosition()
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    spawnPosition = humanoidRootPart.Position
    if isFlying then
        stopFlying()
    end
    if isNoclip then
        stopNoclip()
    end
end)

print("Flight script v2 with cool features loaded!")
print("Press E to toggle flight")
print("Press X to toggle no clip")
print("Press C to collect all unanchored blocks")
print("Press F to toggle speed boost (2x speed + particles)")
print("Press R to reset your position to spawn")
