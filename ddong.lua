local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 설정 (Configuration)
local FOV_RADIUS = 200
local SMOOTHNESS = 0.2 -- 부드러움 조절 (0.1 = 자연스러움, 0.5 = 강하게 고정)
local AIM_KEY = Enum.KeyCode.Q
local TEAM_CHECK = true -- 팀원 제외 활성화 (true = 같은 팀 조준 안 함 / false = 팀 상관없이 조준)

-- 가장 가까운 대상을 찾는 함수
local function getClosest()
    local target = nil
    local shortestDist = FOV_RADIUS
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        -- 팀원 여부 확인 (TEAM_CHECK가 true이고 팀이 존재하며, 나와 같은 팀인 경우 true)
        local isTeammate = TEAM_CHECK and LocalPlayer.Team and (p.Team == LocalPlayer.Team)

        -- 나 자신이 아니고, 캐릭터가 있으며, 같은 팀원이 아닐 때만 조준
        if p ~= LocalPlayer and p.Character and not isTeammate then
            -- 휴머노이드(체력) 및 헤드(또는 몸통) 확인
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso")
            
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

-- 프레임마다 마우스 커서를 타겟으로 부드럽게 이동시키는 루프
RunService.RenderStepped:Connect(function()
    if UserInputService:IsKeyDown(AIM_KEY) then
        local targetPos = getClosest()
        if targetPos then
            local mousePos = UserInputService:GetMouseLocation()
            
            -- 현재 마우스 위치와 타겟 위치의 차이를 계산하여 SMOOTHNESS 비율만큼 이동
            local diffX = (targetPos.X - mousePos.X) * SMOOTHNESS
            local diffY = (targetPos.Y - mousePos.Y) * SMOOTHNESS
            
            -- 마우스 커서 위치 업데이트
            mousemoverel(diffX, diffY)
        end
    end
end)
