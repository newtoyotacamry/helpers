local url = "https://api.botghost.com/webhook/1349573134407438438/wjfwo2f4vyrhd803p9026"
local apiKey = "05c5187fefaf41080d936c37c747deff3bd42cbad42ae186b87303dfd0cadc88"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local requestFunction = (syn and syn.request) or (http and http.request) or (http_request) or (request)
if not requestFunction then
    return
end
local postedPlayers = {}
local function formatNumber(num)
    return tostring(math.floor(num + 0.5)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end
local function fetchHeadshot(userId)
    local thumbnailsApiUrl = ("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&format=Png&size=420x420"):format(userId)
    local headshotURL = nil

    local response = requestFunction({
        Url = thumbnailsApiUrl,
        Method = "GET",
        Headers = {["Content-Type"] = "application/json"}
    })

    if response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.data and data.data[1] and data.data[1].imageUrl then
            headshotURL = data.data[1].imageUrl
        end
    end

    return headshotURL
end
local function getServerData()
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local getServerList = remotes:WaitForChild("GetServerList")
    local servers
    local currentServer
    local success, result = pcall(function()
        return getServerList:InvokeServer("all")
    end)
    if success and result then
        servers = result
    else
        return nil
    end
    for uuid, serverData in pairs(servers) do
        if typeof(serverData) == "table" and tostring(serverData.JobID) == tostring(game.JobId) then
            currentServer = serverData
            break
        end
    end
    return currentServer
end
task.spawn(function()
    while task.wait(3) do -- every 3 seconds
        local entities = Workspace:FindFirstChild("Entities")
        if not entities then continue end
        for _, entity in ipairs(entities:GetChildren()) do
            if entity:IsA("Model") then
                local rc = entity:GetAttribute("RCCells") or 0
                local playerName = entity.Name
                local playerObj = Players:FindFirstChild(playerName)
                if playerObj and playerObj ~= Players.LocalPlayer then
                    local alreadyPosted = postedPlayers[playerObj.UserId]
                    if not alreadyPosted then
                        local is1MPlayer = rc >= 1000000 and rc < 5000000
                        local is5MPlayer = rc >= 5000000
                        if is1MPlayer or is5MPlayer then
                            local username = playerObj.Name
                            local race = entity:GetAttribute("Race") or "Unknown"
                            local weapon = entity:GetAttribute("WeaponType") or "Unknown"
                            local health = (entity:FindFirstChild("Humanoid") and math.floor(entity.Humanoid.Health)) or 0
                            local maxHealth = (entity:FindFirstChild("Humanoid") and math.floor(entity.Humanoid.MaxHealth)) or 0
                            local location = "Unknown"
                            local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                local pos = humanoidRootPart.Position
                                location = string.format("X: %d, Y: %d, Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
                            end
                            local serverData = getServerData()
                            local serverName = serverData and serverData.ServerName or "Unknown Server"
                            local serverRegion = serverData and serverData.ServerRegion or "Unknown Region"
                            local serverPlayers = serverData and tostring(serverData.ServerPlayers) or "N/A"
                            local serverPlayerMax = serverData and tostring(serverData.ServerPlayerMax) or "N/A"
                            local serverPermadeath = serverData and tostring(serverData.Permadeath) or "false"
                            local jobId = serverData and tostring(serverData.JobID) or tostring(game.JobId)
                            local placeId = serverData and tostring(serverData.PlaceID) or tostring(game.PlaceId)
                            local joinScript = ([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game.Players.LocalPlayer)]])
                                :format(placeId, jobId)
                            local avatarHeadshot = fetchHeadshot(playerObj.UserId) or "NoImageFound"
                            local unixTimestamp = os.time()
                            local body = {
                                variables = {
                                    { name = "username", variable = "{username}", value = username },
                                    { name = "rc", variable = "{rc}", value = formatNumber(rc) },
                                    { name = "race", variable = "{race}", value = race },
                                    { name = "weapon", variable = "{weapon}", value = weapon },
                                    { name = "health", variable = "{health}", value = tostring(health) },
                                    { name = "maxhealth", variable = "{maxhealth}", value = tostring(maxHealth) },
                                    { name = "servername", variable = "{servername}", value = serverName },
                                    { name = "serverregion", variable = "{serverregion}", value = serverRegion },
                                    { name = "serverplayers", variable = "{serverplayers}", value = serverPlayers },
                                    { name = "serverplayermax", variable = "{serverplayermax}", value = serverPlayerMax },
                                    { name = "serverpermadeath", variable = "{serverpermadeath}", value = serverPermadeath },
                                    { name = "timestamp", variable = "{timestamp}", value = tostring(unixTimestamp) },
                                    { name = "avatarheadshot", variable = "{avatarheadshot}", value = avatarHeadshot },
                                    { name = "location", variable = "{location}", value = location },
                                    { name = "join_script", variable = "{join_script}", value = joinScript },
                                    { name = "1mplayer", variable = "{1mplayer}", value = tostring(is1MPlayer) },
                                    { name = "5mplayer", variable = "{5mplayer}", value = tostring(is5MPlayer) },
                                }
                            }
                            local webhookData = {
                                Url = url,
                                Method = "POST",
                                Headers = {
                                    ["Authorization"] = apiKey,
                                    ["Content-Type"] = "application/json"
                                },
                                Body = HttpService:JSONEncode(body)
                            }
                            local webhookResponse = requestFunction(webhookData)
                            if webhookResponse.StatusCode == 200 then
                                postedPlayers[playerObj.UserId] = true
                            end
                        end
                    end
                end
            end
        end
    end
end)

local requestFunction = (syn and syn.request) or (http and http.request) or (http_request) or (request)
if not requestFunction then return end

local function getServerData()
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local getServerList = remotes:WaitForChild("GetServerList")
    local success, result = pcall(function()
        return getServerList:InvokeServer("all")
    end)
    if not success or not result then return nil end
    for _, serverData in pairs(result) do
        if typeof(serverData) == "table" and tostring(serverData.JobID) == tostring(game.JobId) then
            return serverData
        end
    end
    return nil
end

local function isArtifactEvent()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and string.find(obj.Name, "Artifact") then
            return true
        end
    end
    return false
end

local function isCaptureEvent()
    local folder = Workspace:FindFirstChild("DebrisFolder") or Workspace:FindFirstChild("Debris")
    if not folder then return false end
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("Model") and obj.Name ~= "TurfControlPart" then
            return true
        end
    end
    return false
end

local function isTurfControlEvent()
    local folder = Workspace:FindFirstChild("DebrisFolder") or Workspace:FindFirstChild("Debris")
    if not folder then return false end
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "TurfControlPart" then
            return true
        end
    end
    return false
end

local function isBirdCageEvent()
    local attr = Workspace:GetAttribute("MatchDuration")
    return (typeof(attr) == "number" and attr > 1)
end

local function isBloodCrownEvent()
    local attr = Workspace:GetAttribute("BloodCrownDuration")
    return (typeof(attr) == "number" and attr > 0)
end

local lastPostTime = 0
local POST_INTERVAL = 10

task.spawn(function()
    while true do
        task.wait(POST_INTERVAL)
        local now = os.time()
        if now - lastPostTime < POST_INTERVAL then continue end
        lastPostTime = now

        local serverData = getServerData()
        local serverName = serverData and serverData.ServerName or "Unknown Server"
        local serverRegion = serverData and serverData.ServerRegion or "Unknown Region"
        local jobId = serverData and tostring(serverData.JobID) or tostring(game.JobId)
        local placeId = serverData and tostring(serverData.PlaceID) or tostring(game.PlaceId)
        local joinScript = ([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game.Players.LocalPlayer)]])
            :format(placeId, jobId)
        local unixTimestamp = os.time()

local body = {
    variables = {
        { name = "artifact_event", variable = "{artifact_event}", value = tostring(isArtifactEvent()) },
        { name = "capture_event", variable = "{capture_event}", value = tostring(isCaptureEvent()) },
        { name = "turf_control_event", variable = "{turf_control_event}", value = tostring(isTurfControlEvent()) },
        { name = "birdcage_event", variable = "{birdcage_event}", value = tostring(isBirdCageEvent()) },
        { name = "bloodcrown_event", variable = "{bloodcrown_event}", value = tostring(isBloodCrownEvent()) },
        { name = "servername", variable = "{servername}", value = serverName },
        { name = "serverregion", variable = "{serverregion}", value = serverRegion },
        { name = "timestamp", variable = "{timestamp}", value = tostring(unixTimestamp) },
        { name = "join_script", variable = "{join_script}", value = joinScript },
    }
}

        requestFunction({
            Url = url,
            Method = "POST",
            Headers = {
                ["Authorization"] = apiKey,
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(body)
        })
    end
end)
