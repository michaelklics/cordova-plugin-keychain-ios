/*
Copyright 2020 Swiftable, LLC. <contact@swiftable.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
var app = {

    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    onDeviceReady: function() {
        this.receivedEvent('deviceready');

        var keychain = window.plugins.KeychainPassword

        keychain.updateKeychainConfiguration("Coardova App Keychain", null, function(json) {
            console.log("Update Keychain Configuration: Success");
            console.log(json);
        }, function(json){
            console.log("Update Keychain Configuration: Failure");
            console.log(json);
        });

        keychain.savePassword("Account Name", "Password", function(json) {
            console.log("Store Passsword: Success");
            console.log(json);
        }, function(json){
            console.log("Store Passsword: Failure");
            console.log(json);
        });

        keychain.getPassword("Account Name", function(json) {
            console.log("Get Password: Success");
            console.log(json);
        }, function(json){
            console.log("Get Password: Failure");
            console.log(json);
        });

        keychain.renameAccount("Account Name", "New Account Name", function(json) {
            console.log("Rename Account: Success");
            console.log(json);
        }, function(json){
            console.log("Rename Account: Failure");
            console.log(json);
        });

        keychain.getPassword("New Account Name", function(json) {
            console.log("Get Password: Success");
            console.log(json);
        }, function(json){
            console.log("Get Password: Failure");
            console.log(json);
        });

        keychain.delete("New Account Name", function(json) {
            console.log("Delete: Success");
            console.log(json);
        }, function(json){
            console.log("Delete: Failure");
            console.log(json);
        });

        keychain.getPassword("New Account Name", function(json) {
            console.log("Get Password: Success");
            console.log(json);
        }, function(json){
            console.log("Get Password: Failure");
            console.log(json);
        });

    },

    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();
