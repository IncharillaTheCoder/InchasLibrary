local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local IncharillaUI = {}
IncharillaUI.__index = IncharillaUI

local Themes = {
    default = {
        background = Color3.fromRGB(18, 18, 28),
        titleBar = Color3.fromRGB(25, 25, 38),
        tab = Color3.fromRGB(30, 30, 45),
        accent = Color3.fromRGB(0, 170, 255),
        text = Color3.fromRGB(255, 255, 255),
        button = Color3.fromRGB(35, 35, 50),
        stroke = Color3.fromRGB(100, 100, 150)
    },
    dark = {
        background = Color3.fromRGB(10, 10, 15),
        titleBar = Color3.fromRGB(15, 15, 25),
        tab = Color3.fromRGB(20, 20, 30),
        accent = Color3.fromRGB(0, 220, 100),
        text = Color3.fromRGB(240, 240, 240),
        button = Color3.fromRGB(25, 25, 40),
        stroke = Color3.fromRGB(80, 80, 120)
    },
    purple = {
        background = Color3.fromRGB(25, 15, 35),
        titleBar = Color3.fromRGB(35, 20, 45),
        tab = Color3.fromRGB(40, 25, 55),
        accent = Color3.fromRGB(180, 80, 255),
        text = Color3.fromRGB(255, 255, 255),
        button = Color3.fromRGB(45, 30, 60),
        stroke = Color3.fromRGB(120, 80, 160)
    },
    red = {
        background = Color3.fromRGB(28, 10, 10),
        titleBar = Color3.fromRGB(40, 15, 15),
        tab = Color3.fromRGB(50, 20, 20),
        accent = Color3.fromRGB(255, 60, 60),
        text = Color3.fromRGB(255, 255, 255),
        button = Color3.fromRGB(45, 20, 20),
        stroke = Color3.fromRGB(150, 80, 80)
    },
    ocean = {
        background = Color3.fromRGB(10, 20, 35),
        titleBar = Color3.fromRGB(15, 30, 50),
        tab = Color3.fromRGB(20, 40, 60),
        accent = Color3.fromRGB(0, 180, 255),
        text = Color3.fromRGB(220, 240, 255),
        button = Color3.fromRGB(25, 45, 65),
        stroke = Color3.fromRGB(50, 100, 150)
    }
}

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
    self.labels = {}
    self.sliders = {}
    self.toggles = {}
    self.dropdowns = {}
    self.keybinds = {}
    self.currentTheme = config.theme or "default"
    
    self.config = {
        name = config.name or "IncharillaUI",
        size = config.size or UDim2.fromOffset(350, 420),
        position = config.position or UDim2.new(0.5, -175, 0.5, -210),
        theme = config.theme or "default",
        transparency = config.transparency or 0.05,
        cornerRadius = config.cornerRadius or 16,
        strokeThickness = config.strokeThickness or 2.5,
        savePosition = config.savePosition == nil and true or config.savePosition,
        saveTheme = config.saveTheme == nil and true or config.saveTheme,
        allowDragging = config.allowDragging == nil and true or config.allowDragging,
        allowMinimize = config.allowMinimize == nil and true or config.allowMinimize,
        allowClose = config.allowClose == nil and true or config.allowClose,
        parent = config.parent or game:GetService("CoreGui"),
        toggleKey = config.toggleKey or Enum.KeyCode.RightShift,
        autoLoad = config.autoLoad == nil and true or config.autoLoad
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
    self.frame.BackgroundColor3 = Themes[self.currentTheme].background
    self.frame.BackgroundTransparency = self.config.transparency
    self.frame.BorderSizePixel = 0
    self.frame.ClipsDescendants = true
    self.frame.Parent = self.gui
    
    self.corner = Instance.new("UICorner")
    self.corner.CornerRadius = UDim.new(0, self.config.cornerRadius)
    self.corner.Parent = self.frame
    
    if self.config.strokeThickness > 0 then
        self.stroke = Instance.new("UIStroke")
        self.stroke.Color = Themes[self.currentTheme].stroke
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
    
    if self.config.savePosition and self.config.autoLoad then
        self:loadConfig()
    end
    
    if self.config.toggleKey then
        self:setupToggleKey()
    end
end

function IncharillaUI:createTitleBar()
    self.titleBar = Instance.new("Frame")
    self.titleBar.Size = UDim2.new(1, 0, 0, 48)
    self.titleBar.BackgroundColor3 = Themes[self.currentTheme].titleBar
    self.titleBar.BorderSizePixel = 0
    self.titleBar.ZIndex = 2
    self.titleBar.Parent = self.frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, self.config.cornerRadius, 0, 0)
    titleCorner.Parent = self.titleBar
    
    self.titleGradient = Instance.new("UIGradient")
    self.titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Themes[self.currentTheme].accent),
        ColorSequenceKeypoint.new(0.5, Themes[self.currentTheme].accent:Lerp(Color3.fromRGB(255, 255, 255), 0.3)),
        ColorSequenceKeypoint.new(1, Themes[self.currentTheme].accent)
    })
    self.titleGradient.Rotation = -15
    self.titleGradient.Transparency = NumberSequence.new(0.2)
    self.titleGradient.Parent = self.titleBar
    
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 20, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = self.config.name:upper()
    self.titleLabel.TextColor3 = Themes[self.currentTheme].text
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
    
    if self.config.saveTheme then
        buttonCount = buttonCount + 1
        buttonX = -40 - (buttonCount-1)*40
        self.themeBtn = self:createTitleButton("T", UDim2.new(1, buttonX, 0.5, -16), Color3.fromRGB(120, 80, 200))
        self.themeBtn.MouseButton1Click:Connect(function()
            self:cycleTheme()
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
    btn.TextSize = text == "×" and 22 or (text == "T" and 16 or 24)
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
    self.tabContainer.BackgroundColor3 = Themes[self.currentTheme].tab
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
    
    if self.config.savePosition then
        self:saveConfig()
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
            if self.config.savePosition then
                self:saveConfig()
            end
        end
    end
    
    self.titleBar.InputBegan:Connect(startDrag)
    self.titleBar.InputEnded:Connect(endDrag)
end

function IncharillaUI:setupToggleKey()
    if not self.config.toggleKey then return end
    
    self.connections.toggleKey = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.config.toggleKey then
            self:setVisible(not self.gui.Enabled)
        end
    end)
end

function IncharillaUI:saveConfig()
    if not writefile then return end
    
    local saveData = {
        position = self.frame.Position,
        minimized = self.minimized,
        theme = self.currentTheme
    }
    
    pcall(function()
        writefile(self.config.name .. "_Config.json", HttpService:JSONEncode(saveData))
    end)
end

function IncharillaUI:loadConfig()
    if not readfile or not isfile or not isfile(self.config.name .. "_Config.json") then return end
    
    pcall(function()
        local saved = HttpService:JSONDecode(readfile(self.config.name .. "_Config.json"))
        if saved.position then
            self.frame.Position = saved.position
        end
        if saved.minimized ~= nil then
            self.minimized = saved.minimized
            if self.minimized then
                self.frame.Size = self.minimizedSize
                self.contentFrame.Visible = false
                self.tabContainer.Visible = false
                if self.minimizeBtn then
                    self.minimizeBtn.Text = "+"
                end
            end
        end
        if saved.theme then
            self:setTheme(saved.theme)
        end
    end)
end

function IncharillaUI:addTab(tabName, displayName)
    displayName = displayName or tabName
    
    local isFirstTab = next(self.tabs) == nil
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.25, 0, 1, 0)
    tabBtn.BackgroundColor3 = isFirstTab and Color3.fromRGB(50, 50, 80) or Color3.fromRGB(40, 40, 60)
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
    tabFrame.ScrollBarImageColor3 = Themes[self.currentTheme].stroke
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.Visible = isFirstTab
    tabFrame.Parent = self.contentFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 8)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = tabFrame
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    if isFirstTab then
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
        end
        
        for _, btn in pairs(self.tabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                }):Play()
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
    if not tabFrame then 
        warn("Tab not found:", tabName)
        return nil 
    end
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 7, 0, 48)
    button.BackgroundColor3 = Themes[self.currentTheme].button
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = tabFrame

    local buttonCount = 0
    for _, child in ipairs(tabFrame:GetChildren()) do
        if child:IsA("TextButton") or (child:IsA("Frame") and child.BackgroundTransparency < 1) then
            buttonCount = buttonCount + 1
        end
    end
    button.LayoutOrder = buttonCount
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Themes[self.currentTheme].stroke
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
            BackgroundColor3 = Themes[self.currentTheme].button:Lerp(Color3.new(1, 1, 1), 0.1)
        }):Play()
        TweenService:Create(buttonStroke, TweenInfo.new(0.25), {
            Color = Themes[self.currentTheme].accent,
            Transparency = 0.2
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundColor3 = Themes[self.currentTheme].button
        }):Play()
        TweenService:Create(buttonStroke, TweenInfo.new(0.25), {
            Color = Themes[self.currentTheme].stroke,
            Transparency = 0.3
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Themes[self.currentTheme].button:Lerp(Color3.new(0, 0, 0), 0.1)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Themes[self.currentTheme].button:Lerp(Color3.new(1, 1, 1), 0.1)
        }):Play()
        if callback then
            task.spawn(callback)
        end
    end)
    
    local buttonData = {
        button = button,
        label = label,
        status = statusIndicator,
        setText = function(self, text)
            label.Text = text
        end,
        setStatus = function(self, visible, color)
            statusIndicator.Visible = visible
            if visible and color then
                statusIndicator.BackgroundColor3 = color
            end
        end,
        setEnabled = function(self, enabled)
            button.Active = enabled
            button.TextTransparency = enabled and 1 or 0.5
            label.TextTransparency = enabled and 0 or 0.5
        end
    }
    
    self.buttons[buttonText] = buttonData
    return buttonData
end

function IncharillaUI:addToggle(tabName, toggleText, defaultValue, callback)
    local buttonData = self:addButton(tabName, toggleText, function()
        local newValue = not buttonData.toggleState
        buttonData.toggleState = newValue
        buttonData:setStatus(newValue, newValue and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50))
        buttonData:setText(newValue and toggleText .. " ✓" or toggleText)
        if callback then
            task.spawn(callback, newValue)
        end
    end)
    
    if buttonData then
        buttonData.toggleState = defaultValue or false
        buttonData:setStatus(buttonData.toggleState, buttonData.toggleState and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50))
        buttonData:setText(buttonData.toggleState and toggleText .. " ✓" or toggleText)
    end
    
    return buttonData
end

function IncharillaUI:addSlider(tabName, sliderText, minValue, maxValue, defaultValue, callback)
    local tabFrame = self.tabs[tabName]
    if not tabFrame then return nil end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 60)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #tabFrame:GetChildren()
    container.Parent = tabFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = sliderText .. ": " .. (defaultValue or minValue)
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 30)
    sliderTrack.BackgroundColor3 = Themes[self.currentTheme].button
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Themes[self.currentTheme].accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Size = UDim2.fromOffset(16, 16)
    sliderThumb.Position = UDim2.new(0, 0, 0.5, -8)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderThumb.BorderSizePixel = 0
    sliderThumb.Parent = sliderTrack
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = sliderThumb
    
    local currentValue = defaultValue or minValue
    local isDragging = false
    
    local function updateSlider(value)
        currentValue = math.clamp(value, minValue, maxValue)
        local percentage = (currentValue - minValue) / (maxValue - minValue)
        
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderThumb.Position = UDim2.new(percentage, -8, 0.5, -8)
        label.Text = sliderText .. ": " .. math.floor(currentValue * 100) / 100
        
        if callback then
            callback(currentValue)
        end
    end
    
    updateSlider(currentValue)
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not isDragging then
                    connection:Disconnect()
                    return
                end
                
                local mousePos = UserInputService:GetMouseLocation()
                local sliderAbsolute = sliderTrack.AbsolutePosition
                local sliderSize = sliderTrack.AbsoluteSize
                
                local relativeX = (mousePos.X - sliderAbsolute.X) / sliderSize.X
                relativeX = math.clamp(relativeX, 0, 1)
                
                local value = minValue + (relativeX * (maxValue - minValue))
                updateSlider(value)
            end)
            
            local function endDrag(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end
            
            UserInputService.InputEnded:Connect(endDrag)
        end
    end
    
    sliderTrack.InputBegan:Connect(onInput)
    
    local sliderData = {
        container = container,
        label = label,
        getValue = function()
            return currentValue
        end,
        setValue = function(value)
            updateSlider(value)
        end
    }
    
    self.sliders[sliderText] = sliderData
    return sliderData
end

function IncharillaUI:addLabel(tabName, text, options)
    local tabFrame = self.tabs[tabName]
    if not tabFrame then return nil end
    
    options = options or {}
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, options.height or 28)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.color or Themes[self.currentTheme].accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = options.size or 14
    label.TextXAlignment = options.align or Enum.TextXAlignment.Left
    label.LayoutOrder = #tabFrame:GetChildren()
    label.Parent = tabFrame
    
    self.labels[text] = label
    return label
end

function IncharillaUI:addDropdown(tabName, dropdownText, options, defaultValue, callback)
    local tabFrame = self.tabs[tabName]
    if not tabFrame then return nil end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #tabFrame:GetChildren()
    container.Parent = tabFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundColor3 = Themes[self.currentTheme].button
    dropdownButton.BackgroundTransparency = 0.1
    dropdownButton.Text = ""
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = container
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdownButton
    
    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = Themes[self.currentTheme].stroke
    dropdownStroke.Thickness = 1.5
    dropdownStroke.Transparency = 0.3
    dropdownStroke.Parent = dropdownButton
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = dropdownText .. ": " .. (defaultValue or options[1] or "Select")
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0.2, 0, 1, 0)
    arrow.Position = UDim2.new(0.8, 0, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Themes[self.currentTheme].accent
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.Parent = container
    
    local dropdownOpen = false
    local dropdownFrame = nil
    local selectedValue = defaultValue or options[1]
    
    local function createDropdownList()
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownFrame = nil
            return
        end
        
        dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, 0, 0, #options * 30)
        dropdownFrame.Position = UDim2.new(0, 0, 1, 5)
        dropdownFrame.BackgroundColor3 = Themes[self.currentTheme].button
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ZIndex = 100
        dropdownFrame.Parent = container
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 8)
        listCorner.Parent = dropdownFrame
        
        local listStroke = Instance.new("UIStroke")
        listStroke.Color = Themes[self.currentTheme].stroke
        listStroke.Thickness = 1
        listStroke.Parent = dropdownFrame
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 30)
            optionButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
            optionButton.BackgroundColor3 = i % 2 == 0 and Themes[self.currentTheme].button or Themes[self.currentTheme].button:Lerp(Color3.new(1,1,1), 0.05)
            optionButton.BackgroundTransparency = 0
            optionButton.Text = option
            optionButton.TextColor3 = Color3.fromRGB(220, 220, 240)
            optionButton.Font = Enum.Font.GothamMedium
            optionButton.TextSize = 12
            optionButton.AutoButtonColor = false
            optionButton.Parent = dropdownFrame
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Themes[self.currentTheme].accent
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = i % 2 == 0 and Themes[self.currentTheme].button or Themes[self.currentTheme].button:Lerp(Color3.new(1,1,1), 0.05)
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selectedValue = option
                label.Text = dropdownText .. ": " .. option
                createDropdownList()
                if callback then
                    callback(option)
                end
            end)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(createDropdownList)
    
    local dropdownData = {
        container = container,
        label = label,
        getValue = function()
            return selectedValue
        end,
        setValue = function(value)
            if table.find(options, value) then
                selectedValue = value
                label.Text = dropdownText .. ": " .. value
                if callback then
                    callback(value)
                end
            end
        end
    }
    
    self.dropdowns[dropdownText] = dropdownData
    return dropdownData
end

function IncharillaUI:addKeybind(tabName, keybindText, defaultKey, callback)
    local buttonData = self:addButton(tabName, keybindText .. ": " .. (defaultKey and defaultKey.Name or "NONE"), function()
        buttonData.listening = true
        buttonData:setText(keybindText .. ": PRESS KEY...")
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                buttonData.currentKey = input.KeyCode
                buttonData:setText(keybindText .. ": " .. input.KeyCode.Name)
                buttonData.listening = false
                connection:Disconnect()
                
                if callback then
                    callback(input.KeyCode)
                end
            end
        end)
    end)
    
    if buttonData then
        buttonData.currentKey = defaultKey
        buttonData.listening = false
    end
    
    return buttonData
end

function IncharillaUI:addSeparator(tabName, height)
    local tabFrame = self.tabs[tabName]
    if not tabFrame then return nil end
    
    height = height or 1
    
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, -20, 0, height)
    separator.Position = UDim2.new(0, 10, 0, 0)
    separator.BackgroundColor3 = Themes[self.currentTheme].stroke
    separator.BackgroundTransparency = 0.7
    separator.BorderSizePixel = 0
    separator.LayoutOrder = #tabFrame:GetChildren()
    separator.Parent = tabFrame
    
    return separator
end

function IncharillaUI:setTheme(themeName)
    if not Themes[themeName] then return end
    
    self.currentTheme = themeName
    
    self.frame.BackgroundColor3 = Themes[themeName].background
    self.titleBar.BackgroundColor3 = Themes[themeName].titleBar
    self.tabContainer.BackgroundColor3 = Themes[themeName].tab
    
    if self.stroke then
        self.stroke.Color = Themes[themeName].stroke
    end
    
    self.titleLabel.TextColor3 = Themes[themeName].text
    
    self.titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Themes[themeName].accent),
        ColorSequenceKeypoint.new(0.5, Themes[themeName].accent:Lerp(Color3.fromRGB(255, 255, 255), 0.3)),
        ColorSequenceKeypoint.new(1, Themes[themeName].accent)
    })
    
    for _, tabFrame in pairs(self.tabs) do
        tabFrame.ScrollBarImageColor3 = Themes[themeName].stroke
    end
    
    for _, buttonData in pairs(self.buttons) do
        buttonData.button.BackgroundColor3 = Themes[themeName].button
        buttonData.button.UIStroke.Color = Themes[themeName].stroke
    end
    
    if self.config.saveTheme then
        self:saveConfig()
    end
end

function IncharillaUI:cycleTheme()
    local themeNames = {}
    for name, _ in pairs(Themes) do
        table.insert(themeNames, name)
    end
    
    local currentIndex = table.find(themeNames, self.currentTheme) or 1
    local nextIndex = (currentIndex % #themeNames) + 1
    
    self:setTheme(themeNames[nextIndex])
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

function IncharillaUI:setTitle(title)
    self.titleLabel.Text = title:upper()
end

function IncharillaUI:setTransparency(transparency)
    self.frame.BackgroundTransparency = transparency
end

function IncharillaUI:bringToFront()
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.gui.DisplayOrder = 999
end

function IncharillaUI:flashTitleBar(color, duration)
    duration = duration or 0.5
    local originalColor = self.titleBar.BackgroundColor3
    
    TweenService:Create(self.titleBar, TweenInfo.new(duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = color or Themes[self.currentTheme].accent
    }):Play()
    
    task.wait(duration/2)
    
    TweenService:Create(self.titleBar, TweenInfo.new(duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = originalColor
    }):Play()
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
