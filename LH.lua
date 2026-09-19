local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Settings = {
    Size = 3,
    Enabled = true,
    TargetPart = "Head"
}

local Player = game:GetService("Players").LocalPlayer
local originalSizes = {}
local visualHeads = {}

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild(Settings.TargetPart) then
            local head = v.Character[Settings.TargetPart]
            
            pcall(function()
                -- 원래 크기 저장
                if not originalSizes[head] then
                    originalSizes[head] = head.Size
                end
                
                -- 3️⃣ 시각적 머리 복사본 생성 (Head 완전 복사) - 먼저 생성!
                if not visualHeads[head] then
                    local visualHead = head:Clone()
                    visualHead.Name = "VisualHead"
                    visualHead.Size = originalSizes[head]  -- 원래 크기
                    visualHead.Transparency = 0  -- 보이게
                    visualHead.CanCollide = false
                    visualHead.CFrame = head.CFrame
                    visualHead.Parent = v.Character  -- ⭐ head 밖에 배치
                    
                    -- 원래 Head와 VisualHead를 Weld로 고정
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = head
                    weld.Part1 = visualHead
                    weld.Parent = visualHead
                    
                    visualHeads[head] = visualHead
                end
                
                -- 1️⃣ 원래 Head를 크게 + 투명하게 (히트박스 역할)
                head.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
                head.Transparency = 1
                head.CanCollide = false  -- ⭐ 충돌 활성화
                head.Massless = true
                
                -- 2️⃣ 원래 Head의 모든 Decal을 투명하게 (표정 제거)
                for _, decal in pairs(head:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal.Transparency = 1
                    end
                end
                
            end)
        end
    end
end)
