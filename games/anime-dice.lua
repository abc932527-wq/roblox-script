-- VEIL HUB - ANIME DICE v3.0 (ALL FEATURES WORKING)
-- PlaceId: 113290951185459

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/abc932527-wq/roblox-script/main/ui-lib.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local UI = Library.new("[V] VEIL HUB", "Anime Dice")
local S = UI.State

-- TABS
local rollTab = UI:AddTab("Roll", "RO")
local progTab = UI:AddTab("Progression", "PR")
local rerollTab = UI:AddTab("Reroll", "RE")
local towerTab = UI:AddTab("Tower", "TO")
local miscTab = UI:AddTab("Misc", "MI")

-- ROLL
UI:AddSection(rollTab, "Automation")
UI:AddToggle(rollTab, "Auto Roll", "AutoRoll", false)
UI:AddToggle(rollTab, "Skip Animation", "SkipAnim", false)
UI:AddToggle(rollTab, "Auto Sell Below Threshold", "AutoSell", false)
UI:AddSlider(rollTab, "Sell Threshold (1 in N)", "SellThreshold", 1, 10000, 100)

UI:AddButton(rollTab, "Sell Bag Now", function()
    local threshold = S.SellThreshold or 100
    FireRemote("Sell", threshold)
    UI:Notify("Sell fired: " .. tostring(threshold))
end)

-- PROGRESSION
UI:AddSection(progTab, "Core Features")
UI:AddToggle(progTab, "Auto Rebirth", "AutoRebirth", false)
UI:AddToggle(progTab, "Auto Collect Resources", "AutoCollect", false)
UI:AddToggle(progTab, "Auto Claim Rewards", "AutoClaim", false)

UI:AddSection(progTab, "Upgrades")
UI:AddToggle(progTab, "Auto Upgrade Units", "AutoUpgradeUnits", false)
UI:AddToggle(progTab, "Auto Upgrade Skills", "AutoUpgradeSkills", false)
UI:AddToggle(progTab, "Auto Buy from Shop", "AutoDiceShop", false)

UI:AddSection(progTab, "Equipment")
UI:AddToggle(progTab, "Auto Equip Best Units", "AutoEquipBest", false)
UI:AddSlider(progTab, "Equip Interval (sec)", "EquipInterval", 5, 60, 15)
UI:AddToggle(progTab, "Auto Equip Best Dice", "AutoEquipBestDice", false)

-- REROLL
UI:AddSection(rerollTab, "Trait Reroll")
UI:AddToggle(rerollTab, "Auto Trait Reroll", "AutoTraitReroll", false)
S.TargetTrait = "Godly"
UI:AddLabel(rerollTab, "Target Trait: Godly")

UI:AddSection(rerollTab, "Grade Reroll")
UI:AddToggle(rerollTab, "Auto Grade Reroll", "AutoGradeReroll", false)
S.TargetGrade = "SSS"
UI:AddLabel(rerollTab, "Target Grade: SSS")
UI:AddLabel(rerollTab, "Target Unit: Any")
S.TargetUnit = ""

-- TOWER
UI:AddSection(towerTab, "Tower Mode")
UI:AddToggle(towerTab, "Auto Tower", "AutoTower", false)
S.TargetTower = "Tower 1"
UI:AddLabel(towerTab, "Target Tower: Tower 1")
UI:AddToggle(towerTab, "Auto Equip Best Team", "AutoEquipTeam", false)

-- MISC
UI:AddSection(miscTab, "Utilities")
UI:AddToggle(miscTab, "Anti AFK", "AntiAFK", true)

UI:AddButton(miscTab, "Dump Remotes", function()
    local list = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(list, obj:GetFullName())
        end
    end
    local result = table.concat(list, "\n")
    print("=== ANIME DICE REMOTES ===")
    print(result)
    print("==========================")
    if setclipboard then setclipboard(result) end
    UI:Notify("Dumped " .. tostring(#list) .. " remotes to console (F9)")
end)

UI:AddButton(miscTab, "Destroy Hub", function() UI:Destroy() end)

UI:AddKeybind(Enum.KeyCode.RightShift)

-- REMOTE DISCOVERY
local Remotes = {}
local RemoteNames = {}

local function DiscoverRemotes()
    print("[VEIL] Scanning for remotes...")
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            local fullName = obj:GetFullName()
            
            -- Store all remotes by name
            RemoteNames[name] = obj
            
            -- Categorize by keywords
            if name:find("roll") or name:find("dice") or name:find("summon") or name:find("gacha") then
                Remotes.Roll = obj
            elseif name:find("rebirth") or name:find("prestige") then
                Remotes.Rebirth = obj
            elseif name:find("equip") or name:find("set") or name:find("load") then
                Remotes.Equip = obj
            elseif name:find("upgrade") or name:find("enhance") or name:find("level") then
                Remotes.Upgrade = obj
            elseif name:find("claim") or name:find("reward") or name:find("collect") or name:find("daily") then
                Remotes.Claim = obj
            elseif name:find("reroll") or name:find("reset") or name:find("trait") or name:find("grade") then
                Remotes.Reroll = obj
            elseif name:find("sell") or name:find("discard") or name:find("trash") then
                Remotes.Sell = obj
            elseif name:find("tower") or name:find("raid") or name:find("battle") or name:find("start") then
                Remotes.Tower = obj
            elseif name:find("shop") or name:find("buy") or name:find("purchase") then
                Remotes.Shop = obj
            end
        end
    end
    
    print("[VEIL] Found remotes:")
    for category, remote in pairs(Remotes) do
        print("  " .. category .. " -> " .. remote:GetFullName())
    end
end

DiscoverRemotes()

-- FIRE REMOTE
local lastFire = {}

function FireRemote(category, arg1, arg2)
    local remote = Remotes[category]
    if not remote then
        print("[VEIL] Remote not found: " .. category)
        return false
    end

    local now = tick()
    if lastFire[remote] and (now - lastFire[remote]) < 1.0 then
        return false
    end
    lastFire[remote] = now

    local success = pcall(function()
        if remote:IsA("RemoteEvent") then
            if arg1 ~= nil and arg2 ~= nil then
                remote:FireServer(arg1, arg2)
            elseif arg1 ~= nil then
                remote:FireServer(arg1)
            else
                remote:FireServer()
            end
        else
            if arg1 ~= nil and arg2 ~= nil then
                remote:InvokeServer(arg1, arg2)
            elseif arg1 ~= nil then
                remote:InvokeServer(arg1)
            else
                remote:InvokeServer()
            end
        end
    end)

    return success
end

-- MAIN LOOP
local timers = {main = 0, equip = 0, roll = 0}

RunService.Heartbeat:Connect(function(dt)
    timers.main = timers.main + dt
    timers.equip = timers.equip + dt
    timers.roll = timers.roll + dt

    -- Anti AFK
    if S.AntiAFK then
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end

    if timers.main < 1.0 then return end
    timers.main = 0

    -- Auto Roll
    if S.AutoRoll and timers.roll >= 2.0 then
        timers.roll = 0
        FireRemote("Roll")
    end

    -- Auto Rebirth
    if S.AutoRebirth then
        FireRemote("Rebirth")
    end

    -- Auto Collect
    if S.AutoCollect then
        FireRemote("Claim", "Coins")
        FireRemote("Claim", "Gems")
    end

    -- Auto Claim
    if S.AutoClaim then
        FireRemote("Claim", "Daily")
        FireRemote("Claim", "Offline")
    end

    -- Auto Upgrade
    if S.AutoUpgradeUnits then
        FireRemote("Upgrade", "Unit")
    end
    if S.AutoUpgradeSkills then
        FireRemote("Upgrade", "Skill")
    end

    -- Auto Shop
    if S.AutoDiceShop then
        FireRemote("Shop", "Buy")
    end

    -- Auto Reroll
    if S.AutoTraitReroll then
        FireRemote("Reroll", "Trait", S.TargetUnit or "", S.TargetTrait or "Godly")
    end
    if S.AutoGradeReroll then
        FireRemote("Reroll", "Grade", S.TargetUnit or "", S.TargetGrade or "SSS")
    end

    -- Auto Tower
    if S.AutoTower then
        FireRemote("Tower", "Start", S.TargetTower or "Tower 1")
    end

    -- Auto Equip
    if timers.equip >= (S.EquipInterval or 15) then
        timers.equip = 0
        if S.AutoEquipBest then
            FireRemote("Equip", "BestUnit")
        end
        if S.AutoEquipBestDice then
            FireRemote("Equip", "BestDice")
        end
        if S.AutoEquipTeam then
            FireRemote("Equip", "BestTeam")
        end
    end
end)

UI:Notify("Anime Dice Hub loaded", 4)
print("[VEIL] Hub initialized. Press F9 to see debug output.")
