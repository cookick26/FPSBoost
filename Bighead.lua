local Settings = {
    Size = 2.3,                   -- Размер хитбокса
    Transparency = 1,          -- Прозрачность (0 - видно, 1 - невидимо)
    Color = Color3.fromRGB(255, 255, 255), -- Цвет (Красный)
    Enabled = true,              -- Включено/Выключено
    TargetPart = "Head"          -- Какую часть увеличиваем (Head или HumanoidRootPart)
}

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        -- Проверяем, что это не наш персонаж и у игрока есть модель
        if v ~= Player and v.Character and v.Character:FindFirstChild(Settings.TargetPart) then
            local part = v.Character[Settings.TargetPart]
            
            pcall(function()
                part.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
                part.Transparency = Settings.Transparency
                part.Color = Settings.Color
                part.Material = Enum.Material.Neon
                part.CanCollide = false -- Чтобы не врезаться в огромные невидимые стены
                part.Massless = true    -- Чтобы физика игрока не ломалась от веса части
            end)
        end
    end
end)
