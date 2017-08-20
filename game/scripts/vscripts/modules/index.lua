local modules = {
	"bosses",
	"custom_abilities",
	"custom_runes",
	"custom_talents",
	"duel",
	"dynamic_minimap",
	"dynamic_wearables",
	"gold",
	"hero_selection",
	"herovoice",
	"kills",
	"options",
	"panorama_shop",
	"SimpleAI",
	"spawner",
	"stats",
	"structures",
	"attributes",
	"antiafk",
	"events_helper",
	"teams",
	"meepo_fixes", -- until rewrite
	"weather",
}

local errors = {}
for k, v in ipairs(modules) do
	if type(k) == "string" then
		k, v = v, k
	else
		k = nil
	end
	local status, nextCall = xpcall(function() require("modules/" .. v .. "/" .. (k or v)) end, function(msg)
		local trace = debug.traceback()
		local limiter = trace:find("in function 'xpcall'") - 8
		return msg .. '\n' .. trace:sub(0, limiter) .. '\n'
	end)
	if not status then
		table.insert(errors, nextCall)
	end
end
if #errors > 0 then
	print("\n#### Module loading error ####")
	for _,v in ipairs(errors) do
		print(v)
	end
	print("##############################")
	error("Found " .. #errors .. " errors while loading modules")
end

require("modules/verify/verify")
