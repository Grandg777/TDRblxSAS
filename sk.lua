-- SaveInstance - сохраняет всю игру со скриптами
-- Это самый мощный способ получить все скрипты игры

print("💾 Запускаем SaveInstance...")

-- Проверяем доступность функции
if not saveinstance then
    print("❌ saveinstance недоступен в этом эмуляторе")
    print("💡 Попробуй Synapse X, Script-Ware или другой продвинутый эмулятор")
    return
end

print("✅ saveinstance доступен!")

-- Базовое сохранение всей игры
print("🔄 Сохраняем всю игру...")
saveinstance()
print("✅ Игра сохранена в папку по умолчанию")

-- Продвинутое сохранение с настройками
print("🔄 Сохраняем с расширенными настройками...")

saveinstance({
    -- Основные настройки
    SavePlayers = false,        -- Не сохранять других игроков
    SaveNonCreatable = true,    -- Сохранить все объекты
    DecompileScripts = true,    -- Декомпилировать скрипты
    DecompileModules = true,    -- Декомпилировать модули
    SaveBytecode = false,       -- Не сохранять байткод
    
    -- Путь сохранения  
    mode = "optimized",         -- Оптимизированный режим
    
    -- Дополнительные опции
    timeout = 10,               -- Таймаут в секундах
    RemovePlayerCharacters = true, -- Убрать персонажей игроков
    
    -- Что сохранять
    SaveWorkspace = true,       -- Сохранить workspace (карту)
    SaveReplicatedStorage = true, -- Сохранить ReplicatedStorage
    SaveReplicatedFirst = true, -- Сохранить ReplicatedFirst
    SaveServerStorage = false,  -- ServerStorage недоступен клиенту
    SaveServerScriptService = false, -- ServerScriptService недоступен
    SaveStarterGui = true,      -- Сохранить StarterGui
    SaveStarterPack = true,     -- Сохранить StarterPack
    SaveStarterPlayer = true,   -- Сохранить StarterPlayer
    SaveSoundService = true,    -- Сохранить SoundService
    SaveLighting = true,        -- Сохранить Lighting
    SaveMaterialService = true  -- Сохранить MaterialService
})

print("✅ Расширенное сохранение завершено!")

-- Сохранение только ReplicatedStorage.Mods
print("🎯 Сохраняем только папку Mods...")

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

-- Информация о сохранении
print("\n📁 Файлы сохранены в:")
print("- workspace/[GameName]/ - полная игра")
print("- workspace/Mods/ - только модули")

print("\n📋 Что найдешь в сохраненных файлах:")
print("✅ Все декомпилированные .lua скрипты")
print("✅ Структуру карты и объектов")
print("✅ GUI элементы")
print("✅ Настройки освещения и звуков")
print("✅ Все модули из ReplicatedStorage")

print("\n🎯 Ищи эти файлы:")
print("- ReplicatedStorage/Mods/SquadMod.lua")
print("- ReplicatedStorage/Mods/MenuMod.lua") 
print("- StarterGui/[MainUI]/LocalScript.lua")
print("- ReplicatedStorage/Remotes/ - все Remote события")

print("\n💡 Если saveinstance не сработал:")
print("1. Убедись что эмулятор поддерживает эту функцию")
print("2. Попробуй другой эмулятор (Synapse X, Script-Ware)")
print("3. Проверь есть ли папка workspace после выполнения")

-- Дополнительная информация
print("\n📊 Информация об игре:")
print("Game ID:", game.PlaceId)
print("Game Name:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown")
print("Creator:", game.CreatorType == Enum.CreatorType.User and "User" or "Group")
print("Creator ID:", game.CreatorId)
