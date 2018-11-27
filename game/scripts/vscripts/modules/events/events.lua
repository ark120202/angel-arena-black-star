Events = Events or class({})
Events.Callbacks = Events.Callbacks or {}

for _, v in ipairs(Events.Registered or {}) do
	Events:Off(v.event, v.id)
end
Events.Registered = {}

function Events:Emit(...)
	local args = {...}
	local event = table.remove(args, 1)
	local callbacks = Events.Callbacks[event]
	if not callbacks then return end

	for i, v in pairs(callbacks) do
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

function Events:Off(event, id)
	Events.Callbacks[event][id] = nil
end

function Events:Register(event, callback)
	local id = self:On(event, callback)
	table.insert(Events.Registered, { event = event, id = id })
end
