const localizationBuilder = require('./localization-builder');
const path = require('path'),
	vdf = require('vdf-extra'),
	fs = require('fs-extra'),
	Promise = require('bluebird'),
	yaml = require('js-yaml'),
	argv = require('yargs').argv;

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

const paths = {
	root: path.resolve(__dirname, '..'),
	game: path.resolve(__dirname, '../game'),
	content: path.resolve(__dirname, '../content'),
	localization: path.resolve(__dirname, '../localization'),
	resourcecompiler: path.join(settings.dota, 'bin/win64/resourcecompiler.exe'),
	addon_game: path.join(settings.dota, 'game/dota_addons', settings.name),
	addon_content: path.join(settings.dota, 'content/dota_addons', settings.name),
};

const gulp = require('gulp'),
	sass = require('gulp-sass'),
	watch = require('gulp-watch'),
	plumber = require('gulp-plumber'),
	replace = require('gulp-replace'),
	gutil = require('gulp-util');

// L10n
gulp.task('localization', () =>
	localizationBuilder.ParseLocalesFromDirectory(paths.localization)
		.then(tokensByLanguages => {
			return Promise.map(Object.keys(tokensByLanguages), language => {
				let lang = {Language: language, Tokens: tokensByLanguages[language]};
				let minified = '\ufeff' + vdf.stringify({lang}, 0);
				return Promise.map([path.join(paths.game, 'resource/addon_' + language + '.txt'), path.join(paths.game, 'panorama/localization/addon_' + language + '.txt')], path => {
					return fs.outputFile(path, minified, 'ucs2');
				});
			});
		})
		.catch(console.error)
);
gulp.task('localization_watch', ['localization'], () => {
	gulp.watch(paths.localization + '/**/*.yml', ['localization']);
});

const shouldWatch = argv.build == null;
gulp.task('src_sass', () =>
	gulp.src(path.join(paths.content, 'panorama_src/styles/**/*.sass'))
		.pipe(shouldWatch ? watch(path.join(paths.content, 'panorama_src/styles/**/*.sass')) : gutil.noop())
		.pipe(plumber())
		.pipe(sass())
		.pipe(replace(/ {2}/g, ''))
		.pipe(gulp.dest(path.join(paths.content, 'panorama/styles')))
);

gulp.task('src_css', () =>
	gulp.src(path.join(paths.content, 'panorama_src/styles/**/*.css'))
		.pipe(shouldWatch ? watch(path.join(paths.content, 'panorama_src/styles/**/*.css')) : gutil.noop())
		.pipe(plumber())
		.pipe(replace(/ {2}/g, ''))
		.pipe(gulp.dest(path.join(paths.content, 'panorama/styles')))
);
gulp.task('panorama', ['src_sass', 'src_css']);

// Startup
gulp.task('default', [
	'panorama',
	shouldWatch ? 'localization_watch' : 'localization'
]);
