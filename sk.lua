-- Tower Defense Auto Sequence Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Настройки
local CONFIG = {
    AUTO_REPLAY = false, -- Измените на true чтобы включить авто реплей
}

-- Состояние скрипта
local scriptEnabled = true
local connections = {}
local currentStep = 1
local units = {}

-- Позиции для спавна
local POSITIONS = {
    FARM1 = CFrame.new(-53.581634521484375, 55.58282470703125, -10.263553619384766, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    FARM2 = CFrame.new(-39.55238342285156, 55.58282470703125, -0.3068962097167969, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    FARM3 = CFrame.new(-36.67011260986328, 55.58282470703125, -25.443614959716797, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    FARM4 = CFrame.new(-53.415794372558594, 55.58282470703125, -27.08768081665039, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    BROLY = CFrame.new(-62.50544357299805, 61.46331787109375, -75.51477813720703, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ICHIGO1 = CFrame.new(85.1407699584961, 55.58282470703125, 57.5001220703125, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ICHIGO2 = CFrame.new(119.20072174072266, 55.58282470703125, 57.84280776977539, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

-- Функция получения денег
local function getMoney()
    local success, money = pcall(function()
        return LocalPlayer:WaitForChild("Money", 5).Value
    end)
    return success and money or 0
end

-- Функция получения UI элементов
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

-- Функция спавна юнита
local function spawnUnit(unitName, position)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return false end
    
    local setEvent = remotes:FindFirstChild("SetEvent")
    if not setEvent then return false end
    
    local success = pcall(function()
        local args = {
            "GameStuff",
            {
                "Summon",
                unitName,
                position
            }
        }
        setEvent:FireServer(unpack(args))
    end)
    
    return success
end

-- Функция улучшения юнита
local function upgradeUnit(unitName)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return false end
    
    local getFunction = remotes:FindFirstChild("GetFunction")
    if not getFunction then return false end
    
    local unitFolder = workspace:FindFirstChild("UnitFolder")
    if not unitFolder then return false end
    
    local unit = unitFolder:FindFirstChild(unitName)
    if not unit then return false end
    
    local success = pcall(function()
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
    
    return success
end

-- Функция отправки старта
local function sendStart()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return false end
    
    local gameStuff = remotes:FindFirstChild("GameStuff")
    if not gameStuff then return false end
    
    local success = pcall(function()
        gameStuff:FireServer("StartVoteYes")
    end)
    
    return success
end

-- Функция отправки скипа
local function sendSkip()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return false end
    
    local gameStuff = remotes:FindFirstChild("GameStuff")
    if not gameStuff then return false end
    
    local success = pcall(function()
        gameStuff:FireServer("SkipVoteYes")
    end)
    
    return success
end

-- Функция отправки реплея
local function sendReplay()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return false end
    
    local getFunction = remotes:FindFirstChild("GetFunction")
    if not getFunction then return false end
    
    local success = pcall(function()
        local args = {
            {
                Type = "Game",
                Index = "Replay",
                Mode = "Reward"
            }
        }
        getFunction:InvokeServer(unpack(args))
    end)
    
    return success
end

-- Основная последовательность
local function executeStep()
    if not scriptEnabled then return end
    
    local money = getMoney()
    
    if currentStep == 1 then
        -- Ставим первую ферму
        if money >= 500 then
            if spawnUnit("Teiuchi", POSITIONS.FARM1) then
                currentStep = 2
                task.wait(1)
            end
        end
        
    elseif currentStep == 2 then
        -- Нажимаем Start
        local gameUI = getGameUI()
        if gameUI and gameUI.startButton and gameUI.startButton.Visible then
            if sendStart() then
                currentStep = 3
                task.wait(2)
            end
        end
        
    elseif currentStep == 3 then
        -- Ждем денег и ставим вторую ферму
        if money >= 500 then
            if spawnUnit("Teiuchi", POSITIONS.FARM2) then
                currentStep = 4
                task.wait(1)
            end
        end
        
    elseif currentStep == 4 then
        -- Ждем денег и ставим 3 и 4 фермы
        if money >= 1000 then
            if spawnUnit("Teiuchi", POSITIONS.FARM3) then
                task.wait(0.5)
                if spawnUnit("Teiuchi", POSITIONS.FARM4) then
                    currentStep = 5
                    task.wait(1)
                end
            end
        end
        
    elseif currentStep == 5 then
        -- Ждем 1100 и ставим Broly
        if money >= 1100 then
            if spawnUnit("Broly", POSITIONS.BROLY) then
                currentStep = 6
                units.broly = {level = 0}
                task.wait(1)
            end
        end
        
    elseif currentStep == 6 then
        -- Качаем Broly первый раз (2600)
        if money >= 2600 and units.broly.level < 1 then
            if upgradeUnit("Broly") then
                units.broly.level = 1
                currentStep = 7
                task.wait(1)
            end
        end
        
    elseif currentStep == 7 then
        -- Качаем Broly второй раз (4100)
        if money >= 4100 and units.broly.level < 2 then
            if upgradeUnit("Broly") then
                units.broly.level = 2
                currentStep = 8
                task.wait(1)
            end
        end
        
    elseif currentStep == 8 then
        -- Ждем 1800 и ставим первого Ichigo
        if money >= 1800 then
            if spawnUnit("Ichigo5", POSITIONS.ICHIGO1) then
                currentStep = 9
                units.ichigo1 = {level = 0}
                task.wait(1)
            end
        end
        
    elseif currentStep >= 9 and currentStep <= 15 then
        -- Качаем первого Ichigo (7 уровней)
        local upgradeCosts = {2250, 3500, 4550, 6300, 8800, 9250, 10950}
        local level = currentStep - 9
        
        if money >= upgradeCosts[level + 1] and units.ichigo1.level < level + 1 then
            if upgradeUnit("Ichigo5") then
                units.ichigo1.level = level + 1
                currentStep = currentStep + 1
                task.wait(1)
            end
        end
        
    elseif currentStep == 16 then
        -- Ставим второго Ichigo
        if money >= 1800 then
            if spawnUnit("Ichigo5", POSITIONS.ICHIGO2) then
                currentStep = 17
                units.ichigo2 = {level = 0}
                task.wait(1)
            end
        end
        
    elseif currentStep >= 17 then
        -- Качаем второго Ichigo насколько хватит денег
        local upgradeCosts = {2250, 3500, 4550, 6300, 8800, 9250, 10950}
        local level = units.ichigo2.level
        
        if level < 7 and money >= upgradeCosts[level + 1] then
            -- Находим второго Ichigo по позиции
            task.wait(0.5) -- Даем время на обновление
            local unitFolder = workspace:FindFirstChild("UnitFolder")
            if unitFolder then
                for _, unit in pairs(unitFolder:GetChildren()) do
                    if unit.Name == "Ichigo5" and unit ~= units.ichigo1_ref then
                        units.ichigo2_ref = unit
                        break
                    end
                end
            end
            
            if upgradeUnit("Ichigo5") then
                units.ichigo2.level = level + 1
                task.wait(1)
            end
        end
    end
end

-- Автоматический старт
local startConnection
startConnection = RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end
    
    local gameUI = getGameUI()
    if gameUI and gameUI.startButton and gameUI.startButton.Visible then
        sendStart()
    end
end)
table.insert(connections, startConnection)

-- Автоматический реплей (если включен)
local replayConnection
local replayTimer = 0
local replayReady = false

replayConnection = RunService.Heartbeat:Connect(function()
    if not scriptEnabled or not CONFIG.AUTO_REPLAY then return end
    
    local gameUI = getGameUI()
    if gameUI and gameUI.resultFrame and gameUI.resultFrame.Visible then
        if not replayReady then
            replayReady = true
            replayTimer = tick()
        elseif tick() - replayTimer >= 5 then
            sendReplay()
            -- Сбрасываем состояние для нового раунда
            currentStep = 1
            units = {}
            replayReady = false
        end
    else
        replayReady = false
    end
end)
table.insert(connections, replayConnection)

-- Основной цикл
local mainConnection
mainConnection = RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end
    executeStep()
end)
table.insert(connections, mainConnection)

-- Создание простого GUI для выключения
local function createControlGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TDAutoControl"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    local destroyButton = Instance.new("TextButton")
    destroyButton.Name = "DestroyButton"
    destroyButton.Size = UDim2.new(0, 100, 0, 50)
    destroyButton.Position = UDim2.new(0, 10, 0, 10)
    destroyButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    destroyButton.BorderSizePixel = 0
    destroyButton.Text = "STOP\nSCRIPT"
    destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyButton.TextScaled = true
    destroyButton.Font = Enum.Font.SourceSansBold
    destroyButton.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = destroyButton
    
    destroyButton.MouseButton1Click:Connect(function()
        scriptEnabled = false
        
        -- Отключаем все соединения
        for _, connection in ipairs(connections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        -- Удаляем GUI
        screenGui:Destroy()
    end)
    
    return screenGui
end

-- Запуск
createControlGUI()
