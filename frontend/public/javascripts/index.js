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
	  	var driver=hMessage.payload.driver
	   	// console.log(bareUrn,hMessage.payload);
	   	latLng = new google.maps.LatLng(hMessage.payload.lat,hMessage.payload.lng);
	   	if(markers[driver]==undefined){
	   		markers[driver]  = new google.maps.Marker({
			      position: latLng,
			      map: Global.map,
			      title:driver
			  })
	   	}else{
	   		markers[driver].setPosition(latLng)
	   	}
	  };
	  //Sets a listener for real time status
	  hClient.onStatus = function(hStatus){
	    if(hStatus.status == hClient.statuses.CONNECTED){
	      this.subscribe("urn:localhost:broadcastChannel",function(msg){
	        console.log("Subscription respond : !",msg);
	      });
	    }
	  };
	  // Starts a connection to the XMPP Server using passed options.
	  hClient.connect('urn:localhost:u1', 'urn:localhost:u1');
	},2000)

})
