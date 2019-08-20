// Ports
var GeolocationState = {
	elmApp: null,

	geo_success: function (rawPosition) {
		GeolocationState.elmApp.ports.changelocation.send(toLocation(rawPosition));
	},

	geo_error: function (rawError) {
		GeolocationState.elmApp.ports.errorlocation.send(toError(rawError));
	},

	geo_id: function (watchID) {
		GeolocationState.elmApp.ports.watchid.send(watchID);
	}
};

function Geolocation_port_init(elmApp){
/*
	// default
	var geo_options = {
		enableHighAccuracy: true,
		maximumAge        : 0, // 30000,
		timeout           : Infinity // 27000
	};
*/
	var geo_options = {
		enableHighAccuracy: true,
		maximumAge        : 10000,
		timeout           : 9000
	};

	GeolocationState.elmApp = elmApp;



	// ****** Ports from elm (subscriptions)
	elmApp.ports.watch.subscribe(function() {
        //console.log("got from Elm: watch");
        watchID = navigator.geolocation.watchPosition(GeolocationState.geo_success, GeolocationState.geo_error, geo_options);
        GeolocationState.geo_id(watchID);
    });

    elmApp.ports.clearWatch.subscribe(function (watchId) {
        //console.log("got from Elm: watchID = ", watchId);
        navigator.geolocation.clearWatch(watchID);
    });
}



// LOCATIONS

function toLocation(rawPosition)
{
	var coords = rawPosition.coords;

	return {
		longitude: coords.longitude,
		latitude: coords.latitude,
		accuracyPos: coords.accuracy,
		altitude: coords.altitude,
		accuracyAltitude: coords.altitudeAccuracy,
		movingSpeed: coords.speed,
		movingDegrees: coords.heading,
		timestamp: rawPosition.timestamp
	};
}


// ERRORS

var errorTypes = ['PermissionDenied', 'PositionUnavailable', 'Timeout'];

function toError(rawError)
{
	return {
		errcode: errorTypes[rawError.code - 1],
		message: rawError.message
	};
}


