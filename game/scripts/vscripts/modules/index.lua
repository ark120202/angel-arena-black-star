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
	"stats"
}

for _,v in ipairs(modules) do
	require("modules/" .. v .. "/index")
end