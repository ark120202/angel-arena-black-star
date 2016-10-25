function IncreaseScale(keys)
	local caster = keys.caster
	caster.TitaniumBarIncreasedScale = keys.PercentageOverModelScale * 0.01
	caster:SetModelScale(caster:GetModelScale() + keys.PercentageOverModelScale * 0.01)
end

function DecreaseScale(keys)
	local caster = keys.caster
	if caster.TitaniumBarIncreasedScale then
		caster:SetModelScale(caster:GetModelScale() - caster.TitaniumBarIncreasedScale)
	end
end