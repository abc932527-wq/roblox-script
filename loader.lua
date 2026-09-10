-- VEIL HUB LOADER v3
-- entry point. fetches main.lua, main.lua routes to game scripts.

local Config = {
    MainScriptUrl = "https://raw.githubusercontent.com/abc932527-wq/roblox-script/main/main.lua",

    -- optional key gate. empty string = no key required
    Key = "",

    -- print fetch/compile steps to console
    Debug = false
}

local function log(...)
    if Config.Debug then
        print("[VEIL]", ...)
    end
end

local function notify(title, text, duration)
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "VeilLoaderNotify"
        sg.ResetOnSpawn = false
        sg.Parent = game:GetService("CoreGui")

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 320, 0, 58)
        f.Position = UDim2.new(1, -340, 1, -80)
        f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        f.BorderSizePixel = 0
        f.Parent = sg
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -16, 0, 22)
        t.Position = UDim2.new(0, 8, 0, 6)
        t.BackgroundTransparency = 1
        t.Text = title
        t.Font = Enum.Font.GothamBold
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextSize = 14
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local b = Instance.new("TextLabel")
        b.Size = UDim2.new(1, -16, 0, 20)
        b.Position = UDim2.new(0, 8, 0, 30)
        b.BackgroundTransparency = 1
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextColor3 = Color3.fromRGB(180, 180, 180)
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = f

        game:GetService("Debris"):AddItem(sg, duration or 4)
    end)
end

local function fetch(url)
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(source) ~= "string" or #source == 0 then
        return nil, source
    end
    return source
end

local function checkKey()
    if Config.Key == "" then
        return true
    end
    local saved = ""
    pcall(function()
        if getgenv and getgenv().VeilLoaderKey then
            saved = getgenv().VeilLoaderKey
        end
    end)
    return saved == Config.Key
end

local function main()
    notify("[V] VEIL", "Loader started")

    if not checkKey() then
        notify("[V] VEIL", "Invalid key", 4)
        warn("[VEIL] Key check failed.")
        return
    end

    log("fetching main:", Config.MainScriptUrl)
    local source, err = fetch(Config.MainScriptUrl)
    if not source then
        notify("[V] VEIL", "Failed to fetch main.lua", 4)
        warn("[VEIL] HttpGet failed:", err)
        return
    end

    local fn, compileErr = loadstring(source)
    if not fn then
        notify("[V] VEIL", "main.lua compile error", 4)
        warn("[VEIL] loadstring error:", compileErr)
        return
    end

    -- hand info to game scripts
    if getgenv then
        getgenv().VeilLoader = {
            PlaceId = game.PlaceId,
            JobId = game.JobId,
            Version = "3.0.0"
        }
    end

    notify("[V] VEIL", "Routing to game script", 3)
    fn()
end

main()
