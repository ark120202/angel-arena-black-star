function string.starts(s, start)
	return string.sub(s, 1, string.len(start)) == start
end

function string.ends(s, e)
	return e == "" or string.sub(s, -string.len(e)) == e
end

function string.split(inputstr, sep)
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. (sep or "%s") .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function string.splitQuoted(inputstr)
	local t = {}
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	for str in inputstr:gmatch("%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then
			local newString = str:gsub(spat,""):gsub(epat,"")
			table.insert(t, newString)
		end
	end
	if buf then error("Missing matching quote for "..buf) end
	return t
end
