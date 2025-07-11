local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Утилиты
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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

-- Создание окна
function Library:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "GUI"
    local windowSize = config.Size or UDim2.new(0, 250, 0, 200)
    
    local Window = {}
    Window.Enabled = true
    
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Главный фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = windowSize
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Заголовок
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowName
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 2.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        Window.Enabled = false
        screenGui:Destroy()
    end)
    
    -- Контейнер для контента
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -40)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = contentFrame
    
    -- Делаем окно перетаскиваемым
    makeDraggable(mainFrame, titleBar)
    
    Window.Frame = mainFrame
    Window.Content = contentFrame
    
    -- Функция создания Toggle
    function Window:CreateToggle(config)
        config = config or {}
        local text = config.Text or "Toggle"
        local default = config.Default or false
        local callback = config.Callback or function() end
        
        local Toggle = {}
        Toggle.Value = default
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 25)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = contentFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 40, 1, 0)
        toggleButton.Position = UDim2.new(1, -40, 0, 0)
        toggleButton.BackgroundColor3 = default and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(255, 85, 85)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = default and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextScaled = true
        toggleButton.Font = Enum.Font.SourceSansBold
        toggleButton.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggleButton
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextScaled = true
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        toggleButton.MouseButton1Click:Connect(function()
            Toggle.Value = not Toggle.Value
            
            if Toggle.Value then
                toggleButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
                toggleButton.Text = "ON"
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
                toggleButton.Text = "OFF"
            end
            
            callback(Toggle.Value)
        end)
        
        function Toggle:SetValue(value)
            Toggle.Value = value
            
            if Toggle.Value then
                toggleButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
                toggleButton.Text = "ON"
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
                toggleButton.Text = "OFF"
            end
            
            callback(Toggle.Value)
        end
        
        return Toggle
    end
    
    -- Функция создания Button
    function Window:CreateButton(config)
        config = config or {}
        local text = config.Text or "Button"
        local callback = config.Callback or function() end
        
        local Button = {}
        
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Size = UDim2.new(1, 0, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.SourceSansBold
        button.Parent = contentFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            callback()
        end)
        
        function Button:SetText(newText)
            button.Text = newText
        end
        
        return Button
    end
    
    -- Функция создания Label
    function Window:CreateLabel(config)
        config = config or {}
        local text = config.Text or "Label"
        
        local Label = {}
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextScaled = true
        label.Font = Enum.Font.SourceSans
        label.Parent = contentFrame
        
        function Label:SetText(newText)
            label.Text = newText
        end
        
        return Label
    end
    
    -- Функция создания Separator
    function Window:CreateSeparator()
        local separator = Instance.new("Frame")
        separator.Name = "Separator"
        separator.Size = UDim2.new(1, 0, 0, 1)
        separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        separator.BorderSizePixel = 0
        separator.Parent = contentFrame
        
        return separator
    end
    
    -- Функция создания ButtonRow (горизонтальные кнопки)
    function Window:CreateButtonRow()
        local ButtonRow = {}
        
        local rowFrame = Instance.new("Frame")
        rowFrame.Name = "ButtonRow"
        rowFrame.Size = UDim2.new(1, 0, 0, 25)
        rowFrame.BackgroundTransparency = 1
        rowFrame.Parent = contentFrame
        
        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rowLayout.Padding = UDim.new(0, 5)
        rowLayout.Parent = rowFrame
        
        function ButtonRow:AddButton(config)
            config = config or {}
            local text = config.Text or "Button"
            local color = config.Color or Color3.fromRGB(85, 170, 255)
            local callback = config.Callback or function() end
            
            local button = Instance.new("TextButton")
            button.Name = "RowButton"
            button.Size = UDim2.new(0, 110, 0, 25)
            button.BackgroundColor3 = color
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextScaled = true
            button.Font = Enum.Font.SourceSans
            button.Parent = rowFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                callback()
            end)
            
            return {
                SetText = function(newText)
                    button.Text = newText
                end
            }
        end
        
        return ButtonRow
    end
    
    return Window
end

return Library
