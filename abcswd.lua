if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

--------------------------------------------------------------------------------
-- [재질 설정 변수] 건물들을 바꿀 최적화 재질입니다.
--------------------------------------------------------------------------------
_G.TargetMaterial = Enum.Material.Plastic 

-- 1. 서비스 및 로컬 플레이어 정의
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 2. GUI 부모 경로 설정
local targetParent = nil
if gethui then
    targetParent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    targetParent = game:GetService("CoreGui").RobloxGui
else
    targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

-- 구버전 GUI 완전 청소
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
-- [시스템 2] DELTA FPS OPTIMIZER MENU (메뉴 크기 및 버튼 확장)
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
MainMenu.Size = UDim2.new(0, 180, 0, 140) -- 버튼 추가를 위해 세로 크기 확장 (100 -> 140)
MainMenu.Position = UDim2.new(0.5, -90, 0.4, -70)
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

-- [버튼 1]: 부스터 버튼
local FpsButton = Instance.new("TextButton")
FpsButton.Name = "FpsButton"
FpsButton.Size = UDim2.new(0.9, 0, 0, 35)
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

-- [버튼 2]: ★ 유리 수동 잠금 버튼 추가
local SelectButton = Instance.new("TextButton")
SelectButton.Name = "SelectButton"
SelectButton.Size = UDim2.new(0.9, 0, 0, 35)
SelectButton.Position = UDim2.new(0.05, 0, 0, 90) 
SelectButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
SelectButton.Text = "Select Glass (유리 지정)"
SelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectButton.TextSize = 12
SelectButton.Font = Enum.Font.SourceSansBold
SelectButton.ZIndex = 502
SelectButton.Parent = MainMenu

local SelectCorner = Instance.new("UICorner")
SelectCorner.CornerRadius = UDim.new(0, 4)
SelectCorner.Parent = SelectButton

--------------------------------------------------------------------------------
-- 🛡️ 수동 유저 지정 화이트리스트 시스템 관련 변수
--------------------------------------------------------------------------------
local WhitelistedTextures = {}
local WhitelistedObjects = {}
local isSelecting = false

-- 유리 선택 모드 토글
SelectButton.MouseButton1Click:Connect(function()
    isSelecting = not isSelecting
    if isSelecting then
        SelectButton.Text = "Click the Glass in Game!"
        SelectButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    else
        SelectButton.Text = "Select Glass (유리 지정)"
        SelectButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    end
end)

-- 마우스 클릭 시 유리를 기억하는 로직
Mouse.Button1Down:Connect(function()
    if isSelecting and Mouse.Target then
        local target = Mouse.Target
        
        -- 오브젝트 본인 등록
        WhitelistedObjects[target] = true
        
        -- 조상 폴더/모델이 있다면 통째로 보호망 등록
        local p = target.Parent
        if p and p ~= Workspace then
            WhitelistedObjects[p] = true
        end
        
        -- MeshPart일 경우 고유 텍스처 ID 추출하여 차단 목록에 등록
        if target:IsA("MeshPart") and target.TextureID ~= "" then
            WhitelistedTextures[target.TextureID] = true
        end
        
        -- SurfaceAppearance 텍스처 ID 추출
        local sa = target:FindFirstChildOfClass("SurfaceAppearance")
        if sa and sa.TextureId ~= "" then
            WhitelistedTextures[sa.TextureId] = true
        end
        
        SelectButton.Text = "Locked: " .. target.Name .. "!"
        SelectButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        isSelecting = false
        
        task.wait(1.5)
        SelectButton.Text = "Select Another Glass (추가 지정)"
        SelectButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    end
end)

--------------------------------------------------------------------------------
-- GUI 드래그 및 단축키 상호작용
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
-- 최적화 실행 메인 로직
--------------------------------------------------------------------------------
FpsButton.MouseButton1Click:Connect(function()
    if isSelecting then return end -- 선택 중일 때는 작동 안 함
    
    FpsButton.Text = "Boosted!"
    FpsButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    FpsButton.Active = false
    
    Lighting.GlobalShadows = false
    
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
            obj:Destroy()
        end
    end

    -- 유리를 판별하는 4중 보안 필터 함수
    local function isGlassObject(instance)
        if not instance or not instance:IsA("Instance") then return false end
        
        -- 1. [★핵심] 유저가 수동으로 클릭하여 지정한 오브젝트/부모인가?
        if WhitelistedObjects[instance] or WhitelistedObjects[instance.Parent] then
            return true
        end
        
        -- 2. [★핵심] 유저가 클릭했던 유리의 텍스처 ID를 공유하는가?
        if instance:IsA("MeshPart") and WhitelistedTextures[instance.TextureID] then
            return true
        end
        local sa = instance:FindFirstChildOfClass("SurfaceAppearance")
        if sa and WhitelistedTextures[sa.TextureId] then
            return true
        end
        
        -- 3. 시스템 기본 감지 (재질이 진짜 유리이거나 투명도가 있는가?)
        if instance:IsA("BasePart") and (instance.Material == Enum.Material.Glass or instance.Transparency > 0) then
            return true
        end
        
        -- 4. 조상 이름 탐지
        local current = instance
        while current and current ~= Workspace and current ~= game do
            local nameLower = string.lower(current.Name)
            if string.find(nameLower, "collision") or string.find(nameLower, "glass") or string.find(nameLower, "window") then
                return true
            end
            current = current.Parent
        end
        
        return false
    end

    -- 플레이어 및 무기 보호 필터
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

    -- 맵 텍스처 최적화 루프
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            
            -- 구출 명단에 등록된 유리 관련 에셋은 '손끝 하나 대지 않고' 완벽히 패스합니다.
            if isGlassObject(obj) then
                -- 구조 성공: 재질, 텍스처 모두 원본 유지
            else
                -- 구출되지 않은 일반 건물들만 찰흙 최적화 진행
                if obj:IsA("BasePart") then
                    if obj.Material ~= Enum.Material.ForceField then
                        obj.Material = _G.TargetMaterial
                        obj.Reflectance = 0
                        if obj:IsA("MeshPart") then
                            obj.TextureID = ""
                        end
                    end
                elseif obj:IsA("SpecialMesh") then
                    obj.TextureId = ""
                elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
                    obj:Destroy()
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                    obj:Destroy()
                end
            end
            
        end
    end

    -- 불필요한 장식품 제거 목록
    local keywords = {
        "tree", "grass", "bush", "foliage", "plant", "flower", "deco", "decoration"
    }

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            -- 지정된 유리는 자동 제거 키워드에 걸려도 파괴하지 않고 살립니다.
            if not isGlassObject(obj) and (obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part")) then
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
