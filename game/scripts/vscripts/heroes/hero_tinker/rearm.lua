function Refresh( keys )
	local caster = keys.caster
	local ability = keys.ability
	RefreshAbilities(caster, REFRESH_LIST_IGNORE_REARM)
	RefreshItems(caster, REFRESH_LIST_IGNORE_REARM)
	local act = _G["ACT_DOTA_TINKER_REARM" .. ability:GetLevel()]
	if not act then
		act = ACT_DOTA_TINKER_REARM3
	end
	caster:Stop()
    StartAnimation(caster, {duration=GetAbilityCooldown(caster, ability), activity=act})
end