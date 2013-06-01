Location = require('./location.js');

function randomInterval(min,max){
    return (max-min)*Math.random()+min;
}
polyline = require("polyline");
automate_pseudos = require("./prenom.js")
function start_node_view(_user_info){
  var apila = new ApilaController(_user_info);
  var view = new NodeView(apila);
  view.init();
  return apila;
}

// node app/assets/javascripts/apila_node/testws.js take_user '{"server":"prod.apila.fr","port":8000,"from":1000,"to":1005,"each":0.5,"tempo":{"min":500,"max":500}}'
if(command=="take_user"){

}

// node app/assets/javascripts/apila_node/testws.js give_user '{"server":"DESTINATION","port":8000,"from":1000,"to":1010,box:[[b,l],[t,r]],"duration":[min,max],"by":1} >/dev/null &
// node app/assets/javascripts/apila_node/testws.js give_user '{"server":"prod.apila.fr","port":8000,"from":1010,"to":1050,"box":[[48.82,2.266],[48.9,2.40]],"duration":[5,10],"by":1,"each":2}'
// >/dev/null &
if(command=="give_user"){
    commandArgs.from -= 1000;
    commandArgs.to -= 1000;
    // commandArgs.each = commandArgs.each *1000;

    //left - right = lon
    var bottom = commandArgs.box[0][0];    
    var left=commandArgs.box[0][1];
    var top = commandArgs.box[1][0];    
    var right = commandArgs.box[1][1];
    var move_options={duration:{
                                min:commandArgs.duration[0],
                                max:commandArgs.duration[1]
                                },
                            box:commandArgs.box
    };
    

    var options = {
        onNearReceived : function(message){
          console.log("near2",message);
            },
        onOpenWebSocketDidSucceed : function(){
            var self = this;
            var duration=randomInterval(move_options.duration.min,move_options.duration.max);
            console.log("duration:",duration);
            
            self.user.mode(User.MODE_GIVE_USER);
            self.send_position=setInterval(function(){
                    self.user.position.apply(self.user,[{lat:self.user.lat,lon:self.user.lon}]);
                },1000)
        
            self.random_move = setTimeout(
                                    function(){
                                        clearInterval(self.send_position);
                                        self.user.logout();
                                    },duration*1000);
        }
    }

    console.log(commandArgs);
    for(var i=commandArgs.from;i<=commandArgs.to;i++){
        var delta=commandArgs.from
        var base = parseInt(i/commandArgs.by);
        var delay = commandArgs.each*(base-parseInt(commandArgs.from/(commandArgs.by)));
        delay+= 1/100*(i%commandArgs.by);
        console.log(""+i+" lancement de "+automate_pseudos[i]+" dans "+delay+" s");
        
        start_automate(automate_pseudos[i],delay,randomInterval(top,bottom),randomInterval(right,left),options);
    };
}
function start_automate(pseudo,delay,lat,lon,options){
        setTimeout(function(){
                console.log("-----------------------------");
                console.log("automate " +pseudo);
                console.log("-----------------------------");
                 var automate = new ApilaController({
                    pseudo : pseudo,
                    password : "ICautomate!",
                    lat : lat,
                    lon : lon,
                    email : "",
                    token : pseudo,
                    options : options
                });
                var view = new NodeView(automate);
                view.init();
                automate.user.login();
                console.log("-----------------------------");
                },delay*1000
          );
}
