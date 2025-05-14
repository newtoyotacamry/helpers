local Players = game:GetService("Players")
local VI      = game:GetService("VirtualInputManager")
local player  = Players.LocalPlayer

local function sendKey(k)
    VI:SendKeyEvent(true,  k, false, game)
    task.wait(0.05)
    VI:SendKeyEvent(false, k, false, game)
end

local lastTimes = {
    continue = 0,
    slot     = 0,
    dungeon  = 0,
    enter    = 0,
}

spawn(function()
    while true do
        local now = tick()
        local gui = player:FindFirstChild("PlayerGui")

        local l2 = gui and gui:FindFirstChild("LoadingGUI2")
        if l2 then
            local c = l2:FindFirstChild("ContinueButton")
            if c and c.Visible and now - lastTimes.continue >= 10 then
                sendKey(Enum.KeyCode.BackSlash); task.wait(0.1)
                sendKey(Enum.KeyCode.Down);      task.wait(0.1)
                sendKey(Enum.KeyCode.Down);      task.wait(0.1)
                sendKey(Enum.KeyCode.Down);      task.wait(0.1)
                sendKey(Enum.KeyCode.Return)
                lastTimes.continue = now
            end
        end

        local sg = gui and gui:FindFirstChild("SlotGUI")
        if sg and sg.Enabled and now - lastTimes.slot >= 10 then
            sendKey(Enum.KeyCode.BackSlash); task.wait(0.1)
            sendKey(Enum.KeyCode.Down);      task.wait(0.1)
            sendKey(Enum.KeyCode.Return)
            lastTimes.slot = now
        end

        if l2 then
            local d = l2:FindFirstChild("DungeonButton")
            if d and d.Visible and now - lastTimes.dungeon >= 10 then
                sendKey(Enum.KeyCode.BackSlash); task.wait(0.1)
                sendKey(Enum.KeyCode.Down);      task.wait(0.1)
                sendKey(Enum.KeyCode.Down);      task.wait(0.1)
                sendKey(Enum.KeyCode.Down);      task.wait(0.1)
                sendKey(Enum.KeyCode.Return)
                lastTimes.dungeon = now
            end
        end

        local du = gui and gui:FindFirstChild("DungeonsUI")
        local eb = du
                   and du:FindFirstChild("HoldFrame")
                   and du.HoldFrame:FindFirstChild("EnterButton")
        if eb and eb.Visible and now - lastTimes.enter >= 10 then
            sendKey(Enum.KeyCode.BackSlash); task.wait(0.1)
            sendKey(Enum.KeyCode.Down);      task.wait(0.1)
            sendKey(Enum.KeyCode.Return)
            lastTimes.enter = now
        end

        task.wait(0.1)
    end
end)
