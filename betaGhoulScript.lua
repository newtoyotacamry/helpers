local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DiscordInviteGui"
screenGui.Parent = playerGui

-- Adjusted frame size to be 50% bigger
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 750, 0, 375)  -- 50% bigger frame size
frame.Position = UDim2.new(0.5, -375, 0.5, -187)  -- Centered position with adjusted offset
frame.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Branding label at the top, adjusting for bigger frame
local brandingLabel = Instance.new("TextLabel")
brandingLabel.Size = UDim2.new(1, 0, 0.2, 0)  -- Adjusted size for new frame
brandingLabel.BackgroundTransparency = 1
brandingLabel.Text = "Error: Premium Required"
brandingLabel.Font = Enum.Font.GothamBold
brandingLabel.TextScaled = true
brandingLabel.TextColor3 = Color3.new(1, 1, 1)
brandingLabel.Parent = frame

-- Info label below the branding label
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0.35, 0)  -- Adjusted size for new frame
infoLabel.Position = UDim2.new(0, 10, 0.2, 0)  -- Adjusted position
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Our Ghoul://RE script is no longer available for free, please go to our discord for a seven day free trial to keep using the script."
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextScaled = true
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.Parent = frame

-- Link label below the info label
local linkLabel = Instance.new("TextLabel")
linkLabel.Size = UDim2.new(1, -20, 0.1, 0)  -- Adjusted size for new frame
linkLabel.Position = UDim2.new(0, 10, 0.58, 0)  -- Adjusted position
linkLabel.BackgroundTransparency = 1
linkLabel.Text = "discord.gg/noxhub"
linkLabel.Font = Enum.Font.Gotham
linkLabel.TextScaled = true
linkLabel.TextColor3 = Color3.new(1, 1, 1)
linkLabel.Parent = frame

-- Copy invite button
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.45, -5, 0.2, 0)
copyButton.Position = UDim2.new(0.05, 0, 0.75, 0)
copyButton.Text = "Copy Invite"
copyButton.Font = Enum.Font.GothamBold
copyButton.TextScaled = true
copyButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.Parent = frame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.45, -5, 0.2, 0)
closeButton.Position = UDim2.new(0.5, 5, 0.75, 0)
closeButton.Text = "Close"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.BackgroundColor3 = Color3.fromRGB(232, 72, 85)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Parent = frame

-- Copy invite functionality
copyButton.MouseButton1Click:Connect(function()
    setclipboard("discord.gg/noxhub")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Link Copied!",
        Text = "Discord invite link copied to clipboard!",
        Duration = 3,
    })
end)

-- Close the GUI
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Tween for smooth animation
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tween = TweenService:Create(frame, tweenInfo, {Position = UDim2.new(0.5, -375, 0.45, -187)})  -- Adjusted position for tween
tween:Play()
