local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local function getSafeScreenCoordinates()
    local screenSize = camera.ViewportSize
    local centerX, centerY = screenSize.X / 2, screenSize.Y / 2

    local function getCoord(minEdge, maxEdge, center, avoidRange)
        local coord
        repeat
            coord = math.random(minEdge, maxEdge)
        until math.abs(coord - center) > avoidRange
        return coord
    end

    local safeX = getCoord(0, screenSize.X, centerX, screenSize.X * 0.2)
    local safeY = getCoord(0, screenSize.Y, centerY, screenSize.Y * 0.2)
    return safeX, safeY
end
task.spawn(function()
    while true do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not char or not hrp then
            if camera then
                local x, y = getSafeScreenCoordinates()
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            end
        end
        task.wait(1)
    end
end)
