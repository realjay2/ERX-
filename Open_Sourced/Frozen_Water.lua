repeat task.wait() until _G.WindUI and _G.Functions and _G.Window and _G.Tabs

local WindUI = _G.WindUI
local Tabs = _G.Tabs

local waterPlatforms = {}
local waterOn = false
local firstExecution = true

local function createPlatform(startPos, endPos, thickness)
    thickness = thickness or 0.5
    local sizeX = math.abs(endPos.X - startPos.X)
    local sizeZ = math.abs(endPos.Z - startPos.Z)

    local part = Instance.new("Part")
    part.Size = Vector3.new(sizeX, thickness, sizeZ)
    part.Position = Vector3.new(
        math.min(startPos.X, endPos.X) + sizeX / 2,
        startPos.Y,
        math.min(startPos.Z, endPos.Z) + sizeZ / 2
    )
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 1
    part.Parent = workspace
    return part
end

Tabs.VehicleMods:Section({
    Title = "Frozen Rivers",
    TextSize = 16,
})

Tabs.VehicleMods:Toggle({
    Title = "Frozen River",
    Desc = "Drive or Walk on Water.",
    Default = false,

    Callback = function(value)
        if value then
            waterPlatforms[1] = createPlatform(Vector3.new(300, -15, 3000), Vector3.new(1634, -15, -9000), 0.5)
            waterPlatforms[2] = createPlatform(Vector3.new(300, -15, 3000), Vector3.new(1634, -15.5, -3000), 0.5)
            waterPlatforms[3] = createPlatform(Vector3.new(300, -15, 0), Vector3.new(1634, -15.5, -3000), 0.5)

            waterOn = true

            WindUI:Notify({
                Title = "Frozen River",
                Content = "Frozen River is ON",
                Duration = 4
            })
        else
            for _, part in pairs(waterPlatforms) do
                if part and part.Parent then
                    part:Destroy()
                end
            end

            waterPlatforms = {}
            waterOn = false

            if not firstExecution then
                WindUI:Notify({
                    Title = "Frozen River",
                    Content = "Frozen River is OFF",
                    Duration = 4
                })
            end
        end

        firstExecution = false
    end,
})
