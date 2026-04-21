--[[
    ███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗
    ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║
    ███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║
    ╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║
    ███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝

    ShadowUI Library v3.0 — Modern Dark Glass Edition
    Полный перепис с нуля: Anthracite + UIGradient + Neon Glow

    Usage:
    local ShadowUI = loadstring(game:HttpGet("YOUR_URL"))()
    local Window = ShadowUI.new({ Name = "My Script", Size = UDim2.fromOffset(600, 400) })
    local Tab = Window:CreateTab("Main", "rbxassetid://3926305904")
    Tab:CreateButton({ Name = "Click Me", Callback = function() print("Hello!") end })
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
--  Constants — Neon Cyan Palette
-- ═══════════════════════════════════════
local NEON = Color3.fromRGB(0, 170, 255)
local NEON_DARK = Color3.fromRGB(0, 120, 200)
local ANTHRACITE = Color3.fromRGB(10, 10, 14)
local DEEP_BLUE = Color3.fromRGB(15, 15, 25)
local CARD_BG = Color3.fromRGB(18, 18, 28)
local SIDEBAR_BG = Color3.fromRGB(8, 8, 16)
local TEXT_WHITE = Color3.fromRGB(240, 240, 255)
local TEXT_DIM = Color3.fromRGB(120, 120, 150)
local TEXT_MUTED = Color3.fromRGB(70, 70, 95)

-- ═══════════════════════════════════════
--  Utility — Instance Factory
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

-- ═══════════════════════════════════════
--  Utility — Smooth Tween Helper
-- ═══════════════════════════════════════
local function Tween(obj, props, duration, style, direction)
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    ), props)
    tween:Play()
    return tween
end

-- ═══════════════════════════════════════
--  Utility — Draggable Frame
-- ═══════════════════════════════════════
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

-- ═══════════════════════════════════════
--  Utility — Hover Effect for Buttons
-- ═══════════════════════════════════════
local function AddHoverEffect(button, normalTransparency, hoverTransparency)
    normalTransparency = normalTransparency or 0.85
    hoverTransparency = hoverTransparency or 0.65

    button.MouseEnter:Connect(function()
        Tween(button, { BackgroundTransparency = hoverTransparency }, 0.25)
    end)
    button.MouseLeave:Connect(function()
        Tween(button, { BackgroundTransparency = normalTransparency }, 0.25)
    end)
end

-- ═══════════════════════════════════════
--  Notification System
-- ═══════════════════════════════════════
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)
    self.Container = Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -340, 0, 0),
        BackgroundTransparency = 1,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
            }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 16),
                PaddingBottom = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
            }),
        },
        Parent = screenGui,
    })
    self.Count = 0
    return self
end

function NotificationSystem:Notify(title, text, duration, notifColor)
    notifColor = notifColor or NEON
    duration = duration or 4
    self.Count = self.Count + 1
    local order = 1000 - self.Count

    -- Card
    local card = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = CARD_BG,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", {
                Color = Color3.fromRGB(30, 30, 50),
                Thickness = 1,
            }),
            -- Neon side strip
            Create("Frame", {
                Name = "SideStrip",
                Size = UDim2.new(0, 3, 1, -12),
                Position = UDim2.new(0, 6, 0, 6),
                BackgroundColor3 = notifColor,
                BorderSizePixel = 0,
                Children = {
                    Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
                },
            }),
            -- Title
            Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 22, 0, 10),
                BackgroundTransparency = 1,
                Text = title or "Notification",
                TextColor3 = TEXT_WHITE,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }),
            -- Body
            Create("TextLabel", {
                Name = "Body",
                Size = UDim2.new(1, -30, 0, 18),
                Position = UDim2.new(0, 22, 0, 32),
                BackgroundTransparency = 1,
                Text = text or "",
                TextColor3 = TEXT_DIM,
                TextSize = 11,
                Font = Enum.Font.GothamSSm,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }),
            -- Progress bar (auto-dismiss)
            Create("Frame", {
                Name = "Progress",
                Size = UDim2.new(1, -20, 0, 2),
                Position = UDim2.new(0, 10, 1, -8),
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = notifColor,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Children = {
                    Create("UICorner", { CornerRadius = UDim.new(0, 1) }),
                },
            }),
        },
        Parent = self.Container,
    })

    -- Animate in with EasingStyle.Back
    card.Position = UDim2.new(0, 40, 0, 0)
    card.BackgroundTransparency = 1
    Tween(card, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.15 }, 0.5, Enum.EasingStyle.Back)

    -- Progress shrink
    local progress = card:FindFirstChild("Progress")
    if progress then
        Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)
    end

    -- Auto dismiss
    task.delay(duration, function()
        Tween(card, {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 0),
        }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.4, function()
            card:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════
--  Window Creation (ShadowUI.new)
-- ═══════════════════════════════════════
function ShadowUI.new(config)
    local self = setmetatable({}, ShadowUI)

    self.Name = config.Name or "ShadowUI"
    self.Size = config.Size or UDim2.fromOffset(580, 420)
    self.Tabs = {}
    self.TabCount = 0
    self.ActiveTab = nil
    self.Open = true
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    -- ─── ScreenGui ───
    self.ScreenGui = Create("ScreenGui", {
        Name = self.Name,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- Anti-detection / CoreGui assignment
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(self.ScreenGui)
        end
    end)
    self.ScreenGui.Parent = CoreGui

    -- ─── Notification System ───
    self.Notifications = NotificationSystem.new(self.ScreenGui)

    -- ═════════════════════════════════════
    --  Main Window Glow (behind frame)
    -- ═════════════════════════════════════
    self.Glow = Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(1, 80, 1, 80),
        Position = UDim2.new(0, -40, 0, -40),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = NEON,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(0, 0, 256, 256),
    })

    -- ═════════════════════════════════════
    --  Main Frame (Anthracite + Gradient)
    -- ═════════════════════════════════════
    self.MainFrame = Create("Frame", {
        Name = "Main",
        Size = self.Size,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = ANTHRACITE,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Children = {
            -- Rounded corners
            Create("UICorner", { CornerRadius = UDim.new(0, 12) }),

            -- UIGradient: top black -> bottom deep blue
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 14)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)),
                }),
                Rotation = 90,
            }),

            -- UIStroke: neon cyan gradient border
            Create("UIStroke", {
                Name = "BorderStroke",
                Color = NEON,
                Thickness = 1.5,
                Transparency = 0.2,
                Children = {
                    Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, NEON),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255)),
                        }),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.7, 0.3),
                            NumberSequenceKeypoint.new(1, 1),
                        }),
                    }),
                },
            }),

            -- Glow (floating behind window)
            self.Glow,
        },
        Parent = self.ScreenGui,
    })

    -- ─── Title Bar ───
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(12, 12, 20),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
            -- Bottom edge fade
            Create("Frame", {
                Name = "BottomEdge",
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = NEON,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
            }),
        },
        Parent = self.MainFrame,
    })

    -- Title text
    self.TitleLabel = Create("TextLabel", {
        Text = self.Name,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.fromOffset(20, 0),
        BackgroundTransparency = 1,
        TextColor3 = NEON,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    -- Close button
    local closeBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0, 5),
        BackgroundColor3 = Color3.fromRGB(239, 68, 68),
        BackgroundTransparency = 0.6,
        Text = "×",
        TextColor3 = TEXT_WHITE,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        },
        Parent = self.TitleBar,
    })
    AddHoverEffect(closeBtn, 0.6, 0.3)
    closeBtn.MouseButton1Click:Connect(function()
        self.Open = false
        Tween(self.MainFrame, { Size = UDim2.new(self.Size.X.Offset, 0, self.Size.Y.Offset, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.35, function()
            self.MainFrame.Visible = false
        end)
    end)

    -- Draggable
    MakeDraggable(self.MainFrame, self.TitleBar)

    -- ═════════════════════════════════════
    --  Sidebar (55px, icon-only)
    -- ═════════════════════════════════════
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 55, 1, -38),
        Position = UDim2.fromOffset(0, 38),
        BackgroundColor3 = SIDEBAR_BG,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 0) }),
            Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
            -- Vertical separator
            Create("Frame", {
                Name = "Separator",
                Size = UDim2.new(0, 1, 1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = NEON,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
            }),
        },
        Parent = self.MainFrame,
    })

    -- ═════════════════════════════════════
    --  Content Area (ScrollingFrame)
    -- ═════════════════════════════════════
    self.Content = Create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, -55, 1, -38),
        Position = UDim2.fromOffset(55, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = NEON,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
                PaddingTop = UDim.new(0, 14),
                PaddingBottom = UDim.new(0, 14),
            }),
        },
        Parent = self.MainFrame,
    })

    -- ─── Toggle Keybind ───
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.ToggleKey then
            self.Open = not self.Open
            if self.Open then
                self.MainFrame.Visible = true
                self.MainFrame.Size = UDim2.new(self.Size.X.Offset, 0, self.Size.Y.Offset, 0)
                Tween(self.MainFrame, { Size = self.Size }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                Tween(self.MainFrame, { Size = UDim2.new(self.Size.X.Offset, 0, self.Size.Y.Offset, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.35, function()
                    self.MainFrame.Visible = false
                end)
            end
        end
    end)

    return self
end

-- ═══════════════════════════════════════
--  Tab Creation
-- ═══════════════════════════════════════
function ShadowUI:CreateTab(name, icon)
    local self = self
    self.TabCount = self.TabCount + 1
    local order = self.TabCount

    -- ─── Tab Container (content page) ───
    local tabContainer = Create("ScrollingFrame", {
        Name = name .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = NEON,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Children = {
            Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2),
            }),
        },
        Parent = self.Content,
    })

    -- ─── Sidebar Button (icon-only) ───
    local sidebarBtn = Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(20, 20, 35),
        BackgroundTransparency = 0.85,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = order,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            -- Icon
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0.5, -10, 0.5, -10),
                BackgroundTransparency = 1,
                Image = icon or "rbxassetid://3926305904",
                ImageColor3 = TEXT_DIM,
                ImageTransparency = 0.2,
                ScaleType = Enum.ScaleType.Fit,
            }),
            -- Active indicator (left bar)
            Create("Frame", {
                Name = "Indicator",
                Size = UDim2.new(0, 3, 0, 0),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = NEON,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Children = {
                    Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
                },
            }),
        },
        Parent = self.Sidebar,
    })

    -- Hover effect on sidebar button
    AddHoverEffect(sidebarBtn, 0.85, 0.65)

    -- Tab data
    local tab = {
        Name = name,
        Container = tabContainer,
        Button = sidebarBtn,
        Window = self,
    }

    -- ─── Tab switching logic ───
    local function activateTab()
        -- Deactivate all
        for _, t in pairs(self.Tabs) do
            t.Container.Visible = false
            local icon = t.Button:FindFirstChild("Icon")
            if icon then
                Tween(icon, { ImageColor3 = TEXT_DIM, ImageTransparency = 0.2 }, 0.3)
            end
            local indicator = t.Button:FindFirstChild("Indicator")
            if indicator then
                Tween(indicator, { BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 0) }, 0.25)
            end
            Tween(t.Button, { BackgroundTransparency = 0.85 }, 0.25)
        end

        -- Activate this tab
        tabContainer.Visible = true
        local icon = sidebarBtn:FindFirstChild("Icon")
        if icon then
            Tween(icon, { ImageColor3 = NEON, ImageTransparency = 0 }, 0.3)
        end
        local indicator = sidebarBtn:FindFirstChild("Indicator")
        if indicator then
            Tween(indicator, { BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0, 24) }, 0.3, Enum.EasingStyle.Back)
        end
        Tween(sidebarBtn, { BackgroundTransparency = 0.5 }, 0.25)
    end

    sidebarBtn.MouseButton1Click:Connect(activateTab)

    -- Store tab
    self.Tabs[name] = tab

    -- Auto-select first tab
    if self.TabCount == 1 then
        activateTab()
    end

    -- Return tab object with element methods
    local tabMeta = {}
    tabMeta.__index = tabMeta

    -- ═════════════════════════════════════
    --  CreateButton
    -- ═════════════════════════════════════
    function tabMeta:CreateButton(btnConfig)
        local btn = Create("TextButton", {
            Name = btnConfig.Name or "Button",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(30, 30, 50),
            BackgroundTransparency = 0.7,
            Text = "",
            BorderSizePixel = 0,
            Children = {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                Create("TextLabel", {
                    Text = btnConfig.Name or "Button",
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.fromOffset(14, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = TEXT_WHITE,
                    TextSize = 13,
                    Font = Enum.Font.GothamSSm,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                -- Subtle neon underline on hover
                Create("Frame", {
                    Name = "Underline",
                    Size = UDim2.new(0, 0, 0, 1),
                    Position = UDim2.new(0, 14, 1, -4),
                    BackgroundColor3 = NEON,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                }),
            },
            Parent = tabContainer,
        })

        local underline = btn:FindFirstChild("Underline")

        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.45 }, 0.25)
            if underline then
                Tween(underline, { Size = UDim2.new(1, -28, 0, 1), BackgroundTransparency = 0.5 }, 0.3)
            end
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.7 }, 0.25)
            if underline then
                Tween(underline, { Size = UDim2.new(0, 0, 0, 1), BackgroundTransparency = 1 }, 0.25)
            end
        end)

        btn.MouseButton1Click:Connect(function()
            -- Click flash
            Tween(btn, { BackgroundTransparency = 0.2 }, 0.1)
            Tween(btn, { BackgroundTransparency = 0.7 }, 0.2)
            if btnConfig.Callback then
                btnConfig.Callback()
            end
        end)

        return btn
    end

    -- ═════════════════════════════════════
    --  CreateToggle
    -- ═════════════════════════════════════
    function tabMeta:CreateToggle(toggleConfig)
        local toggled = false

        local toggleFrame = Create("TextButton", {
            Name = toggleConfig.Name or "Toggle",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(30, 30, 50),
            BackgroundTransparency = 0.85,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Children = {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                -- Label
                Create("TextLabel", {
                    Text = toggleConfig.Name or "Toggle",
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.fromOffset(14, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = TEXT_WHITE,
                    TextSize = 13,
                    Font = Enum.Font.GothamSSm,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                -- Toggle knob track
                Create("Frame", {
                    Name = "Track",
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -50, 0.5, -9),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 60),
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Children = {
                        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                        -- Knob
                        Create("Frame", {
                            Name = "Knob",
                            Size = UDim2.new(0, 14, 0, 14),
                            Position = UDim2.new(0, 2, 0.5, -7),
                            BackgroundColor3 = TEXT_DIM,
                            BorderSizePixel = 0,
                            Children = {
                                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                            },
                        }),
                    },
                }),
            },
            Parent = tabContainer,
        })

        AddHoverEffect(toggleFrame, 0.85, 0.65)

        local track = toggleFrame:FindFirstChild("Track")
        local knob = track and track:FindFirstChild("Knob")

        toggleFrame.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                Tween(track, { BackgroundColor3 = NEON }, 0.3)
                Tween(knob, { Position = UDim2.new(0, 20, 0.5, -7), BackgroundColor3 = TEXT_WHITE }, 0.3, Enum.EasingStyle.Back)
            else
                Tween(track, { BackgroundColor3 = Color3.fromRGB(40, 40, 60) }, 0.3)
                Tween(knob, { Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = TEXT_DIM }, 0.3)
            end
            if toggleConfig.Callback then
                toggleConfig.Callback(toggled)
            end
        end)

        return toggleFrame
    end

    -- ═════════════════════════════════════
    --  CreateSlider
    -- ═════════════════════════════════════
    function tabMeta:CreateSlider(sliderConfig)
        local min = sliderConfig.Min or 0
        local max = sliderConfig.Max or 100
        local current = sliderConfig.Default or min
        local suffix = sliderConfig.Suffix or ""

        local sliderFrame = Create("Frame", {
            Name = sliderConfig.Name or "Slider",
            Size = UDim2.new(1, 0, 0, 52),
            BackgroundColor3 = Color3.fromRGB(30, 30, 50),
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Children = {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                -- Label
                Create("TextLabel", {
                    Name = "Label",
                    Text = sliderConfig.Name or "Slider",
                    Size = UDim2.new(0.6, 0, 0, 20),
                    Position = UDim2.fromOffset(14, 6),
                    BackgroundTransparency = 1,
                    TextColor3 = TEXT_WHITE,
                    TextSize = 12,
                    Font = Enum.Font.GothamSSm,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                -- Value display
                Create("TextLabel", {
                    Name = "Value",
                    Text = tostring(math.floor(current)) .. suffix,
                    Size = UDim2.new(0.4, -14, 0, 20),
                    Position = UDim2.new(0.6, 0, 0, 6),
                    BackgroundTransparency = 1,
                    TextColor3 = NEON,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }),
                -- Track
                Create("Frame", {
                    Name = "Track",
                    Size = UDim2.new(1, -28, 0, 6),
                    Position = UDim2.fromOffset(14, 32),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 50),
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Children = {
                        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                        -- Fill
                        Create("Frame", {
                            Name = "Fill",
                            Size = UDim2.new(0, 0, 1, 0),
                            BackgroundColor3 = NEON,
                            BorderSizePixel = 0,
                            Children = {
                                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                            },
                        }),
                    },
                }),
            },
            Parent = tabContainer,
        })

        local track = sliderFrame:FindFirstChild("Track")
        local fill = track and track:FindFirstChild("Fill")
        local valueLabel = sliderFrame:FindFirstChild("Value")

        -- Set initial fill
        local pct = (current - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)

        -- Slider interaction
        local dragging = false

        local function updateSlider(input)
            local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            current = min + (max - min) * relX
            current = math.floor(current)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            valueLabel.Text = tostring(current) .. suffix
            if sliderConfig.Callback then
                sliderConfig.Callback(current)
            end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        return sliderFrame
    end

    -- ═════════════════════════════════════
    --  CreateDropdown
    -- ═════════════════════════════════════
    function tabMeta:CreateDropdown(dropdownConfig)
        local options = dropdownConfig.Options or {}
        local selected = dropdownConfig.Default or options[1] or "Select..."
        local isOpen = false

        local dropdownFrame = Create("Frame", {
            Name = dropdownConfig.Name or "Dropdown",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(30, 30, 50),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Children = {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                -- Selected text
                Create("TextLabel", {
                    Name = "Selected",
                    Text = selected,
                    Size = UDim2.new(1, -40, 0, 38),
                    Position = UDim2.fromOffset(14, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = TEXT_WHITE,
                    TextSize = 13,
                    Font = Enum.Font.GothamSSm,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                -- Arrow
                Create("TextLabel", {
                    Name = "Arrow",
                    Text = "▼",
                    Size = UDim2.new(0, 20, 0, 38),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = NEON,
                    TextSize = 10,
                    Font = Enum.Font.GothamMedium,
                }),
                -- Options container
                Create("Frame", {
                    Name = "Options",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 38),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Children = {
                        Create("UIListLayout", {
                            Padding = UDim.new(0, 2),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                    },
                }),
                -- Click detector
                Create("TextButton", {
                    Name = "ClickDetector",
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    Text = "",
                    BorderSizePixel = 0,
                }),
            },
            Parent = tabContainer,
        })

        AddHoverEffect(dropdownFrame, 0.7, 0.5)

        local optionsContainer = dropdownFrame:FindFirstChild("Options")
        local selectedLabel = dropdownFrame:FindFirstChild("Selected")
        local arrow = dropdownFrame:FindFirstChild("Arrow")
        local clickDetector = dropdownFrame:FindFirstChild("ClickDetector")
        local optionCount = 0

        -- Populate options
        for i, opt in pairs(options) do
            optionCount = optionCount + 1
            local optBtn = Create("TextButton", {
                Name = "Option_" .. opt,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Color3.fromRGB(25, 25, 42),
                BackgroundTransparency = 0.8,
                Text = opt,
                TextColor3 = TEXT_DIM,
                TextSize = 12,
                Font = Enum.Font.GothamSSm,
                BorderSizePixel = 0,
                Children = {
                    Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                },
                Parent = optionsContainer,
            })

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                selectedLabel.Text = opt
                if dropdownConfig.Callback then
                    dropdownConfig.Callback(opt)
                end
                -- Close dropdown
                isOpen = false
                Tween(dropdownFrame, { Size = UDim2.new(1, 0, 0, 38) }, 0.3, Enum.EasingStyle.Back)
                arrow.Text = "▼"
            end)
        end

        -- Toggle dropdown
        clickDetector.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                local targetHeight = 38 + (optionCount * 30)
                Tween(dropdownFrame, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.35, Enum.EasingStyle.Back)
                arrow.Text = "▲"
            else
                Tween(dropdownFrame, { Size = UDim2.new(1, 0, 0, 38) }, 0.3, Enum.EasingStyle.Back)
                arrow.Text = "▼"
            end
        end)

        return dropdownFrame
    end

    -- ═════════════════════════════════════
    --  CreateLabel
    -- ═════════════════════════════════════
    function tabMeta:CreateLabel(labelConfig)
        local label = Create("TextLabel", {
            Name = labelConfig.Name or "Label",
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = labelConfig.Name or "Label",
            TextColor3 = labelConfig.Color or TEXT_DIM,
            TextSize = 12,
            Font = Enum.Font.GothamSSm,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabContainer,
        })
        return label
    end

    -- ═════════════════════════════════════
    --  CreateSection
    -- ═════════════════════════════════════
    function tabMeta:CreateSection(sectionName)
        local section = Create("Frame", {
            Name = sectionName .. "Section",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Children = {
                Create("TextLabel", {
                    Text = sectionName,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.fromOffset(0, 4),
                    BackgroundTransparency = 1,
                    TextColor3 = NEON,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.fromOffset(0, 22),
                    BackgroundColor3 = NEON,
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                }),
            },
            Parent = tabContainer,
        })
        return section
    end

    -- ═════════════════════════════════════
    --  CreateKeybind
    -- ═════════════════════════════════════
    function tabMeta:CreateKeybind(keybindConfig)
        local currentKey = keybindConfig.Default or Enum.KeyCode.E
        local listening = false

        local keybindFrame = Create("TextButton", {
            Name = keybindConfig.Name or "Keybind",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(30, 30, 50),
            BackgroundTransparency = 0.85,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Children = {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                Create("TextLabel", {
                    Text = keybindConfig.Name or "Keybind",
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.fromOffset(14, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = TEXT_WHITE,
                    TextSize = 13,
                    Font = Enum.Font.GothamSSm,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                Create("TextLabel", {
                    Name = "KeyDisplay",
                    Text = currentKey.Name,
                    Size = UDim2.new(0.3, -10, 0, 24),
                    Position = UDim2.new(0.7, 0, 0.5, -12),
                    BackgroundColor3 = Color3.fromRGB(25, 25, 42),
                    BackgroundTransparency = 0.5,
                    TextColor3 = NEON,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    BorderSizePixel = 0,
                    Children = {
                        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    },
                }),
            },
            Parent = tabContainer,
        })

        AddHoverEffect(keybindFrame, 0.85, 0.65)

        local keyDisplay = keybindFrame:FindFirstChild("KeyDisplay")

        keybindFrame.MouseButton1Click:Connect(function()
            listening = true
            keyDisplay.Text = "..."
            Tween(keyDisplay, { TextColor3 = Color3.fromRGB(255, 255, 100) }, 0.2)
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if listening and not processed then
                listening = false
                currentKey = input.KeyCode
                keyDisplay.Text = currentKey.Name
                Tween(keyDisplay, { TextColor3 = NEON }, 0.2)
                if keybindConfig.Callback then
                    keybindConfig.Callback(currentKey)
                end
            elseif not listening and input.KeyCode == currentKey and keybindConfig.Callback then
                keybindConfig.Callback(currentKey)
            end
        end)

        return keybindFrame
    end

    -- ═════════════════════════════════════
    --  CreateParagraph
    -- ═════════════════════════════════════
    function tabMeta:CreateParagraph(paraConfig)
        local para = Create("Frame", {
            Name = "Paragraph",
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Color3.fromRGB(30, 30, 50),
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Children = {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                Create("TextLabel", {
                    Name = "Title",
                    Text = paraConfig.Title or "",
                    Size = UDim2.new(1, -24, 0, 18),
                    Position = UDim2.fromOffset(12, 8),
                    BackgroundTransparency = 1,
                    TextColor3 = NEON,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                Create("TextLabel", {
                    Name = "Body",
                    Text = paraConfig.Text or "",
                    Size = UDim2.new(1, -24, 0, 20),
                    Position = UDim2.fromOffset(12, 26),
                    BackgroundTransparency = 1,
                    TextColor3 = TEXT_DIM,
                    TextSize = 11,
                    Font = Enum.Font.GothamSSm,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                }),
            },
            Parent = tabContainer,
        })
        return para
    end

    return setmetatable({}, tabMeta)
end

-- ═══════════════════════════════════════
--  Notification Method (on Window)
-- ═══════════════════════════════════════
function ShadowUI:Notify(title, text, duration, color)
    self.Notifications:Notify(title, text, duration, color)
end

-- ═══════════════════════════════════════
--  Destroy
-- ═══════════════════════════════════════
function ShadowUI:Destroy()
    self.ScreenGui:Destroy()
end

return ShadowUI
