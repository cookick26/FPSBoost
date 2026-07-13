-- 제거할 키워드 목록 (소문자로 작성)
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

-- Workspace 안의 모든 오브젝트를 탐색합니다.
for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
    local nameLower = obj.Name:lower()
    local shouldDestroy = false

    -- 1. 먼저 키워드가 포함되어 있는지 검사 (제거 대상 확인)
    for _, keyword in ipairs(keywords) do
        if string.find(nameLower, keyword) then
            shouldDestroy = true
            break
        end
    end

    -- 2. 조건에 해당하면 오브젝트 제거
    if shouldDestroy then
        pcall(function()
            obj:Destroy()
        end)
    end
end
