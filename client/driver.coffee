WrapperHClient = require "./wrapper_hclient"

class Driver extends WrapperHClient
	# actor: "urn:localhost:driver"

	actor: "urn:localhost:driverHandler"
	location:{lat:0,lng:0}
	onConnectCallback: ()->
		console.log("Driver onConnectCallback")
		@hClient.onMessage = @onMessage
		mess = @hClient.buildCommand(@actor, "string", {cmd:"new"})
		@hClient.send mess, (err) ->
			console.log err

	setGeolocation: (location) ->
		if location and location.lat? and location.lng?
			@location=location
		@sendMessage cmd:"move"
		# mess = @hClient.buildMessage(@actor, "move", {},location:{pos:@location})
		# @hClient.send mess, (err) ->
	 #    console.log err

	onMessage: (hMessage) => 
		# console.log('Driver Received :', hMessage)
		command = hMessage.payload
		if command.cmd is "connected"
			@actor = command.params.to
			@onOpenCallback(command.params)
		else
			console.log('Received :', hMessage)

module.exports = Driver