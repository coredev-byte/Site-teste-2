--!strict
-- Signal mínimo (sem BindableEvent). Handlers rodam em task.spawn.

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Signal = {
	Connect: (self: Signal, handler: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	DisconnectAll: (self: Signal) -> (),
}

local Signal = {}
Signal.__index = Signal

function Signal.new(): Signal
	local self = setmetatable({ _handlers = {} :: { [any]: (...any) -> () } }, Signal)
	return (self :: any) :: Signal
end

function Signal:Connect(handler: (...any) -> ()): Connection
	local key = {}
	self._handlers[key] = handler
	local connection = {
		Connected = true,
	}
	local handlers = self._handlers
	function connection.Disconnect(conn: any)
		conn.Connected = false
		handlers[key] = nil
	end
	return (connection :: any) :: Connection
end

function Signal:Fire(...: any)
	for _, handler in self._handlers do
		task.spawn(handler, ...)
	end
end

function Signal:DisconnectAll()
	table.clear(self._handlers)
end

return Signal
