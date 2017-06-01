const fs = require('fs');
const dirContent = fs.readdirSync('./');
dirContent.forEach(fileName => {
	if (fileName.endsWith('.sass')) {
		fs.writeFileSync(fileName, fs.readFileSync(fileName, 'utf8')
			.replace(/#(?:[A-Fa-f0-9]{8})/g, hex => {
				if (!hex.startsWith('#')) hex = '#' + hex;
				return 'rgba('+parseInt(hex.substring(1, 3), 16)+', '+parseInt(hex.substring(3, 5), 16)+', '+parseInt(hex.substring(5, 7), 16)+', ' +
					Number((parseInt(hex.substring(7, 9), 16)/255).toFixed(5)) + ')';
			})
			.replace(/rgba\(\d+, \d+, \d+, [1-9][0-9]*\.?\)/g, rgba => {
				rgba = rgba.replace('rgba(', '').replace(')', '');
				let rgbas = rgba.split(', ');
				rgbas[3] = Number((rgbas[3] / 255).toFixed(5));
				return 'rgba(' + rgbas.join(', ') + ')';
			})
		, 'utf8');
	}
});
