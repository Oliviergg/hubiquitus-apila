WrapperHClient = require "./wrapper_hclient"

class StatChannel extends WrapperHClient
	count:0
	prevCount:0
	
	onOpen: () ->
		@prevCount = 0
		@hClient.subscribe "urn:localhost:broadcastChannel", (response) ->
			console.log response
		
		setInterval ()=>
			console.log @count-@prevCount
			@prevCount = @count
		,@options.delay

	onMessage: () =>
		@count += 1 

user = password = "urn:localhost:listen"
listener = new StatChannel delay:2000,hOptions:{endpoints:["http://test.apila.fr:8080"]}
listener.connect(user,password)


