repeat task.wait() until _G.WindUI

local WindUI = _G.WindUI
local Tabs = _G.Tabs
local Functions = _G.Functions

local firstExecution = true

Tabs.Visuals:Section({
    Title = "Upgraded Roads",
    TextSize = 16,
})

Tabs.Visuals:Toggle({
    Title = "Better Roads",
    Desc = "Newest Version of Better Roads V3",
    Default = false,
    Callback = function(enabled)

        local detectColor = Color3.fromRGB(150, 144, 144)

        _G.OriginalPartData = _G.OriginalPartData or {}
        _G.BetterRoadsLoop = _G.BetterRoadsLoop or nil

        local function ApplyBetterRoads()
            local changedNow = 0
            local roadsModel = workspace:FindFirstChild("Roads")

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = string.lower(obj.Name)
                    local partColor = obj.Color

                    local isRoad = roadsModel and obj:IsDescendantOf(roadsModel)
                    local isParking = name:find("parking") and name:find("lot")
                    local isSidewalk = name:find("sidewalk") or name:find("sidewalkunion")
                    local isMyTest = name == "mytest"
                    local isGrayMatch = math.floor(partColor.R * 255) == 150 
                        and math.floor(partColor.G * 255) == 144 
                        and math.floor(partColor.B * 255) == 144
                    local isRoadLine = name == "roadline"
                    local isYellowLineUnderRoad = false

                    if isRoad and name:find("yellow line") then
                        local parent = obj.Parent
                        if parent and parent:IsA("BasePart") and parent:IsDescendantOf(roadsModel) then
                            isYellowLineUnderRoad = true
                        end
                    end

                    if isRoad or isParking or isSidewalk or isMyTest or isGrayMatch or isRoadLine or isYellowLineUnderRoad then
                        
                        if not _G.OriginalPartData[obj] then
                            _G.OriginalPartData[obj] = {
                                Color = obj.Color,
                                Material = obj.Material,
                            }
                        end

                        if isYellowLineUnderRoad then
                            obj.Color = Color3.fromRGB(255, 255, 255)
                            obj.Material = Enum.Material.SmoothPlastic
                        elseif isRoad or isRoadLine or isParking or isMyTest then
                            obj.Color = Color3.fromRGB(0, 0, 0)
                            obj.Material = Enum.Material.Concrete
                        elseif isSidewalk or isGrayMatch then
                            obj.Color = Color3.fromRGB(102, 98, 98)
                            obj.Material = Enum.Material.Cardboard
                        end

                        changedNow += 1
                    end
                end
            end

            return changedNow
        end

        if enabled then
            ApplyBetterRoads()

            WindUI:Notify({
                Title = "Better Roads",
                Content = "Done",
                Duration = 3,
            })

            if not _G.BetterRoadsLoop then
                _G.BetterRoadsLoop = task.spawn(function()
                    while task.wait(60) do
                        if not _G.BetterRoadsEnabled then break end
                        ApplyBetterRoads()
                    end
                end)
            end
            _G.BetterRoadsEnabled = true

        else
            _G.BetterRoadsEnabled = false

            if _G.BetterRoadsLoop then
                task.cancel(_G.BetterRoadsLoop)
                _G.BetterRoadsLoop = nil
            end

            for obj, data in pairs(_G.OriginalPartData) do
                if obj and obj:IsDescendantOf(workspace) then
                    obj.Color = data.Color
                    obj.Material = data.Material
                end
            end

            _G.OriginalPartData = {}

            if not firstExecution then
                WindUI:Notify({
                    Title = "Better Roads",
                    Content = "♻️ Restored all parts.",
                    Duration = 3,
                })
            end
        end

        firstExecution = false
    end,
})
