function GodTransform(keys)
	local caster = keys.caster
	if caster:IsRealHero() and not caster:HasModifier("modifier_arc_warden_tempest_double") and not Duel:IsDuelOngoing() then
		if HeroSelection:IsHeroSelected(keys.heroname) then
			Notifications:Bottom(caster:GetPlayerOwner(), {text="#hero_selection_change_hero_selected",})
		else
			HeroSelection:ChangeHero(caster:GetPlayerID(), keys.heroname, true, 0, keys.ability)
		end
	end
end

function Check(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:IsRealHero() and not caster:HasModifier("modifier_arc_warden_tempest_double") and HeroSelection:IsHeroSelected(keys.heroname) then
		Notifications:Bottom(caster:GetPlayerOwner(), {text="#hero_selection_change_hero_selected",})
		ability:EndCooldown()
		ability:RefundManaCost()
		caster:Interrupt()
	end
end