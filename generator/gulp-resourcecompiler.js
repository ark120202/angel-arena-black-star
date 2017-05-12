/* eslint no-plusplus: "off" */
//gulp-resourcecompiler
//Supports: js, css, xml, vmap, vsndevts, audio, vpcf, vmdl, vtex, vmat. Not works with panorama's vtex
const Promise = require("bluebird");
const gutil = require("gulp-util");
const through = require("through2");
const exec = require("child_process").exec;
const fs = require("fs-extra");
const path = require("path");
const tempDir = __dirname + "/temp";

const vtex_template = `<!-- dmx encoding keyvalues2_noids 1 format vtex 1 -->
"CDmeVtex"
{
"m_inputTextureArray" "element_array"
[
	"CDmeInputTexture"
	{
		"m_name" "string" "0"
		"m_fileName" "string" "{path}"
		"m_colorSpace" "string" "srgb"
		"m_typeString" "string" "2D"
	}
]
"m_outputTypeString" "string" "2D"
"m_outputFormat" "string" "DXT5"
"m_textureOutputChannelArray" "element_array"
[
	"CDmeTextureOutputChannel"
	{
		"m_inputTextureArray" "string_array"
			[
				"0"
			]
		"m_srcChannels" "string" "rgba"
		"m_dstChannels" "string" "rgba"
		"m_mipAlgorithm" "CDmeImageProcessor"
		{
			"m_algorithm" "string" ""
			"m_stringArg" "string" ""
			"m_vFloat4Arg" "vector4" "0 0 0 0"
		}
		"m_outputColorSpace" "string" "srgb"
	}
]
}`;

function readdirp(dirPath) {
	var paths = [];
	return fs.readdir(dirPath)
		.then(subPaths => {
			return Promise.map(subPaths, subPath => {
				subPath = path.join(dirPath, subPath);
				return fs.stat(subPath)
					.then(subPathStat => {
						if (subPathStat.isDirectory()) {
							return readdirp(subPath)
								.then(subSubPaths => {
									paths = paths.concat(subSubPaths);
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

function compile(executable, pathReplacer, customArgs) {
	return through.obj(function(file, encoding, callback) {
		if (file.isNull()) {
			callback(null, file);
			return;
		}

		if (file.isStream()) {
			callback(new gutil.PluginError("gulp-resourcecompiler", "Streaming not supported"));
			return;
		}

		try {
			let filePath = pathReplacer != null ? pathReplacer(file.path) : file.path;
			/*if (path.extname(file.path) === ".png") {
				vtex_template.replace("{path}", )
				let vtexPath = tempDir + "/vtex.vtex";
				fs.outputFileSync(vtexPath, "", "utf8");
				filePath = pathReplacer != null ? pathReplacer(vtexPath) : vtexPath;
			}*/
			let args = [];
			args.push('"' + executable + '"');
			args.push("-f");
			args.push("-fshallow");
			args.push("-quiet");
			args.push("-nop4");
			args.push("-outroot");
			args.push('"' + tempDir + '"');
			args.push("-i");
			args.push('"' + filePath + '"');
			if (customArgs) args.concat(customArgs);

			exec(args.join(" "), (err, stdout/*, stderr*/) => {
				if (err) {
					this.emit("error", new gutil.PluginError("gulp-resourcecompiler", new Error(stdout), {fileName: file.path}));
					return;
				}
				let compiledFilePath;
				readdirp(tempDir)
					.then(tempFiles => {
						compiledFilePath = tempFiles[0];
						return fs.readFile(compiledFilePath);
					})
					.then(buffer => {
						file.contents = buffer;
						file.path = file.path.substr(0, file.path.lastIndexOf(".")) + path.extname(compiledFilePath);
						this.push(file);
						return fs.emptyDir(tempDir);
					})
					.then(callback)
					.catch(err => {
						this.emit("error", new gutil.PluginError("gulp-resourcecompiler", err, {fileName: file.path}));
					});
			});
		} catch (err) {
			this.emit("error", new gutil.PluginError("gulp-resourcecompiler", err, {fileName: file.path}));
		}
	});
}

module.exports = compile;

/*
"G:\Program Files\Steam\steamapps\common\dota 2 beta\game\bin\win64\resourcecompiler.exe" -fshallow -maxtextureres 256 -dxlevel 110 -quiet -html -unbufferedio -i "g:/program files/steam/steamapps/common/dota 2 beta/content/dota_addons/angelarenablackstar_develop/maps/5v5_ranked.vmap"  -world -entities -phys -vis -gridnav -breakpad  -nop4 -outroot "G:\Apps\git\aabs-server-legacy\outtest"
Usage: resourcecompiler <in resource file list>
  Options:
   -i:    Source dmx file list, or resource project file list.
          Wildcards are accepted. Can skip using the -i option
          if you put file names @ the end of the commandline.
   -filelist <filename>: specify a text file containing a list of files
          to be processed as inputs.
   -r:    If wildcards are specified, recursively searches subdirectories
   -nop4: Disables auto perforce checkout/add.
   -game <path>: Specifies path to a gameinfo.gi file (which mod to build for).
          If this is not specified, it is derived from the input file name.
   -v:    Verbose mode
   -f:    Force-compile all encountered resources
   -fshallow: Force compile top-level resources, but only compile children and sisters as needed
   -fshallow2: Force compile all top-level resources and their children, but sisters as needed
   -360:  compile resources for Xbox 360
   -pc:   compile resources for Windows PC (default)
   -novpk: generate loose files for the map resource and its children instead of generating a vpk
   -vpkincr: incrementally generate vpk, files already in vpk are left intact unless overwritten
   -pauseiferror: pauses for a user keypress before quitting if there was an error
   -pause: pauses for a user keypress before quitting
resourcecompiler: No input files found
*/
