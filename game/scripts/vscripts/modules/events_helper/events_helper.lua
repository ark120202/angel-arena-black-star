Events = Events or class({})
Events.Callbacks = Events.Callbacks or {}
Events.Registered = Events.Registered or {}

function Events:Emit(...)
	local args = {...}
	local event = table.remove(args, 1)
	local callbacks = Events.Callbacks[event]
	print("EMITTED EVENT " .. event .. " with first arg: ", args[0])
	if not callbacks then return end

	for i, v in pairs(callbacks) do
		print(" ... and called callback")
		v.call(unpack(args))
		if v.once then callbacks[i] = nil end
	end
end

function Events:On(event, callback)
	if not Events.Callbacks[event] then Events.Callbacks[event] = {} end
	table.insert(Events.Callbacks[event], { call = callback, once = false })
	return #Events.Callbacks[event]
end

function Events:Once(event, callback)
	if not Events.Callbacks[event] then Events.Callbacks[event] = {} end
	table.insert(Events.Callbacks[event], { call = callback, once = true })
	return #Events.Callbacks[event]
end

function Events:Register(event, listener, callback)
	local uniqueName = event .. "_" ..listener

	-- Remove registered callback if it was found
	local registeredIndex = Events.Registered[uniqueName]
	if registeredIndex then Events.Callbacks[event][registeredIndex] = nil end

	Events.Registered[uniqueName] = self:On(event, callback)
end
