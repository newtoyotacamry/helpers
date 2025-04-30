-- Webhook Configuration
local url = "https://api.botghost.com/webhook/1349573134407438438/wjfwo2f4vyrhd803p9026"
local apiKey = "05c5187fefaf41080d936c37c747deff3bd42cbad42ae186b87303dfd0cadc88"

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- HTTP Request Function
local requestFunction = (syn and syn.request) or (http and http.request) or (http_request) or (request)
if not requestFunction then return end

-- Helpers
local postedPlayers = {}
local function formatNumber(num)
    return tostring(math.floor(num + 0.5)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end
local function fetchHeadshot(userId)
    local url = ("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&format=Png&size=420x420"):format(userId)
    local response = requestFunction({ Url = url, Method = "GET", Headers = {["Content-Type"] = "application/json"} })
    if response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.data and data.data[1] and data.data[1].imageUrl then
            return data.data[1].imageUrl
        end
    end
    return "NoImageFound"
end
local function getServerData()
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local getServerList = remotes:WaitForChild("GetServerList")
    local success, servers = pcall(function() return getServerList:InvokeServer("all") end)
    if not success or not servers then return nil end
    for _, serverData in pairs(servers) do
        if typeof(serverData) == "table" and tostring(serverData.JobID) == tostring(game.JobId) then
            return serverData
        end
    end
    return nil
end

-- Cooldown Tracker
local POST_COOLDOWN_SECONDS = 60
local lastPostTimestamps = {
    Artifact = 0,
    Capture = 0,
    TurfControl = 0,
    BirdCage = 0
}

-- RC Cell Detection
task.spawn(function()
    while task.wait(3) do
        local entities = Workspace:FindFirstChild("Entities")
        if not entities then continue end
        for _, entity in ipairs(entities:GetChildren()) do
            if entity:IsA("Model") then
                local rc = entity:GetAttribute("RCCells") or 0
                local playerName = entity.Name
                local playerObj = Players:FindFirstChild(playerName)
                if playerObj and playerObj ~= Players.LocalPlayer and not postedPlayers[playerObj.UserId] then
                    local is1MPlayer = rc >= 1000000 and rc < 5000000
                    local is5MPlayer = rc >= 5000000
                    if is1MPlayer or is5MPlayer then
                        local race = entity:GetAttribute("Race") or "Unknown"
                        local weapon = entity:GetAttribute("WeaponType") or "Unknown"
                        local health = math.floor(entity:FindFirstChild("Humanoid") and entity.Humanoid.Health or 0)
                        local maxHealth = math.floor(entity:FindFirstChild("Humanoid") and entity.Humanoid.MaxHealth or 0)
                        local pos = entity:FindFirstChild("HumanoidRootPart") and entity.HumanoidRootPart.Position or Vector3.zero
                        local location = string.format("X: %d, Y: %d, Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
                        local serverData = getServerData()
                        local jobId = serverData and serverData.JobID or game.JobId
                        local placeId = serverData and serverData.PlaceID or game.PlaceId
                        local body = {
                            variables = {
                                { name = "username", value = playerObj.Name },
                                { name = "rc", value = formatNumber(rc) },
                                { name = "race", value = race },
                                { name = "weapon", value = weapon },
                                { name = "health", value = tostring(health) },
                                { name = "maxhealth", value = tostring(maxHealth) },
                                { name = "servername", value = serverData and serverData.ServerName or "Unknown Server" },
                                { name = "serverregion", value = serverData and serverData.ServerRegion or "Unknown Region" },
                                { name = "serverplayers", value = tostring(serverData and serverData.ServerPlayers or "N/A") },
                                { name = "serverplayermax", value = tostring(serverData and serverData.ServerPlayerMax or "N/A") },
                                { name = "serverpermadeath", value = tostring(serverData and serverData.Permadeath or "false") },
                                { name = "timestamp", value = tostring(os.time()) },
                                { name = "avatarheadshot", value = fetchHeadshot(playerObj.UserId) },
                                { name = "location", value = location },
                                { name = "join_script", value = string.format([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game.Players.LocalPlayer)]], placeId, jobId) },
                                { name = "1mplayer", value = tostring(is1MPlayer) },
                                { name = "5mplayer", value = tostring(is5MPlayer) },
                            }
                        }
                        local response = requestFunction({
                            Url = url,
                            Method = "POST",
                            Headers = { ["Authorization"] = apiKey, ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode(body)
                        })
                        if response.StatusCode == 200 then
                            postedPlayers[playerObj.UserId] = true
                        end
                    end
                end
            end
        end
    end
end)

-- Shared Event Function
local function postEvent(eventKey, eventName)
    local serverData = getServerData()
    local jobId = serverData and serverData.JobID or game.JobId
    local placeId = serverData and serverData.PlaceID or game.PlaceId
    local now = os.time()
    lastPostTimestamps[eventKey] = now
    local body = {
        variables = {
            { name = "event", value = eventName },
            { name = "servername", value = serverData and serverData.ServerName or "Unknown Server" },
            { name = "serverregion", value = serverData and serverData.ServerRegion or "Unknown Region" },
            { name = "timestamp", value = tostring(now) },
            { name = "join_script", value = string.format([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game.Players.LocalPlayer)]], placeId, jobId) },
        }
    }
    requestFunction({
        Url = url,
        Method = "POST",
        Headers = { ["Authorization"] = apiKey, ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(body)
    })
end

-- Artifact Event
local lastArtifactStatus = false
task.spawn(function()
    while task.wait(5) do
        local found = false
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and string.find(obj.Name, "Artifact") then
                found = true
                break
            end
        end
        if found and not lastArtifactStatus and os.time() - lastPostTimestamps.Artifact >= POST_COOLDOWN_SECONDS then
            postEvent("Artifact", "Artifact Event")
        end
        lastArtifactStatus = found
    end
end)

-- Capture Event
local lastCaptureStatus = false
task.spawn(function()
    while task.wait(5) do
        local debris = Workspace:FindFirstChild("DebrisFolder")
        local found = false
        if debris then
            for _, obj in ipairs(debris:GetChildren()) do
                if obj:IsA("Model") and obj.Name ~= "TurfControlPart" then
                    found = true
                    break
                end
            end
        end
        if found and not lastCaptureStatus and os.time() - lastPostTimestamps.Capture >= POST_COOLDOWN_SECONDS then
            postEvent("Capture", "Capture Event")
        end
        lastCaptureStatus = found
    end
end)

-- Turf Control Event
local lastTurfControlStatus = false
task.spawn(function()
    while task.wait(5) do
        local debris = Workspace:FindFirstChild("DebrisFolder")
        local found = false
        if debris then
            for _, obj in ipairs(debris:GetChildren()) do
                if obj:IsA("Model") and obj.Name == "TurfControlPart" then
                    found = true
                    break
                end
            end
        end
        if found and not lastTurfControlStatus and os.time() - lastPostTimestamps.TurfControl >= POST_COOLDOWN_SECONDS then
            postEvent("TurfControl", "Turf Control Event")
        end
        lastTurfControlStatus = found
    end
end)

-- Bird Cage Event
local lastBirdCageStatus = false
task.spawn(function()
    while task.wait(5) do
        local matchDuration = Workspace:GetAttribute("MatchDuration")
        local isActive = matchDuration and matchDuration > 1
        if isActive and not lastBirdCageStatus and os.time() - lastPostTimestamps.BirdCage >= POST_COOLDOWN_SECONDS then
            postEvent("BirdCage", "BirdCage Event")
        end
        lastBirdCageStatus = isActive
    end
end)
