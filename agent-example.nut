// IDIOT - ACDCWIFI
//agent code
// bootstrap code via https://github.com/tomerweller/iot
//based on https://github.com/electricimp/examples/tree/master/SnackBot and others
// shenkar SE lab (redButkhe/yair99)
// https://github.com/shenkarSElab/IDIOT

const html = @"   ";

//////////////////////
// Global Variables //
//////////////////////
server.log("restart agent at epoch: "+time());
_AC_state <- ""; _SENSOR_state <- ""; _DC_state <- ""; supplyVoltage <- ""; lightLevel<- "";
arraydata <-  { _AC_state = 0, _SENSOR_state = 0, _DC_state = 0, supplyVoltage = 0, lightLevel = 0};

/////////////////////////////////////////////////////////////////
//communication with DEVICE , send json table out
/////////////////////////////////////////////////////////////////
device.on("sendToAgent", function(dataFromDevice){
    arraydata = dataFromDevice;
    //dump table to valid urlencoding
    local tlength = 1;    
    local conct="";
    foreach(i,val in arraydata) {
        conct += "&field"+tlength+"="+val;        
        tlength++; 
    }
    //server.log("conn:"+conct);
   local response = httpPostToThingspeak(conct);
});


/////////////////////////////////////////////////////////////////
/// thingspeek storage
/////////////////////////////////////////////////////////////////
// via https://gist.github.com/evilmachina/6402955
local thingspeakUrl = "https://api.thingspeak.com/update";
local headers = {"Content-Type": "application/x-www-form-urlencoded",
                "X-THINGSPEAKAPIKEY":"xxxx"}; //channel 05
//              "X-THINGSPEAKAPIKEY":"xxxxx"} ;//channel 04
                  
function httpPostToThingspeak (temp) {
  //  foreach(i,val in data){ server.log( i +" = "+val);} // //loop over table

  local request = http.post(thingspeakUrl, headers, temp);
  local response = request.sendsync();
  return response;
}

/////////////////////////////////////////////////////////////////
//comunication with HTML CLIENT
/////////////////////////////////////////////////////////////////
function respondImpValues(request, response) { 
    try
    {
        response.header("Access-Control-Allow-Origin", "*");
        if (request.method=="POST"){
                local args = http.jsondecode(request.body);
                device.send("argsFromJs",args); //route to device, ready for pull
            response.send(200, "OK");
            //server.log("respondImpValues "+http.jsonencode(args));

        }else if(request.method="GET"){
            //send to server imp values
            local jsonVars = http.jsonencode(arraydata);
            response.send(200, jsonVars);
        }
    }
    catch (ex) {
        response.send(500, "Internal Server Error: " + ex);
    }
}
http.onrequest(respondImpValues);



/* via http://captain-slow.dk/2014/01/07/using-mailgun-with-electric-imp/
how to send email */
function mailgun(subject, message)
{
  local from = "imp@no-reply.com";
  local to   = "xxx99@gmail.com"
 
  local apikey = "key-3xxxx";
  local domain = "xxxx.mailgun.org";
 
  local request = http.post("https://api:" + apikey + "@api.mailgun.net/v2/" + domain + "/messages", {"Content-Type": "application/x-www-form-urlencoded"}, "from=" + from + "&to=" + to + "&subject=" + subject + "&text=" + message);
 
  local response = request.sendsync();
  server.log("Mailgun response: " + response.body);
}
//mailgun("Electric Imp", "Just saying hiyush! :)");
