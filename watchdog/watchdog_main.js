const https 			= require("https");
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

// process names and default services
var processes = ["bpxtest", "hardware-rental", "mastercrm", "digitalsignature", "scientific-paper", "studentregistration"];
var defaultServices = ["", "camunda", "tomcat", "adminer", "mailhog"]

// hosts to test
var hosts = [{
	// name or some kind of identifier of the 
	name: "Jira server by DNS",
	// address details
	connectOptions: {
		// host (ip or url like jira.moodle-dhbw.de)
		host: "jira.moodle-dhbw.de",
		// port of target system
		port: 443
	},
	// checks if error was sent
	lastState: true
	
}, {
	name: "Sharepoint server by DNS",
	connectOptions: {
		host: "sharepoint.moodle-dhbw.de",
		port: 443
	},
	lastState: true
}, {
	name: "GitHub server by DNS",
	connectOptions: {
		host: "github.moodle-dhbw.de",
		port: 443
	},
	lastState: true
}, {
	name: "Slack server by DNS",
	connectOptions: {
		host: "slack.moodle-dhbw.de",
		port: 443
	},
	lastState: true
}, {
	name: "Hubspot server by DNS",
	connectOptions: {
		host: "hubspot.moodle-dhbw.de",
		port: 443
	},
	lastState: true
}, {
	name: "Signavio server by DNS",
	connectOptions: {
		host: "signavio-designer.moodle-dhbw.de",
		port: 443
	},
	lastState: true
}, {
	name: "Travis server by DNS",
	connectOptions: {
		host: "travis.moodle-dhbw.de",
		port: 443
	},
	lastState: true
}];

for(var i = 0; i < processes.length; i++){
	for(var k = 0; k < defaultServices.length; k++){
		hosts.push({
			name: "Process " + processes[i] + "with service " + (defaultServices[k] == "" ? "Moodle" : defaultServices[k]) + " server by DNS",
			connectOptions: {
				host: (defaultServices[k] == "" ? "" : (defaultServices[k] + ".")) + processes[i] + ".moodle-dhbw.de",
				port: 443
			},
			lastState: true
		});
	}
}

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
	var options = {
		host: "www." + host.connectOptions.host,
		port: host.connectOptions.port,
		path: "",
		method: "GET"
	};

	var req = https.request(options, function(res) {
		if(res.statusCode === 200){
			console.log("[CLEAR]: " + host.name + "\n==============================================================");
			host.lastState = true;
		} else {
			handleError(host, err);
		}
	});

	req.on('error', function(e) {
		handleError(host, e);
	});
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
	setInterval(mainLoop, 10000);
}

start();
