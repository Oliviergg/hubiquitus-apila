{Actor} = require "hubiquitus"
{validator} = require "hubiquitus"
class driverActor extends Actor
	
	constructor: (topology) ->
		super
		@type = "driverActor"
		# @createChild "instanceDriverActor","inproc",{actor:"urn:localhost:instanceDriverActor"},(mess)=>
		# 	@log "info",mess
	
	onMessage: (hMessage) ->
		geo=hMessage.payload
		geo.driver = hMessage.publisher;
		@log "info", JSON.stringify(hMessage,null,2);
		@send payload:geo, actor:"urn:localhost:broadcastChannel"

module.exports = driverActor;