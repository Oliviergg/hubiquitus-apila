WrapperHClient = require "./wrapper_hclient"

class Admin extends WrapperHClient
	actor: "urn:localhost:driverHandler"
	fork: () ->
		console.log('fork')
		@sendMessage "fork"

module.exports = Admin
