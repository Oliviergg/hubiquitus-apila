polyline = require("polyline")
routes = require("./routes")
Driver = require("./driver")
class Journey
	constructor:(pseudo) ->
		console.log("will start: "+pseudo);

		@pseudo = pseudo
		@stepId = 0
		@steps=[]
		@buildJourney()

		@driver = new Driver()
		@driver.onOpen () =>
			steps = @buildJourney();
			console.log("Lancement de "+pseudo+" dans "+"delay"+" ms");
			setTimeout =>
				@nextStep()
			,0

	
	buildJourney:()->
		# Find a Randow Journey
		route_index = Math.round((Math.random()*(routes.length-1)))
		route = routes[route_index].gm;
		
		# Build all steps of journey
		steps=[];
		gm_steps = route.legs[0].steps;
		gm_steps.forEach (gm_step) =>
			duration=gm_step.duration.value;
			duration = 60 if duration < 60
			#duration = 1
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
		@steps=steps
		@totalSteps = steps.length

	nextStep:() ->
		unless @isNextStep() is true
			@finished()
			return
		step = @steps[@stepId]
		lat = step.coord[0]
		lng = step.coord[1]
		console.log("Pseudo #{@pseudo} - #{(Math.round(@stepId / (@totalSteps - 1 )*10000)) / 100.0} % lat : #{lat} lon : #{lng}")
		@stepId += 1
		@driver.setGeolocation lat:lat,lng:lng
		setTimeout =>
			@nextStep()
		,step.duration*1000

	isNextStep:() ->
		return true if @stepId <= (@totalSteps - 1)
		false

	start: () ->
		@driver.connect "urn:localhost:#{@pseudo}","urn:localhost:#{@pseudo}"

	finished: () ->
		console.log("Pseudo #{@pseudo} - Finished")
		@driver.sendMessage cmd:"finished"

module.exports = Journey
