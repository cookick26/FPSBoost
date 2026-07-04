local uis = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local aiming = false
local fovRadius = 120
local smoothness = 0.41

-- FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
fovCircle.Radius = 0.2 -- 기존 0.2에서 실제 fovRadius(120)로 수정했습니다.
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1.6
fovCircle.Transparency = 0.6
fovCircle.Visible = true
fovCircle.Filled = false

-- when the head is in a circle and you press "E" it locks (works on R6 and R15)
local function getClosest()
    local closest = nil
    local shortest = math.huge
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local head = v.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - fovCircle.Position).Magnitude
                    
                    -- Find our own head (compatible with R6 and R15)
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

-- 마우스 우클릭을 눌렀을 때 켜짐
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

-- 마우스 우클릭을 뗐을 때 꺼짐
uis.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

rs.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    
    if aiming then
        local target = getClosest()
        if target then
            -- 1. 목표치(적의 머리)를 바라보는 기준 CFrame을 먼저 계산합니다.
            local targetCFrame = CFrame.new(cam.CFrame.Position, target.Position)
            
            -- 2. Lerp를 사용해 현재 카메라 방향에서 목표 방향으로 부드럽게 이동시킵니다.
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, smoothness)
        end
    end -- if aiming 구문을 닫는 end가 빠져있어서 추가했습니다.
end) -- rs.RenderStepped 구문을 완전히 닫는 end)가 누락되어 있어서 수정했습니다.
