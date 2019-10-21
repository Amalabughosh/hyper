var express = require('express');
var router = express.Router();
const fs = require('fs');
const uuidv1 = require('uuid/v1');
const path = "bin/data/";

/* GET home page. */
router.get('/', function(req, res, next) {
  res.send('Server is up & running');
});



router.post('/api/create', function (req, res) {

});

router.post('/api/build', async function (req, res) {


  var i,j,text,peernum,chnl;
  chnl=req.body.channel.length.toString() + " ";
  peernum='';
  text = req.body.organizations.length.toString();
   console.log(req.body.organizations.length.toString());
  for ( i=0; i< req.body.organizations.length;i++){
     console.log(req.body.organizations[i].peers);
    text += " " + req.body.organizations[i].peers.toString();
    peernum += req.body.organizations[i].peers.toString() + ",";
  }

  text = "./setorg.sh " + text;
  console.log('command: ' + text);



  for ( i=0; i< req.body.channel.length;i++){
      for ( j=0; j<req.body.channel[i].list.length;j++){
           chnl += req.body.channel[i].list[j].toString()[3] + "," ;
      }
      chnl += " ";
  }
   chnl += peernum;
   chnl = "./setchannel.sh " + chnl;

   console.log('command: ' + chnl);
   text = text +"\n" + chnl;

  const exec = require('child_process').exec 
 await exec(text, function(err, pid, result) {
       if (err){
          console.error(`exec error: ${err}`);
	  res.json({msg: 'Command failed'});
          return;
          }
	console.log('output: ' + result);

	 });


  console.log('in the build');
  var sudo =  require('sudo-js');
  sudo.setPassword('amal');
  var command;

  command = ['./byfn.sh', 'up'];

 //  exec = require('child_process').exec 
  await sudo.exec(command,  function(err, pid, result) {
//process.stdout.write(stdout)
        if (err){
          console.error(`exec error: ${err}`);
	  res.json({msg: 'Command failed'});
          return;
          }
  var i,out;
  out=' ';
  for ( i=result.length-27; i< result.length;i++){
	out+=result[i];
    }


       console.log(result);
	console.log(out);
        res.json({msg: out});
     return;

	 });
	console.log('finishing');

});

router.post('/api/write', function (req, res) {
  var text, invok, test;
  console.log('hiiiiiiiii');
  invok = req.body.text.toString();
  peer=req.body.peerwrite.toString();
  org=req.body.orgwrite.toString();
  chnl=req.body.chnlwrite.toString();
  if (chnl=='0')
      chnl="mychannel";
  else
      chnl="channel"+chnl;     
  text = "./invok.sh";
  test = "./invok.sh " + "'" +invok + "'" + " "+ peer + " "+ org + " " + chnl;
  console.log('command: ' + test);
  console.log('cwd: ' + process.cwd());

  const exec = require('child_process').exec 
  exec(test, function(err, pid, result) {
       if (err){
          console.error(`exec error: ${err}`);
	  res.json({msg: 'Command failed'});
          return;
          }
	console.log('output: ' + result);

	res.json({msg: 'Command run successfuly'});
	 });
	console.log('finishing');
});

router.post('/api/read', function (req, res) {
  var text, print, test,i,j;
  text = "./read.sh";
  print = ' ';
  peer=req.body.peerwrite.toString();
  org=req.body.orgwrite.toString();
  test = text + " " + peer + " "+ org;
  console.log('command: ' + test);
  console.log('cwd: ' + process.cwd());

  const exec = require('child_process').exec 
  exec(test, (err, stdout, stderr) => {
	//process.stdout.write(stdout)
        if (err){
          console.error(`exec error: ${err}`);
	  res.json({msg: 'Command failed'});
          return;
          }
     else{
	console.log('output: ' + stdout);
        for(i=0;i< stdout.length;i++){
            if(stdout[i]=='['){
              j=i;
            }
            if (i>j){
		 print+=(stdout[i]);		
	    }

         }
	res.json({msg: print});
    }
        console.log(print);


	 });	
            
});

router.post('/api/down', function (req, res) {
  var text, invok, test;
  text = "./byfn.sh down";
  console.log('command: ' + text);
  console.log('cwd: ' + process.cwd());

  const exec = require('child_process').exec 
  exec(text, (err, stdout, stderr) => {
	//process.stdout.write(stdout)
        if (err){
          console.error(`exec error: ${err}`);
	  res.json({msg: 'Command failed'});
          return;
          }
	console.log('output: ' + stdout);
	res.json({msg: 'Command run successfuly'});

	 });
	console.log('finishing');
            
});

module.exports = router;
