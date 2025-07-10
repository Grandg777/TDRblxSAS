-- Поиск денег игрока в Tower Defense
-- Проверяем все возможные места где могут храниться деньги

print("💰 Ищем деньги игрока...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. Проверяем атрибуты игрока
print("\n🔍 Проверяем атрибуты игрока:")
local attributes = {"Money", "Cash", "Coins", "Gold", "Currency", "Yen"}
for _, attr in pairs(attributes) do
    local value = LocalPlayer:GetAttribute(attr)
    if value then
        print("✅ " .. attr .. ": " .. tostring(value))
    else
        print("❌ " .. attr .. ": не найдено")
    end
end

-- 2. Проверяем leaderstats
print("\n🔍 Проверяем leaderstats:")
local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
if leaderstats then
    print("✅ leaderstats найден!")
    for _, stat in pairs(leaderstats:GetChildren()) do
        print("📊 " .. stat.Name .. ": " .. tostring(stat.Value) .. " (" .. stat.ClassName .. ")")
    end
else
    print("❌ leaderstats не найден")
end

-- 3. Проверяем GUI элементы
print("\n🔍 Проверяем GUI элементы:")
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
if PlayerGui then
    local foundMoney = false
    
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Visible then
            local text = gui.Text
            -- Ищем числа в тексте
            if text:match("%d+") then
                local number = tonumber(text:match("%d+"))
                if number and number > 0 then
                    -- Проверяем контекст (название, родитель)
                    local context = gui.Name .. " | " .. (gui.Parent and gui.Parent.Name or "")
                    if context:lower():find("money") or context:lower():find("cash") or 
                       context:lower():find("coin") or context:lower():find("currency") or
                       context:lower():find("yen") or context:lower():find("gold") then
                        print("💰 " .. context .. ": " .. text)
                        foundMoney = true
                    elseif number >= 100 and number <= 999999 then
                        -- Возможные деньги (в разумном диапазоне)
                        print("🤔 Возможно деньги - " .. context .. ": " .. text)
                    end
                end
            end
        end
    end
    
    if not foundMoney then
        print("❌ Деньги в GUI не найдены")
    end
else
    print("❌ PlayerGui не найден")
end

-- 4. Проверяем все атрибуты игрока (расширенный поиск)
print("\n🔍 Все атрибуты игрока:")
local function getAllAttributes(obj)
    local attrs = {}
    for name, value in pairs(obj:GetAttributes()) do
        attrs[name] = value
    end
    return attrs
end

local allAttrs = getAllAttributes(LocalPlayer)
if next(allAttrs) then
    for name, value in pairs(allAttrs) do
        if type(value) == "number" and value > 0 then
            print("🔢 " .. name .. ": " .. tostring(value))
        end
    end
else
    print("❌ Атрибуты не найдены")
end

-- 5. Функция для постоянного мониторинга
local function monitorMoney()
    print("\n📡 Запускаем мониторинг денег каждые 2 секунды...")
    print("(Нажми что-то в игре чтобы увидеть изменения)")
    
    spawn(function()
        local lastMoney = {}
        
        while true do
            wait(2)
            
            -- Проверяем атрибуты
            for _, attr in pairs(attributes) do
                local value = LocalPlayer:GetAttribute(attr)
                if value and value ~= lastMoney[attr] then
                    print("💰 " .. attr .. " изменилось: " .. (lastMoney[attr] or 0) .. " → " .. value)
                    lastMoney[attr] = value
                end
            end
            
            -- Проверяем leaderstats
            if leaderstats then
                for _, stat in pairs(leaderstats:GetChildren()) do
                    local value = stat.Value
                    local key = "leaderstats_" .. stat.Name
                    if value ~= lastMoney[key] then
                        print("📊 leaderstats." .. stat.Name .. " изменилось: " .. (lastMoney[key] or 0) .. " → " .. value)
                        lastMoney[key] = value
                    end
                end
            end
        end
    end)
end

-- Запускаем мониторинг
monitorMoney()

print("\n✅ Поиск денег завершен! Смотри результаты выше.")
