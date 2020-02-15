const fs = require('fs-extra');
const _ = require('lodash');
const yaml = require('js-yaml');
const path = require('upath');
const globby = require('globby');

/**
 * @param {string} rootDir
 */
module.exports.parseLocalesFromDirectory = async rootDir => {
  const sourcePaths = await globby(rootDir);
  const localizationSources = {};
  await Promise.all(
    sourcePaths.map(async absoluteSourcePath => {
      const relativeSourcePath = path.relative(rootDir, absoluteSourcePath);
      const language = relativeSourcePath.split('/')[0];
      if (!absoluteSourcePath.endsWith('.yml')) {
        console.warn(`Unknown localization file type: ${relativeSourcePath}`);
        return;
      }

      const text = await fs.readFile(absoluteSourcePath, 'utf8');
      const result = yaml.safeLoad(text, { filename: relativeSourcePath });
      (localizationSources[language] || (localizationSources[language] = [])).push(result);
    }),
  );

  return module.exports.parseLocalesFromObject(localizationSources);
};

/**
 * @param {Record<string, object[]>} localizationSources
 * @returns {Record<string, Record<string, string>>}
 */
module.exports.parseLocalesFromObject = localizationSources =>
  _.mapValues(localizationSources, files => {
    const variables = {};
    const tokens = {};

    // First - parsing Variables
    for (const file of files) {
      if (file.Variables) Object.assign(variables, file.Variables);
      delete file.Language;
      delete file.Variables;
    }

    // Second - parsing tokens
    for (const file of files) {
      for (let [keys, value] of Object.entries(file)) {
        if (Array.isArray(value)) {
          [keys, value] = [value, keys];
        }

        for (const key of _.castArray(keys)) {
          if (tokens[key]) {
            throw new Error('Key ' + key + ' presents in multiple files');
          }

          tokens[key] = value.replace(/\{lc:.+}/g, matched => {
            const variable = matched.slice(4, -1);
            if (variables[variable]) {
              return variables[variable];
            } else {
              console.warn(`Unhandled lc variable: ${variable} (${language} localization)`);
              return '';
            }
          });
        }
      }
    }

    // Third - applying custom rules
    _.each(tokens, (value, key) => {
      if (key.endsWith('_Description')) {
        tokens[key] = value.replace(/\n(?!<h1)/g, ' <br>');
        // Has scepter description?
        if (tokens[key.slice(0, -'Description'.length) + 'aghanim_description']) {
          tokens[key] += '\n' + variables.ability_scepter_upgradable;
        }
      }
    });

    return tokens;
  });
