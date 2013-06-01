Driver = require("./driver")
argv = require('optimist')
    .usage('Usage: $0 -n vehicle number')
    .demand(['n'])
    .argv


centerLat = 48.8
centerLng = 2.3
stepLat = 0.03
stepLng = 0.03

size = 6
demiSize = size / 2

setDriverAtLocation= (iLat,ilng)->
	lat = centerLat + (iLat * stepLat)
	lng = centerLng + (iLng * stepLng)
	driver = new Driver()	
	
	driver.onOpen () ->
		@setGeolocation lat:lat,lng:lng
	user = password = "urn:localhost:driver#{iLat}x#{iLng}"		
	driver.connect(user,password)


for iLat in [-demiSize..demiSize]
	for iLng in [-demiSize..demiSize]
		setDriverAtLocation(iLat,iLng)

