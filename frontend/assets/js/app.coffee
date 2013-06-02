Global = Global || {}
class WrapperHClient
	constructor: (options) ->
		options = options || {}
		@hClient = hClient
		@options = options
		@hOptions = options.hOptions || {}
		
		@hClient.onStatus = (hStatus) =>
			console.log('hClient New Status', hStatus);
			return if hStatus.status isnt @hClient.statuses.CONNECTED
			console.log "connected"
			@onConnectCallback()


	connect: (user,password) ->
		console.log("WrapperHClient connect")
		if @beforeOnMessage?
			@hClient.onMessage = @internalOnMessage
		else
			@hClient.onMessage = @onMessage
		
		@hClient.connect(user,password, @hOptions);

	onConnectCallback: ()->
		console.log("WrapperHClient onConnectCallback")
		@onOpen()

	onOpen: () ->
		console.log("WrapperHClient default onOpen")

	internalOnMessage: (hMessage) =>
		cont = @beforeOnMessage(hMessage)
		@onMessage(hMessage) if cont

	onMessage: (hMessage) ->
		console.log("WrapperHClient default on message")

	sendMessage: (command) ->
		mess = @hClient.buildMessage(@actor, command.cmd, command.params, location:{pos:@location})
		@hClient.send mess, (err) ->
			console.log err

class Driver extends WrapperHClient
	# actor: "urn:localhost:driver"

	actor: "urn:localhost:driverHandler"
	location:{lat:0,lng:0}
	onConnectCallback: ()->
		console.log("Driver onConnectCallback")

		@hClient.subscribe "urn:localhost:broadcastChannel", (response) ->
			console.log "Subscribe respond :#{JSON.stringify(response)}"

		# @hClient.onMessage = @internalOnMessage
		mess = @hClient.buildCommand(@actor, "string", {cmd:"new"})
		@hClient.send mess, (err) ->
			console.log err

	setGeolocation: (location) ->
		@location=location if location and location.lat? and location.lng?
		@sendMessage cmd:"move"
		@hClient.setFilter geo:{lat:@location.lat,lng:@location.lng,radius:5000}

		# mess = @hClient.buildMessage(@actor, "move", {},location:{pos:@location})
		# @hClient.send mess, (err) ->
	 #    console.log err

	beforeOnMessage: (hMessage) => 
		command = hMessage.payload
		if command.cmd is "connected"
			@actor = command.params.to
			@onOpen(command.params)
			return false

		return true

########################
initialize= () ->
	mapOptions = {
		center: new google.maps.LatLng(48.85136, 2.265329),
		zoom: 11,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	}
	Global.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
	
driverMarker= () ->
	pinColor = "FE7569";
	pinImage = new google.maps.MarkerImage("http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" + pinColor,
				new google.maps.Size(21, 34),
				new google.maps.Point(0,0),
				new google.maps.Point(10, 34));
	
	new google.maps.Marker({
							position: Global.map.center
							map: Global.map
							title:"MY"
							icon: pinImage,
							draggable:true
					})


#######################
$ ->
	initialize()
	myMarker = driverMarker();
	markers=[];

	filterCircle = new google.maps.Circle({
		strokeColor: "#3333ff",
		strokeOpacity: 0.8,
		strokeWeight: 2,
		fillColor: "#3333ff",
		fillOpacity: 0.18,
		map: Global.map,
		center: Global.map.center,
		radius: 5000
	 });

	refreshCenter = null;

	setTimeout ->
		
		driver = new Driver(hOptions:{ endpoints:["http://test.apila.fr:8080"]})
		myMarker.driver = driver

		google.maps.event.addListener myMarker, 'dragend', () ->
			console.log("dragend",@)
			filterCircle.setCenter(myMarker.getPosition())

			myMarker.driver.setGeolocation lat:myMarker.getPosition().lat(),lng:myMarker.getPosition().lng()



		driver.onMessage = (hMessage) ->
			command = {}
			command.cmd = hMessage.type
			command.params = hMessage.payload
			hMessage.location = hMessage.location || {} 
			command.location = hMessage.location.pos

			driver = hMessage.payload.driver

			if command.cmd is "move" 
				latLng = new google.maps.LatLng(command.location.lat,command.location.lng);
				if markers[driver] is undefined
					markers[driver] = new google.maps.Marker({
							position: latLng,
							map: Global.map,
							title:driver
					})
				else
					markers[driver].setPosition(latLng)
								
			else if command.cmd is "finished"
				setTimeout () ->
					markers[driver].setMap(null);
				,5000

		# Sets a listener for real time status
		driver.onOpen = () ->
			@hClient.subscribe "urn:localhost:broadcastChannel",(msg) ->
				console.log "Subscription respond : !",msg 

			@hClient.setFilter({
				geo: {
							lat:Global.map.center.lat(),
							lng:Global.map.center.lng(),
							radius: 5000
						 }
				})
		
		driver.connect('urn:localhost:u1', 'urn:localhost:u1')

	,2000

