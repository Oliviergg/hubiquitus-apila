{Actor} = require "hubiquitus"
{validator} = require "hubiquitus"
class instanceDriverActor extends Actor
	
	constructor: (topology) ->
		super
		@type = "instanceDriverActor"
	
	onMessage: (hMessage) ->
		@log "info", ">>> I'm child :#{JSON.stringify(hMessage,null,2)}"

module.exports = instanceDriverActor;