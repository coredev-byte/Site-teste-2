--!strict
-- Agrupa tudo que precisa ser limpo ao fim de um andar/tela:
-- conexões, instâncias, funções e threads.

export type Maid = {
	give: (self: Maid, item: any) -> any,
	clean: (self: Maid) -> (),
}

local Maid = {}
Maid.__index = Maid

function Maid.new(): Maid
	local self = setmetatable({ _items = {} :: { any } }, Maid)
	return (self :: any) :: Maid
end

function Maid:give(item: any): any
	table.insert(self._items, item)
	return item
end

local function cleanItem(item: any)
	local kind = typeof(item)
	if kind == "RBXScriptConnection" then
		item:Disconnect()
	elseif kind == "Instance" then
		item:Destroy()
	elseif kind == "function" then
		item()
	elseif kind == "thread" then
		if coroutine.status(item) ~= "dead" then
			pcall(task.cancel, item)
		end
	elseif kind == "table" then
		if typeof(item.Disconnect) == "function" then
			item:Disconnect()
		elseif typeof(item.Destroy) == "function" then
			item:Destroy()
		elseif typeof(item.clean) == "function" then
			item:clean()
		end
	end
end

function Maid:clean()
	local items = self._items
	self._items = {}
	-- ordem reversa: o que foi criado por último é limpo primeiro
	for i = #items, 1, -1 do
		local ok, err = pcall(cleanItem, items[i])
		if not ok then
			warn("[Maid] cleanup error:", err)
		end
	end
end

return Maid
