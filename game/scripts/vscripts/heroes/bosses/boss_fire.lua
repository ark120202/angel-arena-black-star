function Initialize(keys)
	local caster = keys.caster
	Attachments:AttachProp(caster, "attach_hitloc", "models/heroes/shadow_fiend/arcana_wings.vmdl", 1, {
		pitch = 180,
		yaw = 0,
		roll = 90,
		XPos = 50,
		YPos = 0,
		ZPos = -145
	})
	Attachments:AttachProp(caster, "attach_weapon_r", "models/items/chaos_knight/hellfire_edge/hellfire_edge.vmdl", 1, {
		pitch = 0,
		yaw = 0,
		roll = 0,
		XPos = 0,
		YPos = 0,
		ZPos = 0
	})
	Attachments:AttachProp(caster, "attach_head", "models/items/chaos_knight/hellfire_edge/hellfire_edge.vmdl", 0.7, {
		pitch = -90,
		yaw = 0,
		roll = -90,
		XPos = -8,
		YPos = 0,
		ZPos = -215
	})
	caster:AddItem(CreateItem("item_radiance", caster, caster))
	caster:AddItem(CreateItem("item_monkey_king_bar", caster, caster))
end