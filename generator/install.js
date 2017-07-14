const fs = require('fs-extra'),
	path = require('path'),
	yaml = require('js-yaml');
if (!fs) {
	console.error("Error while loading modules. Make sure you have executed 'npm install' before.");
	return;
}
let settings;
try {
	fs.statSync('./settings.yml');
	settings = yaml.safeLoad(fs.readFileSync('./settings.yml', 'utf8'));
} catch (err) {
	if (err.code === 'ENOENT')			console.error('settings.yml not found.'); else
	if (err.name === 'YAMMLException')	console.error('Bad settings.yml syntax,', err.message); else {
		console.error('Unknown error while parsing settings.yml:');
		console.error(err);
	}
	process.exit(1);
}


const game = path.join(settings.dota, 'game/dota_addons', settings.name);
const content = path.join(settings.dota, 'content/dota_addons', settings.name);
fs.removeSync(game);
fs.removeSync(content);
fs.symlinkSync(path.resolve(__dirname, '../game'), game, 'junction');
fs.symlinkSync(path.resolve(__dirname, '../content'), content, 'junction');
