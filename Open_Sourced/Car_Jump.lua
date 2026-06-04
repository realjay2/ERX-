repeat task.wait() until _G.WindUI and _G.Tabs

local WindUI = _G.WindUI
local Tabs = _G.Tabs
local Functions = _G.Functions
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

local jumpKeybind = Enum.KeyCode.H
local jumpPower = 100
local cooldown = 0.5
local lastJumpTime = 0
local backflipMode = false
local activeGyros = {}
local activeJumps = {}

local carJumpToggleInitialized = false
local backflipToggleInitialized = false
local carJumpEnabled = false

local function getVehicle()
    local char = Player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.Sit then return nil end
    local seat = hum.SeatPart
    if not seat then return nil end
    local vehicle = seat.Parent
    if not vehicle or not vehicle:FindFirstChild("Body") then return nil end
    return vehicle
end

local function cleanupGyro(vehicle)
    if activeGyros[vehicle] then
        local gyro = activeGyros[vehicle]
        if gyro and gyro.Parent then
            gyro:Destroy()
        end
        activeGyros[vehicle] = nil
    end
    if activeJumps[vehicle] then
        activeJumps[vehicle] = nil
    end
end

local function makeCarJump()
    if not carJumpEnabled then return end

    local currentTime = tick()
    if currentTime - lastJumpTime < cooldown then
        return
    end

    local vehicle = getVehicle()
    if not vehicle then
        WindUI:Notify({
            Title = "Car Jump",
            Content = "You must be in a vehicle!",
            Duration = 2,
        })
        return
    end

    local collisionPart = vehicle.Body:FindFirstChild("CollisionPart")
    if not collisionPart then
        WindUI:Notify({
            Title = "Car Jump",
            Content = "Could not find vehicle collision part!",
            Duration = 2,
        })
        return
    end

    cleanupGyro(vehicle)

    local bodyVelocity = collisionPart:FindFirstChildOfClass("BodyVelocity")
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.P = 9e4
        bodyVelocity.Parent = collisionPart
    end

    local currentVelocity = collisionPart.AssemblyLinearVelocity
    local carCFrame = collisionPart.CFrame
    local forwardDirection = carCFrame.LookVector

    if backflipMode then
        bodyVelocity.Velocity = Vector3.new(currentVelocity.X, jumpPower, currentVelocity.Z)
    else
        local forwardPower = jumpPower * 0.3
        local upwardPower = jumpPower * 0.8
        local rampVelocity = forwardDirection * forwardPower + Vector3.new(0, upwardPower, 0)
        bodyVelocity.Velocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z) + rampVelocity
    end

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.D = 1000
    bodyGyro.Parent = collisionPart

    local gravity = workspace.Gravity or 196.2
    local initialVerticalVelocity = jumpPower
    local timeToPeak = initialVerticalVelocity / gravity
    local totalAirTime = 2 * timeToPeak

    local calculatedDuration = totalAirTime
    local backflipDuration = math.clamp(calculatedDuration, 0.4, 2.5)
    local jumpDuration = backflipMode and backflipDuration or 1.5

    local initialY = collisionPart.Position.Y

    activeGyros[vehicle] = bodyGyro
    activeJumps[vehicle] = {
        startTime = currentTime,
        initialCFrame = collisionPart.CFrame,
        initialY = initialY,
        isBackflip = backflipMode
    }

    local jumpData = activeJumps[vehicle]
    local startCFrame = jumpData.initialCFrame

    task.spawn(function()
        local connection
        local backflipComplete = false
        connection = RunService.Heartbeat:Connect(function()
            if not activeJumps[vehicle] or not bodyGyro.Parent then
                connection:Disconnect()
                cleanupGyro(vehicle)
                return
            end

            local elapsed = tick() - jumpData.startTime
            local currentY = collisionPart.Position.Y
            local verticalVelocity = collisionPart.AssemblyLinearVelocity.Y
            local heightDifference = currentY - jumpData.initialY

            if backflipMode then
                local isDescending = verticalVelocity < -10
                local isNearGround = heightDifference < 2
                local shouldComplete = isDescending and isNearGround and not backflipComplete

                if shouldComplete or elapsed >= jumpDuration then
                    if not backflipComplete then
                        bodyGyro.CFrame = startCFrame
                        backflipComplete = true
                    end
                else
                    local progress = math.min(elapsed / jumpDuration, 1)
                    local easedProgress
                    if progress < 0.5 then
                        easedProgress = 4 * progress * progress * progress
                    else
                        local t = 2 * progress - 2
                        easedProgress = 1 + t * t * t / 2
                    end
                    local rotationAmount = easedProgress * 360
                    local backflipRotation = CFrame.Angles(math.rad(rotationAmount), 0, 0)
                    bodyGyro.CFrame = startCFrame * backflipRotation
                end
            else
                bodyGyro.CFrame = startCFrame
            end

            if (backflipComplete and (verticalVelocity > -5 or heightDifference < 0.5)) or (elapsed >= jumpDuration + 0.5) then
                bodyGyro.CFrame = startCFrame
                task.wait(0.2)
                connection:Disconnect()
                cleanupGyro(vehicle)
            end
        end)
    end)

    task.spawn(function()
        task.wait(0.1)
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity:Destroy()
        end
    end)

    lastJumpTime = currentTime

    WindUI:Notify({
        Title = "Car Jump",
        Content = backflipMode and "Backflip!" or "Car jumped!",
        Duration = 1,
    })
end

RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then
        for vehicle, _ in pairs(activeGyros) do
            cleanupGyro(vehicle)
        end
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.Sit then
        for vehicle, _ in pairs(activeGyros) do
            cleanupGyro(vehicle)
        end
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == jumpKeybind and carJumpEnabled then
        makeCarJump()
    end
end)

Tabs.VehicleMods:Section({
    Title = "Merfs Car Jump",
    TextSize = 16,
})

Tabs.VehicleMods:Toggle({
    Title = "Car Jump",
    Desc = "Press H to make your car jump",
    Value = false,
    Callback = function(state)
        carJumpEnabled = state
        if carJumpToggleInitialized then
            WindUI:Notify({
                Title = "Car Jump",
                Content = state and "Car Jump Enabled!" or "Car Jump Disabled!",
                Duration = 2,
            })
        else
            carJumpToggleInitialized = true
        end
    end,
})

Tabs.VehicleMods:Toggle({
    Title = "Backflip Mode",
    Desc = "Enable perfect backflips on jump",
    Value = false,
    Callback = function(state)
        if not carJumpEnabled then
            backflipMode = false
            return
        end
        backflipMode = state
        if backflipToggleInitialized then
            WindUI:Notify({
                Title = "Car Jump",
                Content = state and "Backflip mode enabled!" or "Backflip mode disabled",
                Duration = 2,
            })
        else
            backflipToggleInitialized = true
        end
    end,
})

Tabs.VehicleMods:Slider({
    Title = "Jump Power",
    Desc = "Adjust jump height",
    Value = { Min = 50, Max = 200, Default = 100 },
    Callback = function(val)
        if carJumpEnabled then
            jumpPower = tonumber(string.format("%.0f", val))
        end
    end,
    Precise = true,
})

