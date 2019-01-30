const net 			= require("net");
const fs			= require("fs");
const util			= require("util");
const nodemailer 		= require("nodemailer");

// variables to be set
var transporter;

var transporterOptions = {
	host: "smtp.gmail.com",
	port: 465,
	secure: true,
	auth: {
		user: "moodle.dhbw.mannheim@gmail.com",
		pass: "Asdf'234"
	}
};

var mailOptions = {
	from: '"Friendly Watchdog" <moodle.dhbw.mannheim@gmail.com>', // sender address
	to: "lazar0303@gmail.com, timon.lukas3@gmail.com, s161080@student.dhbw-mannheim.de", // list of receivers
};

// hosts to test
var hosts = [{
	// name or some kind of identifier of the 
	name: "nginx server by IP",
	// address details
	connectOptions: {
		// host (ip or url like jira.moodle-dhbw.de)
		host: "141.72.191.46",
		// port of target system
		port: 22
	},
	// checks if error was sent
	lastState: true
	
}, {
	name: "Nginx server by DN",
	connectOptions: {
		host: "moodle-dhbw.de",
		port: 22
	},
	lastState: true
}, {
	name: "Jira Server http",
	connectOptions: {
		host: "jira.moodle-dhbw.de",
		port: 80
	},
	lastState: true
}, {
	name: "Jira Server ssh",
	connectOptions: {
		host: "141.72.191.48",
		port: 22
	},
	lastState: true
}, {
	name: "Moodle instance 0",
	connectOptions: {
		host: "141.72.191.47",
		port: 8080
	},
	lastState: true
}, {
	name: "Moodle instance 1",
	connectOptions: {
		host: "141.72.191.47",
		port: 8081
	},
	lastState: true
}, {
	name: "Moodle instance 2",
	connectOptions: {
		host: "141.72.191.47",
		port: 8082
	},
	lastState: true
}, {
	name: "Moodle instance 3",
	connectOptions: {
		host: "141.72.191.47",
		port: 8083
	},
	lastState: true
}, {
	name: "Moodle instance 4",
	connectOptions: {
		host: "141.72.191.47",
		port: 8084
	},
	lastState: true
}, {
	name: "Moodle instance 5",
	connectOptions: {
		host: "141.72.191.47",
		port: 8085
	},
	lastState: true
}];

// set startup data
async function setup(){	
	transporter = nodemailer.createTransport(transporterOptions);
}

// handle Errors
async function handleError(host, checkErr){
	if(host.lastState){
		var now = new Date();
		
		fs.writeFile("./errors/errorLog-" + host.name + "-" + now + ".txt", JSON.stringify({host, checkErr}, null, 10), function(err){
			if(err){
				console.log("[ERROR] Failed to create error log:\n" + JSON.stringify(err));
				console.log("-------------------------------------------------------------------------");
				console.log(JSON.stringify({host, checkErr}, null, 10));
				console.log("-------------------------------------------------------------------------");
				
			} else {
				console.log("[ERROR] Error logged: errorLog-" + host.name + "-" + now + ".txt");
			}
		});	
	
		try{
			mailOptions.subject = "Host Down: " + host.name + "-" + now;
			mailOptions.text = "Host Down: " + host.name + "-" + now;
			mailOptions.html = "Host Down: " + host.name + "-" + now;
			
			var info = await transporter.sendMail(mailOptions);
			
			console.log("Message sent: %s", info.messageId);
			
			host.lastState = false;
		} catch (err){
			console.log(err);
		}
	}
}

// check host function
async function checkHost(host){
	var sock = new net.Socket();
	sock.setTimeout(5000);
	
	try {
		sock.on('connect', () => {
			console.log("[CLEAR]: " + host.name + "\n==============================================================");
			host.lastState = true;
			sock.destroy();
		
		}).on('error', err => {
			handleError(host, err);
		
		}).on('timeout', err => {
			handleError(host, err);
		
		}).connect(host.connectOptions);
	
	} catch (err){
		await handleError(host, err);
	}
}

// main check loop
async function mainLoop(){
	for(var h in hosts){
		await checkHost(hosts[h]);
	}
}

async function start(){
	// setup the environment
	await setup();
	
	// calling the main loop every 5 mins
	setInterval(mainLoop, 300000);
}

start();
