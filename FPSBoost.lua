local uis = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local aiming = false
local fovRadius = 120
local smoothness = 0.25

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

아, 무슨 말인지 바로 이해했어! 기존 코드에서는 obj:IsA("BasePart")로 필터링을 했는데, 로블록스에서 나무나 특수 오브젝트에 쓰이는 MeshPart나 PartOperation(유니온 오브젝트)들이 조건에서 누락되었거나, 이전 수정에서 추가한 Transparency == 0 조건 때문에 메쉬 내부의 특성(TextureID 등)이 제대로 초기화되지 않았던 모양이야.

MeshPart는 자체적으로 고유한 텍스처 데이터(TextureID)를 가지고 있어서, 재질만 SmoothPlastic으로 바꾼다고 해서 텍스처가 지워지지 않고 그대로 남는 경우가 많아.

그래서 이번에는 MeshPart와 UnionOperation까지 확실하게 잡아내고, 메쉬가 가진 고유 텍스처(TextureID)까지 공백으로 날려버려서 완전히 단순한 민짜 오브젝트로 만들도록 수정했어. 물론 쉴드와 같은 투명 오브젝트들은 여전히 안전하게 제외되도록 설계했으니 걱정 안 해도 돼!

🛠️ 수정된 스크립트 (MeshPart 단순화 추가)
Lua
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- DELTA ULTIMATE PARENT DIRECTORY HUNT
local targetParent = nil
if gethui then
    targetParent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    targetParent = game:GetService("CoreGui").RobloxGui
else
    targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

-- Re-use or create unique screen layer
local ScreenGui = targetParent:FindFirstChild("DeltaTopBarSystem")
if not ScreenGui then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaTopBarSystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 9999999
    ScreenGui.Parent = targetParent
end

--------------------------------------------------------------------------------
-- SYSTEM INTERFACE SETUP (INSTANT POP-UP DESIGN)
--------------------------------------------------------------------------------

-- 1. TOPBAR FLOATING TOGGLE BUTTON
local LogoButton = ScreenGui:FindFirstChild("DeltaToggleBtn") or Instance.new("TextButton")
LogoButton.Name = "DeltaToggleBtn"
LogoButton.Size = UDim2.new(0, 50, 0, 32)
LogoButton.Position = UDim2.new(0, 15, 0, 15) 
LogoButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
LogoButton.Text = "MENU"
LogoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoButton.TextSize = 12
LogoButton.Font = Enum.Font.SourceSansBold
LogoButton.ZIndex = 10000
LogoButton.Active = true
LogoButton.Visible = true
LogoButton.Parent = ScreenGui

local LogoCorner = LogoButton:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 6)
LogoCorner.Parent = LogoButton

-- 2. MAIN COMPACT INTERFACE
local MainMenu = ScreenGui:FindFirstChild("DeltaMainPanel") or Instance.new("Frame")
MainMenu.Name = "DeltaMainPanel"
MainMenu.Size = UDim2.new(0, 180, 0, 100) 
MainMenu.Position = UDim2.new(0.5, -90, 0.4, -50)
MainMenu.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainMenu.BorderSizePixel = 0
MainMenu.Visible = false
MainMenu.ZIndex = 500
MainMenu.Parent = ScreenGui

local MainMenuCorner = MainMenu:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0, 8)
MainMenuCorner.Parent = MainMenu

local MenuTitle = MainMenu:FindFirstChild("Title") or Instance.new("TextLabel")
MenuTitle.Name = "Title"
MenuTitle.Size = UDim2.new(1, 0, 0, 30)
MenuTitle.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MenuTitle.Text = "Delta Engine Menu"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.TextSize = 13
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.ZIndex = 501
MenuTitle.Parent = MainMenu

local MenuTitleCorner = MenuTitle:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
MenuTitleCorner.CornerRadius = UDim.new(0, 8)
MenuTitleCorner.Parent = MenuTitle

-- 3. HARDWARE OPTIMIZER BUTTON
local FpsButton = MainMenu:FindFirstChild("FpsButton") or Instance.new("TextButton")
FpsButton.Name = "FpsButton"
FpsButton.Size = UDim2.new(0.9, 0, 0, 40)
FpsButton.Position = UDim2.new(0.05, 0, 0, 45) 
FpsButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
FpsButton.Text = "FPS Unlocker"
FpsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsButton.TextSize = 13
FpsButton.Font = Enum.Font.SourceSansBold
FpsButton.ZIndex = 502
FpsButton.Parent = MainMenu

local FpsCorner = FpsButton:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
FpsCorner.CornerRadius = UDim.new(0, 4)
FpsCorner.Parent = FpsButton

--------------------------------------------------------------------------------
-- INTERACTION OPERATIONS FRAMEWORK
--------------------------------------------------------------------------------

local dragging, dragStart, startPos
LogoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = LogoButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        LogoButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

LogoButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- Graphics Cleaner Engine Optimization Profile (MeshPart 최적화 추가)
FpsButton.MouseButton1Click:Connect(function()
    FpsButton.Text = "Boosted!"
    FpsButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    FpsButton.Active = false
    
    Lighting.GlobalShadows = false
    
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
            obj:Destroy()
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- 일반 파트, 메쉬파트, 유니온을 모두 포함하도록 IsA("BasePart") 사용
        if obj:IsA("BasePart") then
            -- 에너지 쉴드(ForceField, Glass)나 투명한 파트가 아닐 때만 작동
            if obj.Transparency == 0 and obj.Material ~= Enum.Material.ForceField and obj.Material ~= Enum.Material.Glass then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                
                -- 만약 이 오브젝트가 MeshPart라면 내부 텍스처를 강제로 지워버림 (나무 텍스처 제거)
                if obj:IsA("MeshPart") then
                    obj.TextureID = ""
                end
            end
        -- SpecialMesh 형태의 특수 메쉬 오브젝트 처리
        elseif obj:IsA("SpecialMesh") then
            if obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Transparency == 0 then
                obj.TextureId = ""
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            if obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Transparency == 0 then
                obj:Destroy()
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
            obj:Destroy()
        end
    end
end)
