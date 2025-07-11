-- Загрузка библиотеки
local Library = loadstring(game:HttpGet("https://github.com/Grandg777/TDRblxSAS/raw/refs/heads/main/inf.lua"))()

-- Создание окна
local Window = Library:CreateWindow({
    Name = "🎯 Tower Defense Auto",
    Size = UDim2.new(0, 250, 0, 250)
})

-- Создание Toggle'ов
local autoSkipToggle = Window:CreateToggle({
    Text = "Auto Skip",
    Default = false,
    Callback = function(value)
        print("Auto Skip:", value)
    end
})

local autoStartToggle = Window:CreateToggle({
    Text = "Auto Start",
    Default = false,
    Callback = function(value)
        print("Auto Start:", value)
    end
})

local autoReplayToggle = Window:CreateToggle({
    Text = "Auto Replay",
    Default = false,
    Callback = function(value)
        print("Auto Replay:", value)
    end
})

-- Создание обычной кнопки
local moneyButton = Window:CreateButton({
    Text = "💰 Show Money",
    Callback = function()
        print("Money button clicked!")
    end
})

-- Создание разделителя
Window:CreateSeparator()

-- Создание горизонтального ряда кнопок
local spawnRow = Window:CreateButtonRow()
local spawn1 = spawnRow:AddButton({
    Text = "Spawn F1",
    Color = Color3.fromRGB(85, 255, 85),
    Callback = function()
        print("Spawn Farm 1")
    end
})

local spawn2 = spawnRow:AddButton({
    Text = "Spawn F2",
    Color = Color3.fromRGB(85, 255, 85),
    Callback = function()
        print("Spawn Farm 2")
    end
})

-- Еще один ряд кнопок
local upgradeRow = Window:CreateButtonRow()
local upgrade1 = upgradeRow:AddButton({
    Text = "UF1 - 0/5",
    Color = Color3.fromRGB(255, 170, 85),
    Callback = function()
        print("Upgrade Farm 1")
    end
})

local upgrade2 = upgradeRow:AddButton({
    Text = "UF2 - 0/5",
    Color = Color3.fromRGB(255, 170, 85),
    Callback = function()
        print("Upgrade Farm 2")
    end
})

-- Создание Label
local infoLabel = Window:CreateLabel({
    Text = "Status: Ready"
})

-- Примеры изменения значений
spawn1:SetText("F1 Spawned")
upgrade1:SetText("UF1 - 1/5")
infoLabel:SetText("Status: Running")
autoSkipToggle:SetValue(true)
