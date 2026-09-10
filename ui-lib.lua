--[[
    VEIL UI LIBRARY v3
    clean rebuild. every past bug fixed at the source.
    - tab text lives on the button itself (nothing to lose)
    - tab select is a real function call (no signal :Fire())
    - all tweens nil-guarded
    - touch + mouse everywhere (pc and mobile)
    - one theme table, edit colors in one place
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Library = {}
Library.__index = Library
Library.Version = "3.0.0"

local Theme = {
    Background  = Color3.fromRGB(12, 12, 16),
    Sidebar     = Color3.fromRGB(16, 16, 22),
    TopBar      = Color3.fromRGB(18, 18, 26),
    Card        = Color3.fromRGB(22, 22, 30),
    CardHover   = Color3.fromRGB(28, 28, 38),
    Accent      = Color3.fromRGB(130, 80, 255),
    AccentGlow  = Color3.fromRGB(160, 110, 255),
    Green       = Color3.fromRGB(45, 212, 120),
    Red         = Color3.fromRGB(235, 65, 65),
    Text        = Color3.fromRGB(235, 235, 245),
    TextDim     = Color3.fromRGB(140, 140, 160),
    TextMuted   = Color3.fromRGB(80, 80, 100),
    Divider     = Color3.fromRGB(35, 35, 50),
    SliderBg    = Color3.fromRGB(30, 30, 42),
    ToggleOff   = Color3.fromRGB(40, 40, 55),
    Knob        = Color3.fromRGB(255, 255, 255)
}

local function Tween(obj, props, duration)
    if not obj then return end
    TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" and k ~= "Children" then
            inst[k] = v
        end
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = inst
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function IsTouch(input)
    return input.UserInputType == Enum.UserInputType.Touch
end

local function IsPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or IsTouch(input)
end

function Library.new(title, gameTitle)
    local self = setmetatable({}, Library)
    self.TabFrames = {}
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

    self._shadow = New("ImageLabel", {
        Size = UDim2.new(0, 640, 0, 490),
        Position = UDim2.new(0.5, -320, 0.5, -245),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = self.ScreenGui
    })

    self.MainFrame = New("Frame", {
        Size = IsMobile and UDim2.new(0.92, 0, 0.78, 0) or UDim2.new(0, 580, 0, 430),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
        Children = {
            New("UICorner", {CornerRadius = UDim.new(0, 12)}),
            New("UIStroke", {Color = Theme.Divider, Thickness = 1, Transparency = 0.5})
        }
    })

    -- topbar
    self.TopBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 12)})}
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Parent = self.TopBar
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = self.TopBar,
        Children = {
            New("UIGradient", {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(0.5, Theme.AccentGlow),
                    ColorSequenceKeypoint.new(1, Theme.Accent)
                },
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0.6),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(1, 0.6)
                }
            })
        }
    })

    New("TextLabel", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "[V] VEIL HUB",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })

    New("TextLabel", {
        Size = UDim2.new(0.35, -44, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = gameTitle or "",
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.TopBar
    })

    local closeBtn = New("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0.5, -15),
        BackgroundColor3 = Theme.Red,
        BackgroundTransparency = 0.85,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Red,
        TextSize = 13,
        Parent = self.TopBar,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 6)})}
    })
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- sidebar
    self.Sidebar = New("Frame", {
        Size = UDim2.new(0, 155, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    New("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        Parent = self.Sidebar
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

    -- content
    self.Content = New("Frame", {
        Size = UDim2.new(1, -155, 1, -46),
        Position = UDim2.new(0, 155, 0, 46),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.MainFrame
    })

    self:_initDrag()

    -- mobile floating toggle
    if IsMobile then
        local mBtn = New("TextButton", {
            Size = UDim2.new(0, 48, 0, 48),
            Position = UDim2.new(1, -60, 1, -120),
            BackgroundColor3 = Theme.Accent,
            Text = "V",
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 20,
            Parent = self.ScreenGui,
            Children = {
                New("UICorner", {CornerRadius = UDim.new(1, 0)}),
                New("UIStroke", {Color = Theme.AccentGlow, Thickness = 2, Transparency = 0.5})
            }
        })
        mBtn.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
        self._mobileBtn = mBtn
    end

    return self
end

function Library:_initDrag()
    local dragging, dragStart, startPos

    self.TopBar.InputBegan:Connect(function(input)
        if IsPress(input) then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or IsTouch(input)) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if IsPress(input) then
            dragging = false
        end
    end)
end

function Library:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        self.MainFrame.Visible = true
        if self._shadow then self._shadow.Visible = true end
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        Tween(self.MainFrame, {
            Size = IsMobile and UDim2.new(0.92, 0, 0.78, 0) or UDim2.new(0, 580, 0, 430)
        }, 0.35)
    else
        Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
        task.delay(0.26, function()
            self.MainFrame.Visible = false
            if self._shadow then self._shadow.Visible = false end
        end)
    end
end

function Library:Destroy()
    self.ScreenGui:Destroy()
    for _, conn in pairs(self.Connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
end

function Library:AddTab(name, icon)
    local label = (icon and icon ~= "") and (icon .. "  " .. name) or ("  " .. name)

    local tabBtn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamSemibold,
        TextColor3 = Theme.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = self.Sidebar,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })

    local indicator = New("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = tabBtn,
        Children = {New("UICorner", {CornerRadius = UDim.new(1, 0)})}
    })

    local contentFrame = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.5,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = self.Content,
        Children = {
            New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}),
            New("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 10)
            })
        }
    })

    self.TabFrames[name] = contentFrame

    tabBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= name then
            Tween(tabBtn, {BackgroundTransparency = 0.7, BackgroundColor3 = Theme.Card}, 0.2)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            Tween(tabBtn, {BackgroundTransparency = 1}, 0.2)
        end
    end)

    local function selectTab()
        for _, frame in pairs(self.TabFrames) do
            frame.Visible = false
        end
        for _, child in ipairs(self.Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                Tween(child, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim}, 0.15)
                for _, c in ipairs(child:GetChildren()) do
                    if c:IsA("Frame") and c.Size.X.Scale == 0 then
                        Tween(c, {BackgroundTransparency = 1}, 0.15)
                    end
                end
            end
        end
        contentFrame.Visible = true
        self.ActiveTab = name
        Tween(tabBtn, {
            BackgroundTransparency = 0.5,
            BackgroundColor3 = Theme.Card,
            TextColor3 = Theme.Text
        }, 0.2)
        Tween(indicator, {BackgroundTransparency = 0}, 0.2)
    end

    tabBtn.MouseButton1Click:Connect(selectTab)

    if not self.ActiveTab then
        selectTab()
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
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
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
        TextWrapped = true,
        Parent = parent
    })
end

function Library:AddToggle(tab, name, stateKey, default, callback)
    local parent = type(tab) == "string" and self.TabFrames[tab] or tab
    self.State[stateKey] = default or false

    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = parent,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })

    New("TextLabel", {
        Size = UDim2.new(0.7, -10, 1, 0),
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
        Position = UDim2.new(1, -56, 0.5, -11),
        BackgroundColor3 = self.State[stateKey] and Theme.Accent or Theme.ToggleOff,
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
        Tween(track, {BackgroundColor3 = on and Theme.Accent or Theme.ToggleOff}, 0.2)
        Tween(knob, {Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.2)
        if callback then callback(on) end
    end)

    btn.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    btn.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = Theme.Card}, 0.15) end)

    return card
end

function Library:AddSlider(tab, name, stateKey, min, max, default, callback)
    local parent = type(tab) == "string" and self.TabFrames[tab] or tab
    self.State[stateKey] = default or min

    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = parent,
        Children = {New("UICorner", {CornerRadius = UDim.new(0, 8)})}
    })

    New("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 22),
        Position = UDim2.new(0, 14, 0, 4),
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
        Position = UDim2.new(0.7, -14, 0, 4),
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
        BackgroundColor3 = Theme.SliderBg,
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

    local hitbox = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card
    })

    local drag = false
    hitbox.InputBegan:Connect(function(i)
        if IsPress(i) then drag = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if IsPress(i) then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or IsTouch(i)) then
            local rel = math.clamp((i.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            self.State[stateKey] = val
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLbl.Text = tostring(val)
            if callback then callback(val) end
        end
    end)

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

    New("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = ">",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.TextMuted,
        TextSize = 14,
        Parent = card
    })

    card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = Theme.Card}, 0.15) end)
    card.MouseButton1Click:Connect(function()
        Tween(card, {BackgroundColor3 = Theme.Accent}, 0.08)
        task.delay(0.12, function()
            Tween(card, {BackgroundColor3 = Theme.Card}, 0.15)
        end)
        if callback then callback() end
    end)

    return card
end

function Library:AddKeybind(toggleKey, panicCallback)
    self.Connections._keybind = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == (toggleKey or Enum.KeyCode.RightShift) then
            self:Toggle()
        elseif input.KeyCode == Enum.KeyCode.End then
            if panicCallback then panicCallback() end
            self:Destroy()
        end
    end)
end

function Library:Notify(text, duration)
    local notif = New("Frame", {
        Size = UDim2.new(0, 280, 0, 40),
        Position = UDim2.new(1, 0, 1, -60),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        Children = {
            New("UICorner", {CornerRadius = UDim.new(0, 8)}),
            New("UIStroke", {Color = Theme.Accent, Thickness = 1, Transparency = 0.7})
        }
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
    Tween(notif, {Position = UDim2.new(1, -300, 1, -60)}, 0.4)
    task.delay(duration or 3, function()
        Tween(notif, {Position = UDim2.new(1, 0, 1, -60)}, 0.3)
        task.delay(0.35, function()
            notif:Destroy()
        end)
    end)
end

return Library
