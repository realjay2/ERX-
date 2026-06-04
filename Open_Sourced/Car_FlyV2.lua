repeat task.wait() until _G.WindUI and _G.Tabs

local WindUI       = _G.WindUI
local Window       = _G.Window
local Tabs         = _G.Tabs
local Functions    = _G.Functions
local Connections  = _G.Connections

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

getgenv()._CarFlySpeed = 50 

Tabs.VehicleMods:Section({
	Title = "Car Fly",
	TextSize = 16,
})

Tabs.VehicleMods:Toggle({
    Title = "Car Fly",
    Desc = "Fly your vehicle (Keybind: J)",
    Value = false,
    Callback = function(Value)
        local ok, err = pcall(function()
            if getgenv()._carfly_conn then getgenv()._carfly_conn:Disconnect() end
            if getgenv()._carfly_hb then getgenv()._carfly_hb:Disconnect() end
            if getgenv()._carfly_vl then pcall(function() getgenv()._carfly_vl:Destroy() end) end
            if getgenv()._carfly_gy then pcall(function() getgenv()._carfly_gy:Destroy() end) end

            getgenv()._carfly_conn = nil
            getgenv()._carfly_hb = nil
            getgenv()._carfly_vl = nil
            getgenv()._carfly_gy = nil

            if not Value then
                getgenv()._carfly_final = false
                return
            end

            getgenv()._carfly_final = true

            local bind = Enum.KeyCode.J
            local on = false

            local function clean()
                if getgenv()._carfly_hb then getgenv()._carfly_hb:Disconnect() end
                if getgenv()._carfly_vl then pcall(function() getgenv()._carfly_vl:Destroy() end) end
                if getgenv()._carfly_gy then pcall(function() getgenv()._carfly_gy:Destroy() end) end
                getgenv()._carfly_hb, getgenv()._carfly_vl, getgenv()._carfly_gy = nil, nil, nil
            end

            local function attach()
                local p = Player
                local c = p and p.Character
                if not c then return end

                local h = c:FindFirstChildOfClass("Humanoid")
                if not h or not h.Sit then return end

                local st = h.SeatPart
                if not st then return end

                local v = st.Parent
                if not v or not v:FindFirstChild("Body") then return end

                local col = v.Body:FindFirstChild("CollisionPart")
                if not col then return end

                for _, d in ipairs(v:GetDescendants()) do
                    if d:IsA("TouchTransmitter") then
                        d:Destroy()
                    end
                end

                workspace.CurrentCamera.CameraSubject = h

                local gy = Instance.new("BodyGyro", col)
                gy.CFrame = workspace.CurrentCamera.CFrame
                gy.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                gy.P = 9e4

                local vl = Instance.new("BodyVelocity", col)
                vl.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                vl.P = 9e4
                vl.Velocity = Vector3.new()

                getgenv()._carfly_vl = vl
                getgenv()._carfly_gy = gy

                getgenv()._carfly_hb = RunService.Heartbeat:Connect(function()
                    if not on then
                        vl.Velocity = Vector3.new()
                        return
                    end
                    if not h.Sit then
                        clean()
                        return
                    end

                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new()

                    if UIS:IsKeyDown(Enum.KeyCode.W) then
                        moveDir += cam.CFrame.LookVector
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then
                        moveDir -= cam.CFrame.LookVector
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then
                        moveDir -= cam.CFrame.RightVector
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then
                        moveDir += cam.CFrame.RightVector
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then
                        moveDir += Vector3.new(0, 1, 0)
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveDir -= Vector3.new(0, 1, 0)
                    end

                    vl.Velocity = moveDir * getgenv()._CarFlySpeed
                    gy.CFrame = cam.CFrame
                end)
            end
					
            getgenv()._carfly_conn = UIS.InputBegan:Connect(function(i, g)
                if g or not getgenv()._carfly_final then return end
                if i.KeyCode == bind then
                    local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                    if not h or not h.Sit then return end
                    on = not on
                    if on then
                        attach()
                    else
                        clean()
                    end
                end
            end)
        end)

        if not ok then
            warn(err)
        end
    end,
})

Tabs.VehicleMods:Slider({
    Title = "Car Fly Speed",
    Desc = "Adjust how fast the vehicle flies",
    Value = {
        Min = 10,
        Max = 250,
        Default = 50,
    },
    Callback = function(NumberValue)
        getgenv()._CarFlySpeed = tonumber(NumberValue)
        WindUI:Notify({
            Title = "Car Fly Speed",
            Content = "Set speed to " .. tostring(NumberValue),
            Duration = 2,
        })
    end,
})
