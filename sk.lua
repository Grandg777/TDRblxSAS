-- Сканер только скриптов в Mods
-- Простой вывод только ModuleScript, LocalScript, Script

print("🔍 Сканируем только скрипты в Mods...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mods = ReplicatedStorage:WaitForChild("Mods")

-- Функция для рекурсивного поиска скриптов
local function findScripts(obj, path, output)
    path = path or ""
    output = output or {}
    
    local currentPath = path == "" and obj.Name or path .. "." .. obj.Name
    
    -- Если это скрипт - добавляем в список
    if obj:IsA("ModuleScript") or obj:IsA("LocalScript") or obj:IsA("Script") then
        local icon = "📦"
        if obj:IsA("LocalScript") then icon = "📜"
        elseif obj:IsA("Script") then icon = "📋" end
        
        local line = icon .. " " .. currentPath .. " (" .. obj.ClassName .. ")"
        table.insert(output, line)
        print(line)
    end
    
    -- Ищем в дочерних объектах
    for _, child in pairs(obj:GetChildren()) do
        findScripts(child, currentPath, output)
    end
    
    return output
end

-- Собираем все скрипты
local scriptsList = findScripts(Mods)

-- Выводим результат в консоль (так как файл не сохраняется)
print("\n" .. string.rep("=", 50))
print("📋 СПИСОК ВСЕХ СКРИПТОВ В MODS:")
print(string.rep("=", 50))

for i, script in ipairs(scriptsList) do
    print(i .. ". " .. script)
end

print("\n📊 Всего найдено скриптов: " .. #scriptsList)
print("🎮 Игра ID: " .. game.PlaceId)
print("⏰ Время: " .. os.date())

-- Пытаемся сохранить простым способом
local content = "-- СКРИПТЫ В MODS\n-- Игра: " .. game.PlaceId .. "\n-- Время: " .. os.date() .. "\n\n"
for i, script in ipairs(scriptsList) do
    content = content .. i .. ". " .. script .. "\n"
end

-- Без создания папок, просто файл
local success = pcall(function()
    writefile("scripts_list.txt", content)
end)

if success then
    print("✅ Список сохранен в scripts_list.txt")
else
    print("❌ Файл не сохранился, но список выведен выше")
    print("📝 Скопируй список из консоли и пришли мне")
end

print("\n🎯 Скопируй этот список и пришли мне!")
print("Я скажу какие модули декомпилировать в первую очередь")
