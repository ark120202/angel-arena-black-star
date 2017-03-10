soul_eater_demon_weapon_from = class({})
LinkLuaModifier("modifier_soul_eater_demon_weapon_from", "heroes/hero_soul_eater/modifier_soul_eater_demon_weapon_from.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function soul_eater_demon_weapon_from:OnSpellStart()
		local caster = self:GetCaster()
		local maka = caster:GetLinkedHeroEntities()[1]
		if maka then
			local scythe = maka:GetWearableInSlot("weapon")
			if scythe then
				local scythe_ent = scythe.entity
				if IsValidEntity(scythe_ent) then
					scythe_ent:SetVisible(true)
				end
			end
			caster:AddNewModifier(caster, self, "modifier_soul_eater_demon_weapon_from", {unit = maka})
		end
	end
end