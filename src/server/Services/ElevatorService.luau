--!strict
-- Portas, transições, display e embarque. Visual pesado (luz piscando, tremor, som)
-- é feito no cliente ao receber FloorEvent { Type = "ElevatorTransition" }.
--
-- Usa Workspace.Elevator se existir, com as peças opcionais:
--   Inside (BasePart)  área de embarque  [obrigatória]
--   DoorLeft / DoorRight (BasePart)       portas que deslizam
--   DisplayPanel.Display.Text (TextLabel)  número do andar
-- Senão, cria um placeholder (World/Builders).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Net = require(script.Parent.Net)
local Builders = require(script.Parent.Parent.World.Builders)
local Characters = require(script.Parent.Parent.World.Characters)

local DOOR_TIME = 1.2

local ElevatorService = {}

local model: Model? = nil
local inside: BasePart? = nil
local doors: { { part: BasePart, closed: CFrame, open: CFrame } } = {}
local displayLabel: TextLabel? = nil
local rng = Random.new()

function ElevatorService.init()
	local existing = Workspace:FindFirstChild("Elevator")
	if existing and existing:IsA("Model") and existing:FindFirstChild("Inside") then
		model = existing
	else
		if existing then
			warn("[Elevator] Workspace.Elevator existe mas não tem 'Inside' — usando placeholder.")
		end
		local placeholder = Builders.elevator(Config.World.ElevatorOrigin)
		placeholder.Name = if existing then "Elevator_Placeholder" else "Elevator"
		placeholder.Parent = Workspace
		model = placeholder
	end

	local m = model :: Model
	local insidePart = m:FindFirstChild("Inside")
	if insidePart and insidePart:IsA("BasePart") then
		inside = insidePart
	end

	for _, name in { "DoorLeft", "DoorRight" } do
		local door = m:FindFirstChild(name)
		if door and door:IsA("BasePart") then
			local dir = if name == "DoorLeft" then -1 else 1
			local closed = door.CFrame
			local open = closed * CFrame.new(dir * door.Size.X * 0.95, 0, 0)
			table.insert(doors, { part = door, closed = closed, open = open })
		end
	end

	local label = m:FindFirstChild("Text", true)
	if label and label:IsA("TextLabel") then
		displayLabel = label
	end
end

function ElevatorService.setDisplay(text: string)
	if displayLabel then
		displayLabel.Text = text
	end
end

-- Abre/fecha as portas. Yield até terminar.
function ElevatorService.setDoors(open: boolean)
	if #doors == 0 then
		return
	end
	local info = TweenInfo.new(DOOR_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	for _, door in doors do
		door.part.CanCollide = not open
		TweenService:Create(door.part, info, { CFrame = if open then door.open else door.closed }):Play()
	end
	task.wait(DOOR_TIME)
end

-- Coloca os jogadores dentro da cabine (posições aleatórias na área Inside).
function ElevatorService.board(players: { Player })
	if not inside then
		return
	end
	for _, player in players do
		Characters.setMovement(player, true)
		Characters.teleport(player, Builders.randomPointIn(inside :: BasePart, rng))
	end
end

-- Transição entre andares. Yield pela duração.
function ElevatorService.runTransition(duration: number, nextFloor: number)
	ElevatorService.setDoors(false)
	Net.fireAll("FloorEvent", { Type = "ElevatorTransition", Duration = duration, Floor = nextFloor })
	-- Display "rolando" números até o destino: reforça o "DESTINATION UNKNOWN".
	local elapsed = 0
	local tick = 0.35
	while elapsed < duration - DOOR_TIME do
		ElevatorService.setDisplay(if elapsed < duration * 0.7 then tostring(rng:NextInteger(10, 99)) else string.format("%02d", nextFloor))
		task.wait(tick)
		elapsed += tick
	end
	ElevatorService.setDisplay(string.format("%02d", nextFloor))
	ElevatorService.setDoors(true)
end

return ElevatorService
