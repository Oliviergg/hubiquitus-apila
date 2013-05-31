{Actor} = require "hubiquitus"
{validator} = require "hubiquitus"
cache = []
nocircular= (key, value)->
  if typeof value is 'object' and value isnt null 
  	if cache.indexOf(value) isnt -1
	    return
    cache.push(value)
  return value

class driverhandlerActor extends Actor
	
	constructor: (topology) ->
		super
		@type = "driverhandlerActor"
		# @createChild "instanceDriverActor","inproc",{actor:"urn:localhost:instanceDriverActor"},(mess)=>
		# 	@log "info",mess
	
	onMessage: (hMessage) ->
		@log "info",">>> #{JSON.stringify(hMessage,null,2)}"
		command = hMessage.payload.params
		@log "info",JSON.stringify(command)
		if command.cmd is "new"
			@log "info",">>> Receive new"
			@createChild "instanceDriverActor","inproc",{actor:"urn:localhost:instanceDriverActor",adapters:[{type:"socket_in"}]},(child)=>
				@log "info", ">>> createChild #{child.actor}"
				@send actor:hMessage.publisher, payload:{ cmd:"connected",params:{to:child.actor}}


module.exports = driverhandlerActor;