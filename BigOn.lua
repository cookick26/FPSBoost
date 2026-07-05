-- [[ 1. 설정 (Settings) ]] --
local HitboxSettings = {
    Size = 2.45,                  -- Размер хитбокса (히트박스 크기)
    Transparency = 1,             -- Прозрачность (투명도: 0 - 보임, 1 - 안 보임)
    Color = Color3.fromRGB(255, 255, 255), -- Цвет (색상)
    Enabled = true,               -- Включено/Выключено (켜기/끄기)
    TargetPart = "Head"           -- Какую часть увеличиваем (크기를 키울 파트: Head 또는 HumanoidRootPart)
}

local AimbotSettings = {
    FovRadius = 120,              -- FOV 원 크기
    Smoothness = 0.41             -- 에임이 따라가는 부드러움 정도
}

-- [[ 2. 서비스 및 변수 선언 ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService") -- 현재 사용되진 않지만 원본 유지

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local aiming = false


-- [[ 4. 기능 함수: 가장 가까운 플레이어 찾기 ]] --
local function getClosest()
    local closest = nil
    local shortest = math.huge
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local head = v.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- 화면 중앙(FOV)으로부터의 거리 계산
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - fovCircle.Position).Magnitude
                    
                    -- 내 캐릭터와 상대방 캐릭터의 실제 3D 거리 계산 (R6, R15 호환)
                    local myHead = Player.Character and Player.Character:FindFirstChild("Head")
                    local dist3D = myHead and (head.Position - myHead.Position).Magnitude or math.huge
                    
                    if distFromCenter <= AimbotSettings.FovRadius and dist3D < shortest then
                        shortest = dist3D
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

-- [[ 5. 마우스 입력 감지 (우클릭 에임봇) ]] --
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- [[ 6. 메인 루프 (매 프레임마다 실행) ]] --
RunService.RenderStepped:Connect(function()
    -- [A] FOV 원 위치 업데이트
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- [B] 에임봇(카메라 락) 로직
    if aiming then
        local target = getClosest()
        if target then
            -- 1. 목표치(적의 머리)를 바라보는 기준 CFrame 계산
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            
            -- 2. Lerp를 사용해 현재 카메라 방향에서 목표 방향으로 부드럽게 이동
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
        end
    end
    
    -- [C] 히트박스(크기 조절) 로직
    if HitboxSettings.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild(HitboxSettings.TargetPart) then
                local part = v.Character[HitboxSettings.TargetPart]
                
                pcall(function()
                    -- 파트 속성 변경
                    part.Size = Vector3.new(HitboxSettings.Size, HitboxSettings.Size, HitboxSettings.Size)
                    part.Transparency = HitboxSettings.Transparency
                    part.Color = HitboxSettings.Color
                    part.Material = Enum.Material.Neon
                    part.CanCollide = false
                    part.Massless = true
                    
                    -- 얼굴(표정) 숨기기
                    if HitboxSettings.TargetPart == "Head" then
                        local face = part:FindFirstChild("face") or part:FindFirstChild("Face")
                        if face and face:IsA("Decal") then
                            face.Transparency = HitboxSettings.Transparency
                        end
                    end
                end)
            end
        end
    end
end)
