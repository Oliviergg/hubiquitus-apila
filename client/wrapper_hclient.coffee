HubiquitusClient = require('hubiquitus4js').HubiquitusClient;

class WrapperHClient
	constructor: (options) ->
		options = options || {}
		@hClient = new HubiquitusClient()
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

module.exports = WrapperHClient