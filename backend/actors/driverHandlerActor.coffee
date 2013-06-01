{Actor} = require "hubiquitus"
{validator} = require "hubiquitus"

class driverhandlerActor extends Actor
	constructor: (topology) ->
		super
		@type = "driverhandlerActor"
	
	onMessage: (hMessage) ->
		# @log "info",">>> #{JSON.stringify(hMessage,null,2)}"
		command = hMessage.payload.params
		if command.cmd is "new"
			# @log "info",">>> Receive new"
			@createChild "driverActor","inproc",{actor:"urn:localhost:driverActor",adapters:[{type:"socket_in"}]},(child)=>
				@log "info", ">>> createChild #{child.actor}"
				@send actor:hMessage.publisher, payload:{ cmd:"connected",params:{to:child.actor}}

		else if command.cmd is "fork"
			@createChild "driverActor","fork",{actor:"urn:localhost:driverActor",adapters:[{type:"socket_in"}]}, (child) =>
				# @log "info", ">>> createChild #{child.actor}"
				@send actor:hMessage.publisher, payload:{ cmd:"connected",params:{to:child.actor}}


module.exports = driverhandlerActor;