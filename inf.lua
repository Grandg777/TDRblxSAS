local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration)
    duration = duration or 0.3
    TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

local function AddDragging(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main Library
function Library:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Window"
    local mainColor = config.Color or Color3.fromRGB(45, 45, 55)
    local accentColor = config.Accent or Color3.fromRGB(0, 162, 255)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    -- Main GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "LibraryGUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = mainColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -250, 0.5, -200),
        Size = UDim2.new(0, 500, 0, 400),
        ClipsDescendants = true
    })
    
    -- UI Corner
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })
    
    -- Top Bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    -- Title
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = windowName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Close Button
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Toggle visibility with configurable key (default Right Shift)
    local isVisible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            isVisible = not isVisible
            MainFrame.Visible = isVisible
        end
    end)
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 65),
        Size = UDim2.new(1, 0, 1, -65)
    })
    
    AddDragging(MainFrame, TopBar)
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    function Window:CreateTab(tabName)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 100, 1, 0),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            AutoButtonColor = false
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            Visible = false
        })
        
        local ContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab Selection
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                tab.Content.Visible = false
            end
            
            TabButton.BackgroundColor3 = mainColor
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        -- Auto-select first tab
        if #Window.Tabs == 0 then
            TabButton.BackgroundColor3 = mainColor
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Section Functions
        function Tab:CreateSection(sectionName)
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Parent = TabContent,
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -10, 0, 30)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SectionFrame
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ElementContainer = Create("Frame", {
                Name = "Elements",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 30),
                Size = UDim2.new(1, -10, 0, 0)
            })
            
            local ElementLayout = Create("UIListLayout", {
                Parent = ElementContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            local function UpdateSize()
                SectionFrame.Size = UDim2.new(1, -10, 0, ElementLayout.AbsoluteContentSize.Y + 35)
            end
            
            ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
            
            -- Button
            function Section:CreateButton(config)
                config = config or {}
                local buttonText = config.Text or "Button"
                local callback = config.Callback or function() end
                
                local ButtonFrame = Create("Frame", {
                    Name = "Button",
                    Parent = ElementContainer,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ButtonFrame
                })
                
                local Button = Create("TextButton", {
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = buttonText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13
                })
                
                Button.MouseButton1Click:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = accentColor}, 0.1)
                    wait(0.1)
                    Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, 0.1)
                    callback()
                end)
                
                UpdateSize()
            end
            
            -- Toggle
            function Section:CreateToggle(config)
                config = config or {}
                local toggleText = config.Text or "Toggle"
                local default = config.Default or false
                local callback = config.Callback or function() end
                
                local ToggleFrame = Create("Frame", {
                    Name = "Toggle",
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0.5, 0),
                    Parent = ToggleButton
                })
                
                local ToggleCircle = Create("Frame", {
                    Parent = ToggleButton,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0.5, 0),
                    Parent = ToggleCircle
                })
                
                local toggled = default
                
                local function UpdateToggle()
                    if toggled then
                        Tween(ToggleButton, {BackgroundColor3 = accentColor})
                        Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)})
                    else
                        Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)})
                        Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)})
                    end
                    callback(toggled)
                end
                
                UpdateToggle()
                
                ToggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        toggled = not toggled
                        UpdateToggle()
                    end
                end)
                
                UpdateSize()
                
                return {
                    SetValue = function(value)
                        toggled = value
                        UpdateToggle()
                    end
                }
            end
            
            -- Slider
            function Section:CreateSlider(config)
                config = config or {}
                local sliderText = config.Text or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local increment = config.Increment or 1
                local callback = config.Callback or function() end
                
                local SliderFrame = Create("Frame", {
                    Name = "Slider",
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.5, 0, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = sliderText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0.5, -5, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = tostring(default),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBar = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    Position = UDim2.new(0, 5, 0, 30),
                    Size = UDim2.new(1, -10, 0, 6)
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0.5, 0),
                    Parent = SliderBar
                })
                
                local SliderFill = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = accentColor,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0.5, 0),
                    Parent = SliderFill
                })
                
                local SliderButton = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0.5, 0),
                    Parent = SliderButton
                })
                
                local value = default
                local dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
                    
                    ValueLabel.Text = tostring(value)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderButton.Position = UDim2.new(pos, -6, 0.5, -6)
                    
                    callback(value)
                end
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                -- Set initial value
                local initialPos = (default - min) / (max - min)
                SliderFill.Size = UDim2.new(initialPos, 0, 1, 0)
                SliderButton.Position = UDim2.new(initialPos, -6, 0.5, -6)
                
                UpdateSize()
                
                return {
                    SetValue = function(newValue)
                        value = math.clamp(newValue, min, max)
                        local pos = (value - min) / (max - min)
                        ValueLabel.Text = tostring(value)
                        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                        SliderButton.Position = UDim2.new(pos, -6, 0.5, -6)
                        callback(value)
                    end
                }
            end
            
            -- Dropdown
            function Section:CreateDropdown(config)
                config = config or {}
                local dropdownText = config.Text or "Dropdown"
                local options = config.Options or {}
                local default = config.Default
                local multiSelect = config.MultiSelect or false
                local callback = config.Callback or function() end
                
                local DropdownFrame = Create("Frame", {
                    Name = "Dropdown",
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local DropdownButton = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = dropdownText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownButton
                })
                
                local Arrow = Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 25, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "▼",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10
                })
                
                local DropdownList = Create("Frame", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownList
                })
                
                local ListLayout = Create("UIListLayout", {
                    Parent = DropdownList,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })
                
                -- Search Box
                local SearchBox = Create("TextBox", {
                    Parent = DropdownList,
                    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -10, 0, 25),
                    Position = UDim2.new(0, 5, 0, 5),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = "Search...",
                    PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    ClearTextOnFocus = false
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = SearchBox
                })
                
                Create("UIPadding", {
                    Parent = SearchBox,
                    PaddingLeft = UDim.new(0, 5)
                })
                
                local selected = multiSelect and {} or default
                local optionButtons = {}
                local expanded = false
                
                local function UpdateDropdownText()
                    if multiSelect then
                        local count = 0
                        for _ in pairs(selected) do count = count + 1 end
                        DropdownButton.Text = count > 0 and dropdownText .. " (" .. count .. ")" or dropdownText
                    else
                        DropdownButton.Text = selected and dropdownText .. " - " .. selected or dropdownText
                    end
                end
                
                local function FilterOptions(searchText)
                    searchText = searchText:lower()
                    for _, optBtn in pairs(optionButtons) do
                        local optionText = optBtn.Text:lower()
                        optBtn.Visible = searchText == "" or optionText:find(searchText, 1, true) ~= nil
                    end
                end
                
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    FilterOptions(SearchBox.Text)
                end)
                
                for _, option in ipairs(options) do
                    local OptionButton = Create("TextButton", {
                        Parent = DropdownList,
                        BackgroundColor3 = Color3.fromRGB(55, 55, 65),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -10, 0, 25),
                        Position = UDim2.new(0, 5, 0, 0),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        AutoButtonColor = false
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = OptionButton
                    })
                    
                    local CheckBox
                    if multiSelect then
                        CheckBox = Create("Frame", {
                            Parent = OptionButton,
                            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                            Position = UDim2.new(0, 5, 0.5, -6),
                            Size = UDim2.new(0, 12, 0, 12)
                        })
                        
                        Create("UICorner", {
                            CornerRadius = UDim.new(0, 2),
                            Parent = CheckBox
                        })
                        
                        OptionButton.Text = "    " .. option
                        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    end
                    
                    optionButtons[option] = OptionButton
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        if multiSelect then
                            if selected[option] then
                                selected[option] = nil
                                CheckBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                            else
                                selected[option] = true
                                CheckBox.BackgroundColor3 = accentColor
                            end
                            UpdateDropdownText()
                            callback(selected)
                        else
                            selected = option
                            UpdateDropdownText()
                            callback(selected)
                            expanded = false
                            Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                            wait(0.2)
                            DropdownList.Visible = false
                            DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                        Arrow.Text = "▼"
                    end
                end)
                
                UpdateSize()
                
                return {
                    SetValue = function(value)
                        if multiSelect then
                            selected = {}
                            for _, v in ipairs(value) do
                                selected[v] = true
                                if optionButtons[v] and optionButtons[v]:FindFirstChild("Frame") then
                                    optionButtons[v].Frame.BackgroundColor3 = accentColor
                                end
                            end
                        else
                            selected = value
                        end
                        UpdateDropdownText()
                        callback(selected)
                    end,
                    GetValue = function()
                        return selected
                    end
                }
            end
            
            -- Text Label
            function Section:CreateText(config)
                config = config or {}
                local text = config.Text or "Text"
                local size = config.Size or 13
                
                local TextFrame = Create("Frame", {
                    Name = "Text",
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, size + 7)
                })
                
                local TextLabel = Create("TextLabel", {
                    Parent = TextFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = size,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
                
                TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    TextFrame.Size = UDim2.new(1, 0, 0, TextLabel.TextBounds.Y + 7)
                end)
                
                UpdateSize()
                
                return {
                    SetText = function(newText)
                        TextLabel.Text = newText
                    end
                }
            end
            
            -- Keybind
            function Section:CreateKeybind(config)
                config = config or {}
                local keybindText = config.Text or "Keybind"
                local default = config.Default or Enum.KeyCode.F
                local callback = config.Callback or function() end
                
                local KeybindFrame = Create("Frame", {
                    Name = "Keybind",
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = keybindText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local KeybindButton = Create("TextButton", {
                    Parent = KeybindFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    Position = UDim2.new(1, -80, 0.5, -12),
                    Size = UDim2.new(0, 70, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = default.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = KeybindButton
                })
                
                local currentKey = default
                local binding = false
                
                KeybindButton.MouseButton1Click:Connect(function()
                    binding = true
                    KeybindButton.Text = "..."
                    KeybindButton.BackgroundColor3 = accentColor
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding and not gameProcessed then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKey = input.KeyCode
                            KeybindButton.Text = currentKey.Name
                            KeybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                            binding = false
                        end
                    elseif not binding and not gameProcessed and input.KeyCode == currentKey then
                        callback(currentKey)
                    end
                end)
                
                UpdateSize()
                
                return {
                    SetKey = function(key)
                        currentKey = key
                        KeybindButton.Text = key.Name
                    end,
                    GetKey = function()
                        return currentKey
                    end
                }
            end
            
            -- Color Picker
            function Section:CreateColorPicker(config)
                config = config or {}
                local pickerText = config.Text or "Color Picker"
                local default = config.Default or Color3.fromRGB(255, 255, 255)
                local callback = config.Callback or function() end
                
                local ColorPickerFrame = Create("Frame", {
                    Name = "ColorPicker",
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local ColorPickerLabel = Create("TextLabel", {
                    Parent = ColorPickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = pickerText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorDisplay = Create("Frame", {
                    Parent = ColorPickerFrame,
                    BackgroundColor3 = default,
                    Position = UDim2.new(1, -30, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20)
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorDisplay
                })
                
                local ColorPickerWindow
                local currentColor = default
                
                ColorDisplay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if ColorPickerWindow then
                            ColorPickerWindow:Destroy()
                            ColorPickerWindow = nil
                            return
                        end
                        
                        ColorPickerWindow = Create("Frame", {
                            Parent = MainFrame,
                            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                            Position = UDim2.new(0.5, -100, 0.5, -100),
                            Size = UDim2.new(0, 200, 0, 200),
                            ZIndex = 10
                        })
                        
                        Create("UICorner", {
                            CornerRadius = UDim.new(0, 6),
                            Parent = ColorPickerWindow
                        })
                        
                        local ColorWheel = Create("ImageLabel", {
                            Parent = ColorPickerWindow,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 10, 0, 10),
                            Size = UDim2.new(0, 150, 0, 150),
                            Image = "rbxasset://textures/AvatarEditorImages/ColorWheel.png"
                        })
                        
                        local ValueSlider = Create("Frame", {
                            Parent = ColorPickerWindow,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Position = UDim2.new(0, 170, 0, 10),
                            Size = UDim2.new(0, 20, 0, 150)
                        })
                        
                        Create("UIGradient", {
                            Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                            },
                            Rotation = -90,
                            Parent = ValueSlider
                        })
                        
                        Create("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = ValueSlider
                        })
                        
                        local CloseButton = Create("TextButton", {
                            Parent = ColorPickerWindow,
                            BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                            Position = UDim2.new(0.5, -30, 1, -30),
                            Size = UDim2.new(0, 60, 0, 25),
                            Font = Enum.Font.Gotham,
                            Text = "Close",
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 12
                        })
                        
                        Create("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = CloseButton
                        })
                        
                        CloseButton.MouseButton1Click:Connect(function()
                            ColorPickerWindow:Destroy()
                            ColorPickerWindow = nil
                        end)
                    end
                end)
                
                UpdateSize()
                
                return {
                    SetColor = function(color)
                        currentColor = color
                        ColorDisplay.BackgroundColor3 = color
                        callback(color)
                    end,
                    GetColor = function()
                        return currentColor
                    end
                }
            end
            
            -- Textbox
            function Section:CreateTextbox(config)
                config = config or {}
                local textboxText = config.Text or "Textbox"
                local placeholder = config.Placeholder or "Enter text..."
                local default = config.Default or ""
                local callback = config.Callback or function() end
                
                local TextboxFrame = Create("Frame", {
                    Name = "Textbox",
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 55)
                })
                
                local TextboxLabel = Create("TextLabel", {
                    Parent = TextboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, -10, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = textboxText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local TextboxInput = Create("TextBox", {
                    Parent = TextboxFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    Position = UDim2.new(0, 5, 0, 25),
                    Size = UDim2.new(1, -10, 0, 25),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                    Text = default,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    ClearTextOnFocus = false
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = TextboxInput
                })
                
                Create("UIPadding", {
                    Parent = TextboxInput,
                    PaddingLeft = UDim.new(0, 5)
                })
                
                TextboxInput.FocusLost:Connect(function()
                    callback(TextboxInput.Text)
                end)
                
                UpdateSize()
                
                return {
                    SetText = function(text)
                        TextboxInput.Text = text
                    end,
                    GetText = function()
                        return TextboxInput.Text
                    end
                }
            end
            
            -- Separator
            function Section:CreateSeparator()
                local Separator = Create("Frame", {
                    Name = "Separator",
                    Parent = ElementContainer,
                    BackgroundColor3 = Color3.fromRGB(70, 70, 80),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1)
                })
                
                UpdateSize()
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Notification System
    function Window:Notification(config)
        config = config or {}
        local title = config.Title or "Notification"
        local text = config.Text or ""
        local duration = config.Duration or 3
        
        local NotificationFrame = Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = mainColor,
            Position = UDim2.new(1, 0, 1, -80),
            Size = UDim2.new(0, 250, 0, 70),
            ClipsDescendants = true
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = NotificationFrame
        })
        
        local NotificationTitle = Create("TextLabel", {
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local NotificationText = Create("TextLabel", {
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 25),
            Size = UDim2.new(1, -20, 0, 40),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        
        Tween(NotificationFrame, {Position = UDim2.new(1, -260, 1, -80)}, 0.3)
        
        wait(duration)
        
        Tween(NotificationFrame, {Position = UDim2.new(1, 0, 1, -80)}, 0.3)
        wait(0.3)
        NotificationFrame:Destroy()
    end
    
    return Window
end

return Library
                        DropdownFrame.Size = UDim2.new(1, 0,
