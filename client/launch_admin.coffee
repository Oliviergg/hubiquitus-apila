Admin = require "./admin"

admin = new Admin()
admin.onOpen ()->
	@fork()

admin.connect 'urn:localhost:admin', 'urn:localhost:admin'
