function IncreaseScale(keys)
	local caster = keys.caster
	caster.BkbIncreasedScale = keys.PercentageOverModelScale * 0.01
	caster:SetModelScale(caster:GetModelScale() + keys.PercentageOverModelScale * 0.01)
end

function DecreaseScale(keys)
	local caster = keys.caster
	if caster.BkbIncreasedScale then
		caster:SetModelScale(caster:GetModelScale() - caster.BkbIncreasedScale)
	end
end