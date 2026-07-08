if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

-- 1. 서비스 및 로컬 플레이어 정의
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 2. GUI 부모 경로 설정
local targetParent = nil
if gethui then
    targetParent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    targetParent = game:GetService("CoreGui").RobloxGui
else
    targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

-- 구버전 GUI 완전 청소 (버그 방지)
if targetParent:FindFirstChild("DeltaTopBarSystem") then
    targetParent.DeltaTopBarSystem:Destroy()
end
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("CrosshairGui") then
    playerGui.CrosshairGui:Destroy()
end

--------------------------------------------------------------------------------
-- [시스템 1] CROSSHAIR (크로스헤어 설정)
--------------------------------------------------------------------------------
local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "CrosshairGui"
CrosshairGui.ResetOnSpawn = false
CrosshairGui.Parent = playerGui

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
local top = createLine(thickness, size, 0, -offsetDistance)       
local bottom = createLine(thickness, size, 0, offsetDistance)    
local left = createLine(size, thickness, -offsetDistance, 0)     
local right = createLine(size, thickness, offsetDistance, 0)     

--------------------------------------------------------------------------------
-- [시스템 2] DELTA FPS OPTIMIZER MENU (UI 슬림화)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaTopBarSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999999
ScreenGui.Parent = targetParent

ScreenGui.Enabled = false 

local LogoButton = Instance.new("TextButton")
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

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 6)
LogoCorner.Parent = LogoButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "DeltaMainPanel"
MainMenu.Size = UDim2.new(0, 180, 0, 100) 
MainMenu.Position = UDim2.new(0.5, -90, 0.4, -50)
MainMenu.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainMenu.BorderSizePixel = 0
MainMenu.Visible = false
MainMenu.ZIndex = 500
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0, 8)
MainMenuCorner.Parent = MainMenu

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Name = "Title"
MenuTitle.Size = UDim2.new(1, 0, 0, 30)
MenuTitle.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MenuTitle.Text = "Cookick System"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.TextSize = 13
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.ZIndex = 501
MenuTitle.Parent = MainMenu

local MenuTitleCorner = Instance.new("UICorner")
MenuTitleCorner.CornerRadius = UDim.new(0, 8)
MenuTitleCorner.Parent = MenuTitle

local FpsButton = Instance.new("TextButton")
FpsButton.Name = "FpsButton"
FpsButton.Size = UDim2.new(0.9, 0, 0, 40)
FpsButton.Position = UDim2.new(0.05, 0, 0, 45) 
FpsButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
FpsButton.Text = "FPS Booster"
FpsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsButton.TextSize = 13
FpsButton.Font = Enum.Font.SourceSansBold
FpsButton.ZIndex = 502
FpsButton.Parent = MainMenu

local FpsCorner = Instance.new("UICorner")
FpsCorner.CornerRadius = UDim.new(0, 4)
FpsCorner.Parent = FpsButton

--------------------------------------------------------------------------------
-- GUI 작동 및 드래그 로직
--------------------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

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

--------------------------------------------------------------------------------
-- 최적화 메인 실행 함수 (텍스처 보존 + 엔진 레벨 렌더링 최적화)
--------------------------------------------------------------------------------
FpsButton.MouseButton1Click:Connect(function()
    FpsButton.Text = "Boosted!"
    FpsButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    FpsButton.Active = false
    
    -- 1. 가장 큰 렉의 원인인 그림자 및 조명 효과 완전 제거
    Lighting.GlobalShadows = false
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
            obj:Destroy()
        end
    end

    -- 캐릭터 보호 필터
    local function isProtected(instance)
        if instance:FindFirstAncestorOfClass("Tool") or instance:IsA("Tool") then
            return true
        end
        local ancestorModel = instance:FindFirstAncestorOfClass("Model")
        if ancestorModel and ancestorModel:FindFirstChildOfClass("Humanoid") then
            return true
        end
        return false
    end

    -- 2. 대규모 맵 최적화 루프 (텍스처 유지 + 렌더링 경량화)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            if obj:IsA("BasePart") then
                -- 그림자를 꺼서 연산 속도 대폭 향상
                obj.CastShadow = false
                obj.Reflectance = 0
                
                -- ★ [핵심 코드]: 통짜 메쉬의 그림(텍스처)은 그대로 놔두고, 로블록스 엔진 자체의 렌더링 정밀도를 낮춰 렉을 줄입니다.
                if obj:IsA("MeshPart") then
                    pcall(function()
                        obj.RenderFidelity = Enum.RenderFidelity.Performance
                    end)
                end
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                -- 건물 본체 텍스처가 아닌 일반 스티커(데칼)만 제거
                local p = obj.Parent
                if p and not p:IsA("MeshPart") then
                    obj:Destroy()
                end
            -- 연기, 불, 반짝임 등 프레임 드랍 유발 요소 무조건 제거
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                obj:Destroy()
            end
        end
    end

    -- 3. 렉 유발 1순위인 잡초/나무/장식품 에셋 완전 박멸
    local keywords = {
        "tree", "grass", "bush", "foliage", "plant", "flower", "deco", "decoration"
    }

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            if obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") then
                local name = obj.Name:lower()
                for _, keyword in ipairs(keywords) do
                    if string.find(name, keyword) and not string.find(name, "window") and not string.find(name, "glass") then
                        pcall(function()
                            obj:Destroy()
                        end)
                        break
                    end
                end
            end
        end
    end
end)
