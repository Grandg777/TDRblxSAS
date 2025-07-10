-- Сканер ТОЛЬКО скриптов в Mods (без GUI мусора)
-- Только ModuleScript, LocalScript, Script

-- Очищаем консоль от мусора
for i = 1, 50 do print() end

print("🔍 СКАНИРУЕМ ТОЛЬКО СКРИПТЫ В MODS")
print("🚫 Игнорируем GUI элементы")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mods = ReplicatedStorage:WaitForChild("Mods")

-- Функция для рекурсивного поиска ТОЛЬКО скриптов
local function findScripts(obj, path, output)
    path = path or ""
    output = output or {}
    
    local currentPath = path == "" and obj.Name or path .. "." .. obj.Name
    
    -- ТОЛЬКО скрипты, никаких GUI элементов
    if obj:IsA("ModuleScript") or obj:IsA("LocalScript") or obj:IsA("Script") then
        local icon = "📦"
        if obj:IsA("LocalScript") then icon = "📜"
        elseif obj:IsA("Script") then icon = "📋" end
        
        local line = icon .. " " .. currentPath
        table.insert(output, line)
    end
    
    -- Ищем в дочерних объектах (но выводим только скрипты)
    for _, child in pairs(obj:GetChildren()) do
        findScripts(child, currentPath, output)
    end
    
    return output
end

-- Собираем все скрипты БЕЗ вывода в консоль
local scriptsList = findScripts(Mods)

-- Теперь выводим ТОЛЬКО финальный результат
print(string.rep("=", 40))
print("📋 НАЙДЕННЫЕ СКРИПТЫ:")
print(string.rep("=", 40))

for i, script in ipairs(scriptsList) do
    print(i .. ". " .. script)
end

print(string.rep("=", 40))
print("📊 Всего: " .. #scriptsList .. " скриптов")
print("🎮 Игра: " .. game.PlaceId)
print(string.rep("=", 40))

-- Простое содержимое для файла
local content = "СКРИПТЫ В MODS:\n\n"
for i, script in ipairs(scriptsList) do
    content = content .. i .. ". " .. script .. "\n"
end
content = content .. "\nВсего: " .. #scriptsList .. " скриптов"

-- Сохраняем
writefile("mods_scripts.txt", content)
print("✅ Сохранено в mods_scripts.txt")
print("📝 Обнови GitHub и пришли мне этот список!")
