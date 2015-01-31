
///////////// Setup //////////////
AC_PIN <- hardware.pin1; SENSOR_PIN <- hardware.pin2; DC_PIN <- hardware.pin5;   // Lonely red LED
data <- {_AC_state = 0, _SENSOR_state = 0, _DC_state = 0, supplyVoltage = 0, lightLevel=0};
serverMsg <- { what=0, value=0,    then=0,    mode=0,    time=0};

// Configure pins:
AC_PIN.configure(DIGITAL_OUT); SENSOR_PIN.configure(ANALOG_IN); DC_PIN.configure(DIGITAL_OUT);

// sendData reads each of the pins, stores them in a table, and sends that 
// table out to the agent. It calls itself every 100ms -- 10 times a second.
function sendData()
{
    data._AC_state =data._AC_state,
    data._SENSOR_state = SENSOR_PIN.read()/1000,
    data._DC_state =data._DC_state,
    data.supplyVoltage = hardware.voltage()
    data.lightLevel = hardware.lightlevel()
    
    // Once the table is constructed, send it out to the agent with "impValues" as the identifier.
    agent.send("sendToAgent", data);
     // Schedule a wakeup in 1000ms, with a callback to this function.
    imp.wakeup(1, sendData);
} sendData(); // Call sendData once, and let it do the rest of the work.


agent.on("argsFromJs", function(args){
  	//ugly convert of table to local table....
	serverMsg.then=args.then.tointeger();
	serverMsg.value=args.value.tointeger();
	serverMsg.what=args.what.tointeger();
	//serverMsg.time=args.time.tointeger();
	serverMsg.mode=args.mode.tointeger();
	
	//_sensor_state should be in some construct so i can call it and all other sensors with values.
   /* server.log("IF( "+data._SENSOR_state+" > "+serverMsg.value +
    ") THEN "+serverMsg.then+ " SET TO "+ serverMsg.mode 
    + " FOR "+ serverMsg.time+     " SECONDS");
    */
});


function logic(){
    
    //logic() > here goes the function to program the imp
    //what = sensor, value = current sensor value
    //then = control AC/DC/XOR , mode = on/off , time = interval
    
    //flip logic
    local flip = (serverMsg.mode + 1) % 2;

    //deal with device sensor
    if(serverMsg.what == 0){
        //if analog device sensor > sent value
        if(data._SENSOR_state > serverMsg.value ){ 
            if(serverMsg.then == 0){    //AC or DC
                AC_PIN.write(serverMsg.mode);
               data._AC_state = serverMsg.mode;
            }else if (serverMsg.then == 1){
                DC_PIN.write(serverMsg.mode);
               data._DC_state = serverMsg.mode;
            }else if (serverMsg.then == 2){
                AC_PIN.write(serverMsg.mode);
                DC_PIN.write(flip);
               data._AC_state = serverMsg.mode;
               data._DC_state = flip;
            }
        }else{ 
             if(serverMsg.then == 0){    //AC or DC
                AC_PIN.write(flip);
               data._AC_state = flip;
            }else if(serverMsg.then == 1){
                DC_PIN.write(flip);
               data._DC_state = flip;
            }else if (serverMsg.then == 2){
                AC_PIN.write(flip);
                DC_PIN.write(serverMsg.mode);
               data._AC_state = flip;
               data._DC_state = serverMsg.mode;
            }
        }  
       
    }
    imp.wakeup(0.5,logic);
} logic();

/*
//timer action
agent.on("flipDC", function(state) {
    server.log("flipDC:" + state);
    DC_PIN.write(1);
    imp.wakeup(state, function(){ DC_PIN.write(0);});
});

agent.on("flipAC", function(state) {
    server.log("flipAC:" + state);
    AC_PIN.write(1);
    imp.wakeup(state, function(){ AC_PIN.write(0);});
});

*/

/*
//act on agent.on
if(args.mode.tointeger() == 1){
        AC_PIN.write(1);
       data._AC_state = 1;
        DC_PIN.write(1);
       data._DC_state = 1;

        server.log("switch on");
	}
	*/

/*

// when we get a "pong" message from the agent
agent.on("pong", function(startMillis) {
    // get the current time
    local endMillis = hardware.millis();
    // calculate how long the round trip took
    local diff = endMillis - startMillis;
    // log it
    //server.log("Round trip took: " + diff + "ms");
    
    // wakeup in 5 seconds and ping again
    imp.wakeup(5.0, ping);
});
 
// pings the server
function ping() {
    // send a ping message with the current millis counter
    agent.send("ping", hardware.millis());
} 
 
// start the ping-pong
ping();
*/
