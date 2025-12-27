local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local IncharillaUI = {}
IncharillaUI.__index = IncharillaUI

function IncharillaUI.new(config)
    local self = setmetatable({}, IncharillaUI)
    
    self.gui = nil
    self.frame = nil
    self.titleBar = nil
    self.tabContainer = nil
    self.contentFrame = nil
    
    self.minimized = false
    self.activeTab = nil
    self.connections = {}
    self.tabs = {}
    self.buttons = {}
    
    self.config = {
        name = config.name or "IncharillaUI",
        size = config.size or UDim2.fromOffset(350, 420),
        position = config.position or UDim2.new(0.5, -175, 0.5, -210),
        backgroundColor = config.backgroundColor or Color3.fromRGB(18, 18, 28),
        titleBarColor = config.titleBarColor or Color3.fromRGB(25, 25, 38),
        tabColor = config.tabColor or Color3.fromRGB(30, 30, 45),
        accentColor = config.accentColor or Color3.fromRGB(0, 170, 255),
        textColor = config.textColor or Color3.fromRGB(255, 255, 255),
        transparency = config.transparency or 0.05,
        cornerRadius = config.cornerRadius or 16,
        strokeColor = config.strokeColor or Color3.fromRGB(100, 100, 150),
        strokeThickness = config.strokeThickness or 2.5,
        savePosition = config.savePosition == nil and true or config.savePosition,
        allowDragging = config.allowDragging == nil and true or config.allowDragging,
        allowMinimize = config.allowMinimize == nil and true or config.allowMinimize,
        allowClose = config.allowClose == nil and true or config.allowClose,
        parent = config.parent or game:GetService("CoreGui")
    }
    
    self:init()
    return self
end

function IncharillaUI:init()
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = self.config.name
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.Parent = self.config.parent
    
    self.frame = Instance.new("Frame")
    self.frame.Size = self.config.size
    self.frame.Position = self.config.position
    self.frame.BackgroundColor3 = self.config.backgroundColor
    self.frame.BackgroundTransparency = self.config.transparency
    self.frame.BorderSizePixel = 0
    self.frame.ClipsDescendants = true
    self.frame.Parent = self.gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.config.cornerRadius)
    corner.Parent = self.frame
    
    if self.config.strokeThickness > 0 then
        self.stroke = Instance.new("UIStroke")
        self.stroke.Color = self.config.strokeColor
        self.stroke.Thickness = self.config.strokeThickness
        self.stroke.Transparency = 0.15
        self.stroke.LineJoinMode = Enum.LineJoinMode.Round
        self.stroke.Parent = self.frame
    end
    
    self:createTitleBar()
    self:createTabContainer()
    
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Size = UDim2.new(1, 0, 1, -88)
    self.contentFrame.Position = UDim2.new(0, 0, 0, 88)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.Parent = self.frame
    
    self.minimizedSize = UDim2.fromOffset(self.config.size.X.Offset, 48)
    
    if self.config.allowDragging then
        self:setupDragging()
    end
end

function IncharillaUI:createTitleBar()
    self.titleBar = Instance.new("Frame")
    self.titleBar.Size = UDim2.new(1, 0, 0, 48)
    self.titleBar.BackgroundColor3 = self.config.titleBarColor
    self.titleBar.BorderSizePixel = 0
    self.titleBar.ZIndex = 2
    self.titleBar.Parent = self.frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, self.config.cornerRadius, 0, 0)
    titleCorner.Parent = self.titleBar
    
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 20, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = self.config.name:upper()
    self.titleLabel.TextColor3 = self.config.textColor
    self.titleLabel.Font = Enum.Font.GothamBlack
    self.titleLabel.TextSize = 20
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Parent = self.titleBar
    
    local buttonX = -40
    local buttonCount = 0
    
    if self.config.allowClose then
        buttonCount = buttonCount + 1
        buttonX = -40
        self.closeBtn = self:createTitleButton("×", UDim2.new(1, buttonX, 0.5, -16), Color3.fromRGB(255, 70, 70))
        self.closeBtn.MouseButton1Click:Connect(function()
            self:destroy()
        end)
    end
    
    if self.config.allowMinimize then
        buttonCount = buttonCount + 1
        buttonX = -40 - (buttonCount-1)*40
        self.minimizeBtn = self:createTitleButton("−", UDim2.new(1, buttonX, 0.5, -16), Color3.fromRGB(80, 80, 120))
        self.minimizeBtn.MouseButton1Click:Connect(function()
            self:toggleMinimize()
        end)
    end
    
    self.titleLabel.Size = UDim2.new(1, -(buttonCount * 40 + 20), 1, 0)
end

function IncharillaUI:createTitleButton(text, position, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(32, 32)
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = text == "×" and 22 or 24
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color:Lerp(Color3.new(1, 1, 1), 0.3)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.2),
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = color:Lerp(Color3.new(1, 1, 1), 0.5)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.2
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = color:Lerp(Color3.new(1, 1, 1), 0.3)
        }):Play()
    end)
    
    btn.Parent = self.titleBar
    return btn
end

function IncharillaUI:createTabContainer()
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Size = UDim2.new(1, 0, 0, 40)
    self.tabContainer.Position = UDim2.new(0, 0, 0, 48)
    self.tabContainer.BackgroundColor3 = self.config.tabColor
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.ZIndex = 2
    self.tabContainer.Parent = self.frame
    
    self.tabListLayout = Instance.new("UIListLayout")
    self.tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    self.tabListLayout.Padding = UDim.new(0, 0)
    self.tabListLayout.Parent = self.tabContainer
end

function IncharillaUI:toggleMinimize()
    if not self.config.allowMinimize then return end
    
    self.minimized = not self.minimized
    
    if self.minimized then
        self.minimizeBtn.Text = "+"
        TweenService:Create(self.frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = self.minimizedSize
        }):Play()
        task.wait(0.15)
        self.contentFrame.Visible = false
        self.tabContainer.Visible = false
    else
        self.minimizeBtn.Text = "−"
        TweenService:Create(self.frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = self.config.size
        }):Play()
        task.wait(0.15)
        self.contentFrame.Visible = true
        self.tabContainer.Visible = true
    end
end

function IncharillaUI:setupDragging()
    local dragging = false
    local dragStart, startPos
    
    local function updateDrag(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end
    
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.frame.Position
            
            self.connections.drag = UserInputService.InputChanged:Connect(updateDrag)
        end
    end
    
    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if self.connections.drag then
                self.connections.drag:Disconnect()
                self.connections.drag = nil
            end
        end
    end
    
    self.titleBar.InputBegan:Connect(startDrag)
    self.titleBar.InputEnded:Connect(endDrag)
end

function IncharillaUI:addTab(tabName, displayName)
    displayName = displayName or tabName
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.25, 0, 1, 0)
    tabBtn.BackgroundColor3 = self.tabs[1] and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(50, 50, 80)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = displayName
    tabBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.AutoButtonColor = false
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = tabName
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.Position = UDim2.new(0, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 4
    tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.Visible = false
    tabFrame.Parent = self.contentFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 8)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = tabFrame
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    if not self.tabs[1] then
        tabFrame.Visible = true
        self.activeTab = tabName
    end
    
    tabBtn.MouseEnter:Connect(function()
        if self.activeTab ~= tabName then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 70)
            }):Play()
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if self.activeTab ~= tabName then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            }):Play()
        end
    end)
    
    tabBtn.MouseButton1Click:Connect(function()
        for name, frame in pairs(self.tabs) do
            frame.Visible = false
            if name ~= tabName then
                for _, btn in pairs(self.tabContainer:GetChildren()) do
                    if btn:IsA("TextButton") and btn.Text == (self.tabNames[name] or name) then
                        TweenService:Create(btn, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                        }):Play()
                    end
                end
            end
        end
        
        tabFrame.Visible = true
        self.activeTab = tabName
        TweenService:Create(tabBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        }):Play()
    end)
    
    tabBtn.Parent = self.tabContainer
    self.tabs[tabName] = tabFrame
    self.tabNames = self.tabNames or {}
    self.tabNames[tabName] = displayName
    
    return tabFrame
end

function IncharillaUI:addButton(tabName, buttonText, callback)
    local tabFrame = self.tabs[tabName]
    if not tabFrame then return nil end
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 48)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.LayoutOrder = #tabFrame:GetChildren()
    button.Parent = tabFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(100, 100, 150)
    buttonStroke.Thickness = 1.5
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = buttonText
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Size = UDim2.fromOffset(8, 8)
    statusIndicator.Position = UDim2.new(1, -20, 0.5, -4)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    statusIndicator.BorderSizePixel = 0
    statusIndicator.Visible = false
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = statusIndicator
    statusIndicator.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        }):Play()
        TweenService:Create(buttonStroke, TweenInfo.new(0.25), {
            Color = self.config.accentColor,
            Transparency = 0.2
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        }):Play()
        TweenService:Create(buttonStroke, TweenInfo.new(0.25), {
            Color = Color3.fromRGB(100, 100, 150),
            Transparency = 0.3
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        }):Play()
        if callback then
            callback()
        end
    end)
    
    local buttonData = {
        button = button,
        label = label,
        status = statusIndicator,
        setText = function(text)
            label.Text = text
        end,
        setStatus = function(visible, color)
            statusIndicator.Visible = visible
            if visible and color then
                statusIndicator.BackgroundColor3 = color
            end
        end
    }
    
    self.buttons[buttonText] = buttonData
    return buttonData
end

function IncharillaUI:addLabel(tabName, text, options)
    local tabFrame = self.tabs[tabName]
    if not tabFrame then return nil end
    
    options = options or {}
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, options.height or 28)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.color or self.config.accentColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = options.size or 14
    label.TextXAlignment = options.align or Enum.TextXAlignment.Left
    label.LayoutOrder = #tabFrame:GetChildren()
    label.Parent = tabFrame
    
    return label
end

function IncharillaUI:setVisible(visible)
    self.gui.Enabled = visible
end

function IncharillaUI:setPosition(position)
    self.frame.Position = position
end

function IncharillaUI:setSize(size)
    self.frame.Size = size
    self.minimizedSize = UDim2.fromOffset(size.X.Offset, 48)
end

function IncharillaUI:destroy()
    for _, conn in pairs(self.connections) do
        pcall(function() conn:Disconnect() end)
    end
    if self.gui then
        self.gui:Destroy()
    end
    setmetatable(self, nil)
end

return IncharillaUI
