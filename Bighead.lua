local Settings = {
    Size = 2.3,                   -- Размер хитбокса (히트박스 크기)
    Transparency = 1,             -- Прозрачность (투명도: 0 - 보임, 1 - 안 보임)
    Color = Color3.fromRGB(255, 255, 255), -- Цвет (색상)
    Enabled = true,               -- Включено/Выключено (켜기/끄기)
    TargetPart = "Head"           -- Какую часть увеличиваем (크기를 키울 파트: Head 또는 HumanoidRootPart)
}

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        -- 본인의 캐릭터가 아니고, 캐릭터 모델과 설정한 파트가 존재하는지 확인
        if v ~= Player and v.Character and v.Character:FindFirstChild(Settings.TargetPart) then
            local part = v.Character[Settings.TargetPart]
            
            pcall(function()
                -- 파트 속성 변경
                part.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
                part.Transparency = Settings.Transparency
                part.Color = Settings.Color
                part.Material = Enum.Material.Neon
                part.CanCollide = false -- 거대한 투명 벽에 부딪히지 않게 함
                part.Massless = true    -- 파트 무게로 인해 캐릭터 물리엔진이 고장나지 않게 함
                
                -- [추가된 부분] 얼굴(표정) 숨기기
                if Settings.TargetPart == "Head" then
                    local face = part:FindFirstChild("face") or part:FindFirstChild("Face")
                    if face and face:IsA("Decal") then
                        face.Transparency = Settings.Transparency -- 표정도 파트와 동일한 투명도 적용
                    end
                end
            end)
        end
    end
end)
