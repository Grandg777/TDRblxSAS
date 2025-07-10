-- SquadMod Decompiler Script
-- Декомпилирует и сохраняет SquadMod модуль

print("🎯 Начинаем декомпиляцию SquadMod...")

-- Находим модуль SquadMod
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mods = ReplicatedStorage:WaitForChild("Mods")
local SquadMod = Mods:WaitForChild("SquadMod")

print("📦 Найден модуль: " .. SquadMod:GetFullName())

-- Функция декомпиляции
local function decompileSquadMod()
    local success, result = pcall(function()
        -- Пробуем разные методы декомпиляции
        if decompile then
            print("🔧 Используем decompile()")
            return decompile(SquadMod)
        elseif getscriptclosure then
            print("🔧 Используем getscriptclosure()")
            local closure = getscriptclosure(SquadMod)
            if closure then
                if decompileFunction then
                    return decompileFunction(closure)
                else
                    return "-- Closure получен, но decompileFunction недоступен\n-- " .. tostring(closure)
                end
            else
                return "-- Не удалось получить closure"
            end
        else
            error("Декомпилятор недоступен")
        end
    end)
    
    if success and result then
        print("✅ Декомпиляция успешна! Размер: " .. #result .. " символов")
        return result
    else
        print("❌ Ошибка декомпиляции: " .. tostring(result))
        
        -- Создаем базовую информацию о модуле
        local info = {
            "-- SQUADMOD DECOMPILATION FAILED",
            "-- Error: " .. tostring(result),
            "-- Module: " .. SquadMod:GetFullName(),
            "-- Type: " .. SquadMod.ClassName,
            "-- Parent: " .. SquadMod.Parent.Name,
            "-- Time: " .. os.date(),
            "",
            "-- Module Children:"
        }
        
        for _, child in pairs(SquadMod:GetChildren()) do
            table.insert(info, "-- " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        
        table.insert(info, "")
        table.insert(info, "-- [ORIGINAL SOURCE CODE NOT AVAILABLE]")
        table.insert(info, "-- Попробуй другой декомпилятор или метод")
        
        return table.concat(info, "\n")
    end
end

-- Декомпилируем SquadMod
local decompiled = decompileSquadMod()

-- Добавляем заголовок с информацией
local header = [[-- SquadMod Decompiled
-- Game: ]] .. game.PlaceId .. [[
-- Player: ]] .. game.Players.LocalPlayer.Name .. [[
-- Time: ]] .. os.date() .. [[
-- Module Path: ]] .. SquadMod:GetFullName() .. [[

]]

local fullContent = header .. decompiled

-- Сохраняем файл (без лишней папки workspace)
local filename = "SquadMod_" .. os.date("%H%M%S") .. ".lua"
local success, error_msg = pcall(function()
    writefile(filename, fullContent)
end)

if success then
    print("✅ SquadMod сохранен как: " .. filename)
    print("📊 Размер файла: " .. #fullContent .. " символов")
    
    -- Проверяем что файл создался
    if readfile then
        local check = readfile(filename)
        if check and #check > 0 then
            print("✅ Файл успешно читается")
            print("📝 Первые 200 символов:")
            print(string.sub(check, 1, 200) .. "...")
        else
            print("⚠️ Файл пустой или не читается")
        end
    end
else
    print("❌ Ошибка сохранения: " .. tostring(error_msg))
    print("📋 Выводим содержимое в консоль:")
    print(string.rep("=", 80))
    print(fullContent)
    print(string.rep("=", 80))
end

print("🎯 Декомпиляция SquadMod завершена!")

-- Дополнительная информация
print("\n📊 Информация о модуле:")
print("Имя:", SquadMod.Name)
print("Тип:", SquadMod.ClassName) 
print("Родитель:", SquadMod.Parent.Name)
print("Полный путь:", SquadMod:GetFullName())
print("Дочерние объекты:", #SquadMod:GetChildren())

-- Показываем структуру модуля
if #SquadMod:GetChildren() > 0 then
    print("\n📁 Содержимое модуля:")
    for i, child in pairs(SquadMod:GetChildren()) do
        print("  " .. i .. ". " .. child.Name .. " (" .. child.ClassName .. ")")
    end
end
