const child_process = require('child_process');
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

process.chdir(path.join(settings.dota, 'game/bin/win64'));
child_process.spawn(path.join(settings.dota, 'game/bin/win64/dota2cfg.exe'), ['-addon', settings.name], {detached: true});
