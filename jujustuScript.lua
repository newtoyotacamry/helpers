local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()
local HttpService = game:GetService("HttpService")
local configFile = "JujutsuConfig.json"
local http = game:GetService("HttpService")
local userId = game.Players.LocalPlayer.UserId

local config = {
    instaKillEnabled = false,
    range = 0,
    tweenToMobEnabled = false,
    tweenSpeed = 0,
    tweenRange = 0,
    tweenPosition = "On Top",
    positionOffset = 1,
    autopromoteEnabled = false,
    autoCollectEnabled = false,
    cooldownToggle = false,
    lastFired = 0,
    collectdelayTime = 0,
    flipDelayTime = 0,
    autoBossEnabled = false,
    autoreplayEnabled = false,
    autocollectToolsEnabled = false,
    autofreezeEnabled = false,
    autofreezeRange = 0,
    itemESPEnabled = false
}

-- Load configuration function
local function loadConfig()
    if isfile(configFile) then
        local data = readfile(configFile)
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        if success then
            for k, v in pairs(result) do
                config[k] = v  -- Update config fields directly
            end
        end
    end
end

local function saveConfig()
    local data = game:GetService("HttpService"):JSONEncode(config)  -- Encode the config directly
    writefile(configFile, data)
end

-- Save configuration function
local function saveConfig()
    local data = game:GetService("HttpService"):JSONEncode(config)  -- Encode the config directly
    writefile(configFile, data)
end

-- Auto-load configuration on script start
loadConfig()



local Window = Luna:CreateWindow({
    Name = "NoxHub",
    Subtitle = "Jujutsu Infinite",
    LoadingEnabled = true,
    LoadingTitle = "Jujutsu Infinite",
    LoadingSubtitle = "NoxHub - Premium Roblox Scripts",

    ConfigSettings = {
		RootFolder = "NoxHub" , 
		ConfigFolder = "JujutsuInf" 
    },
})

Window:CreateHomeTab({
	SupportedExecutors = {}, -- A Table Of Executors Your Script Supports. Add strings of the executor names for each executor.
	DiscordInvite = "uxK9gDWJWf",
	Icon = 1, 
})

local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "settings_input_antenna",
    ImageSource = "Material",
    ShowTitle = true
})

local Button = Tab:CreateButton({
	Name = "Data Rollback",
	Description = "CLick this after you've finished spinning and then rejoin",
    	Callback = function()
           

        local ohString1 = "\255"

        game:GetService("ReplicatedStorage").Remotes.Server.Data.ChangeSetting:InvokeServer(ohString1)
    	end
})

Tab:CreateSection("Instakill")

local instaKillEnabled = false
local range = 0
local tweenToMobEnabled = false
local tweenSpeed = 0
local tweenRange = 0

Tab:CreateToggle({
    Name = "Enable InstaKill",
    CurrentValue = config.instaKillEnabled,
    Callback = function(State)
        instaKillEnabled = State
        config.instaKillEnabled = State
        saveConfig()
    end
})

Tab:CreateSlider({
    Name = "Kill Range",
    Range = {10, 1000},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        range = Value
        config.range = Value
        saveConfig()
    end
})

-- Movement Tab Fixes
Tab:CreateSection("Movement")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")  -- Added UserInputService
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local toggles = {
    EnableSpeedHack = false,
    EnableFlight = false,
    EnableInfiniteJump = false,  -- Added infinite jump toggle
}

local options = {
    Speed = 100,
    FlightSpeed = 150,
}

local infiniteJumpConnection = nil

-- == SPEEDHACK FUNCTION == --
local function handleSpeedHack()
    local function initSpeedHack()
        local character = localPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("SpeedHackVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "SpeedHackVelocity"
                    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = hrp
                end
                return bv
            end
        end
        return nil
    end

    local bv = initSpeedHack()
    while not bv and toggles.EnableSpeedHack do
        task.wait(0.1)
        bv = initSpeedHack()
    end

    while toggles.EnableSpeedHack and localPlayer and localPlayer.Character do
        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            camera = workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end

            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * options.Speed
            else
                moveDirection = Vector3.new(0, 0, 0)
            end

            if bv then
                bv.Velocity = Vector3.new(moveDirection.X, 0, moveDirection.Z)
            end
        end
        task.wait()
    end

    if localPlayer and localPlayer.Character then
        local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local oldBV = hrp:FindFirstChild("SpeedHackVelocity")
            if oldBV then
                oldBV:Destroy()
            end
        end
    end
end

-- == FLIGHT FUNCTION == --
local function handleFlight()
    while toggles.EnableFlight do
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            camera = workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + camera.CFrame.UpVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection - camera.CFrame.UpVector
            end

            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * options.FlightSpeed
            else
                moveDirection = Vector3.new(0, 0, 0)
            end
            hrp.Velocity = moveDirection
        end
        task.wait()
    end
end

-- == INFINITE JUMP FUNCTION == --
local function enableInfiniteJump()
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end

    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if toggles.EnableInfiniteJump and localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function disableInfiniteJump()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end

-- Event: Restart speed hack on character respawn
local function onCharacterAdded(character)
    character:WaitForChild("Humanoid")
    task.wait(0.5)
    if toggles.EnableSpeedHack then
        task.spawn(handleSpeedHack)
    end
end
localPlayer.CharacterAdded:Connect(onCharacterAdded)

--[[ Movement Tab UI Elements ]]--

-- WalkSpeed Toggle
Tab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(active)
        toggles.EnableSpeedHack = active
        if active then
            task.spawn(handleSpeedHack)
        else
            if localPlayer and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16  -- Reset to default
                end
            end
        end
    end,
})

-- Walk Speed Slider (fixed duplicate CurrentValue, using 100 as the default)
Tab:CreateSlider({
    Name = "Walk Speed",
    Range = {10, 500},
    Increment = 1,
    CurrentValue = 100,
    Tooltip = "Adjust the walk speed",
    Callback = function(value)
        options.Speed = value
    end,
})

-- Flight Toggle
Tab:CreateToggle({
    Name = "Flight",
    CurrentValue = false,
    Callback = function(active)
        toggles.EnableFlight = active
        if active then
            task.spawn(handleFlight)
        else
            if localPlayer and localPlayer.Character then
                local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end,
})

-- Flight Speed Slider
Tab:CreateSlider({
    Name = "Flight Speed",
    Range = {10, 1000},
    Increment = 1,
    CurrentValue = 150,
    Callback = function(value)
        options.FlightSpeed = value
    end,
})

-- Infinite Jump Toggle
Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(active)
        toggles.EnableInfiniteJump = active
        if active then
            enableInfiniteJump()
        else
            disableInfiniteJump()
        end
    end,
})

Tab:CreateSection("Tweening")

Tab:CreateToggle({
    Name = "Tween to Near Mobs",
    CurrentValue = config.tweenToMobEnabled,
    Callback = function(State)
        tweenToMobEnabled = State
        config.tweenToMobEnabled = State
        saveConfig()
    end
})

Tab:CreateSlider({
    Name = "Tweening Range",
    Range = {5, 5000},
    Increment = 5,
    CurrentValue = config.tweenRange,
    Callback = function(Value)
        tweenRange = Value
        config.tweenRange = Value
        saveConfig()
    end
})

Tab:CreateSlider({
    Name = "Tween Speed",
    Range = {0.5, 5000},
    Increment = 1,
    CurrentValue = config.tweenSpeed,
    Callback = function(Value)
        tweenSpeed = Value
        config.tweenSpeed = Value
        saveConfig()
    end
})

local tweenPosition = "On Top" 
Tab:CreateDropdown({
    Name = "Tween Position",
    Options = {"On Top", "Under", "Behind"},
    CurrentOption = tweenPosition,
    Callback = function(Selected)
        tweenPosition = Selected
    end
})

local positionOffset = 1
Tab:CreateSlider({
    Name = "Position Offset",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = positionOffset,
    Callback = function(Value)
        positionOffset = Value
    end
})

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local Mag = function(Pos1, Pos2)
    return (Pos1.Position - Pos2.Position).Magnitude
end

local Tween = function(Object1, Object2, Speed, Offset, Wait)
    if Object1 and Object2 then
        local Timing = Mag(Object1, Object2) / Speed
        local TweenInfo = TweenInfo.new(Timing, Enum.EasingStyle.Linear)
        local TweenSystem = TweenService:Create(Object1, TweenInfo, {CFrame = CFrame.new(Object2.Position + Offset)})
        TweenSystem:Play()
        if Wait then
            TweenSystem.Completed:Wait()
        end
    end
end

local function performInstaKill()
    if not instaKillEnabled then return end

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local origin = character.PrimaryPart.Position

    for _, mob in pairs(workspace.Objects.Mobs:GetChildren()) do
        if mob:IsA("Model") and mob.PrimaryPart then
            local distance = (mob.PrimaryPart.Position - origin).Magnitude
            if distance <= range then
                local humanoid = mob:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end
        end
    end
end

local function NoClip()
    for _, v in next, Player.Character:GetChildren() do
        if v:IsA("BasePart") and v.CanCollide then
            v.CanCollide = false
        end
    end
end

local function performTweenToMobs()
    if not tweenToMobEnabled then return end

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    NoClip() 

    for _, mob in pairs(workspace.Objects.Mobs:GetChildren()) do
        if mob:IsA("Model") and mob.PrimaryPart then
            local distance = (mob.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
            if distance <= tweenRange then
                local offset = Vector3.new(0, 0, 0)

                if tweenPosition == "On Top" then
                    offset = Vector3.new(0, positionOffset, 0)
                elseif tweenPosition == "Under" then
                    offset = Vector3.new(0, -positionOffset, 0)
                elseif tweenPosition == "Behind" then
                    offset = Vector3.new(0, 0, -positionOffset)
                end

                Tween(character.PrimaryPart, mob.PrimaryPart, tweenSpeed, offset, true)
            end
        end
    end
end


game:GetService("RunService").Stepped:Connect(function()
    if instaKillEnabled then
        performInstaKill() 
    end
    if tweenToMobEnabled then
        performTweenToMobs()
    end
end)

Tab:CreateSection("Auto Boss")
local autoreplayEnabled = false
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lootUI = game:GetService("Players").LocalPlayer.PlayerGui.Loot
local flipButton = game:GetService("Players").LocalPlayer.PlayerGui.Loot.Frame.Flip
local replayButton = game:GetService("Players").LocalPlayer.PlayerGui.ReadyScreen.Frame.Replay
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer
local flipDelayTime = 0.4

-- Auto Replay Function with a 35-second delay
local function autoReplay()
    while autoreplayEnabled do
        -- Check if replayButton is visible and enabled
        if replayButton.Visible then
            task.wait(45)  -- Wait for an additional 4 seconds before triggering the replay

            -- Trigger the replay if the replay button is visible
            GuiService.SelectedObject = replayButton
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.BackSlash, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)
        end
        task.wait(1)  -- Check every second
    end
end

-- Toggle for Auto Replay
Tab:CreateToggle({
    Name = "Auto Replay",
    CurrentValue = config.autoreplayEnabled,  -- Default off state
    Callback = function(State)
        autoreplayEnabled = State  -- Toggle variable to track the state
        config.autoreplayEnabled = State
        saveConfig()

        -- Start or stop the autoReplay function based on the toggle state
        if State then
            -- Enable auto replay
            task.spawn(autoReplay)  -- Run autoReplay in a separate thread
        else
            -- Disable auto replay
            autoreplayEnabled = false
        end
    end
})



Tab:CreateToggle({
    Name = "Auto Boss",
    CurrentValue = config.autoBossEnabled,  -- Default off state
    Callback = function(State)
        autoBossEnabled = State  -- Toggle variable to track the state
        config.autoBossEnabled = State
        saveConfig()

        -- Start countdown if Auto Boss is enabled
        if State then
            for i = 30, 1, -1 do
                task.delay(30 - i, function()
                    Luna:Notification({
                        Title = "Auto Boss",
                        Icon = "notifications_active",
                        ImageSource = "Material",
                        Content = "Time remaining: " .. i .. " seconds",
                        Time = 1  -- Display each notification for 1 second
                    })
                end)
            end

            -- Final notification when the countdown ends
            task.delay(30, function()
                Luna:Notification({
                    Title = "Countdown Complete!",
                    Icon = "check_circle",
                    ImageSource = "Material",
                    Content = "The countdown is complete!",
                    Time = 5
                })
            end)
        end
    end
})


-- Tween to Boss function
local function tweenToBoss()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local bossSpawn = workspace.Objects.Spawns.BossSpawn

    if character and character.PrimaryPart and bossSpawn then
        local offset = Vector3.new(0, 20, 0)  -- Optional offset if needed
        local speed = 1000  -- Speed for tweening
        Tween(character.PrimaryPart, bossSpawn, speed, offset, true)
    end
end

-- Insta-Kill and Tween to Mobs function
local function performInstaKillAndTween()
    if not autoBossEnabled then return end

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local origin = character.PrimaryPart.Position

    -- Tween to the boss spawn point if not already there
    if (workspace.Objects.Spawns.BossSpawn.Position - origin).Magnitude > 50 then
        tweenToBoss()  -- This will move the player to the BossSpawn
    end

    -- Insta-Kill and Tween to nearby mobs
    for _, mob in pairs(workspace.Objects.Mobs:GetChildren()) do
        if mob:IsA("Model") and mob.PrimaryPart then
            local distance = (mob.PrimaryPart.Position - origin).Magnitude
            if distance <= 1000 then  -- Range of 1000 units
                -- Insta-Kill logic
                local humanoid = mob:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end

                -- Tween to the mob with "On Top" offset
                local offset = Vector3.new(0, 10, 0)  -- Offset on top of the mob
                Tween(character.PrimaryPart, mob.PrimaryPart, 500, offset, true)
            end
        end
    end
end

-- Run the Insta-Kill and Tween logic when the Auto Boss toggle is enabled
game:GetService("RunService").Stepped:Connect(function()
    if autoBossEnabled then
        wait(30)
        performInstaKillAndTween()  -- Perform the action when the toggle is enabled
    end
end)

local Quests = Window:CreateTab({
	Name = "Auto Daily Quest (Turn On Insta Kill)",
	Icon = "looks",
	ImageSource = "Material",
	ShowTitle = true -- This will determine whether the big header text in the tab will show
})

local snow = Quests:CreateButton({
	Name = "Mr Snow",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Mr. Snow"
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    warn("NPC not found or has no PrimaryPart!")
    return
end

local noclipActive = false

-- Function to toggle noclip
local function toggleNoclip(state)
    noclipActive = state
    if noclipActive then
        RunService.Stepped:Connect(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt, duration)
    if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
        prompt:InputHoldBegin()
        wait(duration)
        prompt:InputHoldEnd()
    end
end

local function tweenToPosition(position, callback, shouldFloat)
    local distance = (humanoidRootPart.Position - position).Magnitude
    local speed = 3000
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local floatHeight = shouldFloat and 3 or 0 -- Float height if shouldFloat is true
    local adjustedPosition = position + Vector3.new(0, floatHeight, 0)
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(adjustedPosition) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    toggleNoclip(true) -- Enable noclip before tweening
    tween:Play()
    tween.Completed:Connect(function()
        toggleNoclip(false) -- Disable noclip after tweening

        if callback then
            callback()
        end
    end)
end

local function findAndTweenToSnowPiles()
    local map = workspace:FindFirstChild("Map")
    if not map then
        warn("Map not found!")
        return
    end

    local questObject = map:FindFirstChild("QuestObject")
    if not questObject then
        warn("QuestObject not found under Map!")
        return
    end

    local snowPiles = questObject:FindFirstChild("SnowPiles")
    if not snowPiles then
        warn("SnowPiles folder not found under QuestObject!")
        return
    end

    local usedFolder = snowPiles:FindFirstChild("Used")
    if not usedFolder then
        warn("Used folder not found under SnowPiles!")
        return
    end

    local foundSnowPiles = false
    for _, child in ipairs(usedFolder:GetChildren()) do
        if child.Name == "SnowPile" and child:IsA("BasePart") then
            foundSnowPiles = true
            tweenToPosition(child.Position, function()
                local prompt = child:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    pressProximityPrompt(prompt, 4.5) -- Updated to 4.5 seconds
                end
            end, true) -- Enable floating while tweening to snowpile
            wait(4.5) -- Updated to match interaction time
        end
    end

    if not foundSnowPiles then
        print("No SnowPiles found under Used.")
    else
        print("All SnowPiles have been successfully located and interacted with.")
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    tweenToPosition(targetPosition, function()
        local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            pressProximityPrompt(prompt, 0.5)
            simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(1)
            findAndTweenToSnowPiles()
        end
    end)
end

wait(1)
tweenToNPC()
    	end
})

local cabbage = Quests:CreateButton({
	Name = "Cabbage Merchant",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Cabbage Merchant"
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    return
end

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt)
    while prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled do
        fireproximityprompt(prompt)
        wait(0.1)
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local speed = 3000
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(targetPosition) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    tween:Play()

    tween.Completed:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            pressProximityPrompt(prompt)
            simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
            wait(0.1)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.1)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.1)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.1)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.1)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)

            local firstTargetPosition = Vector3.new(2731.888916015625, 663.6421508789062, 287.21820068359375)
            while (humanoidRootPart.Position - firstTargetPosition).Magnitude > 1 do
                humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(
                    CFrame.new(firstTargetPosition, humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector),
                    0.1
                )
                wait(0.1)
            end

            wait(0.1)
            simulateKeyPress(Enum.KeyCode.E, 4)

            local secondTargetPosition = Vector3.new(3444.66015625, 636.7777099609375, 183.07412719726562)
            while (humanoidRootPart.Position - secondTargetPosition).Magnitude > 1 do
                humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(
                    CFrame.new(secondTargetPosition, humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector),
                    0.1
                )
                wait(0.1)
            end
        end
    end)
end

wait(0.1)
tweenToNPC()
    	end
})

local guts = Quests:CreateButton({
	Name = "Curse Slayer",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Curse Slayer"
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    return
end

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt)
    while prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled do
        fireproximityprompt(prompt)
        wait(0.2)
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local speed = 3000
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(targetPosition) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    tween:Play()

    tween.Completed:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            pressProximityPrompt(prompt)
            simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
        end
    end)
end

wait(1)
tweenToNPC()
    	end
})

local lazy = Quests:CreateButton({
	Name = "Lazy Sorcerer",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Lazy Sorcerer"
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    return
end

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt)
    while prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled do
        fireproximityprompt(prompt)
        wait(0.2)
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local speed = 3000
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(targetPosition) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    tween:Play()

    tween.Completed:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            pressProximityPrompt(prompt)
            simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
        end
    end)
end

wait(1)
tweenToNPC()
end
})

local fort = Quests:CreateButton({
	Name = "Fort Alchemist",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Fort Alchemist"
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    warn("NPC not found or has no PrimaryPart!")
    return
end

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt, duration)
    if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
        prompt:InputHoldBegin()
        wait(duration)
        prompt:InputHoldEnd()
    end
end

local function tweenToPosition(position, callback)
    local distance = (humanoidRootPart.Position - position).Magnitude
    local speed = 3000
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(position) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    tween:Play()
    tween.Completed:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        if callback then
            callback()
        end
    end)
end

local function collectFrostPetal()
    local map = workspace:FindFirstChild("Map")
    if not map then
        warn("Map not found!")
        return
    end

    local forageSpots = map:FindFirstChild("ForageSpots")
    if not forageSpots then
        warn("ForageSpots not found under Map!")
        return
    end

    local frostPetals = {}
    for _, spot in ipairs(forageSpots:GetChildren()) do
        for _, frostPetalModel in ipairs(spot:GetChildren()) do
            if frostPetalModel.Name == "Frost Petal" and frostPetalModel:IsA("Model") then
                for _, part in ipairs(frostPetalModel:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(frostPetals, part)
                    end
                end
            end
        end
    end

    if #frostPetals == 0 then
        warn("No Frost Petal found!")
    else
        print("Frost Petals found:", #frostPetals)
    end

    return frostPetals
end

local function tweenToFrostPetal()
    local frostPetals = collectFrostPetal()
    if not frostPetals or #frostPetals == 0 then
        return
    end

    local collected = 0
    for _, petal in ipairs(frostPetals) do
        if collected >= 9 then
            break
        end

        tweenToPosition(petal.Position, function()
            local prompt = petal:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                pressProximityPrompt(prompt, 1)
                collected = collected + 1
                print("Collected Frost Petal:", collected)
            end
        end)

        wait(2) -- Wait before moving to the next petal
    end

    if collected < 9 then
        print("Only", collected, "Frost Petals were collected.")
    else
        print("Successfully collected 9 Frost Petals.")
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    tweenToPosition(targetPosition, function()
        local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            pressProximityPrompt(prompt, 0.5)
            simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.S, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(0.5)
            simulateKeyPress(Enum.KeyCode.Return, 0.1)
            wait(1)
            tweenToFrostPetal()
            wait(1)
            simulateKeyPress(Enum.KeyCode.BackSlash, 0.1) -- Final action
            print("Final BackSlash action triggered!")
        end
    end)
end

wait(1)
tweenToNPC()
    	end
})

local digger = Quests:CreateButton({
	Name = "Grave Digger",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Grave Digger"
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    return
end

local savedCoordinates = Vector3.new(7282.884765625, 990.78515625, -1070.3953857421875)

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt)
    while prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled do
        fireproximityprompt(prompt)
        wait(0.2)
    end
end

local function tweenToPosition(targetPosition, callback)
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local speed = 3000
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(targetPosition) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    tween:Play()

    tween.Completed:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        if callback then
            callback()
        end
    end)
end

local function interactWithNPC()
    local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        pressProximityPrompt(prompt)
        simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.S, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.S, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)

        -- Tween to saved coordinates after interacting
        tweenToPosition(savedCoordinates)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    tweenToPosition(targetPosition, interactWithNPC)
end

wait(1)
tweenToNPC()
end
})

local temple = Quests:CreateButton({
	Name = "Temple Master",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Temple Master" -- Changed NPC Name
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    return
end

-- Coordinates provided
local targetCoordinates = Vector3.new(6328.4580078125, 982.6458740234375, -409.1114196777344)

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt)
    while prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled do
        fireproximityprompt(prompt)
        wait(0.2)
    end
end

local function tweenToPosition(targetPosition, callback)
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local speed = 3000
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(targetPosition) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    tween:Play()

    tween.Completed:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        if callback then
            callback()
        end
    end)
end

local function interactWithNPC()
    local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        pressProximityPrompt(prompt)
        simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.S, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.S, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)

        -- Tween to provided coordinates
        tweenToPosition(targetCoordinates, function()
            -- Simulate holding 'E' for 4 seconds
            wait(2)
            simulateKeyPress(Enum.KeyCode.E, 4)
            
            -- Simulate pressing backslash
            simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
        end)
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    tweenToPosition(targetPosition, interactWithNPC)
end

wait(1)
tweenToNPC()
    	end
})

local camp = Quests:CreateButton({
	Name = "Camp Sorcerer",
	Description = nil, -- Creates A Description For Users to know what the button does (looks bad if you use it all the time),
    	Callback = function()
         local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local npcName = "Camp Sorcerer" -- Updated NPC name
local objectsFolder = workspace:FindFirstChild("Objects")
local npcFolder = objectsFolder and objectsFolder:FindFirstChild("NPCs")
local npc = npcFolder and npcFolder:FindFirstChild(npcName)

if not npc or not npc.PrimaryPart then
    return
end

local targetCoordinates = Vector3.new(8747.899, 772.301, 1569.553) -- New coordinates

local function simulateKeyPress(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function pressProximityPrompt(prompt)
    while prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled do
        fireproximityprompt(prompt)
        wait(0.2) -- Hold prompt for a short interval
    end
end

local function tweenToPosition(targetPosition, callback)
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local speed = 500
    local tweenTime = distance / speed
    local currentOrientation = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenGoal = { CFrame = CFrame.new(targetPosition) * currentOrientation }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    tween:Play()

    tween.Completed:Connect(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        if callback then
            callback()
        end
    end)
end

local function interactWithNearbyPrompt()
    local prompt = workspace:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        pressProximityPrompt(prompt)
    end
end

local function interactWithNPC()
    local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        -- Proximity prompt interaction with the NPC
        pressProximityPrompt(prompt)
        simulateKeyPress(Enum.KeyCode.BackSlash, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.S, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.S, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)
        wait(0.5)
        simulateKeyPress(Enum.KeyCode.Return, 0.1)

        -- Tween to new coordinates after sequence
        tweenToPosition(targetCoordinates, function()
            wait(2)
            -- Wait and press E for 2 secondssw
        simulateKeyPress(Enum.KeyCode.E, 2)
        
            wait(1)
            tweenToPosition(Vector3.new(7538.853516625, 747.5322265625, 987.73436035162))
        simulateKeyPress(Enum.keyCode.BackSlash, 0.1)
        end)
    end
end

local function tweenToNPC()
    local targetPosition = npc.PrimaryPart.Position + Vector3.new(0, 0, -5)
    tweenToPosition(targetPosition, interactWithNPC)
end

wait(1)
tweenToNPC()
    	end
})

local Misc = Window:CreateTab({
    Name = "Misc",
    Icon = "priority_high",
    ImageSource = "Material",
    ShowTitle = true
})


-- ESP Settings
local ESPEnabled = false
local blacklistedItems = {"Chest"} -- Blacklist
local ESPFolder = Instance.new("Folder", game.CoreGui) -- Store ESP drawings

-- Utility Functions
local function createESP(model)
    -- Get the Root part of the model
    local rootPart = model:FindFirstChild("Root")
    if not rootPart then return end

    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui", ESPFolder)
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.GothamBold

    -- Update Text and Distance
    spawn(function()
        while ESPEnabled and model.Parent do
            local playerRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                local distance = math.floor((playerRoot.Position - rootPart.Position).Magnitude)
                textLabel.Text = string.format("%s\n(%d studs)", model.Name, distance)
            end
            task.wait(0.1)
        end
        billboard:Destroy()
    end)
end

local function toggleESP(enabled)
    ESPEnabled = enabled
    if ESPEnabled then
        for _, model in pairs(workspace.Objects.Drops:GetChildren()) do
            if not table.find(blacklistedItems, model.Name) and model:IsA("Model") then
                createESP(model)
            end
        end
        -- Notify
        Luna:Notification({
            Title = "ESP Enabled",
            Icon = "notifications_active",
            ImageSource = "Material",
            Content = "Item ESP has been enabled."
        })
    else
        -- Clear ESP
        ESPFolder:ClearAllChildren()
        -- Notify
        Luna:Notification({
            Title = "ESP Disabled",
            Icon = "notifications_off",
            ImageSource = "Material",
            Content = "Item ESP has been disabled."
        })
    end
end

-- Watch for New Items
workspace.Objects.Drops.ChildAdded:Connect(function(child)
    if ESPEnabled and not table.find(blacklistedItems, child.Name) and child:IsA("Model") then
        createESP(child)
    end
end)

-- Create Toggle
local Toggle = Misc:CreateToggle({
    Name = "Enable Item ESP",
    Description = "Toggle the item ESP feature to display item distances and names.",
    CurrentValue = config.itemESPEnabled,
    Callback = function(Value)
        config.itemESPEnabled = Value
        toggleESP(Value) 
        saveConfig()
    end
})

Tab:CreateSection("Auto Freeze")

local autofreezeRange = config.autofreezeRange
local autoFreezeEnabled = config.autoFreezeEnabled

-- Create the Toggle for enabling/disabling auto-freeze
local Toggle = Tab:CreateToggle({
    Name = "Enable Auto-Freeze",
    Description = "Enable or disable the auto-freeze feature for nearby humanoids.",
    CurrentValue = config.autoFreezeEnabled,  -- Use saved value
    Callback = function(Value)
        autoFreezeEnabled = Value
        config.autoFreezeEnabled = Value
        saveConfig()

        if Value then
            print("Auto-Freeze enabled")

            -- Auto-freeze logic
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local freezeRemote = replicatedStorage.Remotes.Server.Combat.Rush

            local player = game.Players.LocalPlayer
            local playerCharacter = player.Character or player.CharacterAdded:Wait()

            local function getDistance(pos1, pos2)
                return (pos1 - pos2).Magnitude
            end

            local allowedFolders = {"Mobs", "Characters"}

            while autoFreezeEnabled do
                for _, folderName in ipairs(allowedFolders) do
                    local folder = workspace.Objects:FindFirstChild(folderName)
                    if folder then
                        for _, model in ipairs(folder:GetDescendants()) do
                            local humanoid = model:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Parent ~= playerCharacter then
                                local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
                                local playerRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")

                                if humanoidRootPart and playerRootPart then
                                    local distance = getDistance(playerRootPart.Position, humanoidRootPart.Position)
                                    if distance <= autofreezeRange then
                                        freezeRemote:FireServer(humanoid, false) -- Fire the server with updated parameters
                                    end
                                end
                            end
                        end
                    end
                end
                wait(0.5) -- Adjust the wait time for checking frequency
            end
        else
            print("Auto-Freeze disabled")
        end
    end
})

-- Create the Slider for Range Selection
local Slider = Tab:CreateSlider({
    Name = "Select Range for Freezing",
    Range = {1, 1000},  -- Minimum and Maximum Range for the Slider
    Increment = 1,      -- The value change per step
    CurrentValue = config.autofreezeRange,
    Callback = function(Value)
        autofreezeRange = Value
        config.autofreezeRange = Value
        saveConfig()
        print("Selected range for auto-freeze:", autofreezeRange)
    end
})


local TweenService = game:GetService("TweenService")
local autocollectToolsEnabled = false
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

local function Tween(Object1, Object2, Speed, Offset, Wait)
    if Object1 and Object2 then
        local Timing = (Object1.Position - Object2.Position).Magnitude / Speed
        local TweenInfo = TweenInfo.new(Timing, Enum.EasingStyle.Linear)
        local TweenSystem = TweenService:Create(Object1, TweenInfo, {CFrame = Object2.CFrame + Offset})
        TweenSystem:Play()
        if Wait then
            TweenSystem.Completed:Wait()
        end
    end
end

local function TweenAndFireProximityPrompt(character, targetModel, speed, offset)
    local rootPart = targetModel:FindFirstChild("Root")
    local proximityPrompt = targetModel:FindFirstChild("Collect")

    if rootPart and proximityPrompt then
        -- Tween to the root part
        Tween(character.PrimaryPart, rootPart, speed, offset, true)

        task.wait(0.5) 
        fireproximityprompt(proximityPrompt) -- Trigger the proximity prompt
        print("Proximity Prompt 'Collect' triggered for:", targetModel.Name)
    else
        print("No 'Collect' Proximity Prompt or 'Root' part found for:", targetModel.Name)
    end
end

local function tweenToLoot()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    if autocollectToolsEnabled and character and character.PrimaryPart then
        for _, model in pairs(workspace.Objects.Drops:GetChildren()) do
            if model:IsA("Model") then
                local offset = Vector3.new(0, 0, 0)
                local speed = 5000
                TweenAndFireProximityPrompt(character, model, speed, offset)

                -- Wait for 0.5 seconds after processing each item
                task.wait(0.5)
            end
        end
    end
end


ProximityPromptService.PromptShown:Connect(function(prompt)
     if autocollectToolsEnabled then
        fireproximityprompt(prompt)
        task.wait(0.2)
    end
end)

-- Toggle button for Auto Collect Loots
Misc:CreateToggle({
    Name = "Auto Collect Loot",
    CurrentValue = config.autocollectToolsEnabled,
    Callback = function(State)
        autocollectToolsEnabled = State
        config.autocollectToolsEnabled = State
        saveConfig()
            if autocollectToolsEnabled then
                tweenToLoot()
                task.wait(1) -- Adjust delay to prevent performance issues
            end
        end
})

local autopromoteEnabled = false

Misc:CreateToggle({
    Name = "Auto Promote",
    CurrentValue = config.autopromoteEnabled,
    Callback = function(Value)
        autopromoteEnabled = Value
        config.autopromoteEnabled = Value
        saveConfig()
    end
})

local function performautopromote()
    if autopromoteEnabled then
        local ohString1 = "Clan Head Jujutsu High"
        local ohString2 = "Promote"
        game:GetService("ReplicatedStorage").Remotes.Server.Dialogue.GetResponse:InvokeServer(ohString1, ohString2)
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    performautopromote()
end)

-- Setup necessary services and variables
local autoCollectEnabled = false
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lootUI = game:GetService("Players").LocalPlayer.PlayerGui.Loot
local flipButton = game:GetService("Players").LocalPlayer.PlayerGui.Loot.Frame.Flip
local replayButton = game:GetService("Players").LocalPlayer.PlayerGui.ReadyScreen.Frame.Replay
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer
local flipDelayTime = 0.4

local chestTable = {}
local chestCount = 0
local endFunctions = false  -- Used to track if coroutines are already running

-- Function to update the chest list
local function updateChests()
    local dropsFolder = game.Workspace.Objects.Drops:GetChildren()
    chestTable = {}
    chestCount = 0
    for _, chest in pairs(dropsFolder) do
        if chest:IsA("Model") and chest.Name == "Chest" then
            table.insert(chestTable, chest)
            chestCount = chestCount + 1
        end
    end
end

-- Function to collect a chest
local function collectChest(chest)
    if chest:IsA("Model") and chest.Name == "Chest" then
        local dropsFolder = game.Workspace.Objects.Drops
        local initialChestCount = #dropsFolder:GetChildren()  -- Get the initial chest count
        for _, prompt in pairs(chest:GetChildren()) do
            if prompt:IsA("ProximityPrompt") then
                prompt:InputHoldBegin()
                task.wait(0.06)
                prompt:InputHoldEnd()
                task.wait(1)
            end
        end
        local finalChestCount = #dropsFolder:GetChildren()  -- Get the final chest count
        if finalChestCount < initialChestCount then
            chestCount = finalChestCount
        end
    end
end

-- Function to auto-flip (automate flip button interaction)
local function autoFlip()
    while autoCollectEnabled do
        task.wait()
        if lootUI.Enabled then
            task.wait(flipDelayTime)
            GuiService.SelectedObject = flipButton
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.BackSlash, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)
        else
            task.wait(1)
        end
    end
end

-- Function to auto-collect chests
local function autoCollectChests()
    while autoCollectEnabled do
        task.wait()
        updateChests()
        if chestCount > 0 then
            for _, chest in pairs(chestTable) do
                collectChest(chest)
                break
            end
        end
    end
end

-- Toggle button to enable/disable auto collection
local Toggle = Misc:CreateToggle({
    Name = "Auto Collect Chest",
    CurrentValue = config.autoCollectEnabled,
    Callback = function(Value)
        autoCollectEnabled = Value
        config.autoCollectEnabled = Value
        saveConfig()
        if autoCollectEnabled then
            if not endFunctions then
                -- Start the coroutines only when the toggle is enabled for the first time
                endFunctions = true
                coroutine.wrap(autoFlip)()
                coroutine.wrap(autoCollectChests)()
            end
        else
            endFunctions = false  -- Stop the coroutines when the toggle is disabled
        end
    end
})


Misc:CreateSection("Free Innate Slots, Skip Spins")

local Button = Misc:CreateButton({
    Name = "Grant Gamepasses",
    Callback = function()
                Luna:Notification({
                Title = "Success",
                Content = "Granted Gamepasses",
                ImageSource = "Material",
                Icon = "notifications_active",
                Time = 5
})
        local gamepassIds = {"77102528", "77102481", "77103458", "259500454", "77102969"}
        local player = game:GetService("Players").LocalPlayer
        local replicatedData = player:WaitForChild("ReplicatedData")
        local gamepassesFolder = replicatedData:WaitForChild("gamepasses")

        for _, gamepassId in ipairs(gamepassIds) do
            local gamepassValue = gamepassesFolder:FindFirstChild(gamepassId)

            if not gamepassValue then
              
                gamepassValue = Instance.new("BoolValue")
                gamepassValue.Name = gamepassId
                gamepassValue.Value = true
                gamepassValue.Parent = gamepassesFolder
                print("Inserted BoolValue for game pass with ID:", gamepassId)
            else
                print("BoolValue for game pass with ID already exists:", gamepassId)
            end
        end
    end
})
Misc:CreateSection("Skill Giver(Not Perm)")


local modeSelected = "Innates"
local DropDown = Misc:CreateDropdown({
    Name = "Select Mode",
    Options = {"Innates", "Skills"},
    CurrentOption = {"Innates"},
    Callback = function(value)
        modeSelected = value
    end
})


local skillName
local Input = Misc:CreateInput({
    Name = "Enter Skill/Innate Skill",
    CurrentValue = "",
    TextDisappear = false,  
    Callback = function(value)
        print("Entered skill: " .. value)
        skillName = value  
    end
})

local keybindSelected = "B"
local DropDown = Misc:CreateDropdown({
    Name = "Select Keybind",
    Options = {"B", "C", "G", "T", "V", "X", "Y", "Z"},
    CurrentOption = {"B"},
    Callback = function(value)
        keybindSelected = value
    end
})


local Button = Misc:CreateButton({
    Name = "Assign Skill/Innate Skill",
    Callback = function()
        if not skillName or skillName == "" then
            Luna:Notification({
                Title = "Error",
                Content = "Please enter a skill name.",
                ImageSource = "Material",
                Icon = "notifications_active",
                Time = 5
            })
            return
        end

        local player = game:GetService("Players").LocalPlayer
        local techniques = player:WaitForChild("ReplicatedData"):WaitForChild("techniques")
        local selectedFolder
        if modeSelected == "Innates" then
            selectedFolder = techniques:WaitForChild("innates")
        elseif modeSelected == "Skills" then
            selectedFolder = techniques:WaitForChild("skills")
        end

        if selectedFolder then
            local stringValue = selectedFolder:FindFirstChild(keybindSelected)
            if stringValue and stringValue:IsA("StringValue") then
                stringValue.Value = skillName
                print("Skill assigned: " .. skillName)
                Luna:Notification({
                    Title = "Skill Assigned",
                    Content = "The skill '" .. skillName .. "' has been assigned to " .. keybindSelected,
                    Image = "Material",  -- Custom icon (use your own if needed)
                    Icon = "notifications_active",
                    Time = 5
                })
            else
                Luna:MakeNotification({
                    Title = "Error",
                    Content = "No StringValue found for " .. keybindSelected .. " in " .. modeSelected,
                    Icon = "notifications_active",
                    ImageSource = "Material",  -- Custom icon (use your own if needed)
                    Time = 5
                })
            end
        else
            Luna:Notification({
                Title = "Error",
                Content = "Selected folder (" .. modeSelected .. ") does not exist.",
                ImageSource = "Material",
                Icon = "notifications_active",
                Time = 5
            })
        end
    end
})

Misc:CreateSection("Weapon Giver")

local toolName = ""

-- Create an input box for typing the Tool name
local Input = Misc:CreateInput({
    Name = "Enter Weapon Name",
    PlaceholderText = "Type weapon name here",
    CurrentValue = "",
    Numeric = false,
    Callback = function(Text)
        toolName = Text
    end,
})

-- Button to create and add the Tool to the Backpack
local Button = Misc:CreateButton({
    Name = "Give Weapon (Not Permanent)",
    Callback = function()
        if not toolName or toolName == "" then
            print("Error: Please enter a tool name.")
            return
        end

        local player = game:GetService("Players").LocalPlayer
        local backpack = player.Backpack

        -- Check if the tool already exists
        if backpack:FindFirstChild(toolName) then
            print("Cursed Tool Already Exists: A tool with this name is already in your Backpack.")
            return
        end

        -- Create the tool and add it to the backpack
        local tool = Instance.new("Tool")
        tool.Name = toolName
        tool.Parent = backpack
        print("Tool '" .. toolName .. "' added to the Backpack.")
    end,
})


local Tab = Window:CreateTab({
    Name = "Move Redeemer",
    Icon = "redeem",
    ImageSource = "Material",
    ShowTitle = true,
})

local moveName = ""

local Input = Tab:CreateInput({
	Name = "Move Redeemer(Perm needs money and mastery)",
	Description = nil,
	PlaceholderText = "Input Placeholder",
	CurrentValue = "", -- the current text
	Numeric = false, -- When true, the user may only type numbers in the box (Example walkspeed)
	MaxCharacters = nil, -- if a number, the textbox length cannot exceed the number
	Enter = false, -- When true, the callback will only be executed when the user presses enter.
    	Callback = function(Text)
        moveName = Text
    	end
}, "Input")

local Button = Tab:CreateButton({
    Name = "Redeem Move",
    Callback = function()
        if moveName and moveName ~= "" then
            game:GetService("ReplicatedStorage").Remotes.Server.Data.UnlockStatNode:InvokeServer(moveName)
            print("Redeemed move:", moveName)
        else
            warn("Please enter a move name!")
        end
    end,
})


local Settings = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

local HttpService = game:GetService("HttpService")
local url = ""

local inputURL = Settings:CreateInput({
    Name = "Enter Discord Webhook URL",
    PlaceholderText = "Paste your Discord Webhook URL here",
    CurrentValue = "",
    Numeric = false,
    Callback = function(Text)
        url = Text
    end,
})

-- Create confirm button
local ConfirmButton = Settings:CreateButton({
    Name = "Confirm Webhook URL",
    Callback = function()
        if url == "" then
            -- Show error if URL is empty
            Luna:Notification({
                Title = "Error",
                Icon = "error_outline",
                ImageSource = "Material",
                Content = "Please enter a valid Discord Webhook URL.",
            })
        else
            -- URL is valid, proceed with using the webhook
            print("Webhook URL confirmed:", url)
            Luna:Notification({
                Title = "Webhook Confirmed",
                Icon = "check_circle",
                ImageSource = "Material",
                Content = "Discord Webhook URL has been confirmed.",
            })
        end
    end,
})


-- Send embed message function
function SendMessageEMBED(url, embed)
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["username"] = "NoxHub",
        ["avatar_url"] = "https://media.discordapp.net/attachments/936776180026204241/1351880348728037517/Nox_hub_banner.png?ex=67f7abaf&is=67f65a2f&hm=97696c5a7b3ece682fefc4ed7f2bc637d19ed0d4d1cb7ad7565202f7b7509297&=&format=webp&quality=lossless&width=2638&height=1484",
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["url"] = "https://discord.gg/uxK9gDWJWf",
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = {
                    ["text"] = embed.footer.text
                }
            }
        }
    }
    local body = HttpService:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
    print("Sent")
end

-- Webhook logic for item collection (same as your original)
for _, item in pairs(workspace.Objects.Drops:GetChildren()) do
    local proximityPrompt = item:FindFirstChild("Collect")
    if proximityPrompt then
        proximityPrompt.Triggered:Connect(function(player)
            local parentName = item.Name
            local embed = {
                ["title"] = parentName .. " Collected!",
                ["description"] = player.Name .. " has collected " .. parentName,
                ["color"] = 65280,  -- Green color
                ["fields"] = {
                    {
                        ["name"] = "Player",
                        ["value"] = player.Name
                    },
                    {
                        ["name"] = "Item",
                        ["value"] = parentName
                    }
                },
                ["footer"] = {
                    ["text"] = "NoxHub - Premium Roblox Scripts"
                }
            }
            SendMessageEMBED(url, embed)
        end)
    end
end
