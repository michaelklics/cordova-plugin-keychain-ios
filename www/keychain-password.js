
var KeychainPassword = function() {}

KeychainPassword.prototype.savePassword = function(accountName, password, onSuccess, onFailure) {
    if (onSuccess == null) {
      onSuccess = function() {};
    }
    if (onFailure == null) {
      onFailure = function() {};
    }

    cordova.exec(onSuccess, onFailure, "KeychainPassword", "savePassword", [[accountName, password]]);
}

KeychainPassword.prototype.renameAccount = function(oldAccountName, newAccountName, onSuccess, onFailure) {
    if (onSuccess == null) {
      onSuccess = function() {};
    }
    if (onFailure == null) {
      onFailure = function() {};
    }

    cordova.exec(onSuccess, onFailure, "KeychainPassword", "renameAccount", [[oldAccountName, newAccountName]]);
}

KeychainPassword.prototype.getPassword = function(accountName, onSuccess, onFailure) {
    if (onSuccess == null) {
      onSuccess = function() {};
    }
    if (onFailure == null) {
      onFailure = function() {};
    }

    cordova.exec(onSuccess, onFailure, "KeychainPassword", "getPassword", [[accountName]]);
}

KeychainPassword.prototype.updateKeychainConfiguration = function(service, accessGroup, onSuccess, onFailure) {
    var updates = [];
    if (onSuccess == null) {
      onSuccess = function() {};
    }
    if (onFailure == null) {
      onFailure = function() {};
    }

    if (accessGroup == null) {
      updates.push(service);
    } else {
      updates.push(service, accessGroup);
    }

    cordova.exec(onSuccess, onFailure, "KeychainPassword", "updateKeychainConfiguration", [updates]);
}

KeychainPassword.prototype.delete = function(accountName, onSuccess, onFailure) {
    if (onSuccess == null) {
      onSuccess = function() {};
    }
    if (onFailure == null) {
      onFailure = function() {};
    }

    cordova.exec(onSuccess, onFailure, "KeychainPassword", "delete", [[accountName]]);
}

//-------------------------------------------------------------------

if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.KeychainPassword) {
    window.plugins.KeychainPassword = new KeychainPassword();
}

if (typeof module != 'undefined' && module.exports) {
    module.exports = KeychainPassword;
}
