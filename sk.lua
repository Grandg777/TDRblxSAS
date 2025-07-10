-- Сканер структуры всех модулей в Mods
-- Выводит полную иерархию и сохраняет в файл

print("🔍 Сканируем структуру ReplicatedStorage.Mods...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция для рекурсивного сканирования
local function scanObject(obj, depth, output)
    depth = depth or 0
    output = output or {}
    
    local indent = string.rep("  ", depth)
    local icon = "📄"
    
    -- Выбираем иконку по типу объекта
    if obj:IsA("ModuleScript") then
        icon = "📦"
    elseif obj:IsA("LocalScript") then
        icon = "📜"
    elseif obj:IsA("Script") then
        icon = "📋"
    elseif obj:IsA("Folder") then
        icon = "📁"
    elseif obj:IsA("Configuration") then
        icon = "⚙️"
    elseif obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
        icon = "💾"
    end
    
    -- Формируем строку информации
    local info = string.format("%s%s %s (%s)", indent, icon, obj.Name, obj.ClassName)
    
    -- Добавляем дополнительную информацию для значений
    if obj:IsA("StringValue") and obj.Value ~= "" then
        info = info .. " = \"" .. obj.Value .. "\""
    elseif obj:IsA("IntValue") or obj:IsA("NumberValue") then
        info = info .. " = " .. tostring(obj.Value)
    elseif obj:IsA("BoolValue") then
        info = info .. " = " .. tostring(obj.Value)
    end
    
    table.insert(output, info)
    print(info)
    
    -- Рекурсивно сканируем дочерние объекты
    local children = obj:GetChildren()
    if #children > 0 then
        -- Сортируем детей по типу (сначала папки, потом скрипты, потом остальное)
        table.sort(children, function(a, b)
            local aWeight = a:IsA("Folder") and 1 or (a:IsA("ModuleScript") and 2) or 3
            local bWeight = b:IsA("Folder") and 1 or (b:IsA("ModuleScript") and 2) or 3
            if aWeight == bWeight then
                return a.Name < b.Name
            end
            return aWeight < bWeight
        end)
        
        for _, child in ipairs(children) do
            scanObject(child, depth + 1, output)
        end
    end
    
    return output
end

-- Начинаем сканирование
local Mods = ReplicatedStorage:WaitForChild("Mods")
print("📂 Сканируем: " .. Mods:GetFullName())
print("🎮 Игра ID: " .. game.PlaceId)
print("👤 Игрок: " .. LocalPlayer.Name)
print("⏰ Время: " .. os.date())
print(string.rep("=", 60))

local output = {}

-- Добавляем заголовок в файл
table.insert(output, "-- СТРУКТУРА МОДУЛЕЙ TOWER DEFENSE")
table.insert(output, "-- Игра ID: " .. game.PlaceId)
table.insert(output, "-- Игрок: " .. LocalPlayer.Name)
table.insert(output, "-- Время сканирования: " .. os.date())
table.insert(output, "-- Путь: " .. Mods:GetFullName())
table.insert(output, string.rep("=", 60))
table.insert(output, "")

-- Сканируем основную папку Mods
scanObject(Mods, 0, output)

-- Добавляем статистику
table.insert(output, "")
table.insert(output, string.rep("=", 60))
table.insert(output, "📊 СТАТИСТИКА:")

local stats = {
    ModuleScript = 0,
    LocalScript = 0,
    Script = 0,
    Folder = 0,
    Total = 0
}

for _, obj in pairs(Mods:GetDescendants()) do
    stats.Total = stats.Total + 1
    if obj:IsA("ModuleScript") then
        stats.ModuleScript = stats.ModuleScript + 1
    elseif obj:IsA("LocalScript") then
        stats.LocalScript = stats.LocalScript + 1
    elseif obj:IsA("Script") then
        stats.Script = stats.Script + 1
    elseif obj:IsA("Folder") then
        stats.Folder = stats.Folder + 1
    end
end

table.insert(output, "📦 ModuleScript: " .. stats.ModuleScript)
table.insert(output, "📜 LocalScript: " .. stats.LocalScript)
table.insert(output, "📋 Script: " .. stats.Script)
table.insert(output, "📁 Folder: " .. stats.Folder)
table.insert(output, "📄 Всего объектов: " .. stats.Total)

-- Добавляем список всех ModuleScript для быстрого поиска
table.insert(output, "")
table.insert(output, "🎯 СПИСОК ВСЕХ MODULESCRIPT:")
local modulesList = {}
for _, obj in pairs(Mods:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        table.insert(modulesList, obj:GetFullName():gsub("game%.ReplicatedStorage%.Mods%.", ""))
    end
end
table.sort(modulesList)
for i, modulePath in ipairs(modulesList) do
    table.insert(output, i .. ". " .. modulePath)
end

-- Сохраняем в файл
local filename = "ModsStructure_" .. game.PlaceId .. "_" .. os.date("%H%M%S") .. ".txt"
local content = table.concat(output, "\n")

local success, error_msg = pcall(function()
    writefile(filename, content)
end)

if success then
    print("\n✅ Структура сохранена в файл: " .. filename)
    print("📁 Размер файла: " .. #content .. " символов")
    print("📊 Всего строк: " .. #output)
else
    print("\n❌ Ошибка сохранения: " .. tostring(error_msg))
    print("📋 Выводим содержимое в консоль:")
    print(string.rep("=", 60))
    for _, line in ipairs(output) do
        print(line)
    end
end

print("\n🎯 Что делать дальше:")
print("1. Скинь мне содержимое файла " .. filename)
print("2. Я скажу какие модули декомпилировать в первую очередь")
print("3. Сделаем автофарм на основе приоритетных модулей")
print("4. Profit! 💰")
