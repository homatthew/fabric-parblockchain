var Admin = require('./admin.js');
var Client = require('./client.js');
var NanoTimer = require('nanotimer');
var Prob = require('prob.js')

var args = require('minimist')(process.argv.slice(2), {
  string: ['bmark', 'user', 'canname', 'caaddr', 'mspid', 'channelName', 'paddr', 'oaddr', 'gap'],
  default: {
    timeout: 5000,
    gap: '10000u',
    duration: '10s',
  },
});

if (args.bmark == "smallbank") {
  if(args.transact == undefined
    || args.deposit == undefined
    || args.payment == undefined
    || args.zipfs == undefined
    || args.check == undefined
    || args.amalgamate == undefined
    || args.query == undefined
    || args.user == undefined
    || args.caaddr == undefined
    || args.mspid == undefined
    || args.channelName == undefined
    || args.paddr == undefined
    || args.naccounts == undefined
    || args.pport == undefined
    || args.oaddr == undefined
    || args.oport == undefined) {
    console.log(
      `Invalid arguments:
      must pass following arguments:
      --caname=[ca-name]
      --caaddr=[ca-addr]
      --caport=[ca-port]
      --mspid=[OrgMSP-ID]
      --channelName[channel-name]
      --user[userid]
      --naccounts=[total-number-of-accounts]
      --paddr=[peer-address]
      --pport=[peer-port]
      --oaddr=[orderer-addr]
      --oport=[orderer-port]
      --transact=[transaction-percent, {percent of transaction-type transactions}]
      --deposit=[deposit-percent, {percent of deposit transactions}]
      --payment=[payment-percent, {percent of payment-type transactions}]
      --check=[check-percent, {percent of check-type transactions}]
      --amalgamate=[amalgamate-percent, {percent of amalgamate-type transactions}]
      --query=[query-percent, {percent of query-type transactions}]
      --zipfs=[s of zipf's distribution]
      optional arguments:
      --timeout=[endorsement-timeout, default=5000ms],
      --gap=[fire-transaction-after, default='10000u' {use s, u and n to specify time in seconds, microseconds and nanoseconds}]
      --duration=[benchmark-duration]`
    );
    process.exit(1);
  }
} else {
  if (args.caname == undefined
    || args.user == undefined
    || args.caaddr == undefined
    || args.readWrite == undefined
    || args.readPer == undefined
    || args.writePer == undefined
    || args.hotness == undefined
    || args.mspid == undefined
    || args.channelName == undefined
    || args.paddr == undefined
    || args.naccounts == undefined
    || args.pport == undefined
    || args.oaddr == undefined
    || args.oport == undefined) {

    console.log(
      `Invalid arguments:
      must pass following arguments:
      --caname=[ca-name]
      --caaddr=[ca-addr]
      --caport=[ca-port]
      --mspid=[OrgMSP-ID]
      --channelName[channel-name]
      --user[userid]
      --naccounts=[total-number-of-accounts]
      --paddr=[peer-address]
      --pport=[peer-port]
      --oaddr=[orderer-addr]
      --oport=[orderer-port]
      --readWrite=[rw-count]
      --hotness=[no-of-hot]
      --readPer=[%-hot-read]
      --writePer=[%-hot-write]
      optional arguments:
      --timeout=[endorsement-timeout, default=5000ms],
      --gap=[fire-transaction-after, default='10000u' {use s, u and n to specify time in seconds, microseconds and nanoseconds}]
      --duration=[benchmark-duration]`
    );
    process.exit(1);
  }
}

console.log(args);

var channel = args.channelName;
var user = args.user;
var chaincodeId = channel + 'c';
var client = null;

var distribution = [];
if(args.bmark == "smallbank") {
  distribution.push(args.transact);
  distribution.push(args.transact + args.deposit);
  distribution.push(args.transact + args.deposit + args.payment);
  distribution.push(args.transact + args.deposit + args.payment + args.check);
  distribution.push(args.transact + args.deposit + args.payment + args.check + args.amalgamate);
  distribution.push(args.transact + args.deposit + args.payment + args.check + args.amalgamate + args.query);

}

function getNextAccountUniform(max_account, percent) {
  var random = Math.floor(Math.random()*100) + 1;
  var next_n;
  if (random < percent) {
    next_n = Math.floor((Math.random() * args.hotness * max_account));
  } else {
    next_n = Math.floor((Math.random() *(1 - args.hotness) + args.hotness) * max_account);
  }
  return 'acc' + next_n;
}

function getNextAccountZipf(max_account) {
  if(typeof getNextAccountZipf.f == 'undefined') {
    getNextAccountZipf.f = Prob.zipf(args.zipfs, max_account)
  }

  var next_n;
  next_n = getNextAccountZipf.f();
  return 'acc' + next_n;

}

function finish_benchmark(timer) {
  timer.clearTimeout();
  console.log('benchmark ran for ' + args.duration);
  process.exit(0);
}

function fire_smallbank() {
  var acc1, acc2;
  acc1 = getNextAccountZipf(args.naccounts);
  acc2 = acc1;
  while(acc1 === acc2) {
    acc2 = getNextAccountZipf(args.naccounts);
  }

  let op_index =  Math.floor(Math.random() * 100);
  let amount = Math.floor(Math.random() * 200);
  var amountStr = amount.toString()

  // console.log(op_index);

  if(op_index < distribution[0]) {
    client.invoke(chaincodeId, 'transact_savings', [amountStr, acc1]);
  } else if( op_index < distribution[1]) {
    client.invoke(chaincodeId, 'deposit_checking', [amountStr, acc1]);
  } else if(op_index < distribution[2]) {
    client.invoke(chaincodeId, 'send_payment', [amountStr, acc1, acc2]);
  } else if(op_index < distribution[3]) {
    client.invoke(chaincodeId, 'write_check', [amountStr, acc1]);
  } else if(op_index < distribution[4]) {
    client.invoke(chaincodeId, 'amalgamate', [acc1, acc2]);
  } else if(op_index < distribution[5]) {
    client.invoke(chaincodeId, 'query', [acc1]);
  }
}

function fire_readwrite() {
  let rwCount = args.readWrite;
  let rwCountString = rwCount.toString();
  var read = [];
  var write = [];
  var zer = "0";
  var i;
  for (i = 0 ; i < rwCount; i++) {
    read.push(getNextAccountUniform(args.naccounts, args.readPer));
  }
  for (i = 0 ; i < rwCount; i++) {
    write.push(getNextAccountUniform(args.naccounts, args.writePer));
  }

  switch (rwCount) {
    case 2:
      client.invoke(chaincodeId, 'readwrite', [rwCountString, read[0], read[1], rwCountString, write[0], write[1]]);
      break;
    case 4:
      client.invoke(chaincodeId, 'readwrite', [rwCountString, read[0], read[1], read[2], read[3], rwCountString, write[0], write[1], write[2], write[3]]);
      break;
    case 8:
      client.invoke(chaincodeId, 'readwrite', [rwCountString, read[0], read[1], read[2], read[3], read[4], read[5], read[6], read[7], rwCountString, write[0], write[1], write[2], write[3], write[4], write[5], write[6], write[7]]);
      break;
  }
}

/*
 * Fire transactions at a given rate for 1 second
 * */
function main() {
  console.log('starting benchmark...');
  var timer = new NanoTimer();

  if args.bmark == 'smallbank' {
    timer.setInterval(fire_smallbank, '', args.gap);
  } else {
    timer.setInterval(fire_readwrite, '', args.gap);
  }

  timer.setTimeout(function (t) {
    t.clearTimeout();
  }, [timer], args.duration);
}

var admin = new Admin(args.caname, args.caaddr, args.caport, args.mspid);
admin.registerUser(user);

setTimeout(function() {
  client = new Client(user, channel, args.paddr, args.pport, args.oaddr, args.oport, args.timeout);
  main();
}, 5000);
