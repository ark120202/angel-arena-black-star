function CreateGem(keys)
	local attach = keys.ability
	local key = keys.CasterVar or "custom_gem"
	if keys.CasterVar then attach = keys.caster end
	attach[key] = keys.caster:AddNewModifier(keys.caster, ability, "modifier_custom_gem", {radius = keys.Aura_Radius, teams = keys.Aura_Teams, types = keys.Aura_Types, flags = keys.Aura_Flags})
end

function DestroyGem(keys)
	local attach = keys.ability
	local key = keys.CasterVar or "custom_gem"
	for k, v in pairs(keys) do print(k,v) end
	if keys.CasterVar then
		attach = keys.caster
	end
	attach[key]:Destroy()
end
