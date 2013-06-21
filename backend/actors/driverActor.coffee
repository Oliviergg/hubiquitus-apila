{Actor} = require "hubiquitus"
{validator} = require "hubiquitus"
MongoClient = require('mongodb').MongoClient;


class driverActor extends Actor
	
	constructor: (topology) ->
		super
		@type = "driverActor"
		@msgCount = 0
		MongoClient.connect "mongodb://localhost:27017/exampleDb", (err, db) =>
		  return console.dir(err) if err

		  collection = db.collection('test');
		  doc1 = {'hello':'doc1'};
		  doc2 = {'hello':'doc2'};
		  lotsOfDocs = [{'hello':'doc3'}, {'hello':'doc4'}];

		  # collection.insert(doc1);

		  collection.insert doc2, {w:1}, (err, result) => 
		  	@log "info",result

		  # collection.insert lotsOfDocs, {w:1}, (err, result) -> 
		  # 	@log "info",result




	onMessage: (hMessage) ->
		@msgCount += 1
		@log "info", "message #{JSON.stringify(hMessage,null,2)}"
		hMessage.payload = hMessage.payload || {}
		hMessage.payload.driver = hMessage.publisher
		@send @buildMessage("urn:localhost:broadcastChannel",hMessage.type,hMessage.payload,location:hMessage.location)

module.exports = driverActor;