routes = require("./routes");
automatePseudos = require("./prenom-prod.js")
polyline = require("polyline");
HubiquitusClient = require('hubiquitus4js').HubiquitusClient;

fromId= 0
toId= 20
eachInterval = 500
console.log("running from "+fromId+" to "+toId)

hOptions = {}


place = {
	name:"animate",
	lat:0.0,
	lon:0.0
};
move = {
	tempo:{min:1500,max:2500},
	moveBy:0.5
}; 

buildJourney = ()->
	# Find a Randow Journey
	route_index = Math.round((Math.random()*(routes.length-1)))
	route = routes[route_index].gm;
	
	# Build all steps of journey
	steps=[];
	gm_steps = route.legs[0].steps;
	gm_steps.forEach (gm_step) =>
		duration=gm_step.duration.value;
		if duration < 60
			duration = 60;
		
		points=polyline.decodeLine(gm_step.polyline.points);
		step_duration = duration/points.length;
		if step_duration>2.0
			frame_duration = 1;
			prev_coord = points.shift();
			points.forEach (coord) ->
				nb_frames = Math.round(step_duration/frame_duration);
				lat_slop = (coord[0]-prev_coord[0])/nb_frames;
				lon_slop = (coord[1]-prev_coord[1])/nb_frames;
				for i in [0..nb_frames]
					prev_coord[0] = prev_coord[0] + lat_slop;
					prev_coord[1] = prev_coord[1] + lon_slop;
					steps.push({
						duration:step_duration/nb_frames,
						coord:[prev_coord[0],prev_coord[1]]
					})
		else
			points.forEach (coord) ->
				steps.push {calc:false,duration:step_duration,coord:coord}
	return steps;

nextStep = (journey) ->
	stepId = journey.stepId
	step = journey.steps[stepId]
	return if not step? 
	new_lat = step.coord[0]
	new_lon = step.coord[1]
	console.log("Pseudo:"+journey.pseudo+" > step :"+stepId+"/"+journey.totalSteps+" lat : "+new_lat+" lon : "+new_lon)
	journey.stepId = journey.stepId + 1
	message_to_send = journey.hClient.buildMessage("urn:localhost:driver", "string", {lat:new_lat,lng:new_lon})
	journey.hClient.send message_to_send, (err) ->
		console.log("take_user",error)

	setTimeout ->
		nextStep(journey)
	,step.duration*1000

startJourney = (index) ->
	console.log("will start: "+automatePseudos[index]);
	pseudo = automatePseudos[index];
	
	hClient = new HubiquitusClient();
	console.log("hclient",hClient);
	hClient.onMessage = (hMessage) ->
		console.log('Received :', hMessage);

	hClient.onStatus = (hStatus)->
		console.log('hClient New Status', hStatus)
		return if hStatus.status isnt hClient.statuses.CONNECTED
		steps = buildJourney();
		journey = {
			pseudo:pseudo,
			steps: steps,
			hClient: hClient,
			stepId:0,
			totalSteps:steps.length
		}
		# Démarrage en différé
		delay = eachInterval*(index-fromId)
		console.log(""+index+" Lancement de "+automatePseudos[index]+" dans "+delay+" ms");
		setTimeout ->
			nextStep(journey)
		,delay
	hClient.connect('urn:localhost:'+pseudo, 'urn:localhost:'+pseudo, hOptions);			

start = () ->
	for i in [fromId..toId]
		startJourney(i)

start();
