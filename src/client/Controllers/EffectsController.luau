--!strict
-- Efeitos de câmera/tela. Discretos de propósito: nada que prejudique performance
-- ou cause desconforto. Sons entram aqui quando houver assets (AudioController futuro).

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Theme = require(ReplicatedStorage:WaitForChild("Shared").UI.Theme)
local StateController = require(script.Parent.StateController)

local player = Players.LocalPlayer

local EffectsController = {}

local SHAKE_BIND = "ElevatorShake"
local correction: ColorCorrectionEffect

-- Tremor leve do elevador em movimento (offset do Humanoid, não da câmera inteira).
local function shake(duration: number)
	local start = os.clock()
	RunService:UnbindFromRenderStep(SHAKE_BIND)
	RunService:BindToRenderStep(SHAKE_BIND, Enum.RenderPriority.Camera.Value + 1, function()
		local t = os.clock() - start
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if t >= duration then
			RunService:UnbindFromRenderStep(SHAKE_BIND)
			if humanoid then
				humanoid.CameraOffset = Vector3.zero
			end
			return
		end
		if humanoid then
			-- envelope: entra e sai suave
			local env = math.sin(math.clamp(t / duration, 0, 1) * math.pi)
			local amp = 0.06 * env
			humanoid.CameraOffset = Vector3.new(math.noise(t * 9, 0) * amp, math.noise(0, t * 11) * amp, 0)
		end
	end)
end

-- Pequena queda de brilho, como luz fluorescente oscilando.
local function flicker()
	if not correction then
		return
	end
	local dip = TweenService:Create(correction, TweenInfo.new(0.06), { Brightness = -0.25 })
	local back = TweenService:Create(correction, Theme.Motion.Base, { Brightness = 0 })
	dip.Completed:Connect(function()
		back:Play()
	end)
	dip:Play()
end

function EffectsController.init()
	correction = Instance.new("ColorCorrectionEffect")
	correction.Name = "ElevatorFX"
	correction.Parent = Lighting

	StateController.FloorEvent:Connect(function(payload)
		if payload.Type == "ElevatorTransition" then
			local duration = tonumber(payload.Duration) or 5
			shake(duration)
			task.delay(duration * 0.5, flicker)
		elseif payload.Type == "Armed" or payload.Type == "ColorCall" then
			flicker()
		end
	end)

	StateController.Notice:Connect(function(payload)
		if payload.Type == "Eliminated" then
			flicker()
		end
	end)
end

return EffectsController
