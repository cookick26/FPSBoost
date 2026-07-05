if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

-- 1. 서비스 및 로컬 플레이어 정의 (중복 선언 제거 및 최상단 통합)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 2. GUI 부모 경로 설정 (익스플로잇 및 일반 클라이언트 모두 호환)
local targetParent = nil
if gethui then
    targetParent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    targetParent = game:GetService("CoreGui").RobloxGui
else
    targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

--------------------------------------------------------------------------------
-- [시스템 1] CROSSHAIR (크로스헤어 설정)
--------------------------------------------------------------------------------
local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "CrosshairGui"
CrosshairGui.ResetOnSpawn = false
CrosshairGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local size = 4 -- 각 선의 길이 조절
local thickness = 2 -- 선의 두께 조절
local gap = 2 -- 중앙 갭(빈 공간)의 크기 조절
local offsetY = -28.9 -- 위로 이동
local color = Color3.fromRGB(0, 255, 255) -- 에임 색상

-- 선을 생성하는 함수
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

-- 선의 중앙 앵커 포인트 기준 위치 계산
local offsetDistance = gap + (size / 2)

-- 상, 하, 좌, 우 4개의 선 생성
local top = createLine(thickness, size, 0, -offsetDistance)       -- 위쪽 선
local bottom = createLine(thickness, size, 0, offsetDistance)    -- 아래쪽 선
local left = createLine(size, thickness, -offsetDistance, 0)     -- 왼쪽 선
local right = createLine(size, thickness, offsetDistance, 0)     -- 오른쪽 선

--------------------------------------------------------------------------------
-- [시스템 2] DELTA FPS OPTIMIZER MENU (최적화 메뉴 설정)
--------------------------------------------------------------------------------
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

-- ⚙️ 초기 설정: 스크립트 실행 시 처음에는 메뉴가 보이지 않도록 숨김 처리
ScreenGui.Enabled = false 

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
MenuTitle.Text = "Cookick System"
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
FpsButton.Text = "FPS Booster"
FpsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsButton.TextSize = 13
FpsButton.Font = Enum.Font.SourceSansBold
FpsButton.ZIndex = 502
FpsButton.Parent = MainMenu

local FpsCorner = FpsButton:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
FpsCorner.CornerRadius = UDim.new(0, 4)
FpsCorner.Parent = FpsButton

--------------------------------------------------------------------------------
-- 상호작용 및 최적화 작동 로직 (INTERACTION OPERATIONS FRAMEWORK)
--------------------------------------------------------------------------------

-- ⌨️ Insert 키 입력 시 메뉴 UI 토글 기능 (채팅 중 입력 방지 예외처리 포함)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- 메뉴 버튼 드래그 기능
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

-- 메뉴 켜기/끄기 (MENU 버튼 클릭 시 메인 패널 토글)
LogoButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- 최적화(FPS Unlocker) 작동 로직
FpsButton.MouseButton1Click:Connect(function()
    FpsButton.Text = "Boosted!"
    FpsButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    FpsButton.Active = false
    
    Lighting.GlobalShadows = false
    
    -- 광원 효과 제거
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
            obj:Destroy()
        end
    end

    -- 🛡️ 중요: 플레이어 캐릭터와 무기를 보호하기 위한 검사 함수
    local function isProtected(instance)
        -- 1. 무기(Tool)에 속해 있는지 확인
        if instance:FindFirstAncestorOfClass("Tool") or instance:IsA("Tool") then
            return true
        end
        -- 2. 플레이어 캐릭터(Humanoid를 가진 모델)에 속해 있는지 확인
        local ancestorModel = instance:FindFirstAncestorOfClass("Model")
        if ancestorModel and ancestorModel:FindFirstChildOfClass("Humanoid") then
            return true
        end
        return false
    end

    -- 맵 텍스처 및 파티클 최적화
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            if obj:IsA("BasePart") then
                if obj.Transparency == 0 and obj.Material ~= Enum.Material.ForceField and obj.Material ~= Enum.Material.Glass then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    
                    if obj:IsA("MeshPart") then
                        obj.TextureID = ""
                    end
                end
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
    end

    -- 불필요한 장식품 제거
    local keywords = {
        "tree",
        "grass",
        "bush",
        "foliage",
        "plant",
        "flower",
        "deco",
        "decoration"
    }

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            if obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") then
                local name = obj.Name:lower()

                for _, keyword in ipairs(keywords) do
                    if string.find(name, keyword) then
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
