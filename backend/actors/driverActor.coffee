{Actor} = require "hubiquitus"
{validator} = require "hubiquitus"
class driverActor extends Actor
	
	constructor: (topology) ->
		super
		@type = "driverActor"
		@msgCount = 0

	onMessage: (hMessage) ->
		@msgCount += 1
		
		hMessage.payload = hMessage.payload || {}
		hMessage.payload.driver = hMessage.publisher
		@send @buildMessage("urn:localhost:broadcastChannel",hMessage.type,hMessage.payload,location:hMessage.location)

module.exports = driverActor;