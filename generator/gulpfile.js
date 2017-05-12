const gulp = require("gulp"),
	resourcecompiler = require("./gulp-resourcecompiler");
//const childProcess = require("child_process");
const dcgt = require("dota-custom-game-toolkit");
const path = require("path"),
	vdf = require("vdf-extra"),
	fs = require("fs-extra"),
	Promise = require("bluebird");
const paths = {
	root: path.resolve(__dirname, ".."),
	game: path.resolve(__dirname, "../game"),
	content: path.resolve(__dirname, "../content"),
	localization: path.resolve(__dirname, "../localization"),
	resourcecompiler: "G:/Program Files/Steam/steamapps/common/dota 2 beta/game/bin/win64/resourcecompiler.exe",
	addon_game: "G:/Program Files/Steam/steamapps/common/dota 2 beta/game/dota_addons/angelarenablackstar_develop",
	addon_content: "G:/Program Files/Steam/steamapps/common/dota 2 beta/content/dota_addons/angelarenablackstar_develop",
};

gulp.task("localization", next => {
	dcgt.ParseLocalesFromDirectory(paths.localization)
		.then(tokensByLanguages => {
			return Promise.map(Object.keys(tokensByLanguages), language => {
				let lang = {Language: language, Tokens: tokensByLanguages[language]};
				let minified = "\ufeff" + vdf.stringify({lang}, 0);
				return Promise.map([path.join(paths.game, "resource/addon_" + language + ".txt"), path.join(paths.game, "panorama/localization/addon_" + language + ".txt")], path => {
					return fs.ensureFile(path).then(() => fs.writeFile(path, minified, "ucs2"));
				});
			});
		})
		.then(() => {
			next();
		})
		.catch(console.error);
});

gulp.task("maps", () =>
	gulp.src(path.join(paths.content, "maps/*.vmap"))
		.pipe(resourcecompiler(paths.resourcecompiler, p => p.replace(paths.content, paths.addon_content), ["-world -entities -phys -vis -gridnav -breakpad"]))
		.pipe(gulp.dest(path.join(paths.game, "maps")))
);
