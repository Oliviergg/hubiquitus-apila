
var routes = require("./routes");
var automatePseudos = require("./prenom-prod.js")
var polyline = require("polyline");
var HubiquitusClient = require('hubiquitus4js').HubiquitusClient;

var fromId= 0
var toId= 20
var eachInterval = 500
console.log("running from "+fromId+" to "+toId)

var hOptions = {
    transport : 'socketio',
    endpoints : ['http://localhost:8080/']
};


var place = {
	name:"animate",
	lat:0.0,
	lon:0.0
};
var move = {
	tempo:{min:1500,max:2500},
	moveBy:0.5
}; 

var buildJourney = function(){
	var self = this;
	// Find a Randow Journey
	var route_index = Math.round((Math.random()*(routes.length-1)))
	var route = routes[route_index].gm;
	
	// Build all steps of journey
	var steps=[];
	var gm_steps = route.legs[0].steps;
	gm_steps.forEach(function(gm_step){
		var duration=gm_step.duration.value;
		if(duration < 60 ) duration = 60;
		
		var points=polyline.decodeLine(gm_step.polyline.points);
		var step_duration = duration/points.length;
		if(step_duration>2.0){
			var frame_duration = 1;
			var prev_coord = points.shift();
			points.forEach(function(coord){
				var nb_frames = Math.round(step_duration/frame_duration);
				var lat_slop = (coord[0]-prev_coord[0])/nb_frames;
				var lon_slop = (coord[1]-prev_coord[1])/nb_frames;
				for(var i=0; i<nb_frames ;i++){
					prev_coord[0] = prev_coord[0] + lat_slop;
					prev_coord[1] = prev_coord[1] + lon_slop;
					steps.push({
						duration:step_duration/nb_frames,
						coord:[prev_coord[0],prev_coord[1]]
					});        
				}                                    
			});                
		}else{
			points.forEach(function(coord){
				steps.push({calc:false,
					duration:step_duration,
					coord:coord
				})
		});            
		}
	});
	return steps;
}

nextStep = function(journey){
	var stepId = journey.stepId;
	var step = journey.steps[stepId];
	if(step == undefined){
		return;
	}
	var new_lat = step.coord[0];
	var new_lon = step.coord[1];
	console.log("Pseudo:"+journey.pseudo+" > step :"+stepId+"/"+journey.totalSteps+" lat : "+new_lat+" lon : "+new_lon);
	journey.stepId += 1;
  var message_to_send = journey.hClient.buildMessage("urn:localhost:driver", "string", {lat:new_lat,lng:new_lon});
	journey.hClient.send(message_to_send, function(error){
		console.log("take_user",error)
	});

	setTimeout(function(){nextStep(journey)},step.duration*1000);  
}


var startJourney = function(journey){
	console.log("-----------------------------");
	console.log("automate " +journey.pseudo);
	console.log("-----------------------------");
	setTimeout(function(){nextStep(journey)},Math.random()*1000*10);
}
var start = function(){
	for(i=fromId;i<=toId;i++){
		(function(index){
			console.log("will start: "+automatePseudos[index]);
			var pseudo=automatePseudos[index];
			// var pseudo="léonie";
			var hClient = new HubiquitusClient();
			console.log("hclient",hClient);
			hClient.onMessage = function(hMessage){
			    console.log('Received :', hMessage);
			};
			hClient.onStatus = function(hStatus){
			    console.log('hClient New Status', hStatus);
			    if(hStatus.status == hClient.statuses.CONNECTED){
						var delay =eachInterval*(i-fromId);
						console.log(""+index+" Lancement de "+automatePseudos[index]+" dans "+delay+" ms");
						var steps = buildJourney();
						var journey = {
							pseudo:pseudo,
							steps: steps,
							hClient: hClient,
							stepId:0,
							totalSteps:steps.length
						}
						startJourney(journey);
			    }
			};
			hClient.connect('urn:localhost:'+pseudo, 'urn:localhost:'+pseudo, hOptions);			
		}(i));
	};
}

start();
