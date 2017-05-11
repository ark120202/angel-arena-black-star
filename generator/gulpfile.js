const gulp = require("gulp");
//const childProcess = require("child_process");
const dcgt = require("dota-custom-game-toolkit");
const path = require("path"),
	vdf = require("vdf-extra"),
	fs = require("fs-extra"),
	Promise = require("bluebird");
//childProcess.spawn;

gulp.task("localization", next => {
	dcgt.ParseLocalesFromDirectory(localeDir)
		.then(tokensByLanguages => {
			return Promise.map(Object.keys(tokensByLanguages), language => {
				let lang = {Language: language, Tokens: tokensByLanguages[language]};
				let minified = "\ufeff" + vdf.stringify({lang}, 0);
				return Promise.map([path.join(gameDir, "resource/addon_" + language + ".txt"), path.join(gameDir, "panorama/localization/addon_" + language + ".txt")], path => {
					return fs.ensureFile(path).then(() => fs.writeFile(path, minified, "ucs2"));
				});
			});
		})
		.then(() => {
			next();
		})
		.catch(console.error);
});
