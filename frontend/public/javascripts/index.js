var Global={}
function initialize() {
	var mapOptions = {
		center: new google.maps.LatLng(48.85136, 2.265329),
		zoom: 11,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	
	Global.map = new google.maps.Map(document.getElementById("map-canvas"),
			mapOptions);
}

$(document).ready(function(){
	initialize();
	var markers=[];
	setTimeout(function(){

		//Sets a listener for incoming real time messages
		hClient.onMessage = function(hMessage){
			var command = {}
			command.cmd = hMessage.type
			command.params = hMessage.payload
			hMessage.location = hMessage.location || {} 
			command.location = hMessage.location.pos

			var driver=hMessage.payload.driver

			if(command.cmd === "move"){
				latLng = new google.maps.LatLng(command.location.lat,command.location.lng);
				if(markers[driver]==undefined){
					markers[driver] = new google.maps.Marker({
							position: latLng,
							map: Global.map,
							title:driver
					})
				}else{
					markers[driver].setPosition(latLng)
				}	  		
			}else if(command.cmd === "finished"){
				setTimeout(function(){
					markers[driver].setMap(null);
				},5000)
			}
		};
		//Sets a listener for real time status
		hClient.onStatus = function(hStatus){
			if(hStatus.status == hClient.statuses.CONNECTED){
				this.subscribe("urn:localhost:broadcastChannel",function(msg){
					console.log("Subscription respond : !",msg);
				});
				this.setFilter({
					geo: {
								// lat: 48.8,
								// lng: 2.3,
								// radius: 5000
							 }
					})

			}
		};
		// Starts a connection to the XMPP Server using passed options.
		hClient.connect('urn:localhost:u1', 'urn:localhost:u1')

	},2000)

})
