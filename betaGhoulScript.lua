local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/newtoyotacamry/scripts/refs/heads/main/NoxHubUI'))()

Rayfield.Theme = {
    Default = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 200, 255),
    Background = Color3.fromRGB(25, 25, 25), 
    LightContrast = Color3.fromRGB(40, 40, 40), 
    DarkContrast = Color3.fromRGB(15, 15, 15), 
    TextColor = Color3.fromRGB(220, 220, 220),
    TextDark = Color3.fromRGB(170, 170, 170),
    CloseButtonBackground = Color3.fromRGB(50, 50, 50),
    CloseButtonAccent = Color3.fromRGB(255, 80, 80),
    TabBackground = Color3.fromRGB(30, 30, 30),
    TabStroke = Color3.fromRGB(80, 80, 80),
    SelectedTabBackground = Color3.fromRGB(45, 45, 45),
    SectionBackground = Color3.fromRGB(30, 30, 30),
    SectionStroke = Color3.fromRGB(80, 80, 80),
    Divider = Color3.fromRGB(60, 60, 60),
    InputBackground = Color3.fromRGB(35, 35, 35),
    DropdownBackground = Color3.fromRGB(35, 35, 35),
    DropdownAccent = Color3.fromRGB(0, 200, 255),
    SliderBackground = Color3.fromRGB(35, 35, 35),
    SliderAccent = Color3.fromRGB(0, 200, 255),
    ButtonBackground = Color3.fromRGB(40, 40, 40),
    ButtonAccent = Color3.fromRGB(0, 200, 255),
    ToggleBackground = Color3.fromRGB(35, 35, 35),
    ToggleAccent = Color3.fromRGB(0, 200, 255),
    ToggleOn = Color3.fromRGB(0, 255, 128), 
    ToggleOff = Color3.fromRGB(200, 60, 60), 
    KeybindBackground = Color3.fromRGB(35, 35, 35),
    KeybindAccent = Color3.fromRGB(0, 200, 255),
    NotificationBackground = Color3.fromRGB(30, 30, 30),
    NotificationText = Color3.fromRGB(220, 220, 220),
}

local Window = Rayfield:CreateWindow({
    Name = "Ghoul://RE | NoxHub",
    LoadingTitle = "Loading Ghoul://RE...",
    LoadingSubtitle = "NoxHub | Premium Scripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NoxHub",
    }
})

local MainTab = Window:CreateTab("Ghoul://RE", "home")

local function loadSecureScript(url)
    _G.NoxTrigger = { __NoxHubAuthorized = true }

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        Rayfield:Notify({ Title = "❌ Load Error", Content = "Failed to fetch script.", Duration = 5 })
        return
    end

    local func, err = loadstring(response)
    if not func then
        Rayfield:Notify({ Title = "❌ Compile Error", Content = err, Duration = 5 })
        return
    end

    local ok, execErr = pcall(function()
        local returned = func()
        if type(returned) == "function" then
            returned()
        end
    end)

    if not ok then
        Rayfield:Notify({ Title = "❌ Runtime Error", Content = execErr, Duration = 5 })
        return
    end

    Rayfield:Notify({ Title = "✅ Success", Content = "Script loaded securely.", Duration = 4 })
end

-- === Buttons ===
MainTab:CreateSection("Load NoxHub")

MainTab:CreateButton({
    Name = "Load Ghoul://RE Main",
    Callback = function()
        loadSecureScript("https://raw.githubusercontent.com/newtoyotacamry/scripts/refs/heads/main/betaGhoulREMain")
    end
})

MainTab:CreateButton({
    Name = "Load Ghoul://RE AutoFarm",
    Callback = function()
        loadSecureScript("https://raw.githubusercontent.com/newtoyotacamry/scripts/refs/heads/main/betaGhoulREAuto")
    end
})

-- === Toggles ===
MainTab:CreateSection("AutoExec")

MainTab:CreateToggle({
    Name = "AutoLoad Ghoul://RE Main",
    Flag = "autoMain",
    CurrentValue = false,
    Callback = function(state)
        if state then
            wait(1)
            loadSecureScript("https://raw.githubusercontent.com/newtoyotacamry/scripts/refs/heads/main/betaGhoulREMain")
        end
    end
})

MainTab:CreateToggle({
    Name = "AutoLoad Ghoul://RE AutoFarm",
    Flag = "autoAutoFarm",
    CurrentValue = false,
    Callback = function(state)
        if state then
            wait(1)
            loadSecureScript("https://raw.githubusercontent.com/newtoyotacamry/scripts/refs/heads/main/betaGhoulREAuto")
        end
    end
})

loadstring(game:HttpGet('https://raw.githubusercontent.com/newtoyotacamry/scripts/refs/heads/main/ghoulScanner.lua'))()

Rayfield:LoadConfiguration()

