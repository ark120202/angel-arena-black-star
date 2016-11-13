function Initialize(keys)
	local caster = keys.caster
	Attachments:AttachProp(caster, "attach_hitloc", "models/heroes/omniknight/omniknightwings.vmdl", 1, {})
	Attachments:AttachProp(caster, "attach_attack1", "models/items/keeper_of_the_light/weapon_astaffancients_new/weapon_astaffancients_new.vmdl", 1, {
		pitch = 4,
		XPos = -10,
		YPos = 57,
		ZPos = -200
	})
end