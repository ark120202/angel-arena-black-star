const fs = require('fs-extra'),
	_ = require('lodash'),
	yaml = require('js-yaml'),
	path = require('path'),
	Promise = require('bluebird');


/**
 * Performs recursive readdir
 *
 * @param {string} dirPath Start directory
 * @returns {Promise<Array<string>>} Array of all found files
 */
function readdirp(dirPath) {
	let paths = [];
	return fs.readdir(dirPath)
		.then(subPaths => {
			return Promise.map(subPaths, subPath => {
				subPath = path.join(dirPath, subPath);
				return fs.stat(subPath)
					.then(subPathStat => {
						if (subPathStat.isDirectory()) {
							return readdirp(subPath)
								.then(subSubPaths => {
									paths = _.concat(paths, subSubPaths);
								});
						} else {
							return paths.push(subPath);
						}
					});
			});
		})
		.then(() => {
			return paths;
		});
}

module.exports = {

	/**
	 * Finds and parses all localization files from specified directory.
	 *
	 * @param {string} localizationDir Directory
	 * @returns {Array<Object>} Array of all found localization files, with extra 'Language' key
	 */
	ParseLocalesFromDirectory(localizationDir) {
		return readdirp(localizationDir)
			.then(paths => {
				return Promise.map(paths, _localeElement => {
					let localeElement = path.relative(localizationDir, _localeElement);
					let locale = localeElement.split('\\')[0];
					if (localeElement.endsWith('.yml')) {
						return fs.readFile(_localeElement, 'utf-8')
							.then(fileText => {
								let parsedFileContent;
								try {
									parsedFileContent = yaml.safeLoad(fileText);
								} catch (err) {
									if (err.name === 'YAMLException') {
										let mark = err.mark;
										console.error({
											file: _localeElement.replace(/\\/g, '/'),
											column: mark.column,
											line: mark.line,
											reason: err.reason,
											message: err.message,
										});
									} else {
										throw err;
									}
								}
								return _.assign(parsedFileContent, {Language: locale});
							});
					} else {
						console.warn('Only yaml localization files are allowed, file ', _localeElement, ' is unhandled');
					}
				});
			})
			.then(localizations => {
				return this.ParseLocalesFromObject(localizations);
			});
	},

	/**
	 * Parses all yaml localization files, applies specific rules and groups them by language.
	 *
	 * @param {Array<Object>} kvs Array of parsed Yaml files with 'Language' property
	 * @returns {Object} All parsed localization tokens, grouped by language
	 */
	ParseLocalesFromObject(kvs) {
		let groupedKVs = _.groupBy(kvs, 'Language');
		let tokensByLanguages = {};
		_.each(groupedKVs, (tokenArrays, language) => {
			let variables = {};
			let tokens = {};

			//First - parsing Variables
			_.each(tokenArrays, kv => {
				if (kv.Variables) _.assign(variables, kv.Variables);
				delete kv.Language;
				delete kv.Variables;
			});

			//Second - parsing tokens
			_.each(tokenArrays, kv => {
				_.each(kv, (value, keys) => {
					if (_.isArray(value)) {
						let t = keys;
						keys = value;
						value = t;
					}
					_.each(_.isArray(keys) ? keys : [keys], key => {
						if (tokens[key]) {
							throw new Error('Key ' + key + ' presents in multiple files');
						} else {
							tokens[key] = value.replace(/\{lc:.+}/g, matched => {
								let variable = matched.slice(4, -1);
								if (variables[variable]) {
									return variables[variable];
								} else {
									console.warn('Unhandled lc variable: ', variable, ' (', language, 'localization )');
									return '';
								}
							});
						}
					});
				});
			});

			//Third - applying custom rules
			_.each(tokens, (value, key) => {
				if (key.endsWith('_Description')) {
					tokens[key] = value.replace(/\n(?!<h1)/g, ' <br>');
					//Has scepter description?
					if (tokens[key.slice(0, -'Description'.length) + 'aghanim_description']) {
						tokens[key] += '\n' + variables.ability_scepter_upgradable;
					}
				}
			});

			tokensByLanguages[language] = tokens;
		});
		return tokensByLanguages;
	}
};
