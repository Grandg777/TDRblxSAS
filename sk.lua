-- SaveInstance с прогресс-баром
-- Показывает сколько объектов обработано

print("💾 Запускаем SaveInstance с прогрессом...")

-- Проверяем доступность функции
if not saveinstance then
    print("❌ saveinstance недоступен в этом эмуляторе")
    return
end

print("✅ saveinstance доступен!")

-- Функция для подсчета всех объектов
local function countAllObjects()
    local total = 0
    local services = {
        game.Workspace,
        game.ReplicatedStorage,
        game.ReplicatedFirst,
        game.StarterGui,
        game.StarterPack,
        game.StarterPlayer,
        game.SoundService,
        game.Lighting,
        game.MaterialService
    }
    
    for _, service in pairs(services) do
        total = total + #service:GetDescendants() + 1 -- +1 для самого сервиса
    end
    
    return total
end

-- Подсчитываем общее количество объектов
print("🔍 Подсчитываем объекты...")
local totalObjects = countAllObjects()
print("📊 Всего объектов для сохранения: " .. totalObjects)

-- Переменные для прогресса
local processedObjects = 0
local lastProgressUpdate = 0

-- Функция обновления прогресса
local function updateProgress()
    processedObjects = processedObjects + 1
    local progressPercent = math.floor((processedObjects / totalObjects) * 100)
    
    -- Обновляем каждые 5% или каждые 100 объектов
    if progressPercent >= lastProgressUpdate + 5 or processedObjects % 100 == 0 then
        lastProgressUpdate = progressPercent
        local progressBar = ""
        local filled = math.floor(progressPercent / 5) -- 20 символов = 100%
        
        for i = 1, 20 do
            if i <= filled then
                progressBar = progressBar .. "█"
            else
                progressBar = progressBar .. "░"
            end
        end
        
        print(string.format("🔄 [%s] %d%% (%d/%d)", 
            progressBar, progressPercent, processedObjects, totalObjects))
    end
end

-- Хук для отслеживания прогресса (если доступен)
local function hookSaveInstance()
    -- Пытаемся подключиться к внутренним событиям saveinstance
    local success = pcall(function()
        if getgenv and getgenv().saveinstance_progress then
            getgenv().saveinstance_progress = updateProgress
        end
    end)
    
    if not success then
        print("⚠️ Автоматический прогресс недоступен, используем таймер")
        -- Запускаем примерный прогресс по таймеру
        spawn(function()
            local startTime = tick()
            local estimatedTime = totalObjects / 50 -- Примерно 50 объектов в секунду
            
            while processedObjects < totalObjects do
                wait(0.5)
                local elapsed = tick() - startTime
                local estimatedProgress = math.min(elapsed / estimatedTime, 0.95) -- Максимум 95%
                processedObjects = math.floor(estimatedProgress * totalObjects)
                updateProgress()
            end
        end)
    end
end

-- Запускаем хук прогресса
hookSaveInstance()

print("🚀 Начинаем сохранение игры...")
print("⏱️ Примерное время: " .. math.ceil(totalObjects / 50) .. " секунд")

-- Сохраняем игру с прогрессом
local startTime = tick()

saveinstance({
    SavePlayers = false,
    SaveNonCreatable = true,
    DecompileScripts = true,
    DecompileModules = true,
    SaveBytecode = false,
    mode = "optimized",
    timeout = 30,
    RemovePlayerCharacters = true,
    SaveWorkspace = true,
    SaveReplicatedStorage = true,
    SaveReplicatedFirst = true,
    SaveServerStorage = false,
    SaveServerScriptService = false,
    SaveStarterGui = true,
    SaveStarterPack = true,
    SaveStarterPlayer = true,
    SaveSoundService = true,
    SaveLighting = true,
    SaveMaterialService = true
})

-- Завершаем прогресс
processedObjects = totalObjects
updateProgress()

local endTime = tick()
local totalTime = endTime - startTime

print("✅ Сохранение завершено!")
print(string.format("⏱️ Время выполнения: %.1f секунд", totalTime))
print(string.format("⚡ Скорость: %.1f объектов/сек", totalObjects / totalTime))

-- Дополнительное сохранение только Mods с прогрессом
print("\n🎯 Сохраняем отдельно папку Mods...")

local modsObjects = #game.ReplicatedStorage.Mods:GetDescendants()
local modsProcessed = 0

print("📦 Объектов в Mods: " .. modsObjects)

-- Сохраняем Mods
local success, error_msg = pcall(function()
    saveinstance({
        Instance = game.ReplicatedStorage.Mods,
        DecompileScripts = true,
        DecompileModules = true,
        SaveNonCreatable = true,
        mode = "optimized"
    })
end)

if success then
    print("✅ Папка Mods сохранена отдельно")
else
    print("❌ Ошибка сохранения Mods: " .. tostring(error_msg))
end

-- Итоговая информация
print("\n📁 Результаты сохранения:")
print("- workspace/[GameName]/ - полная игра")
print("- workspace/Mods/ - только модули")
print("\n🎯 Ищи декомпилированные файлы:")
print("- ReplicatedStorage/Mods/SquadMod.lua")
print("- ReplicatedStorage/Mods/MenuMod.lua")
print("- StarterGui/MainUI/LocalScript.lua")

print("\n📊 Статистика:")
print("Game ID:", game.PlaceId)
print("Объектов обработано:", totalObjects)
print("Время выполнения:", string.format("%.1f сек", totalTime))

-- Проверяем что файлы создались
spawn(function()
    wait(2)
    if isfile and isfolder then
        local gameFolder = "workspace/" .. tostring(game.PlaceId)
        if isfolder(gameFolder) then
            print("✅ Папка игры создана: " .. gameFolder)
        else
            print("⚠️ Папка игры не найдена, проверь workspace/")
        end
    end
end)
