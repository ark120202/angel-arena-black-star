Events = Events or class({})
Events.Callbacks = Events.Callbacks or {}
Events.Registered = Events.Registered or {}

function Events:Emit(...)
	local args = {...}
	local event = table.remove(args, 1)
	local callbacks = Events.Callbacks[event]
	if callbacks then
		for i = #callbacks, 1, -1 do
			local v = callbacks[i]
			v.call(unpack(args))
			if v.once then table.remove(callbacks, i) end
		end
	end
	return call
end

function Events:On(event, callback, once)
	if once == nil then once = false end

	if not Events.Callbacks[event] then Events.Callbacks[event] = {} end
	table.insert(Events.Callbacks[event], {call = callback, once = once})
end

function Events:Register(event, listener, callback)
	local uniqueName = event .. "_" ..listener

	-- Remove registered callback if it was found
	if Events.Registered[uniqueName] then
		table.removeByValue(Events.Callbacks[event], Events.Registered[uniqueName])
	end
	Events.Registered[uniqueName] = callback
	self:On(event, callback)
end
