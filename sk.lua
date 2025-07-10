-- Декомпилятор подмодулей SquadMod
-- Попробуем декомпилировать каждый подмодуль отдельно

print("🎯 Декомпилируем подмодули SquadMod...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SquadMod = ReplicatedStorage.Mods.SquadMod

-- Приоритетные модули для автофарма
local priorityModules = {
    "UnitInfo",    -- Информация о юнитах
    "LevelMod",    -- Уровни и улучшения  
    "SellMod",     -- Продажа юнитов
    "SlotsMod",    -- Слоты для юнитов
    "ViewMod"      -- Отображение
}

-- Функция декомпиляции одного модуля
local function decompileModule(module)
    local success, result = pcall(function()
        if decompile then
            return decompile(module)
        elseif getscriptclosure then
            local closure = getscriptclosure(module)
            if closure and decompileFunction then
                return decompileFunction(closure)
            end
        end
        error("Декомпилятор недоступен")
    end)
    
    if success and result and #result > 50 then
        return result
    else
        return "-- FAILED TO DECOMPILE: " .. module.Name .. 
               "\n-- Error: " .. tostring(result) ..
               "\n-- [SOURCE CODE NOT AVAILABLE]"
    end
end

-- Декомпилируем приоритетные модули
for _, moduleName in ipairs(priorityModules) do
    local module = SquadMod:FindFirstChild(moduleName)
    if module then
        print("🔧 Декомпилируем: " .. moduleName)
        
        local decompiled = decompileModule(module)
        
        local header = [[-- ]] .. moduleName .. [[ Decompiled
-- From: SquadMod.]] .. moduleName .. [[
-- Game: ]] .. game.PlaceId .. [[
-- Time: ]] .. os.date() .. [[

]]
        
        local content = header .. decompiled
        local filename = "SquadMod_" .. moduleName .. ".lua"
        
        local success, error_msg = pcall(function()
            writefile(filename, content)
        end)
        
        if success then
            print("✅ " .. moduleName .. " сохранен")
        else
            print("❌ Ошибка " .. moduleName .. ": " .. tostring(error_msg))
        end
    else
        print("❌ Модуль не найден: " .. moduleName)
    end
end

-- Показываем все доступные модули
print("\n📋 Все подмодули SquadMod:")
for i, child in pairs(SquadMod:GetChildren()) do
    print("  " .. i .. ". " .. child.Name .. " (" .. child.ClassName .. ")")
end

print("\n💡 Если декомпиляция не работает, попробуй:")
print("1. Другой эмулятор с лучшим декомпилятором")
print("2. Анализ через require() и вывод функций")
print("3. Отслеживание RemoteEvents вместо декомпиляции")
