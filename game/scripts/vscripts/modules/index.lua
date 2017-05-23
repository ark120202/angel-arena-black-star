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
}

for k, v in ipairs(modules) do
	if type(k) == "string" then
		k, v = v, k
	else
		k = nil
	end
	require("modules/" .. v .. "/" .. (k or v))
end
