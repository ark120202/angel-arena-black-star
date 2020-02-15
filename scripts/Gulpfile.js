const path = require('upath');
const fs = require('fs-extra');
const gulp = require('gulp');
const sass = require('gulp-sass');
const vdf = require('vdf-extra');
const { parseLocalesFromDirectory } = require('./localization');

const gamePath = path.resolve(__dirname, '../game');
const contentPath = path.resolve(__dirname, '../content');

const localizationPath = path.resolve(__dirname, '../localization');
gulp.task('watch:localization', () =>
  gulp.watch(localizationPath, { ignoreInitial: false }, gulp.task('localization')),
);
gulp.task('localization', async () => {
  const tokensByLanguages = await parseLocalesFromDirectory(localizationPath);
  await Promise.all(
    Object.entries(tokensByLanguages).map(([language, tokens]) => {
      const filePath = path.join(gamePath, `resource/addon_${language}.txt`);
      const lang = { Language: language, Tokens: tokens };
      return fs.outputFile(filePath, '\uFEFF' + vdf.stringify({ lang }), 'ucs2');
    }),
  );
});

const sassPath = path.join(contentPath, 'panorama_src/styles/**/*.{sa,sc,c}ss');
gulp.task('watch:sass', () => gulp.watch(sassPath, { ignoreInitial: false }, gulp.task('sass')));
gulp.task('sass', () =>
  gulp
    .src(sassPath)
    .pipe(sass())
    .pipe(gulp.dest(path.join(contentPath, 'panorama/styles'))),
);

gulp.task('build', gulp.parallel('sass', 'localization'));
gulp.task('watch', gulp.parallel('watch:sass', 'watch:localization'));
