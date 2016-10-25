function WakeDamageCount(keys)
	local target = keys.unit
	local damage = keys.Damage
	target.cherub_sleep_cloud_damage = (target.cherub_sleep_cloud_damage or 0) + damage
	if target.cherub_sleep_cloud_damage > keys.damage_to_wake then
		target:RemoveModifierByNameAndCaster("modifier_cherub_sleep_cloud_sleep", keys.caster)
	end
end

function ClearThinkerTime(keys)
	keys.target.cherub_sleep_cloud_counter = nil
	keys.target.cherub_sleep_cloud_damage = nil
end

function ThinkerCountTime(keys)
	local target = keys.target
	if not target:HasModifier("modifier_cherub_sleep_cloud_sleep") then
		target.cherub_sleep_cloud_counter = (target.cherub_sleep_cloud_counter or 0) + keys.think_interval
		if target.cherub_sleep_cloud_counter >= keys.time_to_sleep then
			keys.ability:ApplyDataDrivenModifier(keys.caster, target, "modifier_cherub_sleep_cloud_sleep", {})
		end
	end
end