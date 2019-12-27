const localizationBuilder = require('./localization-builder');
const path = require('path'),
	vdf = require('vdf-extra'),
	fs = require('fs-extra'),
	yaml = require('js-yaml');

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
	through2 = require('through2');

gulp.task('localization', async () => {
	const tokensByLanguages = await localizationBuilder.ParseLocalesFromDirectory(paths.localization);
	await Promise.all(
		Object.entries(tokensByLanguages).map(([language, tokens]) => {
			const lang = { Language: language, Tokens: tokens };
			const minified = '\ufeff' + vdf.stringify({lang}, 0);
			return fs.outputFile(path.join(paths.game, 'resource/addon_' + language + '.txt'), minified, 'ucs2');
		}),
	);
});

gulp.task('localization_watch', gulp.parallel(
	'localization',
	() => {
		gulp.watch(paths.localization + '/**/*.yml', gulp.task('localization'));
	},
));

const shouldWatch = !process.argv.includes('build');
const noop = () => through2.obj();
gulp.task('src_sass', () =>
	gulp.src(path.join(paths.content, 'panorama_src/styles/**/*.sass'))
		.pipe(shouldWatch ? watch(path.join(paths.content, 'panorama_src/styles/**/*.sass')) : noop())
		.pipe(plumber())
		.pipe(sass())
		.pipe(replace(/ {2}/g, ''))
		.pipe(gulp.dest(path.join(paths.content, 'panorama/styles')))
);

gulp.task('src_css', () =>
	gulp.src(path.join(paths.content, 'panorama_src/styles/**/*.css'))
		.pipe(shouldWatch ? watch(path.join(paths.content, 'panorama_src/styles/**/*.css')) : noop())
		.pipe(plumber())
		.pipe(replace(/ {2}/g, ''))
		.pipe(gulp.dest(path.join(paths.content, 'panorama/styles')))
);
gulp.task('panorama', gulp.parallel('src_sass', 'src_css'));

// Startup
gulp.task('default', gulp.parallel('panorama', shouldWatch ? 'localization_watch' : 'localization'));
