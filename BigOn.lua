local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local plr = players.LocalPlayer
local cam = workspace.CurrentCamera

-- ==========================================
-- [1] 에임봇(Aimbot) 설정
-- ==========================================
local aiming = false
local fovRadius = 120
local smoothness = 0.41

-- FOV 원 그리기
local fovCircle = Drawing.new("Circle")
fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
fovCircle.Radius = fovRadius -- 실제 fovRadius 변수와 연동
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1.6
fovCircle.Transparency = 0.6
fovCircle.Visible = true
fovCircle.Filled = false

-- ==========================================
-- [2] 히트박스(Hitbox) 확장 설정
-- ==========================================
local HitboxSettings = {
    Size = 2.3,                  -- 히트박스 크기 (Размер хитбокса)
    Transparency = 1,            -- 투명도 (0 - 보임, 1 - 안 보임)
    Color = Color3.fromRGB(255, 255, 255), 
    Enabled = true,              -- 활성화 여부
    TargetPart = "Head"          -- 크기를 키울 부위 (Head 또는 HumanoidRootPart)
}

-- ==========================================
-- [3] 에임봇 함수
-- ==========================================
-- FOV 원 안에 있는 가장 가까운 플레이어의 머리를 찾습니다 (R6, R15 호환)
local function getClosest()
    local closest = nil
    local shortest = math.huge
    
    for _, v in pairs(players:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local head = v.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - fovCircle.Position).Magnitude
                    
                    -- 자신의 머리 찾기
                    local myHead = plr.Character and plr.Character:FindFirstChild("Head")
                    local dist3D = myHead and (head.Position - myHead.Position).Magnitude or math.huge
                    
                    if distFromCenter <= fovRadius and dist3D < shortest then
                        shortest = dist3D
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

-- 마우스 우클릭 입력 감지
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

uis.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- ==========================================
-- [4] 메인 루프 (에임봇 & 히트박스 동시 처리)
-- ==========================================
rs.RenderStepped:Connect(function()
    -- 1. FOV 원 위치 업데이트
    fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    
    -- 2. 에임봇 카메라 고정 로직
    if aiming then
        local target = getClosest()
        if target then
            -- 목표치를 바라보는 기준 CFrame 계산 후 Lerp로 부드럽게 이동
            local targetCFrame = CFrame.new(cam.CFrame.Position, target.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, smoothness)
        end
    end

    -- 3. 히트박스 확장 로직
    if HitboxSettings.Enabled then
        for _, v in pairs(players:GetPlayers()) do
            -- 본인이 아니며 캐릭터 모델과 타겟 부위가 존재하는지 확인
            if v ~= plr and v.Character and v.Character:FindFirstChild(HitboxSettings.TargetPart) then
                local part = v.Character[HitboxSettings.TargetPart]
                
                pcall(function()
                    part.Size = Vector3.new(HitboxSettings.Size, HitboxSettings.Size, HitboxSettings.Size)
                    part.Transparency = HitboxSettings.Transparency
                    part.Color = HitboxSettings.Color
                    part.Material = Enum.Material.Neon
                    part.CanCollide = false -- 투명한 벽에 부딪히는 것을 방지
                    part.Massless = true    -- 커진 부위의 무게로 인해 물리 엔진이 꼬이는 것을 방지
                end)
            end
        end
    end
end)
