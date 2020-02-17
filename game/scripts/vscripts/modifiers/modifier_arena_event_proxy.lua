modifier_arena_event_proxy = modifier_arena_event_proxy or {}
if IsClient() then return end

function modifier_arena_event_proxy:DeclareFunctions()
	return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_arena_event_proxy:OnDeath(event)
	Events:Emit("OnDeath", event)
end
