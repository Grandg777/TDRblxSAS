-- ИСПРАВЛЕНИЕ для старого GUI
-- Вставь это ВМЕСТО старого кода создания кнопок фарма

-- Контейнер для кнопок спавна
local spawnFrame = Instance.new("Frame")
spawnFrame.Name = "SpawnFrame"
spawnFrame.Size = UDim2.new(1, 0, 0, 25)
spawnFrame.BackgroundTransparency = 1
spawnFrame.LayoutOrder = 5
spawnFrame.Parent = contentFrame

local spawnLayout = Instance.new("UIListLayout")
spawnLayout.FillDirection = Enum.FillDirection.Horizontal
spawnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- ИСПРАВЛЕНО: убрал SpaceBetween
spawnLayout.SortOrder = Enum.SortOrder.LayoutOrder
spawnLayout.Padding = UDim.new(0, 5)
spawnLayout.Parent = spawnFrame

-- Функция создания кнопки фарма
local function createFarmButton(name, text, color, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 110, 0, 25) -- ИСПРАВЛЕНО: фиксированный размер
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

-- Обработчики кнопок (добавь после создания кнопок)
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
