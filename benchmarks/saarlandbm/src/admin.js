'use strict'

var path = require('path')
var Fabric_Client = require('fabric-client')
var Fabric_CA_Client = require('fabric-ca-client')

module.exports = class Admin {
    constructor(ca_name, ca_address, port, mspid) {
        this.ca_name = ca_name;
        this.ca_address = ca_address;
        this.ca_port = port;
        this.fabric_client = new Fabric_Client();
        this.fabric_ca_client = null;
        this.admin_user = null;
        this.mspid = mspid;
        this.member_user = null;
        this.admin_init = null;
        this.store_path = path.join(__dirname, 'hfc-key-store');
    
        // create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
        this.admin_init = Fabric_Client.newDefaultKeyValueStore({ path: this.store_path
        }).then((state_store) => {
            // assign the store to the fabric client
            this.fabric_client.setStateStore(state_store);
            var crypto_suite = Fabric_Client.newCryptoSuite();
            // use the same location for the state store (where the users' certificate are kept)
            // and the crypto store (where the users' keys are kept)
            var crypto_store = Fabric_Client.newCryptoKeyStore({path: this.store_path});
            crypto_suite.setCryptoKeyStore(crypto_store);
            this.fabric_client.setCryptoSuite(crypto_suite);
            var	tlsOptions = {
                trustedRoots: [],
                verify: false
            };
            // be sure to change the http to https when the CA is running TLS enabled
            this.fabric_ca_client = new Fabric_CA_Client('http://' + this.ca_address + ':' + this.ca_port, tlsOptions , this.ca_name, crypto_suite);

            // first check to see if the admin is already enrolled
            return this.fabric_client.getUserContext('admin', true);
        }).then((user_from_store) => {
            if (user_from_store && user_from_store.isEnrolled()) {
                console.log('Successfully loaded admin from persistence');
                this.admin_user = user_from_store;
                return null;
            } else {
                // need to enroll it with CA server
                return this.fabric_ca_client.enroll({
                    enrollmentID: 'admin',
                    enrollmentSecret: 'adminpw'
                }).then((enrollment) => {
                    console.log('Successfully enrolled admin user "admin"');
                    return this.fabric_client.createUser(
                        {
                            username: 'admin',
                            mspid: this.mspid,
                            cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
                        });
                }).then((user) => {
                    this.admin_user = user;
                    return this.fabric_client.setUserContext(this.admin_user);
                }).catch((err) => {
                    console.error('Failed to enroll and persist admin. Error: ' + err.stack ? err.stack : err);
                    throw new Error('Failed to enroll admin');
                });
            }
        }).then(() => {
            console.log('Assigned the admin user to the fabric client ::' + this.admin_user.toString());
            return Promise.resolve();
        }).catch((err) => {
            console.error('Failed to enroll admin: ' + err);
            return Promise.reject(new Error('cannot enroll admin account'));
        });

    }

    registerUser(username) {
        this.admin_init.then(() => {
            Fabric_Client.newDefaultKeyValueStore({ path: this.store_path
            }).then((state_store) => {
                // assign the store to the fabric client
                this.fabric_client.setStateStore(state_store);
                var crypto_suite = Fabric_Client.newCryptoSuite();
                // use the same location for the state store (where the users' certificate are kept)
                // and the crypto store (where the users' keys are kept)
                var crypto_store = Fabric_Client.newCryptoKeyStore({path: this.store_path});
                crypto_suite.setCryptoKeyStore(crypto_store);
                this.fabric_client.setCryptoSuite(crypto_suite);
                var	tlsOptions = {
                    trustedRoots: [],
                    verify: false
                };
                // be sure to change the http to https when the CA is running TLS enabled
                this.fabric_ca_client = new Fabric_CA_Client('http://' + this.ca_address + ':' + this.ca_port, null , '', crypto_suite);

                // first check to see if the admin is already enrolled
                return this.fabric_client.getUserContext('admin', true);
            }).then((user_from_store) => {
                if (user_from_store && user_from_store.isEnrolled()) {
                    // console.log('Successfully loaded admin from persistence');
                    this.admin_user = user_from_store;
                } else {
                    throw new Error('Failed to get admin.... run enrollAdmin.js');
                }

                // at this point we should have the admin user
                // first need to register the user with the CA server
                var affiliation = null;
                if (this.mspid === 'Org1MSP') {
                    affiliation = 'org1.department1';
                } else  {
                    affiliation = 'org2.department2';
                }
                return this.fabric_ca_client.register({enrollmentID: username, affiliation: affiliation,role: 'client'}, this.admin_user);
            }).then((secret) => {
                // next we need to enroll the user with CA server
                // console.log('Successfully registered ' + username + ' - secret:'+ secret);

                return this.fabric_ca_client.enroll({enrollmentID: username, enrollmentSecret: secret});
            }).then((enrollment) => {
                // console.log('Successfully enrolled member user:' + username);
                return this.fabric_client.createUser(
                    {
                        username: username,
                        mspid: this.mspid,
                        cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
                    });
            }).then((user) => {
                this.member_user = user;

                return this.fabric_client.setUserContext(this.member_user);
            }).then(()=>{
                console.log(username + ' was successfully registered and enrolled and is ready to interact with the fabric network');
                return Promise.resolve();
            }).catch((err) => {
                console.error('Failed to register: ' + err);
                if(err.toString().indexOf('Authorization') > -1) {
                    console.error('Authorization failures may be caused by having admin credentials from a previous CA instance.\n' +
                        'Try again after deleting the contents of the store directory '+ this.store_path);
                }
                return Promise.reject(new Error('Cannot register client'));
            });
        });
    }
}
