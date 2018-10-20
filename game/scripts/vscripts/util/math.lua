function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

function math.clamp(x, min, max)
	return math.max(min, math.min(max, x))
end
