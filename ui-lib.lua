--[[
    VEIL UI LIBRARY v4.0 - GUARANTEED WORKING TABS
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local Theme = {
    Background  = Color3.fromRGB(10, 10, 14),
    Sidebar     = Color3.fromRGB(14, 14, 20),
    TopBar      = Color3.fromRGB(16, 16, 24),
    Card        = Color3.fromRGB(22, 22, 30),
    CardHover   = Color3.fromRGB(28, 28, 38),
    Accent      = Color3.fromRGB(120, 60, 255),
    Text        = Color3.fromRGB(240, 240, 250),
    TextDim     = Color3.fromRGB(150, 150, 170),
    TextMuted   = Color3.fromRGB(90, 90, 110),
    Divider     = Color3.fromRGB(30, 30, 45),
    ToggleOff   = Color3.fromRGB(38, 38, 52),
    ToggleOn    = Color3.fromRGB(120, 60, 255),
    Knob        = Color3.fromRGB(255, 255, 255)
}

local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "Children" then
            inst[k] = v
        end
    end
    if props and props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = inst
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Library.new(title, gameTitle)
    local self = setmetatable({}, Library)
    self.TabFrames = {}
    self.TabButtons = {}
    self.ActiveTab = nil
    self.Connections = {}
    self.State = {}
    self.Visible = true

    self.ScreenGui = New("ScreenGui", {
        Name = "VeilHub_" .. math.random(100000, 999999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(self.ScreenGui) end)
    end
    self.ScreenGui.Parent = CoreGui

    self.MainFrame = New("Frame", {
        Size = UDim2.new(0, 600, 0, 450),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        Children = {
            New("UICorner", {CornerRadius = UDim.new(0, 12)}),
            New("UIStroke", {Color = Theme.Divider, Thickness = 1})
        }
    })

    -- TOPBAR
    self.TopBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 12)})}
    })

    New("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "[V] VEIL HUB",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })

    New("TextLabel", {
        Size = UDim2.new(0.35, -60, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = gameTitle or "",
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = self.TopBar
    })

    local closeBtn = New("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -42, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(230, 60, 60),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Parent = self.TopBar,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })
    closeBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    -- SIDEBAR
    self.Sidebar = New("Frame", {
        Size = UDim2.new(0, 160, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })

    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = self.Sidebar
    })

    New("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = self.Sidebar
    })

    -- CONTENT
    self.Content = New("Frame", {
        Size = UDim2.new(1, -160, 1, -48),
        Position = UDim2.new(0, 160, 0, 48),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 12)})}
    })

    New("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 12),
        Parent = self.Content
    })

    return self
end

function Library:Toggle()
    self.Visible = not self.Visible
    self.MainFrame.Visible = self.Visible
end

function Library:Destroy()
    self.ScreenGui:Destroy()
    for _, conn in pairs(self.Connections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
end

function Library:AddTab(name, icon)
    local label = (icon and icon ~= "") and (icon .. " " .. name) or name

    -- Create tab button in sidebar
    local tabBtn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        Text = label,
        Font = Enum.Font.GothamSemibold,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        LayoutOrder = #self.TabButtons + 1,
        Parent = self.Sidebar,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })

    -- Add padding to text
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = tabBtn
    })

    -- Create content frame
    local contentFrame = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = self.Content,
        Children = {
            New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}),
            New("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})
        }
    })

    self.TabFrames[name] = contentFrame
    self.TabButtons[name] = tabBtn

    -- Click handler
    tabBtn.MouseButton1Click:Connect(function()
        -- Hide all content frames
        for _, frame in pairs(self.TabFrames) do
            frame.Visible = false
        end
        -- Reset all tab buttons
        for _, btn in pairs(self.TabButtons) do
            btn.BackgroundColor3 = Theme.Card
            btn.TextColor3 = Theme.Text
        end
        -- Show this tab
        contentFrame.Visible = true
        tabBtn.BackgroundColor3 = Theme.Accent
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        self.ActiveTab = name
    end)

    -- Auto-select first tab
    if not self.ActiveTab then
        tabBtn.MouseButton1Click:Connect(function() end) -- dummy to trigger
        contentFrame.Visible = true
        tabBtn.BackgroundColor3 = Theme.Accent
        self.ActiveTab = name
    end

    return contentFrame
end

function Library:AddSection(tab, title)
    local parent = type(tab) == "string" and self.TabFrames[tab] or tab
    local section = New("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = parent
    })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = string.upper(title),
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })
    return section
end

function Library:AddLabel(tab, text)
    local parent = type(tab) == "string" and self.TabFrames[tab] or tab
    return New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })
end

function Library:AddToggle(tab, name, stateKey, default, callback)
    local parent = type(tab) == "string" and self.TabFrames[tab] or tab
    self.State[stateKey] = default or false

    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = parent,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })

    New("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    local track = New("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = self.State[stateKey] and Theme.ToggleOn or Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = card,
        Children = {New("UICorner", {CornerRadius = UDim.new(1, 0)})}
    })

    local knob = New("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = self.State[stateKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Theme.Knob,
        BorderSizePixel = 0,
        Parent = track,
        Children = {New("UICorner", {CornerRadius = UDim.new(1, 0)})}
    })

    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card
    })

    btn.MouseButton1Click:Connect(function()
        self.State[stateKey] = not self.State[stateKey]
        local on = self.State[stateKey]
        track.BackgroundColor3 = on and Theme.ToggleOn or Theme.ToggleOff
        knob.Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        if callback then callback(on) end
    end)

    return card
end

function Library:AddSlider(tab, name, stateKey, min, max, default, callback)
    local parent = type(tab) == "string" and self.TabFrames[tab] or tab
    self.State[stateKey] = default or min

    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = parent,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })

    New("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 22),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    local valLbl = New("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 22),
        Position = UDim2.new(0.7, -14, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = card
    })

    local trackBg = New("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 36),
        BackgroundColor3 = Color3.fromRGB(28, 28, 40),
        BorderSizePixel = 0,
        Parent = card,
        Children = {New("UICorner", {CornerRadius = UDim.new(1, 0)})}
    })

    local fill = New("Frame", {
        Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = trackBg,
        Children = {New("UICorner", {CornerRadius = UDim.new(1, 0)})}
    })

    return card
end

function Library:AddButton(tab, name, callback)
    local parent = type(tab) == "string" and self.TabFrames[tab] or tab

    local card = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Parent = parent,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })

    New("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    card.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return card
end

function Library:AddKeybind(toggleKey)
    self.Connections._keybind = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == (toggleKey or Enum.KeyCode.RightShift) then
            self:Toggle()
        end
    end)
end

function Library:Notify(text, duration)
    local notif = New("Frame", {
        Size = UDim2.new(0, 280, 0, 42),
        Position = UDim2.new(1, 0, 1, -60),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })
    New("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "[V] " .. text,
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    task.delay(duration or 3, function() notif:Destroy() end)
end

return Library
