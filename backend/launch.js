require("coffee-script");
hubiquitus=require("hubiquitus")

hubiquitus.start({
  actor: "urn:localhost:tracker",
  type: "htracker",
  properties:{
     channel: {
         actor: "urn:localhost:trackChannel",
         type: "hchannel",
         properties: {
             subscribers: [],
             db:{
                 host: "localhost",
                 port: 27017,
                 name: "admin"
             },
             collection: "trackChannel"
         }
     }
  },
  adapters: [ { type: "socket_in"} ],
  children: [
    {
      actor: "urn:localhost:gateway",
      type: "hgateway",
      log:{
         logLevel:"info"
      },
      children: [
        {
          actor: "urn:localhost:auth",
          type: "hauth"
        },

      ],
      adapters: [ { type: "socket_in"} ],
      properties: {
         socketIOPort: 8080,
         authActor: "urn:localhost:auth",
         authTimeout: 3000
      }
    },
    {
      actor: "urn:localhost:driverHandler",
      type: "driverHandlerActor",
      adapters: [{type: "socket_in"}]
    },
    {
      actor: "urn:localhost:driver",
      type: "driverActor",
      adapters: [{type: "socket_in"}]
    },
    {
      actor: "urn:localhost:broadcastChannel",
      type: "hchannel",
      properties: {
        subscribers: [],
        collection: "broadcastChannel",
        db:{
          host: "localhost",
          port: 27017,
          name: "onRadio"
        },
      }
    },

    // {
    //   // The socket_in is needed because Actor need to receive subscription Ack       
    //   actor: "urn:localhost:onRadioPlaylistActor",
    //   type: "onRadioPlaylistActor",
    //   adapters: [  
    //     { 
    //       type: "channel_in",
    //       channel: "urn:localhost:broadcastChannel",
    //     },
    //     {
    //       type: "socket_in",
    //     }
    //   ]
    // },

  ],
});