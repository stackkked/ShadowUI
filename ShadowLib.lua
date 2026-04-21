--[[
    ███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗
    ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║
    ███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║
    ╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║
    ███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝
    
    ShadowUI Library v2.0
    Красивая UI библиотека для Roblox
    
    Usage:
    local ShadowUI = loadstring(game:HttpGet("YOUR_URL"))()
--]]

local ShadowUI = {}
ShadowUI.__index = ShadowUI

-- ═══════════════════════════════════════
--  Services
-- ═══════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ═══════════════════════════════════════
--  Utility Functions
-- ═══════════════════════════════════════
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "Children" then
            inst[k] = v
        end
    end
    if props and props.Children then
        for _, child in pairs(props.Children) do
            child.Parent = inst
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function Tween(obj, props, duration, style)
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    ), props)
    tween:Play()
    return tween
end

-- ═══════════════════════════════════════
--  Default Theme
-- ═══════════════════════════════════════
local DefaultTheme = {
    Background = Color3.fromRGB(15, 15, 30),
    Secondary = Color3.fromRGB(10, 10, 22),
    Accent = Color3.fromRGB(124, 58, 237),
    AccentLight = Color3.fromRGB(160, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 170),
    TextMuted = Color3.fromRGB(80, 80, 100),
    Border = Color3.fromRGB(30, 30, 58),
    Success = Color3.fromRGB(16, 185, 129),
    Warning = Color3.fromRGB(245, 158, 11),
    Error = Color3.fromRGB(239, 68, 68),
    Info = Color3.fromRGB(59, 130, 246),
    CornerRadius = UDim.new(0, 8),
}

-- ═══════════════════════════════════════
--  Window Creation
-- ═══════════════════════════════════════
function ShadowUI.new(config)
    local self = setmetatable({}, ShadowUI)
    
    self.Name = config.Name or "ShadowUI"
    self.Size = config.Size or UDim2.fromOffset(500, 400)
    self.Theme = config.Theme or DefaultTheme
    self.Tabs = {}
    self.TabCount = 0
    self.ActiveTab = nil
    self.Open = true
    self.Notifications = {}
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    -- Create ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = self.Name,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (syn and syn.protect_gui) 
            and (function() 
                syn.protect_gui(self.ScreenGui) 
                return CoreGui 
            end)() 
            or CoreGui
    })
    
    -- Create Main Frame
    self.MainFrame = Create("Frame", {
        Name = "Main",
        Size = self.Size,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = self.Theme.CornerRadius }),
            Create("UIStroke", { 
                Color = self.Theme.Border,
                Thickness = 1
            }),
        },
        Parent = self.ScreenGui
    })
    
    -- Title Bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { 
                CornerRadius = UDim.new(0, 8) 
            }),
        },
        Parent = self.MainFrame
    })
    
    -- Title elements...
    self.TitleLabel = Create("TextLabel", {
        Text = self.Name,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.fromOffset(40, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    -- Make draggable
    MakeDraggable(self.MainFrame, self.TitleBar)
    
    -- Sidebar
    self.Sidebar = Create("Frame", {
        Size = UDim2.new(0, 90, 1, -36),
        Position = UDim2.fromOffset(0, 36),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
        },
        Parent = self.MainFrame
    })
    
    -- Content area
    self.Content = Create("ScrollingFrame", {
        Size = UDim2.new(1, -90, 1, -52),
        Position = UDim2.fromOffset(90, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
            }),
        },
        Parent = self.MainFrame
    })
    
    -- Status bar
    self.StatusBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, -16),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.ToggleKey then
            self.Open = not self.Open
            self.MainFrame.Visible = self.Open
        end
    end)
    
    return self
end

-- ═══════════════════════════════════════
--  Tab System
-- ═══════════════════════════════════════
function ShadowUI:CreateTab(name, icon)
    self.TabCount = self.TabCount + 1
    local tabIndex = self.TabCount
    
    local tab = {
        Name = name,
        Window = self,
        Frame = Create("Frame", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            Children = {
                Create("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                }),
            },
            Parent = self.Content
        })
    }
    
    -- Tab button in sidebar
    local tabBtn = Create("TextButton", {
        Name = name .. "Btn",
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = (tabIndex == 1) 
            and Color3.fromRGB(124, 58, 237, 0.15)
            or Color3.fromRGB(255, 255, 255, 0),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = (tabIndex == 1) 
            and self.Theme.Accent 
            or self.Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        LayoutOrder = tabIndex,
        Parent = self.Sidebar
    })
    
    tab.Button = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        -- Deselect all
        for _, t in pairs(self.Tabs) do
            t.Frame.Visible = false
            Tween(t.Button, {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255, 0),
                TextColor3 = self.Theme.TextMuted
            }, 0.2)
        end
        -- Select this tab
        tab.Frame.Visible = true
        Tween(tabBtn, {
            BackgroundColor3 = Color3.fromRGB(124, 58, 237, 0.15),
            TextColor3 = self.Theme.Accent
        }, 0.2)
    end)
    
    -- Auto-select first tab
    if tabIndex == 1 then
        tab.Frame.Visible = true
    end
    
    table.insert(self.Tabs, tab)
    self.ActiveTab = self.Tabs[1]
    setmetatable(tab, { __index = self })
    return tab
end

-- ═══════════════════════════════════════
--  Toggle Component
-- ═══════════════════════════════════════
function ShadowUI:CreateToggle(config)
    local currentValue = config.Default or false
    
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Children = {
            Create("TextLabel", {
                Text = config.Name,
                Size = UDim2.new(1, -50, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = self.Theme.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
        },
        Parent = self.Frame
    })
    
    local track = Create("Frame", {
        Size = UDim2.fromOffset(36, 20),
        Position = UDim2.new(1, -40, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = currentValue 
            and self.Theme.Accent 
            or Color3.fromRGB(42, 42, 62),
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        },
        Parent = frame
    })
    
    local thumb = Create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        },
        Parent = track
    })
    
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame
    })
    
    local function updateToggle()
        if currentValue then
            Tween(track, { BackgroundColor3 = self.Theme.Accent }, 0.2)
            Tween(thumb, { Position = UDim2.new(0, 18, 0.5, 0) }, 0.2)
        else
            Tween(track, { BackgroundColor3 = Color3.fromRGB(42, 42, 62) }, 0.2)
            Tween(thumb, { Position = UDim2.new(0, 2, 0.5, 0) }, 0.2)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        updateToggle()
        if config.Callback then
            config.Callback(currentValue)
        end
    end)
    
    updateToggle()
end

-- ═══════════════════════════════════════
--  Slider Component
-- ═══════════════════════════════════════
function ShadowUI:CreateSlider(config)
    local currentValue = config.Default or config.Min or 0
    local min = config.Min or 0
    local max = config.Max or 100
    
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Children = {
            Create("TextLabel", {
                Text = config.Name,
                Size = UDim2.new(0.7, 0, 0, 20),
                BackgroundTransparency = 1,
                TextColor3 = self.Theme.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
        },
        Parent = self.Frame
    })
    
    local valueLabel = Create("TextLabel", {
        Text = tostring(currentValue),
        Size = UDim2.new(0.3, 0, 0, 20),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame
    })
    
    local track = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.fromOffset(0, 26),
        BackgroundColor3 = Color3.fromRGB(42, 42, 62),
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        },
        Parent = frame
    })
    
    local fill = Create("Frame", {
        Size = UDim2.fromScale((currentValue - min) / (max - min), 1),
        BackgroundColor3 = self.Theme.Accent,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        },
        Parent = track
    })
    
    local sliderBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.fromOffset(0, 18),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame
    })
    
    local dragging = false
    
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp(
                (input.Position.X - track.AbsolutePosition.X) 
                / track.AbsoluteSize.X, 0, 1
            )
            currentValue = math.floor(min + (max - min) * relX)
            valueLabel.Text = tostring(currentValue)
            Tween(fill, { 
                Size = UDim2.fromScale(relX, 1) 
            }, 0.05)
            if config.Callback then
                config.Callback(currentValue)
            end
        end
    end)
end

-- ═══════════════════════════════════════
--  Button Component
-- ═══════════════════════════════════════
function ShadowUI:CreateButton(config)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Text = config.Name,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        Children = {
            Create("UICorner", { 
                CornerRadius = UDim.new(0, 6) 
            }),
        },
        Parent = self.Frame
    })
    
    btn.MouseButton1Click:Connect(function()
        Tween(btn, { BackgroundColor3 = self.Theme.AccentLight }, 0.1)
        task.delay(0.1, function()
            Tween(btn, { BackgroundColor3 = self.Theme.Accent }, 0.2)
        end)
        if config.Callback then
            config.Callback()
        end
    end)
    
    return btn
end

-- ═══════════════════════════════════════
--  Dropdown Component
-- ═══════════════════════════════════════
function ShadowUI:CreateDropdown(config)
    local selected = config.Default or config.Options[1] or ""
    local isOpen = false
    
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.Frame
    })
    
    Create("TextLabel", {
        Text = config.Name,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = Color3.fromRGB(26, 26, 46),
        BorderSizePixel = 0,
        Text = selected,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            Create("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
            Create("UIStroke", { Color = self.Theme.Border }),
        },
        Parent = frame
    })
    
    local list = Create("Frame", {
        Size = UDim2.new(1, 0, 0, #config.Options * 28),
        Position = UDim2.fromOffset(0, 54),
        BackgroundColor3 = Color3.fromRGB(20, 20, 38),
        BorderSizePixel = 0,
        Visible = false,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            Create("UIListLayout", { Padding = UDim.new(0, 2) }),
        },
        Parent = frame
    })
    
    for i, option in pairs(config.Options) do
        local optBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            Text = "  " .. option,
            TextColor3 = (option == selected) 
                and self.Theme.Accent 
                or self.Theme.TextSecondary,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = list
        })
        optBtn.MouseButton1Click:Connect(function()
            selected = option
            btn.Text = selected
            isOpen = false
            list.Visible = false
            frame.Size = UDim2.new(1, 0, 0, 60)
            if config.Callback then config.Callback(selected) end
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        list.Visible = isOpen
        frame.Size = isOpen 
            and UDim2.new(1, 0, 0, 60 + #config.Options * 28)
            or UDim2.new(1, 0, 0, 60)
    end)
end

-- ═══════════════════════════════════════
--  Keybind Component
-- ═══════════════════════════════════════
function ShadowUI:CreateKeybind(config)
    local currentKey = config.Default or Enum.KeyCode.Unknown
    local listening = false
    
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = self.Frame
    })
    
    Create("TextLabel", {
        Text = config.Name,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local keyLabel = Create("TextButton", {
        Size = UDim2.new(0, 60, 0, 24),
        Position = UDim2.new(1, -60, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(26, 26, 46),
        BorderSizePixel = 0,
        Text = currentKey.Name,
        TextColor3 = self.Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = self.Theme.Border }),
        },
        Parent = frame
    })
    
    keyLabel.MouseButton1Click:Connect(function()
        listening = true
        keyLabel.Text = "..."
        keyLabel.TextColor3 = self.Theme.Accent
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if listening then
            listening = false
            currentKey = input.KeyCode
            keyLabel.Text = currentKey.Name
            keyLabel.TextColor3 = self.Theme.TextMuted
            if config.Callback then config.Callback(currentKey) end
        end
    end)
end

-- ═══════════════════════════════════════
--  Notification System
-- ═══════════════════════════════════════
function ShadowUI:Notify(config)
    local types = {
        success = { icon = "✓", color = self.Theme.Success },
        warning = { icon = "⚠", color = self.Theme.Warning },
        error   = { icon = "✕", color = self.Theme.Error },
        info    = { icon = "i", color = self.Theme.Info },
    }
    
    local notifType = types[config.Type] or types.info
    local duration = config.Duration or 5
    local position = config.Position or "TopRight"
    
    -- Calculate position
    local positions = {
        TopRight = UDim2.fromScale(1, 0),
        TopCenter = UDim2.fromScale(0.5, 0),
        Center = UDim2.fromScale(0.5, 0.5),
        BottomRight = UDim2.fromScale(1, 1),
    }
    
    local anchors = {
        TopRight = Vector2.new(1, 0),
        TopCenter = Vector2.new(0.5, 0),
        Center = Vector2.new(0.5, 0.5),
        BottomRight = Vector2.new(1, 1),
    }
    
    -- Count existing notifications at this position
    local count = 0
    for _, n in pairs(self.Notifications) do
        if n.Position == position then
            count = count + 1
        end
    end
    
    local yOffset = count * 70
    local isBottom = position == "BottomRight"
    
    -- Create notification frame
    local notif = Create("Frame", {
        Size = UDim2.fromOffset(280, 60),
        Position = positions[position] + UDim2.fromOffset(
            -20,
            isBottom and (-20 - yOffset) or (20 + yOffset)
        ),
        AnchorPoint = anchors[position],
        BackgroundColor3 = Color3.fromRGB(17, 17, 34),
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { 
                Color = notifType.color,
                Transparency = 0.7,
                Thickness = 1
            }),
        },
        Parent = self.ScreenGui
    })
    
    -- Icon
    Create("TextLabel", {
        Text = notifType.icon,
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        TextColor3 = notifType.color,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = notif
    })
    
    -- Title
    Create("TextLabel", {
        Text = config.Title or "Notification",
        Size = UDim2.new(1, -100, 0, 18),
        Position = UDim2.fromOffset(46, 10),
        BackgroundTransparency = 1,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notif
    })
    
    -- Content
    Create("TextLabel", {
        Text = config.Content or "",
        Size = UDim2.new(1, -100, 0, 16),
        Position = UDim2.fromOffset(46, 30),
        BackgroundTransparency = 1,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notif
    })
    
    -- Progress bar
    local progress = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.fromOffset(0, -2),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = notifType.color,
        Children = {
            Create("UICorner", { 
                CornerRadius = UDim.new(0, 1) 
            }),
        },
        Parent = notif
    })
    
    -- Animate in
    if position == "Center" then
        notif.Size = UDim2.fromOffset(0, 60)
        Tween(notif, { Size = UDim2.fromOffset(280, 60) }, 0.3)
    else
        local startX = position:find("Right") and 1.1 or -0.1
        notif.Position = UDim2.fromScale(startX, notif.Position.Y.Scale)
        Tween(notif, { 
            Position = positions[position] + UDim2.fromOffset(
                -20,
                isBottom and (-20 - yOffset) or (20 + yOffset)
            )
        }, 0.4, Enum.EasingStyle.Back)
    end
    
    -- Animate progress bar
    Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration)
    
    -- Auto dismiss
    task.delay(duration, function()
        Tween(notif, { 
            Position = notif.Position + UDim2.fromOffset(300, 0) 
        }, 0.3)
        task.delay(0.3, function()
            notif:Destroy()
            -- Remove from tracking
            for i, n in pairs(self.Notifications) do
                if n.Frame == notif then
                    table.remove(self.Notifications, i)
                    break
                end
            end
        end)
    end)
    
    -- Track notification
    table.insert(self.Notifications, {
        Frame = notif,
        Position = position
    })
    
    return notif
end

-- ═══════════════════════════════════════
--  Cleanup
-- ═══════════════════════════════════════
function ShadowUI:Destroy()
    self.ScreenGui:Destroy()
end

return ShadowUI