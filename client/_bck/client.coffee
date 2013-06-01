{hClient} = require("hubiquitus4js")

hOptions = {}

hClient.connectDriver = () ->
	mess = @buildCommand("urn:localhost:driverHandler", "string", {cmd:"new"})
	@send mess, (err) ->
    console.log err



hClient.onMessage = (hMessage) -> 
	console.log('Received :', hMessage)
	command = hMessage.payload
	if command.cmd is "connected"
		@connectedTo = command.params.to
		mess = hClient.buildCommand(@connectedTo, "string", {cmd:"Ok"})
		hClient.send mess, (err) ->
  	  console.log err


hClient.onStatus = (hStatus) ->
	console.log('hClient New Status', hStatus);
	return if hStatus.status isnt hClient.statuses.CONNECTED
	console.log "connected"
	@connectDriver()

	# setTimeout -> 
	# 	console.log "setTimeout"
	# 	mess = hClient.buildCommand("urn:localhost:driverHandler", "string", {cmd:"echo"})
	# 	hClient.send mess, (err) ->
	#     console.log err
	# ,5000


hClient.connect('urn:localhost:u1', 'urn:localhost:u1', hOptions);			
