var changeTime = -1;
var ParticleList = [];
var currentParticles = [];
var currentSounds = [];
var SoundList = {};
var particlesEnabled = true;

function RemoveParticles() {
	for (var i = 0; i < ParticleList.length; i++) {
		Particles.DestroyParticleEffect(ParticleList[i], false);
		Particles.ReleaseParticleIndex(ParticleList[i]);
		console.log('Removed particle (' + ParticleList[i] + ')');
	}
	ParticleList = [];
}

function CreateParticleForWeather() {
	for (var i = 0; i < currentParticles.length; i++) {
		var index = Particles.CreateParticle(currentParticles[i], ParticleAttachment_t.PATTACH_EYES_FOLLOW, Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()));
		console.log('Just created particle (' + index + ', ' + currentParticles[i] + ')');
		ParticleList.push(index);
	}
}

function ToggleWeatherParticles() {
	particlesEnabled = !particlesEnabled;
	$('#CurrentWeatherIcon').SetHasClass('Disabled', !particlesEnabled);
	particlesEnabled ? CreateParticleForWeather() : RemoveParticles();
}

function StopSounds() {
	for (var event in SoundList) {
		Game.StopSound(SoundList[event].handle);
		console.log('Stopped sound: ' + event);
	}
	SoundList = {};
}

function EmitSoundsForWeather() {
	var now = Game.GetGameTime();
	for (var event in currentSounds) {
		if (!SoundList[event] || now >= SoundList[event].time) {
			console.log('Just emitted sound', event);
			SoundList[event] = {
				handle: Game.EmitSound(event),
				time: now + currentSounds[event]
			};
		}
	}
}

(function() {
	DynamicSubscribePTListener('weather', function(tableName, changesObject, deletionsObject) {
		if (changesObject.current) {
			$('#CurrentWeatherIcon').SetImage(TransformTextureToPath('weather/' + changesObject.current));
			$('#WeatherTime').SetDialogVariable('current_weather', $.Localize('weather_' + changesObject.current));
		}
		if (changesObject.particles) {
			currentParticles = _.values(changesObject.particles);
			if (particlesEnabled) {
				RemoveParticles();
				CreateParticleForWeather();
			}
		}
		if (changesObject.sounds) {
			currentSounds = changesObject.sounds;
			StopSounds();
			EmitSoundsForWeather();
		}
		if (changesObject.changeTime != null) {
			console.log('Updated start time to ' + changesObject.changeTime);
			changeTime = changesObject.changeTime;
		}
	});
})();
