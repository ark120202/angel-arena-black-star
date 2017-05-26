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


const game = path.join(settings.dota, 'game/dota_addons');
const content = path.join(settings.dota, 'content/dota_addons');
try {
	fs.renameSync(path.join(game, 'angelarenablackstar'), path.join(game, '___angelarenablackstar'));
	fs.renameSync(path.join(content, 'angelarenablackstar'), path.join(content, '___angelarenablackstar'));
} catch (err) {
	console.error('Make sure you have access to dota directory and you have executed install.js before');
	process.exit(1);
}

process.chdir(path.join(settings.dota, 'game/bin/win64'));
child_process.spawn(path.join(settings.dota, 'game/bin/win64/dota2cfg.exe'), ['-addon', 'angelarenablackstar'], {detached: true});

fs.ensureDirSync(path.join(game, 'angelarenablackstar'));
fs.ensureDirSync(path.join(content, 'angelarenablackstar'));

setTimeout(() => {
	fs.removeSync(path.join(game, 'angelarenablackstar'));
	fs.removeSync(path.join(content, 'angelarenablackstar'));
	fs.renameSync(path.join(game, '___angelarenablackstar'), path.join(game, 'angelarenablackstar'));
	fs.renameSync(path.join(content, '___angelarenablackstar'), path.join(content, 'angelarenablackstar'));
}, settings.delay || 1600);
