argv = require('optimist')
    .usage('Usage: $0 -n vehicle number')
    .demand(['n'])
    .argv

automatePseudos = require("./prenom-prod.js")
Journey = require "./journey"


startDrivers = (nb) ->
	nb -= 1
	console.log("running #{nb} drivers")
	for index in [0..nb]
		j = new Journey(automatePseudos[index]);
		j.start()

startDrivers(argv.n)




