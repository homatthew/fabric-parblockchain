'use strict'

var path = require('path')
var Fabric_Client = require('fabric-client');


function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = class Client {
    constructor(username, channel, peer_addr, peer_port, orderer_addr, orderer_port, timeout) {
        this.username = username;
        this.channelname = channel;
        this.peer_addr = peer_addr;
        this.peer_port = peer_port;
        this.orderer_addr = orderer_addr;
        this.orderer_port = orderer_port;
        this.member_user = null;
        this.timeout = timeout;

        this.store_path = path.join(__dirname, 'hfc-key-store');

        this.fabric_client = new Fabric_Client();
        this.channel = this.fabric_client.newChannel(this.channelname);
        this.peer = this.fabric_client.newPeer('grpc://' + this.peer_addr + ':' + this.peer_port);
        this.channel.addPeer(this.peer);
        this.orderer = this.fabric_client.newOrderer('grpc://' + this.orderer_addr + ':' + this.orderer_port);
        this.channel.addOrderer(this.orderer);

        this.init = Fabric_Client.newDefaultKeyValueStore({ path: this.store_path
        }).then((state_store) => {
            // assign the store to the fabric client
            this.fabric_client.setStateStore(state_store);
            var crypto_suite = Fabric_Client.newCryptoSuite();
            // use the same location for the state store (where the users' certificate are kept)
            // and the crypto store (where the users' keys are kept)
            var crypto_store = Fabric_Client.newCryptoKeyStore({path: this.store_path});
            crypto_suite.setCryptoKeyStore(crypto_store);
            this.fabric_client.setCryptoSuite(crypto_suite);

            // get the enrolled user from persistence, this user will sign all requests
            return this.fabric_client.getUserContext(this.username, true);
        }).then((user_from_store) => {
            if (user_from_store && user_from_store.isEnrolled()) {
                // console.log('Successfully loaded user1 from persistence');
                this.member_user = user_from_store;
                return Promise.resolve('successfully loaded client from persistence...');
            } else {
                return Promise.reject(new Error('Failed to get user1.... run registerUser.js'));
            }
        });
    }

    query(chaincodeId, key) {
        this.init.then(() => {
            var request = {
                chaincodeId: chaincodeId,
                fcn: 'query',
                args: [key]
            };

            return this.channel.queryByChaincode(request);
        }).then((query_response) => {
            if (query_response && query_response.length ==1) {
                if (query_response[0] instanceof Error) {
                    console.log('error from query = ' + query_response[0]);
                } else {
                    // console.log('Query response = ' +  query_response[0].toString());
                }
            } else {
                console.log('no payload returned by the chaincode');
            }
        }).catch((err) => {
            console.log('Error executing query chaincode:' + err);
        });
    }

    invoke(chaincodeId, fcn, args) {
        this.init.then(() => {
            var tx_id = this.fabric_client.newTransactionID();
            var request = {
                chaincodeId: chaincodeId,
                fcn: fcn,
                args: args,
                chainId: this.channelname,
                txId: tx_id
            };

            var endorsed = this.channel.sendTransactionProposal(request, this.timeout);
            endorsed.then((results) => {
                var proposalResponses = results[0];
                var proposal = results[1];
                let isProposalGood = false;
                if (proposalResponses && proposalResponses[0].response &&
                    proposalResponses[0].response.status === 200) {
                    // console.log('Transaction Proposal was good');
                    isProposalGood = true;
                }

                var request = {
                    proposalResponses: proposalResponses,
                    proposal: proposal
                };

                // var transaction_id_string = tx_id.getTransactionID();

                // var promises = [];

                var sendPromise = this.channel.sendTransaction(request);

                // promises.push(sendPromise);
                //
                // let event_hub = this.channel.newChannelEventHub(this.peer);
                //
                // let txPromise = new Promise((resolve, reject) => {
                //     let handle = setTimeout(() => {
                //         event_hub.unregisterTxEvent(transaction_id_string);
                //         event_hub.disconnect();
                //         resolve({event_status : 'TIMEOUT'}); //we could use reject(new Error('Trnasaction did not complete within 30 seconds'));
                //     }, this.timeout);
                //     event_hub.registerTxEvent(transaction_id_string, (tx, code) => {
                //         // this is the callback for transaction event status
                //         // first some clean up of event listener
                //         clearTimeout(handle);
                //
                //         // now let the application know what happened
                //         var return_status = {event_status : code, tx_id : transaction_id_string};
                //         if (code !== 'VALID') {
                //             console.error('The transaction was invalid, code = ' + code);
                //             resolve(return_status); // we could use reject(new Error('Problem with the tranaction, event status ::'+code));
                //         } else {
                //             console.log('The transaction has been committed on peer ' + event_hub.getPeerAddr());
                //             resolve(return_status);
                //         }
                //     }, (err) => {
                //         //this is the callback if something goes wrong with the event registration or processing
                //         reject(new Error('There was a problem with the eventhub ::'+err));
                //     },
                //         {disconnect: true} //disconnect when complete
                //     );
                //     event_hub.connect();
                //
                // });
                // promises.push(txPromise);
                //
                // return Promise.all(promises);
                //
                return Promise.resolve();

            }).catch((err) => {
                return Promise.reject(new Error('endorsement failure'));
            });

        }).catch((err) => {
            console.error('Promise rejected');
            console.error(err);
        });
    }
}
