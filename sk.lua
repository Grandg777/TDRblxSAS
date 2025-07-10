-- Tower Defense Auto GUI
-- Темный интерфейс с Auto Skip, Auto Start, Auto Replay

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Настройки
local settings = {
    autoSkip = false,
    autoStart = false,
    autoReplay = false
}

local connections = {}
local gui = nil

-- Функция для получения денег
local function getMoney()
    local success, money = pcall(function()
        return LocalPlayer.Money.Value
    end)
    return success and money or 0
end

-- Функция для получения элементов UI игры
local function getGameUI()
    local success, result = pcall(function()
        local gu = LocalPlayer.PlayerGui:FindFirstChild("GU")
        local mainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        
        if not gu or not mainUI then return nil end
        
        local menuFrame = gu:FindFirstChild("MenuFrame")
        local topFrame = menuFrame and menuFrame:FindFirstChild("TopFrame")
        local resultFrame = mainUI:FindFirstChild("ResultFrame")
        
        if not topFrame then return nil end
        
        return {
            skipButton = topFrame:FindFirstChild("Skip"),
            startButton = topFrame:FindFirstChild("Start"),
            resultFrame = resultFrame
        }
    end)
    
    return success and result or nil
end

-- Переменные для фарма
local farmUnits = {
    farm1 = nil, -- Ссылка на первый фарм юнит
    farm2 = nil  -- Ссылка на второй фарм юнит
}

local upgradePrices = {1100, 1500, 1500, 3000, 5000}

-- Функции для спавна и улучшения
local function spawnFarmUnit(position, farmSlot)
    local money = getMoney()
    if money < 500 then
        print("❌ Недостаточно денег для спавна (нужно 500, есть " .. money .. ")")
        return false
    end
    
    local success = pcall(function()
        local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
        local setEvent = remotes and remotes:FindFirstChild("SetEvent")
        
        if not setEvent then
            warn("❌ SetEvent remote не найден")
            return
        end
        
        local args = {
            "GameStuff",
            {
                "Summon",
                "Teiuchi",
                position
            }
        }
        setEvent:FireServer(unpack(args))
        
        -- Ждем появления юнита и сохраняем ссылку
        wait(1)
        local unitFolder = workspace:FindFirstChild("UnitFolder")
        if unitFolder then
            for _, unit in pairs(unitFolder:GetChildren()) do
                if unit.Name == "Teiuchi" and not farmUnits.farm1 and not farmUnits.farm2 then
                    farmUnits[farmSlot] = unit
                    break
                elseif unit.Name == "Teiuchi" and farmSlot == "farm2" and not farmUnits.farm2 then
                    farmUnits[farmSlot] = unit
                    break
                end
            end
        end
    end)
    
    if success then
        print("🏗️ Фарм юнит " .. farmSlot .. " заспавлен")
        return true
    else
        warn("❌ Ошибка спавна фарм юнита")
        return false
    end
end

local function upgradeFarmUnit(farmSlot)
    local unit = farmUnits[farmSlot]
    if not unit or not unit.Parent then
        print("❌ Фарм юнит " .. farmSlot .. " не найден")
        return false
    end
    
    -- Получаем текущий уровень (пока заглушка)
    local currentLevel = unit:GetAttribute("Level") or 0
    if currentLevel >= 5 then
        print("❌ Фарм юнит " .. farmSlot .. " уже максимального уровня")
        return false
    end
    
    local requiredMoney = upgradePrices[currentLevel + 1]
    local money = getMoney()
    if money < requiredMoney then
        print("❌ Недостаточно денег для улучшения " .. farmSlot .. " (нужно " .. requiredMoney .. ", есть " .. money .. ")")
        return false
    end
    
    local success = pcall(function()
        local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
        local getFunction = remotes and remotes:FindFirstChild("GetFunction")
        
        if not getFunction then
            warn("❌ GetFunction remote не найден")
            return
        end
        
        local args = {
            {
                Type = "GameStuff"
            },
            {
                "Upgrade",
                unit
            }
        }
        getFunction:InvokeServer(unpack(args))
    end)
    
    if success then
        print("⬆️ Фарм юнит " .. farmSlot .. " улучшен")
        return true
    else
        warn("❌ Ошибка улучшения фарм юнита")
        return false
    end
end

-- Функции автоматизации
local function sendSkip()
    local currentTime = tick()
    if currentTime - lastActions.skip < 2 then return end -- Защита от спама
    
    local success = pcall(function()
        local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
        local gameStuff = remotes and remotes:FindFirstChild("GameStuff")
        
        if not gameStuff then
            warn("❌ GameStuff remote не найден")
            return
        end
        
        local args = {"SkipVoteYes"}
        gameStuff:FireServer(unpack(args))
        lastActions.skip = currentTime
    end)
    
    if success then
        print("⏩ Скип отправлен")
    else
        warn("❌ Ошибка отправки скипа")
    end
end

local function sendStart()
    local currentTime = tick()
    if currentTime - lastActions.start < 2 then return end -- Защита от спама
    
    local success = pcall(function()
        local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
        local gameStuff = remotes and remotes:FindFirstChild("GameStuff")
        
        if not gameStuff then
            warn("❌ GameStuff remote не найден")
            return
        end
        
        local args = {"StartVoteYes"}
        gameStuff:FireServer(unpack(args))
        lastActions.start = currentTime
    end)
    
    if success then
        print("▶️ Старт отправлен")
    else
        warn("❌ Ошибка отправки старта")
    end
end

local function sendReplay()
    local currentTime = tick()
    if currentTime - lastActions.replay < 5 then return end -- Защита от спама
    
    local success = pcall(function()
        local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
        local getFunction = remotes and remotes:FindFirstChild("GetFunction")
        
        if not getFunction then
            warn("❌ GetFunction remote не найден")
            return
        end
        
        -- Отправляем только первый запрос - Replay
        local args = {
            {
                Type = "Game",
                Index = "Replay",
                Mode = "Reward"
            }
        }
        getFunction:InvokeServer(unpack(args))
        
        lastActions.replay = currentTime
    end)
    
    if success then
        print("🔄 Replay отправлен")
    else
        warn("❌ Ошибка отправки replay")
    end
end

-- Создание GUI
local function createGUI()
    -- Основной ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TowerDefenseAuto"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Главный фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 200)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Закругленные углы
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
    titleLabel.Text = "🎯 Tower Defense Auto"
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
    
    -- Контейнер для контента
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -40)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Layout для элементов
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = contentFrame
    
    -- Функция создания Toggle
    local function createToggle(name, text, layoutOrder)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name
        toggleFrame.Size = UDim2.new(1, 0, 0, 25)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.LayoutOrder = layoutOrder
        toggleFrame.Parent = contentFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Toggle"
        toggleButton.Size = UDim2.new(0, 40, 1, 0)
        toggleButton.Position = UDim2.new(1, -40, 0, 0)
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = "OFF"
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
        
        return toggleButton
    end
    
    -- Создание Toggle'ов
    local autoSkipToggle = createToggle("AutoSkip", "Auto Skip", 1)
    local autoStartToggle = createToggle("AutoStart", "Auto Start", 2)
    local autoReplayToggle = createToggle("AutoReplay", "Auto Replay", 3)
    
    -- Кнопка Money
    local moneyButton = Instance.new("TextButton")
    moneyButton.Name = "MoneyButton"
    moneyButton.Size = UDim2.new(1, 0, 0, 30)
    moneyButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    moneyButton.BorderSizePixel = 0
    moneyButton.Text = "💰 Show Money"
    moneyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    moneyButton.TextScaled = true
    moneyButton.Font = Enum.Font.SourceSansBold
    moneyButton.LayoutOrder = 4
    moneyButton.Parent = contentFrame
    
    local moneyCorner = Instance.new("UICorner")
    moneyCorner.CornerRadius = UDim.new(0, 6)
    moneyCorner.Parent = moneyButton
    
    -- Контейнер для кнопок спавна
    local spawnFrame = Instance.new("Frame")
    spawnFrame.Name = "SpawnFrame"
    spawnFrame.Size = UDim2.new(1, 0, 0, 25)
    spawnFrame.BackgroundTransparency = 1
    spawnFrame.LayoutOrder = 5
    spawnFrame.Parent = contentFrame

    local spawnLayout = Instance.new("UIListLayout")
    spawnLayout.FillDirection = Enum.FillDirection.Horizontal
    spawnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    spawnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    spawnLayout.Padding = UDim.new(0, 5)
    spawnLayout.Parent = spawnFrame

    -- Функция создания кнопки фарма
    local function createFarmButton(name, text, color, layoutOrder)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 110, 0, 25)
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.SourceSans
        button.LayoutOrder = layoutOrder
        button.Parent = spawnFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button
        
        return button
    end

    -- Создание кнопок спавна
    local spawnFarm1 = createFarmButton("SpawnFarm1", "Spawn F1", Color3.fromRGB(85, 255, 85), 1)
    local spawnFarm2 = createFarmButton("SpawnFarm2", "Spawn F2", Color3.fromRGB(85, 255, 85), 2)

    -- Контейнер для кнопок улучшения
    local upgradeFrame = Instance.new("Frame")
    upgradeFrame.Name = "UpgradeFrame"
    upgradeFrame.Size = UDim2.new(1, 0, 0, 25)
    upgradeFrame.BackgroundTransparency = 1
    upgradeFrame.LayoutOrder = 6
    upgradeFrame.Parent = contentFrame

    local upgradeLayout = Instance.new("UIListLayout")
    upgradeLayout.FillDirection = Enum.FillDirection.Horizontal
    upgradeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    upgradeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    upgradeLayout.Padding = UDim.new(0, 5)
    upgradeLayout.Parent = upgradeFrame

    local upgradeFarm1 = createFarmButton("UpgradeFarm1", "UF1 - 0/5", Color3.fromRGB(255, 170, 85), 1)
    upgradeFarm1.Parent = upgradeFrame
    local upgradeFarm2 = createFarmButton("UpgradeFarm2", "UF2 - 0/5", Color3.fromRGB(255, 170, 85), 2)
    upgradeFarm2.Parent = upgradeFrame
    
    -- Функция переключения Toggle
    local function setupToggle(toggleButton, settingName)
        toggleButton.Activated:Connect(function()
            settings[settingName] = not settings[settingName]
            
            if settings[settingName] then
                toggleButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
                toggleButton.Text = "ON"
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
                toggleButton.Text = "OFF"
            end
            
            print("🔧 " .. settingName .. ": " .. (settings[settingName] and "включено" or "выключено"))
        end)
    end
    
    -- Настройка Toggle'ов
    setupToggle(autoSkipToggle, "autoSkip")
    setupToggle(autoStartToggle, "autoStart")
    setupToggle(autoReplayToggle, "autoReplay")
    
    -- Обработка кнопки Money
    moneyButton.Activated:Connect(function()
        local money = getMoney()
        print("💰 Текущие деньги: " .. money)
    end)
    
    -- Обработчики кнопок фарма
    spawnFarm1.Activated:Connect(function()
        local position = CFrame.new(-53.786128997802734, 55.58282470703125, 1.467529296875, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        spawnFarmUnit(position, "farm1")
    end)
    
    spawnFarm2.Activated:Connect(function()
        local position = CFrame.new(-40.75933074951172, 55.58282470703125, 2.94580078125, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        spawnFarmUnit(position, "farm2")
    end)
    
    upgradeFarm1.Activated:Connect(function()
        upgradeFarmUnit("farm1")
    end)
    
    upgradeFarm2.Activated:Connect(function()
        upgradeFarmUnit("farm2")
    end)
    
    -- Закрытие GUI
    closeButton.Activated:Connect(function()
        print("🔴 Закрытие Tower Defense Auto...")
        
        -- Отключаем все Auto функции
        settings.autoSkip = false
        settings.autoStart = false
        settings.autoReplay = false
        
        -- Отключаем все соединения
        for i, connection in ipairs(con.connections) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
        connections = {}
        
        -- Удаляем GUI немедленно
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        gui = nil
        
        print("✅ GUI закрыт, все функции отключены")
    end)
    
    -- Перетаскивание GUI
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
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
    
    return screenGui
end

-- Основная логика автоматизации
local function startAutomation()
    local replayStartTime = 0
    local lastSkipVisible = false
    local lastStartVisible = false
    local lastResultVisible = false
    local replaySent = false -- Флаг для предотвращения повторной отправки
    
    local connection = RunService.Heartbeat:Connect(function()
        if not gui then return end -- Останавливаем если GUI закрыт
        
        local gameUI = getGameUI()
        if not gameUI then return end
        
        -- Auto Skip - отправляем только при изменении видимости
        if settings.autoSkip and gameUI.skipButton then
            local isVisible = gameUI.skipButton.Visible
            if isVisible and not lastSkipVisible then
                sendSkip()
            end
            lastSkipVisible = isVisible
        end
        
        -- Auto Start - отправляем только при изменении видимости
        if settings.autoStart and gameUI.startButton then
            local isVisible = gameUI.startButton.Visible
            if isVisible and not lastStartVisible then
                sendStart()
            end
            lastStartVisible = isVisible
        end
        
        -- Auto Replay - отправляем только при изменении видимости + 5 сек задержка
        if settings.autoReplay and gameUI.resultFrame then
            local isVisible = gameUI.resultFrame.Visible
            
            if isVisible and not lastResultVisible then
                replayStartTime = tick()
                replaySent = false -- Сбрасываем флаг при новом появлении
                print("⏱️ Результат показан, жду 5 секунд для Replay...")
            elseif isVisible and not replaySent and replayStartTime > 0 and tick() - replayStartTime >= 5 then
                sendReplay()
                replaySent = true -- Помечаем что отправили
            elseif not isVisible then
                replayStartTime = 0
                replaySent = false -- Сбрасываем при скрытии
            end
            
            lastResultVisible = isVisible
        end
    end)
    
    table.insert(connections, connection)
end

-- Запуск
print("🚀 Запуск Tower Defense Auto GUI...")
gui = createGUI()
startAutomation()
print("✅ GUI создан! Используй Toggle'ы для автоматизации.")
