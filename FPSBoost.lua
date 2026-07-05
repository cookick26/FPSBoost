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

-- Graphics Cleaner Engine Optimization Profile (캐릭터 및 무기 보호 기능 추가)
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

    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- 캐릭터나 무기 부품이면 최적화를 건너뜀 (안전 장치)
        if not isProtected(obj) then
            -- 일반 파트, 메쉬파트, 유니온을 모두 포함하도록 IsA("BasePart") 사용
            if obj:IsA("BasePart") then
                -- 에너지 쉴드(ForceField, Glass)나 투명한 파트가 아닐 때만 작동
                if obj.Transparency == 0 and obj.Material ~= Enum.Material.ForceField and obj.Material ~= Enum.Material.Glass then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    
                    -- 만약 이 오브젝트가 MeshPart라면 내부 텍스처를 강제로 지워버림
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
    end

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
        -- 여기서도 캐릭터나 무기는 파괴하지 않도록 보호
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
