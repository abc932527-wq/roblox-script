-- VEIL HUB MAIN v3.1 (DEBUG)
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

local RAW = "https://raw.githubusercontent.com/abc932527-wq/roblox-script/main/games/"

-- by PlaceId
local GameScripts = {
    [113290951185459] = RAW .. "anime-dice.lua",
}

-- by game name
local NameScripts = {
    ["Anime Dice"] = RAW .. "anime-dice.lua",
}

local placeId = game.PlaceId

local gameName = ""
pcall(function()
    gameName = MarketplaceService:GetProductInfo(placeId).Name
end)

-- Debug notification
game.StarterGui:SetCore("SendNotification", {
    Title = "[V] VEIL",
    Text = "PlaceId: " .. tostring(placeId) .. "\nName: " .. gameName,
    Duration = 5
})

local url = GameScripts[placeId] or NameScripts[gameName]

if not url then
    game.StarterGui:SetCore("SendNotification", {
        Title = "[V] VEIL ERROR",
        Text = "No script configured for this game",
        Duration = 8
    })
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "VeilRouterMsg"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 420, 0, 110)
    f.Position = UDim2.new(0.5, -210, 0.5, -55)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.BorderSizePixel = 0
    f.Parent = sg
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -24, 1, -24)
    t.Position = UDim2.new(0, 12, 0, 12)
    t.BackgroundTransparency = 1
    t.Text = "[V] VEIL: no script for this game yet.\nPlaceId: " .. tostring(placeId) .. "\nName: " .. gameName
    t.Font = Enum.Font.GothamBold
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = 14
    t.TextWrapped = true
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Top
    t.Parent = f

    game:GetService("Debris"):AddItem(sg, 15)
    warn("[VEIL] No script configured. PlaceId:", placeId, "Name:", gameName)
    return
end

game.StarterGui:SetCore("SendNotification", {
    Title = "[V] VEIL",
    Text = "Fetching: " .. url,
    Duration = 3
})

local ok, source = pcall(function()
    return game:HttpGet(url)
end)

if not ok or type(source) ~= "string" or #source == 0 then
    game.StarterGui:SetCore("SendNotification", {
        Title = "[V] VEIL ERROR",
        Text = "Failed to fetch script\nCheck if file exists in repo",
        Duration = 8
    })
    warn("[VEIL] Failed to fetch game script:", url, "Error:", ok)
    return
end

game.StarterGui:SetCore("SendNotification", {
    Title = "[V] VEIL",
    Text = "Executing script...",
    Duration = 2
})

local fn, compileErr = loadstring(source)
if not fn then
    game.StarterGui:SetCore("SendNotification", {
        Title = "[V] VEIL ERROR",
        Text = "Script compile error\nCheck console for details",
        Duration = 8
    })
    warn("[VEIL] Game script compile error:", compileErr)
    return
end

fn()
