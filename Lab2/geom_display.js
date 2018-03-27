function onEachFeature(feature, layer) {
	var popupContent = "";
	if (feature.properties && feature.properties.popupContent) {
		popupContent += feature.properties.popupContent;
	}
	layer.bindPopup(popupContent);
}

function isArray(obj) { 
	return Object.prototype.toString.call(obj) === '[object Array]'; 
}

function display(divId, lon, lat, zoom){
	var wkx = require('wkx');
	var buffer = require('buffer');
	
	console.log(isArray(geometry.features))
	if(geometry.features != null) {
		for (var i in geometry.features) {
			console.log(geometry.features[i]);
			var wkbLonlat = geometry.features[i].geometry;
			var hexAry = wkbLonlat.match(/.{2}/g);
    
			var intAry = [];
			for (var j in hexAry) {
				intAry.push(parseInt(hexAry[j], 16));
			}
			
			var buf = new buffer.Buffer(intAry);
			var geom = wkx.Geometry.parse(buf);
			geometry.features[i].geometry = geom.toGeoJSON();
		}
	}
	else {
		var wkbLonlat = geometry.geometry;
		var hexAry = wkbLonlat.match(/.{2}/g);
		var intAry = [];
		for (var i in hexAry) {
			intAry.push(parseInt(hexAry[i], 16));
		}
		var buf = new buffer.Buffer(intAry);
		var geom = wkx.Geometry.parse(buf);
		geometry.geometry = geom.toGeoJSON();
	}
	
	var map = L.map(divId).setView([lon, lat], zoom);
	console.log(geometry);

    L.tileLayer('https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoicm9ja3N0b25lIiwiYSI6ImNpbGMxNXpjdTIxMmt1YmtucnpsbGZtdjIifQ.QfAz3o5VbZ02UoXVUR5Gqw', {
           	  maxZoom: 18,
              attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
                '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                'Imagery © <a href="http://mapbox.com">Mapbox</a>',
              id: 'mapbox.light'
        }).addTo(map);

	L.geoJson(geometry,{
		filter: function (feature, layer) {
				return !feature.properties.newStyle;
		},
		onEachFeature: onEachFeature,
		pointToLayer: function (feature, latlng) {
			return L.circleMarker(latlng, {
				radius: 8,
				fillColor: "#ff7800",
				color: "#000",
				weight: 1,
				opacity: 1,
				fillOpacity: 0.8
			});
		}
	}).addTo(map);

	L.geoJson(geometry,{
		filter: function (feature, layer) {
				return feature.properties.newStyle;
		},
		onEachFeature: onEachFeature,
		pointToLayer: function (feature, latlng) {
			return L.circleMarker(latlng, {
				radius: 8,
				fillColor: "#ff7800",
				color: "#000",
				weight: 1,
				opacity: 1,
				fillOpacity: 0.8
			});
		},
		style: {
            weight: 2,
            color: "#500",
            opacity: 1,
            fillColor: "#B0DE5C",
            fillOpacity: 0.5
        }
	}).addTo(map);

}