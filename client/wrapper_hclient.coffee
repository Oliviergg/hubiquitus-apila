HubiquitusClient = require('hubiquitus4js').HubiquitusClient;

class WrapperHClient
	constructor: (options) ->
		options = options || {}
		@hClient = new HubiquitusClient()
		@hOptions = options.hOptions || {}
		my = @
		@hClient.onStatus = (hStatus) ->
			console.log('hClient New Status', hStatus);
			return if hStatus.status isnt @statuses.CONNECTED
			console.log "connected"
			my.onConnectCallback()

	connect: (user,password) ->
		console.log("WrapperHClient connect")
		@hClient.onMessage = @onMessage
		@hClient.connect(user,password, @hOptions);

	onConnectCallback: ()->
		console.log("WrapperHClient onConnectCallback")
		@onOpenCallback()

	onOpenCallback: () ->
		console.log("WrapperHClient onOpenCallback")

	onOpen: (callback) ->
		console.log("WrapperHClient onOpen")
		@onOpenCallback = callback

	onMessage: (hMessage) -> 
		console.log("WrapperHClient onMessage")
		console.log hMessage

	sendMessage: (command) ->
		mess = @hClient.buildMessage(@actor, command.cmd, command.params, location:{pos:@location})
		@hClient.send mess, (err) ->
	    console.log err

module.exports = WrapperHClient