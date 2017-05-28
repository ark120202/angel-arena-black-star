Events = Events or class({})
Events.Callbacks = Events.Callbacks or {}

function Events:Emit(...)
	local args = {...}
	local name = table.remove(args, 1)
	local callbacks = Events.Callbacks[name]
	if callbacks then
		for i = #callbacks, 1, -1 do
			local v = callbacks[i]
			v.call(unpack(args))
			if v.once then table.remove(callbacks, i) end
		end
	end
	return call
end

function Events:On(name, callback, once)
	if once == nil then once = false end

	if not Events.Callbacks[name] then Events.Callbacks[name] = {} end
	table.insert(Events.Callbacks[name], {call = callback, once = once})
end
