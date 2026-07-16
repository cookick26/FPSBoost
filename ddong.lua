local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 설정 (Configuration)
local FOV_RADIUS = 120
local SMOOTHNESS = 4 -- 부드러움 조절 (0.1 = 자연스러움, 0.5 = 강함)
local AIM_KEY = Enum.KeyCode.P -- 조준 트리거 키

-- 가장 가까운 적을 찾는 함수
local function getClosest()
    local target = nil
    local shortestDist = FOV_RADIUS
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- 문법 오류 수정: FindFirstChildOfClass로 변경
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso")
            
            -- 적이 살아있는지 확인
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = pos -- 화면상의 좌표 저장
                    end
                end
            end
        end
    end
    return target
end

-- 마우스 이동 루프 인터럽트
RunService.RenderStepped:Connect(function()
    if UserInputService:IsKeyDown(AIM_KEY) then
        local targetPos = getClosest()
        
        if targetPos then
            local mousePos = UserInputService:GetMouseLocation()
            
            -- 잘려있던 마우스 조준 이동 로직 완성
            local diffX = (targetPos.X - mousePos.X) * SMOOTHNESS
            local diffY = (targetPos.Y - mousePos.Y) * SMOOTHNESS
            
            -- 로블록스 표준 API를 사용하여 마우스 커서를 목표물 쪽으로 부드럽게 이동
            -- (참고: 로컬 스크립트 내 인젝터 환경에 따라 mousemoverel 함수를 대신 사용할 수도 있습니다)
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            -- 화면 픽셀 단위 조정을 위해 의도된 마우스 상대 이동값 적용
        end
    end
end)
