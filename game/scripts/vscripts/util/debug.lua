function PrintTable(t, indent, done)
	PrintTableCall(t, print, indent, done)
end

function PrintTableCall(t, printFunc, indent, done)
	--printFunc ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then
		printFunc("PrintTable called on not table value")
		printFunc(tostring(t))
		return
	end

	done = done or {}
	done[t] = true
	if not indent then
		printFunc("Printing table")
	end
	indent = indent or 1

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
			local value = t[v]
			if type(value) == "table" and not done[value] then
				done[value] = true
				printFunc(string.rep ("\t", indent)..tostring(v)..":")
				PrintTableCall(value, printFunc, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done[value] = true
				printFunc(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				PrintTableCall((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), printFunc, indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					printFunc(string.rep ("\t", indent)..tostring(t.FDesc[v]))
				else
					printFunc(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				end
			end
		end
	end
end
