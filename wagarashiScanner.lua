local url = "https://api.botghost.com/webhook/1349573134407438438/owlxznd6ol9ztw7cb6y"
local apiKey = "05c5187fefaf41080d936c37c747deff3bd42cbad42ae186b87303dfd0cadc88"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local requestFunction = (syn and syn.request) or (http and http.request) or (http_request) or (request)
if not requestFunction then return end

local postedPlayers = {}

local function fetchHeadshot(userId)
	local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..userId.."&size=420x420&format=Png"
	local result = requestFunction({
		Url = url,
		Method = "GET",
		Headers = {["Content-Type"] = "application/json"}
	})
	if result and result.StatusCode == 200 then
		local body = HttpService:JSONDecode(result.Body)
		if body and body.data and body.data[1] then
			return body.data[1].imageUrl
		end
	end
end

local function getGuiServerInfo()
	local plr = Players.LocalPlayer
	local gui = plr:FindFirstChild("PlayerGui")
	local serverName = "Unknown"
	local serverRegion = "Unknown"

	if gui then
		local serverInfoGui = gui:FindFirstChild("ServerInfo")
		if serverInfoGui and serverInfoGui:FindFirstChild("ServerInfo") then
			local inner = serverInfoGui.ServerInfo
			local nameText = inner:FindFirstChild("ServerName")
			local regionText = inner:FindFirstChild("Region")
			if nameText and nameText:IsA("TextLabel") then
				serverName = nameText.Text
			end
			if regionText and regionText:IsA("TextLabel") then
				serverRegion = regionText.Text
			end
		end
	end

	return serverName, serverRegion
end

local function getBackpackToolList(playerName)
	local plr = Players:FindFirstChild(playerName)
	if not plr or not plr:FindFirstChild("Backpack") then return "No tools" end

	local names = {}
	for _, tool in ipairs(plr.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			table.insert(names, tool.Name)
		end
	end

	return #names > 0 and table.concat(names, ", ") or "No tools"
end

local function getServerData()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local getServerList = remotes and remotes:FindFirstChild("GetServerList")
	if not getServerList then return end

	local success, result = pcall(function()
		return getServerList:InvokeServer("all")
	end)
	if not success or not result then return end

	for _, data in pairs(result) do
		if typeof(data) == "table" and tostring(data.JobID) == tostring(game.JobId) then
			return data
		end
	end
end

task.spawn(function()
	while task.wait(5) do
		local aliveFolder = Workspace:FindFirstChild("Alive")
		if not aliveFolder then continue end

		for _, model in ipairs(aliveFolder:GetChildren()) do
			if not model:IsA("Model") then continue end

			local effects = model:FindFirstChild("Effects")
			local displayNameVal = effects and effects:FindFirstChild("DisplayName")
			if not (displayNameVal and displayNameVal:IsA("StringValue")) then continue end

			local words = string.split(displayNameVal.Value, " ")
			local second = words[2]
			if second ~= "Uchihra" and second ~= "Hiyuga" then continue end

			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then continue end

			local plr = Players:FindFirstChild(model.Name)
			if not plr or postedPlayers[plr.UserId] then continue end

			local pos = model:FindFirstChild("HumanoidRootPart") and model.HumanoidRootPart.Position or Vector3.zero
			local loc = string.format("X: %d, Y: %d, Z: %d", pos.X, pos.Y, pos.Z)

			local headshot = fetchHeadshot(plr.UserId) or ""
			local guiServerName, guiRegion = getGuiServerInfo()
			local backpackTools = getBackpackToolList(plr.Name)

			local serverData = getServerData() or {}
			local serverPlayers = tonumber(serverData.ServerPlayers or 0)
			local serverPlayerMax = tonumber(serverData.ServerPlayerMax or 0)

			local joinScript = ([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game.Players.LocalPlayer)]])
				:format(serverData.PlaceID or game.PlaceId, serverData.JobID or game.JobId)

			local message = string.format("Found %s: %s (%s) at %s", second, plr.Name, displayNameVal.Value, loc)
			local body = {
				variables = {
					{ name = "username", variable = "{username}", value = plr.Name },
					{ name = "health", variable = "{health}", value = ("%d/%d"):format(humanoid.Health, humanoid.MaxHealth) },
					{ name = "location", variable = "{location}", value = loc },
					{ name = "server_name", variable = "{server_name}", value = guiServerName },
					{ name = "server_region", variable = "{server_region}", value = guiRegion },
					{ name = "players", variable = "{players}", value = ("%d/%d"):format(serverPlayers, serverPlayerMax) },
					{ name = "join_script", variable = "{join_script}", value = joinScript },
					{ name = "avatar", variable = "{avatar}", value = headshot },
					{ name = "tools", variable = "{tools}", value = backpackTools },
					{ name = "clan", variable = "{clan}", value = second },
					{ name = "event_message", variable = "{event_message}", value = message }
				}
			}

			local response = requestFunction({
				Url = url,
				Method = "POST",
				Headers = {
					["Authorization"] = apiKey,
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode(body)
			})

			if response and response.StatusCode == 200 then
				postedPlayers[plr.UserId] = true
			end
		end
	end
end)
