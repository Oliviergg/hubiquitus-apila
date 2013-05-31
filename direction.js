fs = require('fs');
gm = require('googlemaps');
polyline = require("polyline");

gm.config('encode-polylines',false)

global.last_direction={};
global.directions=[]
direction_callback = function(err,data){
  if(err){
    console.log("!!error",err);
	return
  };
  var route = data.routes[0];
  // var leg = routes.legs[0];
  // 
  // 
  // routes.decoded_polyline.points = data.routes[0]
  // var points = routes.overview_polyline.points;
  // points. = polyline.decodeLine(points);
  
  // global.points = points;
  // global.last_direction=data;
  global.directions.push({gm:route});
}

	// gm.directions('55, rue de sevres, paris', 
	// '114, rue du chemin vert, paris' , 
	// direction_callback , 
	// 'false');	

idf = {bottom_left:[48.8,2.22],top_right:[48.9,2.45]};
parisO = {bottom_left:[48.8,2.22],top_right:[48.9,2.34]};
parisE = {bottom_left:[48.8,2.34],top_right:[48.9,2.45]};
paris = {bottom_left:[48.82,2.266],top_right:[48.9,2.40]};
var zones = [idf,parisE,parisO,paris,paris,paris,paris];

directions_max=200;
directions_coords=[]
for(var i=1;i<=directions_max;i++){
//	console.log("from "+from.lat+","+from.lon,"to "+to.lat+","+to.lon);
	zone = zones[Math.round(Math.random()*(zones.length-1))];
	console.log(zone);
	directions_coords.push({
		from:{
			lat:Math.random()*(zone.top_right[0]-zone.bottom_left[0])+zone.bottom_left[0],
			lon:Math.random()*(zone.top_right[1]-zone.bottom_left[1])+zone.bottom_left[1]
		}, 
		to:{
			lat:Math.random()*(zone.top_right[0]-zone.bottom_left[0])+zone.bottom_left[0],
			lon:Math.random()*(zone.top_right[1]-zone.bottom_left[1])+zone.bottom_left[1]
		}, 
	});
};



request_direction=setInterval(function(){
	coords = directions_coords.pop();
	if(coords == undefined){
		clearTimeout(request_direction)
	}else{
		console.log(coords);
		gm.directions(""+coords.from.lat+","+coords.from.lon, 
		""+coords.to.lat+","+coords.to.lon , 
		direction_callback , 
		'false');		
	};


},1000)

waitingAllDirections=setInterval(function(){
	if(global.directions.length == directions_max){
		console.log("Waiting "+global.directions.length+" sur "+directions_max);
		fs.open('./routes.js', 'w', 666, function( e, id ) {
		  escaped_directions = JSON.stringify(global.directions);
		  to_write= 'directions=eval('+escaped_directions+');'+"\n"
		  to_write+='routes=(directions);'+"\n";
		  to_write+='if (typeof module !== undefined) module.exports = routes;'+"\n";
		  fs.write( id, to_write, null, 'utf8', function(){
		  	fs.close(id, function(){
		  	  console.log('file closed');
		  	});
		  });
		});
		clearInterval(waitingAllDirections);
	}else{
		console.log("Waiting "+global.directions.length+" sur "+directions_max)
	}
	
},1000);

