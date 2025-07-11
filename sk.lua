-- Tower Defense Auto GUI с простой библиотекой
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Загрузка библиотеки
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grandg777/TDRblxSAS/refs/heads/main/inf.lua"))() -- Замените на URL вашей библиотеки

-- Настройки
local settings = {
    autoSkip = false,
    autoStart = false, 
    autoReplay = false
}

-- Переменные для защиты от спама
local lastActions = {
    skip = 0,
    start = 0,
    replay = 0
}

-- Переменные для фарм юнитов
local farmUnits = {
    farm1 = nil,
    farm2 = nil
}

local farmLevels = {
    farm1 = 0,
    farm2 = 0
}

local upgradePrices = {1100, 1500, 1500, 3000, 5000}
local connections = {}
local gui = nil

-- UI элементы для обновления
local uiElements = {
    upgrade1Btn = nil,
    upgrade2Btn = nil
}

-- Функция для получения денег
local function getMoney()
    local success, money = pcall(function()
        return LocalPlayer:WaitForChild("Money", 5).Value
    end)
    return success and money or 0
end

-- Функция для получения элементов UI игры
local function getGameUI()
    local success, result = pcall(function()
        local gu = PlayerGui:FindFirstChild("GU")
        local mainUI = PlayerGui:FindFirstChild("MainUI")
        
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

-- Функция для обновления текста кнопок улучшения
local function updateUpgradeButtons()
    if uiElements.upgrade1Btn then
        uiElements.upgrade1Btn:SetText("UF1 - " .. farmLevels.farm1 .. "/5")
    end
    if uiElements.upgrade2Btn then
        uiElements.upgrade2Btn:SetText("UF2 - " .. farmLevels.farm2 .. "/5")
    end
end

-- Функция для спавна фарм юнита
local function spawnFarmUnit(position, farmSlot)
    local money = getMoney()
    if money < 500 then
        print("❌ Недостаточно денег для спавна (нужно 500, есть " .. money .. ")")
        return false
    end
    
    -- Проверяем существование RemoteEvent
    local success = pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
        local setEvent = remotes and remotes:FindFirstChild("SetEvent")
        
        if not setEvent then
            warn("❌ SetEvent remote не найден")
            return false
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
    end)
    
    if success then
        print("🏗️ Отправлен запрос на спавн фарм юнита " .. farmSlot)
        
        -- Ждем появления юнита и сохраняем ссылку
        task.wait(1)
        
        local unitFolder = workspace:FindFirstChild("UnitFolder")
        if unitFolder then
            -- Ищем нового Teiuchi
            local units = {}
            for _, unit in pairs(unitFolder:GetChildren()) do
                if unit.Name == "Teiuchi" and unit:IsA("Model") then
                    table.insert(units, unit)
                end
            end
            
            -- Проверяем какие юниты уже сохранены
            for _, unit in pairs(units) do
                if farmSlot == "farm1" and not farmUnits.farm1 then
                    -- Проверяем что этот юнит не farm2
                    if unit ~= farmUnits.farm2 then
                        farmUnits.farm1 = unit
                        farmLevels.farm1 = 0
                        print("✅ Фарм юнит 1 сохранен")
                        updateUpgradeButtons()
                        return true
                    end
                elseif farmSlot == "farm2" and not farmUnits.farm2 then
                    -- Проверяем что этот юнит не farm1
                    if unit ~= farmUnits.farm1 then
                        farmUnits.farm2 = unit
                        farmLevels.farm2 = 0
                        print("✅ Фарм юнит 2 сохранен")
                        updateUpgradeButtons()
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Функция для улучшения фарм юнита
local function upgradeFarmUnit(farmSlot)
    local unit = farmUnits[farmSlot]
    if not unit or not unit.Parent then
        print("❌ Фарм юнит " .. farmSlot .. " не найден или был удален")
        farmUnits[farmSlot] = nil
        farmLevels[farmSlot] = 0
        updateUpgradeButtons()
        return false
    end
    
    local currentLevel = farmLevels[farmSlot]
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
    
    -- Проверяем существование RemoteFunction
    local success = pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
        local getFunction = remotes and remotes:FindFirstChild("GetFunction")
        
        if not getFunction then
            warn("❌ GetFunction remote не найден")
            return false
        end
        
        -- Отправляем конкретную ссылку на юнита
        local args = {
            {
                Type = "GameStuff"
            },
            {
                "Upgrade",
                unit -- Передаем конкретный объект юнита
            }
        }
        getFunction:InvokeServer(unpack(args))
    end)
    
    if success then
        farmLevels[farmSlot] = currentLevel + 1
        print("⬆️ Фарм юнит " .. farmSlot .. " улучшен до уровня " .. farmLevels[farmSlot])
        updateUpgradeButtons()
        return true
    else
        warn("❌ Ошибка улучшения фарм юнита " .. farmSlot)
    end
    
    return false
end

-- Функции автоматизации
local function sendSkip()
    local currentTime = tick()
    if currentTime - lastActions.skip < 5 then return end -- Защита от спама
    
    local success = pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
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
    end
end

local function sendStart()
    local currentTime = tick()
    if currentTime - lastActions.start < 5 then return end -- Защита от спама
    
    local success = pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
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
    end
end

local function sendReplay()
    local currentTime = tick()
    if currentTime - lastActions.replay < 10 then return end -- Защита от спама
    
    local success = pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
        local getFunction = remotes and remotes:FindFirstChild("GetFunction")
        
        if not getFunction then
            warn("❌ GetFunction remote не найден")
            return
        end
        
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
    end
end

-- Создание GUI
local function createGUI()
    -- Создаем окно
    local Window = Library:CreateWindow({
        Name = "🎯 Tower Defense Auto",
        Size = UDim2.new(0, 250, 0, 280)
    })
    
    -- Auto функции
    local autoSkipToggle = Window:CreateToggle({
        Text = "Auto Skip",
        Default = false,
        Callback = function(value)
            settings.autoSkip = value
            print("🔧 Auto Skip: " .. (value and "включено" or "выключено"))
        end
    })
    
    local autoStartToggle = Window:CreateToggle({
        Text = "Auto Start", 
        Default = false,
        Callback = function(value)
            settings.autoStart = value
            print("🔧 Auto Start: " .. (value and "включено" or "выключено"))
        end
    })
    
    local autoReplayToggle = Window:CreateToggle({
        Text = "Auto Replay",
        Default = false,
        Callback = function(value)
            settings.autoReplay = value
            print("🔧 Auto Replay: " .. (value and "включено" or "выключено"))
        end
    })
    
    -- Кнопка показа денег
    local moneyButton = Window:CreateButton({
        Text = "💰 Show Money",
        Callback = function()
            local money = getMoney()
            print("💰 Текущие деньги: " .. money)
        end
    })
    
    -- Разделитель
    Window:CreateSeparator()
    
    -- Кнопки спавна
    local spawnRow = Window:CreateButtonRow()
    local spawn1Btn = spawnRow:AddButton({
        Text = "Spawn F1",
        Color = Color3.fromRGB(85, 255, 85),
        Callback = function()
            local position = CFrame.new(-53.786128997802734, 55.58282470703125, 1.467529296875, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            spawnFarmUnit(position, "farm1")
        end
    })
    
    local spawn2Btn = spawnRow:AddButton({
        Text = "Spawn F2",
        Color = Color3.fromRGB(85, 255, 85),
        Callback = function()
            local position = CFrame.new(-40.75933074951172, 55.58282470703125, 2.94580078125, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            spawnFarmUnit(position, "farm2")
        end
    })
    
    -- Кнопки улучшения
    local upgradeRow = Window:CreateButtonRow()
    uiElements.upgrade1Btn = upgradeRow:AddButton({
        Text = "UF1 - 0/5",
        Color = Color3.fromRGB(255, 170, 85),
        Callback = function()
            upgradeFarmUnit("farm1")
        end
    })
    
    uiElements.upgrade2Btn = upgradeRow:AddButton({
        Text = "UF2 - 0/5",
        Color = Color3.fromRGB(255, 170, 85),
        Callback = function()
            upgradeFarmUnit("farm2")
        end
    })
    
    -- Периодическая проверка юнитов
    task.spawn(function()
        while Window.Enabled do
            task.wait(1)
            
            -- Проверяем существование юнитов
            for slot, unit in pairs(farmUnits) do
                if unit and not unit.Parent then
                    farmUnits[slot] = nil
                    farmLevels[slot] = 0
                    updateUpgradeButtons()
                    print("⚠️ Фарм юнит " .. slot .. " был удален")
                end
            end
        end
    end)
    
    return Window
end

-- Основная логика автоматизации
local function startAutomation()
    -- Переменные для отслеживания состояния
    local skipState = {
        lastVisible = false,
        lastSent = 0
    }
    
    local startState = {
        lastVisible = false,
        lastSent = 0
    }
    
    local replayState = {
        lastVisible = false,
        visibleStartTime = 0,
        sent = false
    }
    
    local connection = RunService.Heartbeat:Connect(function()
        if not gui or not gui.Enabled then return end
        
        local gameUI = getGameUI()
        if not gameUI then return end
        
        local currentTime = tick()
        
        -- Auto Skip
        if settings.autoSkip and gameUI.skipButton then
            local isVisible = gameUI.skipButton.Visible
            
            -- Отправляем только при появлении кнопки и если прошло достаточно времени
            if isVisible and not skipState.lastVisible and (currentTime - skipState.lastSent) > 10 then
                sendSkip()
                skipState.lastSent = currentTime
            end
            
            skipState.lastVisible = isVisible
        end
        
        -- Auto Start
        if settings.autoStart and gameUI.startButton then
            local isVisible = gameUI.startButton.Visible
            
            -- Отправляем только при появлении кнопки и если прошло достаточно времени
            if isVisible and not startState.lastVisible and (currentTime - startState.lastSent) > 10 then
                sendStart()
                startState.lastSent = currentTime
            end
            
            startState.lastVisible = isVisible
        end
        
        -- Auto Replay
        if settings.autoReplay and gameUI.resultFrame then
            local isVisible = gameUI.resultFrame.Visible
            
            if isVisible then
                -- Если результат только появился
                if not replayState.lastVisible then
                    replayState.visibleStartTime = currentTime
                    replayState.sent = false
                    print("⏱️ Результат показан, жду 5 секунд для Replay...")
                end
                
                -- Отправляем через 5 секунд, но только один раз
                if not replayState.sent and (currentTime - replayState.visibleStartTime) >= 5 then
                    sendReplay()
                    replayState.sent = true
                end
            else
                -- Сбрасываем состояние когда результат скрыт
                if replayState.lastVisible then
                    replayState.visibleStartTime = 0
                    replayState.sent = false
                end
            end
            
            replayState.lastVisible = isVisible
        end
    end)
    
    table.insert(connections, connection)
end

-- Функция закрытия GUI
local function closeGUI()
    -- Отключаем все автоматические функции
    settings.autoSkip = false
    settings.autoStart = false
    settings.autoReplay = false
    
    -- Отключаем все соединения
    for _, connection in ipairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
    
    -- Обнуляем ссылки на юнитов
    farmUnits = {
        farm1 = nil,
        farm2 = nil
    }
    farmLevels = {
        farm1 = 0,
        farm2 = 0
    }
    
    -- Закрываем GUI
    if gui then
        gui.Enabled = false
        gui = nil
    end
    
    print("✅ GUI закрыт, все функции отключены")
end

-- Запуск
print("🚀 Запуск Tower Defense Auto GUI...")
gui = createGUI()

if gui then
    startAutomation()
    print("✅ GUI создан! Используй Toggle'ы для автоматизации.")
    
    -- Привязываем закрытие к кнопке X в GUI
    -- (Кнопка закрытия уже встроена в библиотеку)
else
    print("❌ Не удалось создать GUI")
end

-- Глобальная функция для закрытия
_G.CloseTowerDefenseAuto = closeGUI
