argv = require('optimist')
    .usage('Usage: $0 -n vehicle number')
    .demand(['n'])
    .argv

automatePseudos = require("./prenom-prod.js")
Journey = require "./journey"

hClient = require("./wrapper_hclient")


# start count drivers and maintain that count
startDrivers = (count) ->
	count -= 1
	console.log("running #{count} drivers")
	for index in [0..count]
		j = new Journey(automatePseudos[index]);
		j.start()

	catchFinished = new hClient(hOptions:{endpoints:["http://test.apila.fr:8080"]})
	
	catchFinished.onOpen =  () ->
		@hClient.subscribe "urn:localhost:broadcastChannel", (response) ->
			console.log response

	catchFinished.onMessage = (hMessage) ->
		if hMessage.type is "finished"
			j = new Journey(automatePseudos[1]);
			j.start()

	user = password = "urn:localhost:catchfinished"		
	catchFinished.connect(user,password)

startDrivers(argv.n)




