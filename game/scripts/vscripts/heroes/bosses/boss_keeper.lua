function SetUpPose(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_invulnerable")
	Attachments:AttachProp(caster, "attach_hitloc", "models/items/rubick/golden_ornithomancer_mantle/golden_ornithomancer_mantle.vmdl", 0.7, {
		pitch = -180,
		yaw = 20,
		roll = 0,
		XPos = 145,
		YPos = -15,
		ZPos = 0
	})
end