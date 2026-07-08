if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

--------------------------------------------------------------------------------
-- [★ 최적화 및 유리 보호 설정 변수]
--------------------------------------------------------------------------------
_G.TargetMaterial = Enum.Material.Plastic       -- 일반 건물 벽들을 바꿀 최적화 재질
_G.ProtectMeshPartTextures = false              -- [★치트키] 만약 유리창이 자꾸 찰흙으로 변하면 
                                                -- 이 글자를 true 로 바꾸고 실행하세요!
--------------------------------------------------------------------------------

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

-- 구버전 GUI 및 기능 완전히 청소 (코드 중첩 버그 방지)
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
-- [시스템 2] DELTA FPS OPTIMIZER MENU (최적화 메뉴 설정)
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
MenuTitleCorner.Parent = MainMenu

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
-- 상호작용 및 최적화 작동 로직
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

    -- 🛡️ [수정 핵심]: 투명도가 있거나 유리창 키워드가 들어간 MeshPart를 감지하는 필터
    local function isGlassObject(instance)
        if not instance or not instance:IsA("Instance") then return false end
        
        -- 1. 본인 검사 (유리 재질이거나, 투명도가 0보다 큰 경우 유리창으로 판단)
        if instance:IsA("BasePart") then
            if instance.Material == Enum.Material.Glass or instance.Transparency > 0 then
                return true
            end
        end
        
        -- 2. 조상 검사 (부모 폴더 중 유리창/윈도우 관련 단어가 있거나 투명한 파트가 포함된 경우)
        local current = instance
        while current and current ~= Workspace and current ~= game do
            local nameLower = string.lower(current.Name)
            if string.find(nameLower, "collision") or string.find(nameLower, "glass") or string.find(nameLower, "window") or string.find(nameLower, "pane") then
                return true
            end
            if current:IsA("BasePart") and (current.Material == Enum.Material.Glass or current.Transparency > 0) then
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

    -- 맵 최적화 대규모 루프
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            
            -- 유리 감지망에 걸린 필터는 텍스처와 형태를 완벽히 유지
            if isGlassObject(obj) then
                if obj:IsA("BasePart") and obj.Material == Enum.Material.Glass then
                    obj.Material = Enum.Material.Glass
                end
            else
                -- 유리가 아닌 일반 건물, 도로 등만 최적화 진행
                if obj:IsA("BasePart") then
                    local nameLower = string.lower(obj.Name)
                    -- 3중 예외 처리 필터링
                    if not string.find(nameLower, "collision") and not string.find(nameLower, "glass") and not string.find(nameLower, "window") and obj.Material ~= Enum.Material.Glass then
                        if obj.Material ~= Enum.Material.ForceField then
                            obj.Material = _G.TargetMaterial
                            obj.Reflectance = 0
                            
                            -- [★옵션]: ProtectMeshPartTextures 가 false 일 때만 MeshPart 텍스처 제거
                            if obj:IsA("MeshPart") and not _G.ProtectMeshPartTextures then
                                obj.TextureID = ""
                            end
                        end
                    end
                elseif obj:IsA("SpecialMesh") then
                    if not _G.ProtectMeshPartTextures then
                        obj.TextureId = ""
                    end
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj:Destroy()
                elseif obj:IsA("SurfaceAppearance") then
                    -- [★옵션]: ProtectMeshPartTextures 가 false 일 때만 정밀 텍스처 제거
                    if not _G.ProtectMeshPartTextures then
                        obj:Destroy()
                    end
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                    obj:Destroy()
                end
            end
            
        end
    end

    -- 불필요한 장식품 제거 목록
    local keywords = {
        "tree", "grass", "bush", "foliage", "plant", "flower", "deco", "decoration", "glass"
    }

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isProtected(obj) then
            -- 우리가 지켜야 할 투명 유리창은 자동 제거 목록에 들어가도 파괴하지 않음
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
