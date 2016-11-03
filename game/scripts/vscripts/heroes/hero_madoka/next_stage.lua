function Transform(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability.removedAbilities = {}
	ability:SetActivated(false)
	for i = 0, caster:GetAbilityCount() - 1 do
		local a = caster:GetAbilityByIndex(i)
		if a and a ~= ability then
			ability.removedAbilities[i] = {name = a:GetAbilityName(), level = a:GetLevel()}
			for _,v in ipairs(caster:FindAllModifiers()) do
				if v:GetAbility() == a then
					v:Destroy()
				end
			end
			UTIL_Remove(a)
		end
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "dota_ability_changed", {})
end

function Untransform(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
end

function CheckPlayers(keys)
	local caster = keys.caster
	if #GetPlayersInTeam(caster:GetTeamNumber()) <= 1 then
		caster:RemoveModifierByName("modifier_madoka_spec")
	end
end