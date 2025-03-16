local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "NoxHub - Rune Slayer BETA",
   Icon = "gamepad-2", -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Rune Slayer BETA",
   LoadingSubtitle = "by NewToyotaCamry",
   Theme = "DarkBlue", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NoxHub", -- Create a custom folder for your hub/game
      FileName = "RS Config"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "NsJnGMJG4A",
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "NoxHub RS",
      Subtitle = "Key System",
      Note = "Get your FREE key at https://discord.gg/XhJzGP6mWd", 
      FileName = "NoxHubKey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://gitfront.io/r/newtoyotacamry/kP7MnCWdm12P/keys/raw/keys.txt"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")

--// PLAYER SETUP
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera
local harvestables = workspace:WaitForChild("Harvestable")

local MainTab = Window:CreateTab("Main")
MainTab:CreateSection("Toggles")

--// STATE VARIABLES
local isMoving = false
local selectedTargetType = "Lilyleaf"
local tweenSpeed = 20
local MOVE_UPDATE_INTERVAL = 0.1
local STOP_DISTANCE = 5
local lastMoveTime = 0
local currentTween = nil

local noRagdollEnabled = false
local noRagdollConnection = nil
local noFallDamageEnabled = false
local noFallConnection = nil
local noclipEnabled = false
local noclipConnection = nil
local removeKillbricksEnabled = false
local fullbrightEnabled = false

local flightEnabled = false
local flightSpeed = 25
local flightLoop = nil

local infiniteJumpEnabled = false
local movementSpeedEnabled = false
local movementSpeedValue = 30
local movementSpeedLoop
local autoRespawnEnabled = false -- Initial toggle state

--// ORIGINAL LIGHTING
local originalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient
}

--// HIGHLIGHT INSTANCE
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(0, 255, 0)
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0
highlight.Enabled = false
highlight.Parent = workspace

--// CHARACTER REFRESH
local function refreshCharacterReferences()
	character = player.Character
	rootPart = character:WaitForChild("HumanoidRootPart", 5)
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	rootPart = character:WaitForChild("HumanoidRootPart", 5)
	humanoid = character:WaitForChild("Humanoid")

	if flightEnabled then startFlight() end
	if noclipEnabled then applyNoclip() end
	if removeKillbricksEnabled then applyKillbrickRemover() end
	if fullbrightEnabled then applyFullbright() end
	if noFallDamageEnabled then applyNoFallDamage() end
	if noRagdollEnabled then applyNoRagdoll() end
end)

--// SUPPORT FUNCTIONS
local function applyNoclip()
	if noclipConnection then noclipConnection:Disconnect() end
	noclipConnection = RunService.Stepped:Connect(function()
    	for _, part in ipairs(character:GetDescendants()) do
        	if part:IsA("BasePart") then part.CanCollide = false end
    	end
	end)
end

local function disableNoclip()
	if noclipConnection then noclipConnection:Disconnect() end
	for _, part in ipairs(character:GetDescendants()) do
    	if part:IsA("BasePart") then part.CanCollide = true end
	end
end

local function applyKillbrickRemover()
	local keywords = {"Kill", "Lava", "Death", "TouchKill", "Damage"}
	for _, part in ipairs(workspace:GetDescendants()) do
    	if part:IsA("BasePart") then
        	for _, word in ipairs(keywords) do
            	if part.Name:lower():find(word:lower()) then
                	part.CanTouch = false
                	part.CanCollide = false
                	part.Transparency = 1
                	local tt = part:FindFirstChildOfClass("TouchTransmitter")
                	if tt then tt:Destroy() end
            	end
        	end
    	end
	end
end

local function applyFullbright()
	Lighting.Brightness = 5
	Lighting.ClockTime = 12
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.new(1, 1, 1)
	Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

local function restoreLighting()
	for k, v in pairs(originalLighting) do Lighting[k] = v end
end

local function applyNoFallDamage()
	if noFallConnection then noFallConnection:Disconnect() end
	noFallConnection = humanoid.StateChanged:Connect(function(_, state)
    	if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Landed then
        	humanoid:ChangeState(Enum.HumanoidStateType.Running)
    	end
	end)
end

local function applyNoRagdoll()
	if noRagdollConnection then noRagdollConnection:Disconnect() end
	noRagdollConnection = humanoid.StateChanged:Connect(function(_, state)
    	if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
        	humanoid:ChangeState(Enum.HumanoidStateType.Running)
    	end
	end)
end

local function startMovementSpeed()
	if movementSpeedLoop then movementSpeedLoop:Disconnect() end
	movementSpeedLoop = RunService.RenderStepped:Connect(function()
    	if humanoid then
        	humanoid.WalkSpeed = movementSpeedValue
    	end
	end)
end

local function stopMovementSpeed()
	if movementSpeedLoop then movementSpeedLoop:Disconnect() end
	movementSpeedLoop = nil
	if humanoid then humanoid.WalkSpeed = 16 end
end

local function pressKey(key)
	VirtualInput:SendKeyEvent(true, key, false, nil)
	task.wait(0.005)
	VirtualInput:SendKeyEvent(false, key, false, nil)
end

--// INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
	if infiniteJumpEnabled and humanoid then
    	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--// FLIGHT
local movement = { Forward = 0, Right = 0, Up = 0 }

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.W then movement.Forward = 1 end
	if input.KeyCode == Enum.KeyCode.S then movement.Forward = -1 end
	if input.KeyCode == Enum.KeyCode.A then movement.Right = -1 end
	if input.KeyCode == Enum.KeyCode.D then movement.Right = 1 end
	if input.KeyCode == Enum.KeyCode.Space then movement.Up = 1 end
	if input.KeyCode == Enum.KeyCode.LeftControl then movement.Up = -1 end
	if input.KeyCode == Enum.KeyCode.B then
    	flightEnabled = not flightEnabled
    	Rayfield.Flags["Toggle_Flight"] = flightEnabled
    	if flightEnabled then startFlight() else stopFlight() end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then movement.Forward = 0 end
	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then movement.Right = 0 end
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then movement.Up = 0 end
end)

function startFlight()
	refreshCharacterReferences()
	if not character or not rootPart then return end
	rootPart.Anchored = true
	if flightLoop then flightLoop:Disconnect() end

	flightLoop = RunService.RenderStepped:Connect(function()
    	local moveVec = camera.CFrame.LookVector * movement.Forward + camera.CFrame.RightVector * movement.Right + Vector3.new(0, movement.Up, 0)
    	if moveVec.Magnitude > 0 then
        	moveVec = moveVec.Unit * flightSpeed
        	local targetPos = rootPart.Position + moveVec * 0.1
        	local goal = { Position = targetPos }
        	local tween = TweenService:Create(rootPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), goal)
        	tween:Play()
    	end
	end)
end

function stopFlight()
	if flightLoop then flightLoop:Disconnect() end
	flightLoop = nil
	if rootPart then rootPart.Anchored = false end
end

--// STATE VARIABLES
local isAntiAFKEnabled = false
local antiAFKConnection

--// ANTI-AFK FUNCTIONALITY
local function pressWKey()
	-- Simulate pressing the W key for 0.1 seconds
	VirtualInput:SendKeyEvent(true, Enum.KeyCode.W, false, nil)  -- Press W
	wait(0.1)  -- Wait for 0.1 seconds
	VirtualInput:SendKeyEvent(false, Enum.KeyCode.W, false, nil)  -- Release W
end

local function startAntiAFK()
	isAntiAFKEnabled = true
    
	-- Create a loop to tap W every 3 seconds
	while isAntiAFKEnabled do
    	pressWKey()  -- Simulate pressing the W key
    	wait(150)  -- Wait for 3 seconds before the next tap
	end
end

local function stopAntiAFK()
	isAntiAFKEnabled = false
end

local Button = MainTab:CreateButton({
	Name = "Kill",
	Callback = function()
	   Rayfield:Destroy()
	end,
 })

--// MAIN UI TOGGLES
MainTab:CreateToggle({ Name = "No Clip", CurrentValue = false, Flag = "Toggle_Noclip", Callback = function(v) noclipEnabled = v if v then applyNoclip() else disableNoclip() end end })
MainTab:CreateToggle({ Name = "No Killbricks", CurrentValue = false, Flag = "Toggle_RemoveKillbricks", Callback = function(v) removeKillbricksEnabled = v if v then applyKillbrickRemover() end end })
MainTab:CreateToggle({ Name = "No Fall Damage", CurrentValue = false, Flag = "Toggle_NoFall", Callback = function(v) noFallDamageEnabled = v if v then applyNoFallDamage() elseif noFallConnection then noFallConnection:Disconnect() end end })
MainTab:CreateToggle({ Name = "No Ragdoll", CurrentValue = false, Flag = "Toggle_NoRagdoll", Callback = function(v) noRagdollEnabled = v if v then applyNoRagdoll() elseif noRagdollConnection then noRagdollConnection:Disconnect() end end })
MainTab:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "Toggle_Fullbright", Callback = function(v) fullbrightEnabled = v if v then applyFullbright() else restoreLighting() end end })

-- Declare the state variable for Auto Respawn
local autoRespawnEnabled = false -- Default state for Auto Respawn

-- Function to check if the Respawn GUI is visible
local function isRespawnGuiVisible()
    local respawnGui = player:WaitForChild("PlayerGui"):FindFirstChild("InfoOverlays"):FindFirstChild("ConfirmFrame")
    return respawnGui and respawnGui:FindFirstChild("MainFrame") and respawnGui.MainFrame.Visible
end

-- Function to simulate key presses
local function simulateKeyPress(keyCode)
    local VirtualInput = game:GetService("VirtualInputManager")
    VirtualInput:SendKeyEvent(true, keyCode, false, nil) -- Key down
    task.wait(0.1) -- Mimic realistic timing
    VirtualInput:SendKeyEvent(false, keyCode, false, nil) -- Key up
end

-- Function to perform the key sequence for Auto Respawn
local function performKeySequence()
	wait(0.5)
    simulateKeyPress(Enum.KeyCode.BackSlash) -- Simulate pressing "\"
    task.wait(0.3)
    simulateKeyPress(Enum.KeyCode.Down) -- Simulate pressing "Down Arrow"
    task.wait(0.3)
    simulateKeyPress(Enum.KeyCode.Return) -- Simulate pressing "Enter"
    task.wait(0.3)
    simulateKeyPress(Enum.KeyCode.BackSlash) -- Simulate pressing "\" again
end

-- Function to monitor the Respawn GUI and trigger the key sequence
local function monitorAutoRespawn()
    while autoRespawnEnabled do
        if isRespawnGuiVisible() then
            performKeySequence()
            break -- Exit the loop after one successful execution
        end
        task.wait(1) -- Check every 0.5 seconds
    end
end

-- Update character references and restart monitoring when the player respawns
player.CharacterAdded:Connect(function(newChar)
    refreshCharacterReferences() -- Use the existing function to refresh references
    if autoRespawnEnabled then
        task.spawn(monitorAutoRespawn) -- Restart monitoring if Auto Respawn is enabled
    end
end)

-- Add the toggle to the `MainTab`
MainTab:CreateToggle({
    Name = "Auto Respawn",
    CurrentValue = false,
    Flag = "Toggle_AutoRespawn", -- Unique identifier to avoid conflicts
    Callback = function(v)
        autoRespawnEnabled = v
        if autoRespawnEnabled then
            task.spawn(monitorAutoRespawn) -- Start monitoring in a separate thread
        end
    end,
})


local RunService = game:GetService("RunService")
local NoEffectsEnabled = false -- Default state for No Effects

-- List of effect elements and their specific handling
local effectsList = {
    RainDrops = "ParticleEmitter",
    RainPart = "BasePart",
    Fog = "Part",
    rolldust = "ParticleEmitter",
    RainParticles = "Part"
}

-- Function to continuously block effects
local function blockEffects()
    if not NoEffectsEnabled then return end -- Only run when No Effects is enabled

    local effectsFolder = Workspace:FindFirstChild("Effects")
    if effectsFolder then
        for effectName, effectType in pairs(effectsList) do
            local effect = effectsFolder:FindFirstChild(effectName)
            if effect and effect:IsA(effectType) then
                if effectType == "ParticleEmitter" or effectType == "BasePart" then
                    effect.Enabled = false -- Disable effect
                elseif effectType == "Part" then
                    effect.Transparency = 1 -- Make the Part invisible
                    effect.CanCollide = false -- Disable collision
                end
            end
        end
    end
end

-- Adding the toggle in your MainTab
MainTab:CreateToggle({
    Name = "No Weather",
    CurrentValue = false,
    Flag = "NoEffectsToggle", -- Ensures no flag conflicts
    Callback = function(state)
        NoEffectsEnabled = state
        if not NoEffectsEnabled then
            -- Re-enable effects when toggled off
            local effectsFolder = Workspace:FindFirstChild("Effects")
            if effectsFolder then
                for effectName, effectType in pairs(effectsList) do
                    local effect = effectsFolder:FindFirstChild(effectName)
                    if effect and effect:IsA(effectType) then
                        if effectType == "ParticleEmitter" or effectType == "BasePart" then
                            effect.Enabled = true -- Re-enable effect
                        elseif effectType == "Part" then
                            effect.Transparency = 0 -- Make the Part visible
                            effect.CanCollide = true -- Re-enable collision
                        end
                    end
                end
            end
        end
    end
})

-- Use RunService.Heartbeat to continuously enforce No Effects
RunService.Heartbeat:Connect(blockEffects)

	MainTab:CreateToggle({
	Name = "Anti-AFK",
	CurrentValue = false,
	Flag = "Toggle_AntiAFK",
	Callback = function(v)
    	if v then
        	startAntiAFK()
    	else
        	stopAntiAFK()
    	end
	end
})

--// MOVEMENT SECTION
MainTab:CreateSection("Movement")
MainTab:CreateToggle({ Name = "Flight - [B]", CurrentValue = false, Flag = "Toggle_Flight", Callback = function(v) flightEnabled = v if v then startFlight() else stopFlight() end end })
MainTab:CreateSlider({ Name = "Flight Speed", Range = {10, 120}, Increment = 5, Suffix = " studs/sec", CurrentValue = 50, Flag = "Slider_FlightSpeed", Callback = function(v) flightSpeed = v end })
MainTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "Toggle_InfiniteJump", Callback = function(v) infiniteJumpEnabled = v end })
MainTab:CreateToggle({ Name = "Fast Walk", CurrentValue = false, Flag = "Toggle_MovementSpeed", Callback = function(v) movementSpeedEnabled = v if v then startMovementSpeed() else stopMovementSpeed() end end })
MainTab:CreateSlider({ Name = "Walk Speed", Range = {5, 120}, Increment = 1, Suffix = " studs/sec", CurrentValue = 30, Flag = "Slider_WalkSpeed", Callback = function(v) movementSpeedValue = v end })

--// TELEPORT TAB
local TeleTab = Window:CreateTab("Teleport")
local teleportLocations = {
	Wayshire = Vector3.new(758.1, 168.1, 333),
	Lakeshire = Vector3.new(-297.2, 170, -866),
	Ashenshire = Vector3.new(895.4, 250, -1240),
	Ali_Quest = Vector3.new(1030, 116, 193),
	AncientDemon_Quest = Vector3.new(-960, 58, -668),
	Austri_Potions = Vector3.new(1055, 253, -1163),
	Banker = Vector3.new(850, 151, 244),
	Beowulf_Quest = Vector3.new(1045, 253, -1135),
	Billy_Quest = Vector3.new(-325, 160, -972),
	Bjorn_Quest = Vector3.new(895, 248, -1270),
	Boran_Quest = Vector3.new(665, 146, 408),
	David_Fish = Vector3.new(-423, 156, -904),
	Drogar_Quest = Vector3.new(1004, -217.5, 1703),
	Eldra_Inn = Vector3.new(1258, 254, -1100),
	Evelyne_Quest = Vector3.new(-471, 159, -791),
	FatherMattias_Church = Vector3.new(1452, 141, 742),
	Gromvak_Quest = Vector3.new(458, 207, -1988),
	Halric_Quest = Vector3.new(756, 177, 320),
	Hobo_Quest = Vector3.new(-609, 152, 1201),
	Hodor_Quest = Vector3.new(-658, 266, -888),
	Jane_Quest = Vector3.new(926, 128, 390),
	Joe_Cooker = Vector3.new(2458, 167, -1571),
	John_Merchant = Vector3.new(-385, 155, -956),
	Jude_Cooker = Vector3.new(1540, 125, 571),
	Kaelis_Quest = Vector3.new(1258, 268, -1106),
	Karen_Quest = Vector3.new(1040, 133, 414),
	Kevin_Quest = Vector3.new(-530, 139, 1345),
	KnightsTemplar = Vector3.new(-410, 386, -784),
	LightningSpirit_Quest = Vector3.new(2778, 1082, -533),
	Lockmeier_Bounty = Vector3.new(780, 143.2, 462),
	Madonna_Storage = Vector3.new(1105, 249, -1183),
	Maelis_Quest = Vector3.new(385, 195, -1442),
	MaelisFairy = Vector3.new(385, 195, -1441),
	Margaret_Appearance = Vector3.new(1144, 130, 518),
	Mira_Inn = Vector3.new(758, 147, 510),
	Roderick_Quest = Vector3.new(-237, 221, 903),
	Schoen_MageShop = Vector3.new(620, 180, 518),
	SickGirl_Quest = Vector3.new(1040, 133, 416),
	Soldat_Quest = Vector3.new(795, 165, 375),
	Suori_Quest = Vector3.new(-140, 114, 367),
	Susan_Inn = Vector3.new(-373, 162, -827),
	Tarin_Quest = Vector3.new(886, 248, -1230),
	Winfrid_Blacksmith = Vector3.new(1025, 128, 525),
	Yuri_Quest = Vector3.new(-530, 139, 1345),
}

local function SetNoclip(state)
	if character then
    	for _, part in pairs(character:GetDescendants()) do
        	if part:IsA("BasePart") then part.CanCollide = not state end
    	end
	end
end

local function TeleportTo(location)
	if rootPart and teleportLocations[location] then
    	local distance = (rootPart.Position - teleportLocations[location]).Magnitude
    	local time = distance / tweenSpeed
    	SetNoclip(true)
    	local tween = TweenService:Create(rootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(teleportLocations[location])})
    	tween:Play()
    	tween.Completed:Connect(function() SetNoclip(false) end)
	end
end

TeleTab:CreateSection("Flight Speed")

TeleTab:CreateSlider({ Name = "Flight Speed", Range = {10, 100}, Increment = 5, Suffix = "Speed", CurrentValue = 50, Flag = "SpeedSlider", Callback = function(v) tweenSpeed = v end })

-- Teleport Tab Section
TeleTab:CreateSection("Guild Board Locations")
TeleTab:CreateButton({ Name = "Teleport to Wayshire", Callback = function() TeleportTo("Wayshire") end })
TeleTab:CreateButton({ Name = "Teleport to Lakeshire", Callback = function() TeleportTo("Lakeshire") end })
TeleTab:CreateButton({ Name = "Teleport to Ashenshire", Callback = function() TeleportTo("Ashenshire") end })

TeleTab:CreateSection("NPC Locations")
TeleTab:CreateButton({ Name = "Teleport to Ali (Quest)", Callback = function() TeleportTo("Ali_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to AncientDemon (Quest)", Callback = function() TeleportTo("AncientDemon_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Austri (Potions)", Callback = function() TeleportTo("Austri_Potions") end })
TeleTab:CreateButton({ Name = "Teleport to Banker", Callback = function() TeleportTo("Banker") end })
TeleTab:CreateButton({ Name = "Teleport to Beowulf (Quest)", Callback = function() TeleportTo("Beowulf_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Billy (Quest)", Callback = function() TeleportTo("Billy_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Bjorn (Quest)", Callback = function() TeleportTo("Bjorn_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Boran (Quest)", Callback = function() TeleportTo("Boran_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to David (Fish)", Callback = function() TeleportTo("David_Fish") end })
TeleTab:CreateButton({ Name = "Teleport to Drogar (Quest)", Callback = function() TeleportTo("Drogar_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Eldra (Inn)", Callback = function() TeleportTo("Eldra_Inn") end })
TeleTab:CreateButton({ Name = "Teleport to Evelyne (Quest)", Callback = function() TeleportTo("Evelyne_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to FatherMattias (Church)", Callback = function() TeleportTo("FatherMattias_Church") end })
TeleTab:CreateButton({ Name = "Teleport to Gromvak (Quest)", Callback = function() TeleportTo("Gromvak_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Halric (Quest)", Callback = function() TeleportTo("Halric_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Hobo (Quest)", Callback = function() TeleportTo("Hobo_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Hodor (Quest)", Callback = function() TeleportTo("Hodor_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Jane (Quest)", Callback = function() TeleportTo("Jane_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Joe (Cooker)", Callback = function() TeleportTo("Joe_Cooker") end })
TeleTab:CreateButton({ Name = "Teleport to John (Merchant)", Callback = function() TeleportTo("John_Merchant") end })
TeleTab:CreateButton({ Name = "Teleport to Jude (Cooker)", Callback = function() TeleportTo("Jude_Cooker") end })
TeleTab:CreateButton({ Name = "Teleport to Karen (Quest)", Callback = function() TeleportTo("Karen_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Kaelis (Quest)", Callback = function() TeleportTo("Kaelis_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Kevin (Quest)", Callback = function() TeleportTo("Kevin_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to KnightsTemplar", Callback = function() TeleportTo("KnightsTemplar") end })
TeleTab:CreateButton({ Name = "Teleport to Lockmeier (Bounty)", Callback = function() TeleportTo("Lockmeier_Bounty") end })
TeleTab:CreateButton({ Name = "Teleport to LightningSpirit (Quest)", Callback = function() TeleportTo("LightningSpirit_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Maelis (Quest)", Callback = function() TeleportTo("Maelis_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to MaelisFairy", Callback = function() TeleportTo("MaelisFairy") end })
TeleTab:CreateButton({ Name = "Teleport to Margaret (Appearance)", Callback = function() TeleportTo("Margaret_Appearance") end })
TeleTab:CreateButton({ Name = "Teleport to Madonna (Storage)", Callback = function() TeleportTo("Madonna_Storage") end })
TeleTab:CreateButton({ Name = "Teleport to Mira (Inn)", Callback = function() TeleportTo("Mira_Inn") end })
TeleTab:CreateButton({ Name = "Teleport to Roderick (Quest)", Callback = function() TeleportTo("Roderick_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Schoen (MageShop)", Callback = function() TeleportTo("Schoen_MageShop") end })
TeleTab:CreateButton({ Name = "Teleport to SickGirl (Quest)", Callback = function() TeleportTo("SickGirl_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Soldat (Quest)", Callback = function() TeleportTo("Soldat_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Suori (Quest)", Callback = function() TeleportTo("Suori_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Susan (Inn)", Callback = function() TeleportTo("Susan_Inn") end })
TeleTab:CreateButton({ Name = "Teleport to Tarin (Quest)", Callback = function() TeleportTo("Tarin_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Yuri (Quest)", Callback = function() TeleportTo("Yuri_Quest") end })
TeleTab:CreateButton({ Name = "Teleport to Winfrid (Blacksmith)", Callback = function() TeleportTo("Winfrid_Blacksmith") end })

-- Forward declarations for functions used in UI callbacks
local StartAutofarm
local StartSellingItems

-----------------------------------
-- [ Autofarm UI Setup ]
-----------------------------------
local AutofarmTab = Window:CreateTab("AutoFarm")
local autofarmEnabled = false
local selectedTargets = {}
local activeKeywords = {}
local flightSpeed = 50
local verticalOffset = 1
local sellItemsEnabled = false
local activeTweenTarget = nil -- Track the current tween target

-- Update activeKeywords based on target toggles
local function updateActiveKeywords()
	activeKeywords = {}
	for keyword, enabled in pairs(selectedTargets) do
    	if enabled then
        	table.insert(activeKeywords, keyword:lower())
    	end
	end
end

local Section = AutofarmTab:CreateSection("Settings")

AutofarmTab:CreateToggle({
	Name = "Enable AutoFarm",
	CurrentValue = autofarmEnabled,
	Flag = "EnableAutofarm",
	Callback = function(value)
    	autofarmEnabled = value
    	if value then
        	StartAutofarm()
    	end
	end,
})

AutofarmTab:CreateSlider({
	Name = "Flight Speed",
	Range = {20, 100},
	Increment = 5,
	CurrentValue = flightSpeed,
	Callback = function(val)
    	flightSpeed = val
	end,
})

AutofarmTab:CreateSlider({
	Name = "Vertical Offset (do not select 0)",
	Range = {-3, 5},
	Increment = 1,
	CurrentValue = verticalOffset,
	Callback = function(val)
    	verticalOffset = val
	end,
})

AutofarmTab:CreateToggle({
	Name = "Sell Items",
	CurrentValue = sellItemsEnabled,
	Callback = function(val)
    	sellItemsEnabled = val
    	if val then GoSellingItems() end
	end,
})

local targetTypes = {
	Harvestable = {"Apple", "SpiderEgg", "Vitalshroom", "Flax", "Cotton", "Beehive", "Pineroot", "Scorchleaf", "Moss", "Mandrake root", "Lilyleaf", "Bahlstalk", "Falthorn"},
	Ore = {"Copper", "Iron", "Silver", "Volcanic Ice", "Platinum", "Mithril"},
	Wood = {"Small Oak", "Oak", "Pine", "Elderwood", "Lakewood", "Ashwood"},
}

for category, targets in pairs(targetTypes) do
	local Section = AutofarmTab:CreateSection(category)
	for _, target in ipairs(targets) do
    	AutofarmTab:CreateToggle({
        	Name = "Target: " .. target,
        	CurrentValue = false,
        	Flag = "Target_" .. target,
        	Callback = function(value)
            	selectedTargets[target] = value or nil
            	updateActiveKeywords()
        	end,
    	})
	end
end

-----------------------------------
-- [ Services & References ]
-----------------------------------
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	Character = LocalPlayer.Character
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
end)

-----------------------------------
-- [ Harvest Cache ]
-----------------------------------
local HarvestableFolder = workspace:FindFirstChild("Harvestable")
local harvestCache = {}

local function updateHarvestCache()
    if HarvestableFolder then
        harvestCache = {} -- Reset the cache
        for _, child in ipairs(HarvestableFolder:GetChildren()) do
            -- Check if the object has an "InteractPrompt" child
            if child:FindFirstChild("InteractPrompt") then
                table.insert(harvestCache, child)
            end
        end
    end
end

if HarvestableFolder then
    HarvestableFolder.ChildAdded:Connect(function(child)
        -- Add to cache if it has an "InteractPrompt"
        if child:FindFirstChild("InteractPrompt") then
            table.insert(harvestCache, child)
        end
    end)
    
    HarvestableFolder.ChildRemoved:Connect(function(child)
        -- Remove from cache if it gets deleted
        for i, v in ipairs(harvestCache) do
            if v == child then
                table.remove(harvestCache, i)
                break
            end
        end
    end)
    
    updateHarvestCache() -- Initial population of the cache
end

-----------------------------------
-- [ Helper Functions ]
-----------------------------------
local function GetTargetPart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function FindNearestTarget()
    local nearest, shortestDist = nil, math.huge
    if not RootPart then
        return nil
    end
    local rootPos = RootPart.Position

    for _, obj in ipairs(harvestCache) do
        local part = GetTargetPart(obj)
        if part then
            local dist = (rootPos - part.Position).Magnitude
            if dist < shortestDist then
                nearest = part
                shortestDist = dist
            end
        end
    end

    return nearest
end

local function moveToTargetConstantSpeed(part)
    -- Ensure the player remains in flight
    local hoverOffset = Vector3.new(0, 0, 0) -- Hover 10 studs above the current position
    local hoverConnection

    -- Function to maintain hovering
    local function startHovering()
        hoverConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if RootPart then
                local hoverPosition = RootPart.Position + hoverOffset
                RootPart.CFrame = CFrame.new(hoverPosition, hoverPosition + Vector3.new(0, 0, -1)) -- Face forward
            end
        end)
    end

    -- Stop hovering when it's no longer needed
    local function stopHovering()
        if hoverConnection then
            hoverConnection:Disconnect()
            hoverConnection = nil
        end
    end

    -- Start pursuing the target
    if part and RootPart then
        activeTweenTarget = part
        stopHovering() -- Stop hovering since we now have a target

        while autofarmEnabled and part.Parent and RootPart and Character and Humanoid and activeTweenTarget == part do
            local desiredPos = part.Position + Vector3.new(0, verticalOffset, 0)
            local currentPos = RootPart.Position
            local direction = (desiredPos - currentPos)
            local distance = direction.Magnitude

            local dt = RunService.Heartbeat:Wait()
            local step = flightSpeed * dt

            local newPos
            if distance > 0.1 then
                local moveVec = direction.Unit * math.min(step, distance)
                newPos = currentPos + moveVec
            else
                newPos = desiredPos
            end

            local faceDir = (part.Position - newPos).Unit
            RootPart.CFrame = CFrame.new(newPos, newPos + faceDir)

            -- Disable collisions on character parts
            for _, p in ipairs(Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end

    -- If no active target, fallback to hovering
    if not part or not part.Parent or activeTweenTarget ~= part then
        startHovering()
        repeat
            task.wait(0.1) -- Brief wait to check for a new target
            part = FindNearestTarget()
        until part and part.Parent and autofarmEnabled

        stopHovering() -- Stop hovering once a new target is found
        moveToTargetConstantSpeed(part) -- Resume flight
    end
end

-----------------------------------
-- [ Harvest Simulation with Continuous Reassessment ]
-----------------------------------

-- Get Player & Character
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Harvestable = workspace:WaitForChild("Harvestable")

-- Object names to search for
local ObjectNames = {
    "Apple", "SpiderEgg", "Vitalshroom", "Flax", "Cotton", "Beehive", "Pineroot", "Scorchleaf", "Moss", "Mandrake root",
    "Lilyleaf", "Bahlstalk", "Falthorn", "Copper", "Iron", "Silver", "Volcanic Ice", "Platinum", "Mithril",
    "Small Oak", "Oak", "Pine", "Elderwood", "Lakewood", "Ashwood"
}

-- Actions to try on the closest object
local Actions = { "Mine", "Chop", "Harvest" }

-- Utility: get world position of a given object
local function getObjectPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        return (obj.PrimaryPart and obj.PrimaryPart.Position)
            or (obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position)
    end
    return nil -- Fallback if no valid position
end

-- Shared state variables
local closestObject = nil
local shortestDistance = math.huge

-- Loop: Closest Target Finder
local function ClosestTargetLoop()
    while autofarmEnabled do
        -- Reset closest object and distance
        local tempClosestObject, tempShortestDistance = nil, math.huge

        -- Find the closest matching object
        for _, obj in ipairs(Harvestable:GetChildren()) do
            local objNameLower = obj.Name:lower()
            for _, targetName in ipairs(ObjectNames) do
                if objNameLower:find(targetName:lower()) then
                    local objPos = getObjectPosition(obj)
                    if objPos then
                        local distance = (objPos - HumanoidRootPart.Position).Magnitude
                        if distance < tempShortestDistance then
                            tempClosestObject = obj
                            tempShortestDistance = distance
                        end
                    end
                    break -- Stop checking other names once one matched
                end
            end
        end

        -- Update shared state
        closestObject = tempClosestObject
        shortestDistance = tempShortestDistance

        task.wait(0.2) -- Run the search every 0.2 seconds
    end
end

-- Loop: Interaction with Closest Object
local function InteractionLoop()
    while autofarmEnabled do
        if closestObject and shortestDistance <= 10 then -- Check if object is within 10 studs
            for _, action in ipairs(Actions) do
                task.spawn(function()
                    LocalPlayer.Character.CharacterHandler.Input.Events.Interact:FireServer({
                        player = LocalPlayer,
                        Object = closestObject,
                        Action = action
                    })
                end)
            end

		end

        task.wait(0.5) -- Run interaction every 0.2 seconds
    end
end

-- Loop: Simulate Key Press
local function KeyPressLoop()
    while autofarmEnabled do
        if closestObject and shortestDistance <= 10 then -- Check if object is within 10 studs
            -- Simulate pressing the "E" key
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) -- Press "E"
            task.wait(0.2) -- Short delay to mimic realistic press timing
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) -- Release "E"
        else
            warn("❌ No object within 10 studs to interact with.")
        end

        task.wait(2) -- Run keypress simulation every 0.5 seconds
    end
end

-- Start the loops in separate threads
task.spawn(ClosestTargetLoop)
task.spawn(InteractionLoop)
task.spawn(KeyPressLoop)



-----------------------------------
-- [ Sell Items Loop ]
-----------------------------------
GoSellingItems = function()
	local sellItems = {
    	"Agility Rune", "Amber", "Amphithere", "Amphithere Feather", "Ancient Demon",
    	"Animal Heart", "Apple", "Ashwood Log", "Bahlstalk", "Banshee", "Basilisk",
    	"Basilisk Skin", "Bass", "Bear", "Beehive", "Black Bass", "Black Ooze Chunk",
    	"Black Ooze Slime", "Boar", "Braelor", "Carapace", "Carapace", "Contractor",
    	"Copper Ore", "Crocodile", "Deer", "Demon Heart", "Demon Hide", "Dire Bear",
    	"Dire Bear Claw", "Dire Bear Hide", "Dire Bear Ribcage", "Dolphin", "Dolphin",
    	"Drogar", "Ectoplasm", "Elder Greatwood", "Elder Treant", "Elder Vine",
    	"Elderwood Log", "Falthorn", "Fiend", "Flax", "Frog Tongue", "Giant Boar Tusk",
    	"Giant Boar Tusk", "Goblin", "Goblin Champion", "Gralthar", "Heavy Leather",
    	"Hill Troll", "Honey", "Imp", "Intellect Rune", "Iron Ore", "King Mandrake",
    	"Lakewood Log", "Lesser Intellect Rune", "Lesser Stamina Rune",
    	"Lesser Strength Rune", "Light Leather", "Light Leather", "Lilyleaf",
    	"Lycanthar", "Mandrake Root", "Medium Leather", "Mithril Ore", "Moss",
    	"Mud Crab", "Oak Log", "Old Cup", "Panther", "Panther Claw", "Pine Log",
    	"Pineroot", "Pirahna", "Platinum Ore", "Purity", "Rat", "Rat Head",
    	"Rat King", "Rat Skin", "Raw Crocodile Meat", "Raw Deer Meat", "Raw Fish",
    	"Raw Panther Meat", "Raw Prime Meat", "Raw Serpent Meat", "Razor Fang",
    	"Ruby", "Rune Golem", "Salmon", "Sapphire", "Scorchleaf", "Seaweed",
    	"Serpent", "Serpent Fang", "Silver Ore", "Slime", "Slime Chunk", "Slime Core",
    	"Slime King", "Small Oak", "Spider", "Spider Carapace", "Spider Eye",
    	"Spider Gem", "Spider Leg", "Spider Mandible", "Spider Queen", "Spider Silk",
    	"Spirit Rune", "Stamina Rune", "Storm Caller", "Strength Rune", "Spider Queen",
    	"Thick Leather", "Troll Hide", "Vitalshroom", "Volcanic Ice",
    	"Volcanic Ice Shard", "Wolf", "Wolf Tooth", "Raw Boar Meat", "Cotton"
	}
	local sellLookup = {}
	for _, v in ipairs(sellItems) do
    	sellLookup[v] = true
	end

	while sellItemsEnabled do
    	local backpack = LocalPlayer:FindFirstChild("Backpack")
    	if backpack then
        	for _, tool in ipairs(backpack:GetChildren()) do
            	if tool:IsA("Tool") and sellLookup[tool.Name] then
                	local sellEvent = Character:FindFirstChild("CharacterHandler")
                    	and Character.CharacterHandler:FindFirstChild("Input")
                    	and Character.CharacterHandler.Input:FindFirstChild("Events")
                    	and Character.CharacterHandler.Input.Events:FindFirstChild("SellEvent")
                	if sellEvent then
                    	sellEvent:FireServer(tool)
                	end
            	end
        	end
    	end
    	task.wait(0.5)
	end
end

-- Function to dynamically lock the camera above the player's Head
local function lockCameraAbovePlayer()
    if cameraUpdateConnection then
        cameraUpdateConnection:Disconnect()
    end

    cameraUpdateConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local head = Character and Character:FindFirstChild("Head")
        if head then
            local cameraOffset = Vector3.new(0, 20, -10) -- 20 studs above and 10 studs behind the head
            local desiredPosition = head.Position + cameraOffset
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(desiredPosition, head.Position)
        else
            if cameraUpdateConnection then
                cameraUpdateConnection:Disconnect()
                cameraUpdateConnection = nil
            end
        end
    end)
end

-- Function to dynamically lock the camera above the player's Head
local function lockCameraAbovePlayer()
    if cameraUpdateConnection then
        cameraUpdateConnection:Disconnect()
    end

    cameraUpdateConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local head = Character and Character:FindFirstChild("Head")
        if head then
            local cameraOffset = Vector3.new(0, 20, -10) -- 20 studs above and 10 studs behind the head
            local desiredPosition = head.Position + cameraOffset
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(desiredPosition, head.Position)
        else
            -- Disconnect if the head is not found
            if cameraUpdateConnection then
                cameraUpdateConnection:Disconnect()
                cameraUpdateConnection = nil
            end
        end
    end)
end

-- Function to unlock the camera and restore default behavior
local function unlockCamera()
    if cameraUpdateConnection then
        cameraUpdateConnection:Disconnect()
        cameraUpdateConnection = nil
    end

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = game.Players.LocalPlayer.Character or game.Players.LocalPlayer
end

-- Extend the initializeCharacter function to include re-locking the camera
local function initializeCharacter()
    local player = game.Players.LocalPlayer
    Character = player.Character or player.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")

    -- Reapply the camera lock on respawn
    if autofarmEnabled then
        lockCameraAbovePlayer()
    end
end

-- Listen for character respawn events and reinitialize character references
local player = game.Players.LocalPlayer
player.CharacterAdded:Connect(function()
    task.defer(function()
        initializeCharacter()
    end)
end)

-- Function to start autofarm and lock the camera
StartAutofarm = function()
    autofarmEnabled = true -- Enable autofarm state

    -- Lock the camera in a static position above the player
    lockCameraAbovePlayer()

    -- Start the autofarm loops in parallel
    task.spawn(ClosestTargetLoop)
    task.spawn(InteractionLoop)
    task.spawn(KeyPressLoop)

    while autofarmEnabled do
        if RootPart and Character and Humanoid then
            -- Find the nearest target and move to it
            local targetPart = FindNearestTarget()
            if targetPart then
                moveToTargetConstantSpeed(targetPart)
            end
        end
        task.wait(0.25) -- Adjust the frequency of the loop
    end

    -- Unlock the camera when autofarm is disabled
    unlockCamera()
end

-- Function to stop autofarm and unlock the camera
StopAutofarm = function()
    autofarmEnabled = false -- Disable autofarm state
    unlockCamera()
end

-- Main Autofarm Loop
local lastResetTime = tick()

StartAutofarm = function()
    autofarmEnabled = true
    lockCameraAbovePlayer()

    task.spawn(ClosestTargetLoop)
    task.spawn(InteractionLoop)
    task.spawn(KeyPressLoop)

    while autofarmEnabled do
        if tick() - lastResetTime >= 30 then
            lastResetTime = tick()
        end

        if RootPart and Character and Humanoid then
            local targetPart = FindNearestTarget()
            if targetPart then
                moveToTargetConstantSpeed(targetPart)
            end
        end

        task.wait(0.25) -- Adjust the frequency of the loop
    end

    unlockCamera()
end

--==[ AUTOMOB ]==--

--==[ Variables ]==--
local automobTab = Window:CreateTab("AutoKill")
local mobAutofarmEnabled = false
local selectedTargets = {}
local activeKeywords = {}
local flightSpeed = 75
local verticalOffset = 2
local sellItemsEnabled = false

--==[ Update Active Keywords ]==--
local function updateActiveKeywords()
	activeKeywords = {}
	for keyword, enabled in pairs(selectedTargets) do
    	if enabled then
        	table.insert(activeKeywords, keyword:lower())
    	end
	end
end

--==[ UI Setup ]==--
automobTab:CreateSection("Settings")

automobTab:CreateToggle({
	Name = "Enable AutoKill",
	CurrentValue = false,
	Callback = function(val)
    	mobAutofarmEnabled = val
    	if val then StartMobAutofarm() end
	end,
})

automobTab:CreateSlider({
	Name = "Flight Speed",
	Range = {20, 100},
	Increment = 5,
	CurrentValue = 50,
	Callback = function(val)
    	flightSpeed = val
	end,
})

automobTab:CreateSlider({
	Name = "Vertical Offset (do not select 0)",
	Range = {-25, 25},
	Increment = 1,
	CurrentValue = 2,
	Callback = function(val)
    	verticalOffset = val
	end,
})

automobTab:CreateToggle({
	Name = "Sell Items",
	CurrentValue = false,
	Callback = function(val)
    	sellItemsEnabled = val
    	if val then StartSellingItems() end
	end,
})

local autoClickerEnabled = false

automobTab:CreateToggle({
	Name = "Auto Attack (beta)",
	CurrentValue = false,
	Callback = function(val)
    	autoClickerEnabled = val
    	if val then
        	StartAutoClicker()
    	end
	end,
})

automobTab:CreateSection("Mobs")
local targetTypes = {
"Adult Spider", "Amphithere", "Baracuda", "Banshee", "Bear",
"Beaver", "Bee", "Big Bee", "Black Ooze Slime", "Boar",
"Braelor", "Crocodile", "Deer", "Fiend", "Goblin Rogue",
"Goblin Scout", "Goblin Warrior", "Gralthar", "Hill Troll", "Imp",
"Mandrake", "Mud Crab", "Panther", "Rat", "Serpent",
"Slime", "Spider", "Storm Caller", "Wolf"
}

for _, target in ipairs(targetTypes) do
	automobTab:CreateToggle({
    	Name = "Target: " .. target,
    	CurrentValue = false,
    	Callback = function(val)
        	selectedTargets[target] = val or nil
        	updateActiveKeywords()
    	end,
	})
end

automobTab:CreateSection("Boss Mobs")
local targetBossTypes = {
	"Basilisk", "Dire Bear", "Drogar", "Elder Treant", "Goblin Champion",
"Lycanthar", "Mandrake King", "Mother Spider", "Rat King", "Razor Fang",
"Rune Golem", "Slime King", "Vampiric Dragon Lord"
}

for _, target in ipairs(targetBossTypes) do
	automobTab:CreateToggle({
    	Name = "Target: " .. target,
    	CurrentValue = false,
    	Callback = function(val)
        	selectedTargets[target] = val or nil
        	updateActiveKeywords()
    	end,
	})
end

--==[ Services & References ]==--
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	Character = LocalPlayer.Character
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
end)

--==[ Mob Cache ]==--
local AliveFolder = workspace:FindFirstChild("Alive")
local mobCache = {}

local function updateMobCache()
	if AliveFolder then
    	mobCache = AliveFolder:GetChildren()
	end
end

if AliveFolder then
	AliveFolder.ChildAdded:Connect(function(child)
    	table.insert(mobCache, child)
	end)
	AliveFolder.ChildRemoved:Connect(function(child)
    	for i, v in ipairs(mobCache) do
        	if v == child then table.remove(mobCache, i) break end
    	end
	end)
	updateMobCache()
end

--==[ Helpers ]==--
local function GetTargetPart(obj)
	if obj:IsA("Model") then
    	return obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
	elseif obj:IsA("BasePart") then
    	return obj
	end
	return nil
end

local function FindNearestTarget()
	local nearest, shortestDist = nil, math.huge
	if not RootPart then return nil end
	local rootPos = RootPart.Position

	for _, obj in ipairs(mobCache) do
    	-- Skip mobs that have the "MinExp" attribute
    	if obj:GetAttribute("MinExp") then
        	continue
    	end

    	local part = GetTargetPart(obj)
    	if part then
        	local objName = obj.Name:lower()
        	for _, keyword in ipairs(activeKeywords) do
            	if string.find(objName, keyword) then
                	local dist = (rootPos - part.Position).Magnitude
                	if dist < shortestDist then
                    	nearest = part
                    	shortestDist = dist
                	end
            	end
        	end
    	end
	end
	return nearest
end

local function moveToTargetConstantSpeed(part)
	if not part or not RootPart then return end

	local lastTargetPos = nil

	-- Lock camera to player
	Camera.CameraSubject = RootPart

	while mobAutofarmEnabled and part.Parent and RootPart and Character and Humanoid do
    	local desiredPos = part.Position + Vector3.new(0, verticalOffset, 0)
    	local currentPos = RootPart.Position
    	local direction = (desiredPos - currentPos)
    	local distance = direction.Magnitude

    	-- Calculate movement step
    	local dt = RunService.Heartbeat:Wait()
    	local step = flightSpeed * dt

    	-- Always move a small amount toward destination, even if already close
    	local newPos
    	if distance > 0.1 then
        	local moveVec = direction.Unit * math.min(step, distance)
        	newPos = currentPos + moveVec
    	else
        	-- Force reapply same position to suppress gravity
        	newPos = desiredPos
    	end

    	-- Face the mob
    	local faceDir = (part.Position - newPos).Unit
    	RootPart.CFrame = CFrame.new(newPos, newPos + faceDir)

    	-- Ensure Noclip always remains on
    	for _, p in ipairs(Character:GetDescendants()) do
        	if p:IsA("BasePart") then
            	p.CanCollide = false
        	end
    	end
	end
end

--==[ Sell Items Loop ]==--
StartSellingItems = function()
	local sellItems = {
    	"Agility Rune", "Amber", "Amphithere", "Amphithere Feather", "Ancient Demon",
    	"Animal Heart", "Apple", "Ashwood Log", "Bahlstalk", "Banshee", "Basilisk",
    	"Basilisk Skin", "Bass", "Bear", "Beehive", "Black Bass", "Black Ooze Chunk",
    	"Black Ooze Slime", "Boar", "Braelor", "Carapace", "Carapace", "Contractor",
    	"Copper Ore", "Crocodile", "Deer", "Demon Heart", "Demon Hide", "Dire Bear",
    	"Dire Bear Claw", "Dire Bear Hide", "Dire Bear Ribcage", "Dolphin", "Dolphin",
    	"Drogar", "Ectoplasm", "Elder Greatwood", "Elder Treant", "Elder Vine",
    	"Elderwood Log", "Falthorn", "Fiend", "Flax", "Frog Tongue", "Giant Boar Tusk",
    	"Giant Boar Tusk", "Goblin", "Goblin Champion", "Gralthar", "Heavy Leather",
    	"Hill Troll", "Honey", "Imp", "Intellect Rune", "Iron Ore", "King Mandrake",
    	"Lakewood Log", "Lesser Intellect Rune", "Lesser Stamina Rune",
    	"Lesser Strength Rune", "Light Leather", "Light Leather", "Lilyleaf",
    	"Lycanthar", "Mandrake Root", "Medium Leather", "Mithril Ore", "Moss",
    	"Mud Crab", "Oak Log", "Old Cup", "Panther", "Panther Claw", "Pine Log",
    	"Pineroot", "Pirahna", "Platinum Ore", "Purity", "Rat", "Rat Head",
    	"Rat King", "Rat Skin", "Raw Crocodile Meat", "Raw Deer Meat", "Raw Fish",
    	"Raw Panther Meat", "Raw Prime Meat", "Raw Serpent Meat", "Razor Fang",
    	"Ruby", "Rune Golem", "Salmon", "Sapphire", "Scorchleaf", "Seaweed",
    	"Serpent", "Serpent Fang", "Silver Ore", "Slime", "Slime Chunk", "Slime Core",
    	"Slime King", "Small Oak", "Spider", "Spider Carapace", "Spider Eye",
    	"Spider Gem", "Spider Leg", "Spider Mandible", "Spider Queen", "Spider Silk",
    	"Spirit Rune", "Stamina Rune", "Storm Caller", "Strength Rune", "Spider Queen",
    	"Thick Leather", "Troll Hide", "Vitalshroom", "Volcanic Ice",
    	"Volcanic Ice Shard", "Wolf", "Wolf Tooth", "Raw Boar Meat", "Cotton", 
	}
	local sellLookup = {}
	for _, v in ipairs(sellItems) do sellLookup[v] = true end

	while sellItemsEnabled do
    	local backpack = LocalPlayer:FindFirstChild("Backpack")
    	if backpack then
        	for _, tool in ipairs(backpack:GetChildren()) do
            	if tool:IsA("Tool") and sellLookup[tool.Name] then
                	local sellEvent = Character:FindFirstChild("CharacterHandler")
                    	and Character.CharacterHandler:FindFirstChild("Input")
                    	and Character.CharacterHandler.Input:FindFirstChild("Events")
                    	and Character.CharacterHandler.Input.Events:FindFirstChild("SellEvent")
                	if sellEvent then
                    	sellEvent:FireServer(tool)
                	end
            	end
        	end
    	end
    	task.wait(0.5)
	end
end

--==[ Start Autofarm ]==--
local lastResetTime = tick() -- Timestamp of the last reset

StartMobAutofarm = function()
	while mobAutofarmEnabled do
    	-- Reset the target every 30 seconds
    	if tick() - lastResetTime >= 10 then
        	lastResetTime = tick()  -- Update the reset time
    	end

    	if RootPart and Character and Humanoid then
        	local targetPart = FindNearestTarget()
        	if targetPart then
            	moveToTargetConstantSpeed(targetPart)
        	else
            	Camera.CameraSubject = RootPart
        	end
    	end
    	task.wait(0.25)
	end
	Camera.CameraSubject = Humanoid
end

local VirtualInputManager = game:GetService("VirtualInputManager")

StartAutoClicker = function()
	coroutine.wrap(function()
    	while autoClickerEnabled do
        	local nearestTarget = FindNearestTarget()
        	if nearestTarget and RootPart then
            	local distance = (nearestTarget.Position - RootPart.Position).Magnitude
            	if distance <= 25 then
                	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            	end
        	end
        	task.wait(0.2)
    	end
	end)()
end

--COMBAT TAB--

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")


local CombatTab = Window:CreateTab("Combat")

-- Configuration
local detectionRadius = 30
local monitoredMobs = {}
local AutoParryEnabled = false
local FaceSourceEnabled = false
local lockDuration = 0.6 -- Duration (in seconds) to lock on the mob
local isLocked = false   -- State to prevent immediate repeated locking


local AttackAnimations = {

	["Absorb"] = {
    	"rbxassetid://18187288231",
	},

	["Action"] = {
    	"rbxassetid://17593571953",
	},

	["Attack"] = {
    	"rbxassetid://12845378288",
    	"rbxassetid://13307649187",
    	"rbxassetid://13311696639",
    	"rbxassetid://13837626742",
    	"rbxassetid://13980101679",
    	"rbxassetid://14137493381",
    	"rbxassetid://14139806172",
    	"rbxassetid://14379649100",
    	"rbxassetid://14431331575",
    	"rbxassetid://14480058780",
    	"rbxassetid://14533902841",
    	"rbxassetid://14566786497",
    	"rbxassetid://14571012422",
    	"rbxassetid://14619672243",
    	"rbxassetid://14699431275",
    	"rbxassetid://14706677261",
    	"rbxassetid://14886832498",
    	"rbxassetid://14894681018",
    	"rbxassetid://15003188623",
    	"rbxassetid://15134813843",
    	"rbxassetid://15214523028",
    	"rbxassetid://15297001570",
    	"rbxassetid://15297971385",
    	"rbxassetid://15399067354",
    	"rbxassetid://15443689941",
    	"rbxassetid://15689660145",
    	"rbxassetid://15727553853",
    	"rbxassetid://15761938856",
    	"rbxassetid://17083997180",
    	"rbxassetid://17141284782",
    	"rbxassetid://17205391052",
	},

	["Attack(2)"] = {
    	"rbxassetid://14139858370",
    	"rbxassetid://17083998981",
	},

	["Attack2"] = {
    	"rbxassetid://12845642828",
    	"rbxassetid://13307681826",
    	"rbxassetid://13837736752",
    	"rbxassetid://13984524915",
    	"rbxassetid://14137748840",
    	"rbxassetid://14139905000",
    	"rbxassetid://14431347126",
    	"rbxassetid://14481523170",
    	"rbxassetid://14534216662",
    	"rbxassetid://14566843031",
    	"rbxassetid://14620854834",
    	"rbxassetid://14706694667",
    	"rbxassetid://14886897726",
    	"rbxassetid://14894698913",
    	"rbxassetid://15003270957",
    	"rbxassetid://15134955010",
    	"rbxassetid://15214570612",
    	"rbxassetid://15297031875",
    	"rbxassetid://15297987460",
    	"rbxassetid://15399312584",
    	"rbxassetid://15689699463",
    	"rbxassetid://15727664942",
    	"rbxassetid://15762508824",
    	"rbxassetid://17084000275",
    	"rbxassetid://17141293456",
    	"rbxassetid://17205395938",
	},

	["Attack2(2)"] = {
    	"rbxassetid://14620865636",
	},

	["Attack3"] = {
    	"rbxassetid://12846628030",
    	"rbxassetid://13984806725",
    	"rbxassetid://14137785395",
    	"rbxassetid://14431381746",
    	"rbxassetid://14534382398",
    	"rbxassetid://14621851912",
    	"rbxassetid://14706743550",
    	"rbxassetid://14887593177",
    	"rbxassetid://14894710799",
    	"rbxassetid://15003435254",
    	"rbxassetid://15147336602",
    	"rbxassetid://15214658823",
    	"rbxassetid://15297056707",
    	"rbxassetid://15298084850",
    	"rbxassetid://15689735343",
    	"rbxassetid://15727774150",
    	"rbxassetid://15762685047",
    	"rbxassetid://17084001458",
    	"rbxassetid://17141295663",
    	"rbxassetid://17206216676",
	},

	["Attack3(2)"] = {
    	"rbxassetid://14138256143",
    	"rbxassetid://15297571467",
    	"rbxassetid://15728500435",
	},

	["Attack4"] = {
    	"rbxassetid://12855598895",
    	"rbxassetid://13984923525",
    	"rbxassetid://14138537118",
    	"rbxassetid://14442168395",
    	"rbxassetid://14534618423",
    	"rbxassetid://14622030598",
    	"rbxassetid://14715767169",
    	"rbxassetid://14887780810",
    	"rbxassetid://14894713887",
    	"rbxassetid://15003601140",
    	"rbxassetid://15147353462",
    	"rbxassetid://15214698472",
    	"rbxassetid://15297093697",
    	"rbxassetid://15298164813",
    	"rbxassetid://15689773756",
    	"rbxassetid://15729003317",
    	"rbxassetid://15763456548",
    	"rbxassetid://17084002950",
    	"rbxassetid://17141296967",
    	"rbxassetid://17206221145",
	},

	["Attack4(2)"] = {
    	"rbxassetid://14442359130",
	},

	["Attack5"] = {
    	"rbxassetid://13984956067",
    	"rbxassetid://14534450332",
    	"rbxassetid://14622042246",
    	"rbxassetid://14715871928",
    	"rbxassetid://14888911999",
    	"rbxassetid://15003725933",
    	"rbxassetid://15147609038",
    	"rbxassetid://15214852835",
    	"rbxassetid://15297152415",
    	"rbxassetid://15298189109",
    	"rbxassetid://15690780832",
    	"rbxassetid://15736174531",
    	"rbxassetid://15763507362",
    	"rbxassetid://17141300094",
    	"rbxassetid://17206237036",
	},

	["Attack5(2)"] = {
    	"rbxassetid://14888958609",
	},

	["Attack6"] = {
    	"rbxassetid://14040077970",
    	"rbxassetid://14535005075",
    	"rbxassetid://14622195047",
    	"rbxassetid://14727787593",
    	"rbxassetid://14889087499",
    	"rbxassetid://15003750099",
    	"rbxassetid://15147833538",
    	"rbxassetid://15214882684",
    	"rbxassetid://15297351175",
    	"rbxassetid://15298211724",
    	"rbxassetid://15697509559",
    	"rbxassetid://15736242384",
    	"rbxassetid://17141302015",
    	"rbxassetid://17206239713",
	},

	["Attack6(2)"] = {
    	"rbxassetid://15147857441",
    	"rbxassetid://15298233838",
    	"rbxassetid://15736462496",
	},

	["Attack7"] = {
    	"rbxassetid://14535761290",
    	"rbxassetid://14680761175",
    	"rbxassetid://14728765052",
    	"rbxassetid://14890884041",
    	"rbxassetid://15147881001",
    	"rbxassetid://15215365875",
    	"rbxassetid://15698379593",
    	"rbxassetid://15736547487",
    	"rbxassetid://17206241531",
	},

	["Attack7(2)"] = {
    	"rbxassetid://14680787618",
	},

	["Attack8"] = {
    	"rbxassetid://14729326590",
    	"rbxassetid://15147939807",
    	"rbxassetid://15698416537",
    	"rbxassetid://15736740870",
    	"rbxassetid://17206244641",
	},

	["Bash"] = {
    	"rbxassetid://18225033102",
    	"rbxassetid://18226362620",
	},

	["Beached"] = {
    	"rbxassetid://14429708742",
    	"rbxassetid://14431230740",
	},

	["Bite"] = {
    	"rbxassetid://133712885529956",
    	"rbxassetid://17705640667",
    	"rbxassetid://91853744986846",
	},

	["Charge"] = {
    	"rbxassetid://18225036551",
    	"rbxassetid://18226364547",
	},

	["Lunge"] = {
    	"rbxassetid://135624745187041",
	},

}

-- Flatten animation list for fast lookup
local attackAnimationIds = {}
for _, list in pairs(AttackAnimations) do
	for _, id in ipairs(list) do
    	attackAnimationIds[id] = true
	end
end

-- Simulate Parry
local function simulateParry()
	task.wait(0.2)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
	task.wait(0.45)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- Face the source of the animation without delays
local function faceSourceWithLock(mobPart)
    if FaceSourceEnabled and not isLocked then
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and mobPart then
            -- Instantly face the mob
            character.HumanoidRootPart.CFrame = CFrame.new(
                character.HumanoidRootPart.Position, 
                Vector3.new(mobPart.Position.X, character.HumanoidRootPart.Position.Y, mobPart.Position.Z)
            )

            -- Lock to prevent repeated adjustments
            isLocked = true
            task.delay(lockDuration, function()
                isLocked = false -- Unlock after the duration
            end)
        end
    end
end

-- Find best part for distance
local function getClosestValidPart(model)
    for _, partName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "Head"}) do
        local part = model:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

-- Monitor Mob
local function monitorMob(mob)
    if monitoredMobs[mob] then return end

    local humanoid = mob:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local animConnection = humanoid.AnimationPlayed:Connect(function(animTrack)
            if not AutoParryEnabled then return end
            local animId = animTrack.Animation and animTrack.Animation.AnimationId or ""
            if attackAnimationIds[animId] then
                local character = Players.LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local mobPart = getClosestValidPart(mob)
                   -- Inside monitorMob function:
if mobPart then
    local distance = (character.HumanoidRootPart.Position - mobPart.Position).Magnitude
    if distance <= detectionRadius then
        faceSourceWithLock(mobPart) -- Use the updated function with locking
        simulateParry()
    end
end

                end
            end
        end)

        mob.AncestryChanged:Connect(function(_, parent)
            if not parent and monitoredMobs[mob] then
                animConnection:Disconnect()
                monitoredMobs[mob] = nil
            end
        end)

        monitoredMobs[mob] = true
    end
end

-- Heartbeat Mob Scanner
RunService.Heartbeat:Connect(function()
    if not AutoParryEnabled then return end
    for _, mob in ipairs(Workspace.Alive:GetChildren()) do
        if not monitoredMobs[mob] then
            local mobPart = getClosestValidPart(mob)
            if mobPart and (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - mobPart.Position).Magnitude
                if distance <= detectionRadius then
                    monitorMob(mob)
                end
            end
        end
    end
end)

-- Rayfield Toggles
CombatTab:CreateToggle({
    Name = "AutoParry",
    CurrentValue = false,
    Callback = function(state)
        AutoParryEnabled = state
    end
})

CombatTab:CreateToggle({
    Name = "Face Mob",
    CurrentValue = false,
    Callback = function(state)
        FaceSourceEnabled = state
    end
})

local autoClick = false
local VirtualInputManager = game:GetService("VirtualInputManager")

CombatTab:CreateToggle({
	Name = "AutoAttack",
	CurrentValue = false,
	Flag = "AutoClickToggle",
	Callback = function(value)
    	autoClick = value
    	if autoClick then
        	while autoClick do
            	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            	task.wait(0.5)
        	end
    	end
	end
})

--// ESP TAB //
local ESPTab = Window:CreateTab("ESP")

--// ESP Variables
local espEnabled = false
local mobESPEnabled = false
local maxRange = 1000
local showNames = false
local showHealth = false
local showDistance = false
local showTracers = false

local playerESP = {}
local mobESP = {}

--// Utility
local function getDistance(a, b)
	if a and b then
    	return (a.Position - b.Position).Magnitude
	end
	return math.huge
end

--// Create ESP for Player or Mob
local function createESP(target, tableRef, isMob)
	if tableRef[target] then return end

	local targetHRP = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
	if not targetHRP then return end

	local localHRP = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if getDistance(localHRP, targetHRP) > maxRange then return end

	-- Highlight
	local highlight = Instance.new("Highlight")
	highlight.Name = isMob and "MobESP" or "PlayerESP"
	highlight.FillColor = isMob and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = target
	highlight.Parent = game.CoreGui

	-- Billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPBillboard"
	billboard.Size = UDim2.new(0, 100, 0, 18)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = target:FindFirstChild("Head") or target:FindFirstChildWhichIsA("BasePart")
	billboard.Parent = game.CoreGui

	local label = Instance.new("TextLabel", billboard)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.Text = ""

	tableRef[target] = {
    	Highlight = highlight,
    	Billboard = billboard,
    	Label = label,
    	Tracer = nil
	}
end

--// Remove ESP
local function removeESP(target, tableRef)
	local esp = tableRef[target]
	if esp then
    	if esp.Highlight then esp.Highlight:Destroy() end
    	if esp.Billboard then esp.Billboard:Destroy() end
    	if esp.Tracer then esp.Tracer:Remove() end
    	tableRef[target] = nil
	end
end

--// Update ESP Displays
local function updateESP()
	local localChar = game.Players.LocalPlayer.Character
	local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")

	-- Player ESP
	for _, player in ipairs(game.Players:GetPlayers()) do
    	if player ~= game.Players.LocalPlayer and not player:GetAttribute("InventoryLoaded") then
        	local char = player.Character
        	if espEnabled and char and getDistance(localHRP, char:FindFirstChild("HumanoidRootPart")) <= maxRange then
            	createESP(char, playerESP, false)

            	local data = playerESP[char]
            	if data and data.Label then
                	local info = {}
                	if showNames then table.insert(info, player.Name) end
                	if showHealth and char:FindFirstChildOfClass("Humanoid") then
                    	table.insert(info, "HP: " .. math.floor(char:FindFirstChildOfClass("Humanoid").Health))
                	end
                	if showDistance then
                    	table.insert(info, "Dist: " .. math.floor(getDistance(localHRP, char:FindFirstChild("HumanoidRootPart"))))
                	end
                	data.Label.Text = table.concat(info, " | ")
            	end

            	if showTracers then
                	if not data.Tracer then
                    	local line = Drawing.new("Line")
                    	line.Visible = true
                    	line.Color = Color3.new(1, 1, 1)
                    	line.Thickness = 1.5
                    	data.Tracer = line
                	end
                	local targetHRP = char:FindFirstChild("HumanoidRootPart")
                	if targetHRP then
                    	local from, onScreenFrom = workspace.CurrentCamera:WorldToViewportPoint(localHRP.Position)
                    	local to, onScreenTo = workspace.CurrentCamera:WorldToViewportPoint(targetHRP.Position)
                    	data.Tracer.Visible = onScreenFrom and onScreenTo
                    	if onScreenFrom and onScreenTo then
                        	data.Tracer.From = Vector2.new(from.X, from.Y)
                        	data.Tracer.To = Vector2.new(to.X, to.Y)
                    	end
                	end
            	elseif data.Tracer then
                	data.Tracer.Visible = false
            	end
        	else
            	removeESP(char, playerESP)
        	end
    	end
	end

	-- Mob ESP
	for _, mob in ipairs(workspace.Alive:GetChildren()) do
    	if mobESPEnabled and mob:IsA("Model") and not game.Players:GetPlayerFromCharacter(mob) then
        	local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        	if getDistance(localHRP, mobHRP) <= maxRange then
            	createESP(mob, mobESP, true)

            	local data = mobESP[mob]
            	if data and data.Label then
                	local info = {}
                	if showNames then table.insert(info, mob.Name) end
                	if showHealth and mob:FindFirstChildOfClass("Humanoid") then
                    	table.insert(info, "HP: " .. math.floor(mob:FindFirstChildOfClass("Humanoid").Health))
                	end
                	if showDistance then
                    	table.insert(info, "Dist: " .. math.floor(getDistance(localHRP, mobHRP)))
                	end
                	data.Label.Text = table.concat(info, " | ")
            	end

            	if showTracers then
                	if not data.Tracer then
                    	local line = Drawing.new("Line")
                    	line.Visible = true
                    	line.Color = Color3.new(1, 1, 1)
                    	line.Thickness = 1.5
                    	data.Tracer = line
                	end
                	if mobHRP then
                    	local from, onScreenFrom = workspace.CurrentCamera:WorldToViewportPoint(localHRP.Position)
                    	local to, onScreenTo = workspace.CurrentCamera:WorldToViewportPoint(mobHRP.Position)
                    	data.Tracer.Visible = onScreenFrom and onScreenTo
                    	if onScreenFrom and onScreenTo then
                        	data.Tracer.From = Vector2.new(from.X, from.Y)
                        	data.Tracer.To = Vector2.new(to.X, to.Y)
                    	end
                	end
            	elseif data.Tracer then
                	data.Tracer.Visible = false
            	end
        	else
            	removeESP(mob, mobESP)
        	end
    	end
	end
end

--// ESP Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
	if espEnabled or mobESPEnabled then
    	updateESP()
	end
end)

ESPTab:CreateSection("ESP")

--// Rayfield Controls
ESPTab:CreateToggle({
	Name = "Player ESP",
	CurrentValue = false,
	Flag = "PlayerESP",
	Callback = function(Value)
    	espEnabled = Value
    	if not Value then
        	for target in pairs(playerESP) do
            	removeESP(target, playerESP)
        	end
    	end
	end
})

ESPTab:CreateToggle({
	Name = "Mob ESP",
	CurrentValue = false,
	Flag = "MobESP",
	Callback = function(Value)
    	mobESPEnabled = Value
    	if not Value then
        	for target in pairs(mobESP) do
            	removeESP(target, mobESP)
        	end
    	end
	end
})

ESPTab:CreateSection("Settings")

ESPTab:CreateSlider({
	Name = "ESP Range",
	Range = {50, 5000},
	Increment = 50,
	Suffix = " studs",
	CurrentValue = maxRange,
	Flag = "ESPRANGE",
	Callback = function(Value)
    	maxRange = Value
	end
})

ESPTab:CreateToggle({
	Name = "Show NameTags",
	CurrentValue = false,
	Flag = "ShowNameTags",
	Callback = function(Value)
    	showNames = Value
	end
})

ESPTab:CreateToggle({
	Name = "Show Health",
	CurrentValue = false,
	Flag = "ShowHealth",
	Callback = function(Value)
    	showHealth = Value
	end
})

ESPTab:CreateToggle({
	Name = "Show Distance",
	CurrentValue = false,
	Flag = "ShowDistance",
	Callback = function(Value)
    	showDistance = Value
	end
})

ESPTab:CreateToggle({
	Name = "Enable Tracers",
	CurrentValue = false,
	Flag = "ShowTracers",
	Callback = function(Value)
    	showTracers = Value
	end
})
