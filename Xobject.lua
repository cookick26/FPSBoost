local keywords = {
    "tree",
    "bush",
    "foliage",
    "plant",
    "flower",
    "deco",
    "decoration"
}

for _, obj in ipairs(workspace:GetDescendants()) do
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
