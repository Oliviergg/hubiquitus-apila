WrapperHClient = require "./wrapper_hclient"

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
		@hClient.setFilter lat:@location.lat,lng:@location.lng,radius:5000

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

module.exports = Driver