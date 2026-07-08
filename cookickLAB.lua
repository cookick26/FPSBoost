if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

--------------------------------------------------------------------------------
-- [1] 서비스 및 전역 변수 정의 (통합 관리)
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- [2] GUI 부모 경로 설정 (익스플로잇 및 일반 클라이언트 호환)
--------------------------------------------------------------------------------
local targetParent = nil
if gethui then
    targetParent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    targetParent = game:GetService("CoreGui").RobloxGui
else
    targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

--------------------------------------------------------------------------------
-- [3] 기능별 설정 값 (Settings)
--------------------------------------------------------------------------------
local HitboxSettings = {
    Enabled = false, -- 초기 상태: 꺼짐 (메뉴에서 토글 가능)
    Size = 2.65,
    Transparency = 1,
    Color = Color3.fromRGB(255, 255, 255),
    TargetPart = "Head"
}

local AimbotSettings = {
    Enabled = false, -- 초기 상태: 꺼짐 (메뉴에서 토글 가능)
    FovRadius = 120,
    Smoothness = 0.45
}

local aiming = false

--------------------------------------------------------------------------------
-- [시스템 1] CROSSHAIR (크로스헤어 설정)
--------------------------------------------------------------------------------
local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "CrosshairGui"
CrosshairGui.ResetOnSpawn = false
CrosshairGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local size = 4
local thickness = 2
local gap = 2
local offsetY = -28.9
local color = Color3.fromRGB(0, 255, 255)

local function createLine(sizeX, sizeY, offsetX, offsetY_Pos)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, sizeX, 0, sizeY)
    line.Position = UDim2.new(0.5, offsetX, 0.5, offsetY + offsetY_Pos)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = color
    line.BorderSizePixel = 0
    line.Parent = CrosshairGui
    return line
end

local offsetDistance = gap + (size / 2)
createLine(thickness, size, 0, -offsetDistance)
createLine(thickness, size, 0, offsetDistance)
createLine(size, thickness, -offsetDistance, 0)
createLine(size, thickness, offsetDistance, 0)

--------------------------------------------------------------------------------
-- [시스템 2] 에임봇 FOV 서클 (Drawing API)
--------------------------------------------------------------------------------
local fovCircle = Drawing.new("Circle")
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
fovCircle.Radius = AimbotSettings.FovRadius
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1.6
fovCircle.Transparency = 0.6
fovCircle.Visible = false -- 초기에는 에임봇이 꺼져있으므로 숨김
fovCircle.Filled = false

--------------------------------------------------------------------------------
-- [시스템 3] 통합 메뉴 GUI 디자인 (버튼 추가 및 레이아웃 수정)
--------------------------------------------------------------------------------
local ScreenGui = targetParent:FindFirstChild("DeltaTopBarSystem")
if not ScreenGui then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaTopBarSystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 9999999
    ScreenGui.Parent = targetParent
end

ScreenGui.Enabled = false 

-- 1. 토글 버튼 (MENU)
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

-- 2. 메인 패널 (크기 확장: 180x100 -> 180x185)
local MainMenu = ScreenGui:FindFirstChild("DeltaMainPanel") or Instance.new("Frame")
MainMenu.Name = "DeltaMainPanel"
MainMenu.Size = UDim2.new(0, 180, 0, 185) 
MainMenu.Position = UDim2.new(0.5, -90, 0.4, -92)
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
MenuTitle.Text = "Cookick System"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.TextSize = 13
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.ZIndex = 501
MenuTitle.Parent = MainMenu

local MenuTitleCorner = MenuTitle:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
MenuTitleCorner.CornerRadius = UDim.new(0, 8)
MenuTitleCorner.Parent = MenuTitle

-- 3. 버튼 생성 공통 함수
local function createMenuButton(name, text, posY, color)
    local btn = MainMenu:FindFirstChild(name) or Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, posY) 
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    btn.ZIndex = 502
    btn.Parent = MainMenu
    
    local corner = btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    return btn
end

-- 버튼들 정의
local FpsButton = createMenuButton("FpsButton", "FPS Booster", 40, Color3.fromRGB(138, 43, 226))
local HitboxButton = createMenuButton("HitboxButton", "Hitbox: OFF", 85, Color3.fromRGB(200, 50, 50))
local AimbotButton = createMenuButton("AimbotButton", "Aimbot: OFF", 130, Color3.fromRGB(200, 50, 50))

--------------------------------------------------------------------------------
-- [4] 핵심 기능 상호작용 및 오퍼레이션 로직
--------------------------------------------------------------------------------

-- Insert 키 입력 시 전체 UI 토글
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- MENU 버튼 드래그 로직
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

-- MENU 버튼 클릭 시 메인 패널 토글
LogoButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- [기능 1] FPS Booster 작동
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

    local function isProtected(instance)
        if instance:FindFirstAncestorOfClass("Tool") or instance:IsA("Tool") then return true end
        local ancestorModel = instance:FindFirstAncestorOfClass("Model")
        if ancestorModel and ancestorModel:FindFirstChildOfClass("Humanoid") then return true end
        return false
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            if obj:IsA("BasePart") then
                if obj.Transparency == 0 and obj.Material ~= Enum.Material.ForceField and obj.Material ~= Enum.Material.Glass then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    if obj:IsA("MeshPart") then obj.TextureID = "" end
                end
            elseif obj:IsA("SpecialMesh") then
                if obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Transparency == 0 then obj.TextureId = "" end
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                if obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Transparency == 0 then obj:Destroy() end
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                obj:Destroy()
            end
        end
    end

    local keywords = {"tree", "glass", "grass", "bush", "foliage", "plant", "flower", "deco", "decoration"}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            if obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") then
                local name = obj.Name:lower()
                for _, keyword in ipairs(keywords) do
                    if string.find(name, keyword) then
                        pcall(function() obj:Destroy() end)
                        break
                    end
                end
            end
        end
    end
end)

-- [기능 2] Hitbox 토글 버튼 
HitboxButton.MouseButton1Click:Connect(function()
    HitboxSettings.Enabled = not HitboxSettings.Enabled
    if HitboxSettings.Enabled then
        HitboxButton.Text = "Hitbox: ON"
        HitboxButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        HitboxButton.Text = "Hitbox: OFF"
        HitboxButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- 비활성화 시 모든 플레이어의 히트박스를 원래 크기(대략 기본값)로 초기화
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(HitboxSettings.TargetPart) then
                pcall(function()
                    local part = v.Character[HitboxSettings.TargetPart]
                    part.Size = (HitboxSettings.TargetPart == "Head") and Vector3.new(2, 1, 1) or Vector3.new(2, 2, 1)
                    part.Transparency = 0
                    if HitboxSettings.TargetPart == "Head" then
                        local face = part:FindFirstChild("face") or part:FindFirstChild("Face")
                        if face then face.Transparency = 0 end
                    end
                end)
            end
        end
    end
end)

-- [기능 3] Aimbot 토글 버튼
AimbotButton.MouseButton1Click:Connect(function()
    AimbotSettings.Enabled = not AimbotSettings.Enabled
    if AimbotSettings.Enabled then
        AimbotButton.Text = "Aimbot: ON"
        AimbotButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        fovCircle.Visible = false
    else
        AimbotButton.Text = "Aimbot: OFF"
        AimbotButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        fovCircle.Visible = false
        aiming = false
    end
end)

--------------------------------------------------------------------------------
-- [5] 루프 기반 시스템 처리 (RenderStepped 통합 관리)
--------------------------------------------------------------------------------

-- 가장 가까운 대상을 구하는 에임봇 타겟팅 함수
local function getClosest()
    local closest = nil
    local shortest = math.huge
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local head = v.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - fovCircle.Position).Magnitude
                    local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
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

-- 마우스 우클릭 입력 체크 (에임봇 구동용)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if AimbotSettings.Enabled then
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- 매 프레임마다 연산되는 통합 루프
RunService.RenderStepped:Connect(function()
    -- 1. FOV 서클 위치 실시간 업데이트
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- 2. 히트박스 실시간 연산
    if HitboxSettings.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(HitboxSettings.TargetPart) then
                local part = v.Character[HitboxSettings.TargetPart]
                pcall(function()
                    part.Size = Vector3.new(HitboxSettings.Size, HitboxSettings.Size, HitboxSettings.Size)
                    part.Transparency = HitboxSettings.Transparency
                    part.Color = HitboxSettings.Color
                    part.Material = Enum.Material.Neon
                    part.CanCollide = false
                    part.Massless = true
                    
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
    
    -- 3. 에임봇 실시간 연산
    if AimbotSettings.Enabled and aiming then
        local target = getClosest()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
        end
    end
end)
