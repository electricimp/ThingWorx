// MIT License
//
// Copyright 2018 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

// This library allows your agent code to work with the ThingWorx platform (https://developer.thingworx.com/) 
// via the ThingWorx REST API (https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart).
//
// This version of the library supports the following functionality:
// - Access ThingWorx platform
// - Thing creation and deletion
// - Thing Property creation
// - Setting a value of Thing Property
//
// All requests that are made to the ThingWorx platform occur asynchronously.
// Every method that sends a request has an optional parameter which takes a callback function that will be
// executed when the operation is completed, whether successfully or not.
// Every callback has at least one parameter, error. If error is null, the operation has been executed successfully.
// Otherwise, error is an instance of the ThingWorxError class and contains the details of the error.

// ThingWorx library operation error types
enum THING_WORX_ERROR {
    // the library detects an error, e.g. the library is wrongly initialized or
    // a method is called with invalid argument(s). The error details can be
    // found in the error.details value
    LIBRARY_ERROR,
    // HTTP request to ThingWorx failed. The error details can be found in
    // the error.httpStatus and error.httpResponse properties
    REQUEST_FAILED,
    // Unexpected response from ThingWorx. The error details can be found in
    // the error.details and error.httpResponse properties
    UNEXPECTED_RESPONSE
};

// Error details produced by the library
const THING_WORX_REQUEST_FAILED = "ThingWorx request failed with status code";
const THING_WORX_NON_EMPTY_ARG = "Non empty argument required";

// Internal library constants
const _THING_WORX_CREATE_THING_PATH = "Resources/EntityServices/Services/CreateThing";
const _THING_WORX_THING_PATH = "Things/%s";
const _THING_WORX_ENABLE_THING_PATH = "Things/%s/Services/EnableThing";
const _THING_WORX_RESTART_THING_PATH = "Things/%s/Services/RestartThing";
const _THING_WORX_CREATE_THING_PROPERTY_PATH = "Things/%s/Services/AddPropertyDefinition";
const _THING_WORX_SET_PROPERTY_VALUE_PATH = "Things/%s/Properties/%s";
const _THING_WORX_THING_TEMPLATE_DEFAULT = "GenericThing";

class ThingWorx {
    static VERSION = "1.0.0";

    _endpoint = null;
    _appKey = null;
    _debug = null;

    // ThingWorx class constructor.
    //
    // Parameters:
    //     endpoint : string         ThingWorx platform endpoint. Must include the scheme.
    //                               Example: "https://PP-1802281448E8.Devportal.Ptc.Io".
    //     appKey : string           ThingWorx Application Key.
    //                               See https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/create-appkey
    //
    // Returns:                      ThingWorx instance created.
    constructor(endpoint, appKey) {
        _endpoint = endpoint;
        _appKey = appKey;
    }

    // Creates a new Thing, enables and restarts it.
    // See https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/use-rest-api-create-new-thing
    //
    // Parameters:
    //     thingName : string        Name of the new Thing.
    //                               Must be unique across the ThingWorx platform instance.
    //     thingTemplateName :       A Thing Template which may be used for the Thing creation.
    //         string                See https://developer.thingworx.com/resources/guides/thingworx-foundation-quickstart/thing-template
    //         (optional)            If not specified, the standard ThingWorx "GenericThing"
    //                               template is used.
    //     callback : function       Optional callback function executed once the operation
    //         (optional)            is completed.
    //                               The callback signature:
    //                               callback(error), where
    //                                   error :               Error details,
    //                                     ThingWorxError      or null if the operation succeeds.
    //
    // Returns:                      Nothing
    function createThing(thingName, thingTemplateName = null, callback = null) {
        if (!_validateNonEmptyArg(thingName, "thingName", callback)) {
            return;
        }
        if (typeof thingTemplateName == "function") {
            callback = thingTemplateName;
            thingTemplateName = null;
        }
        local body = {
            "name" : thingName,
            "thingTemplateName" : thingTemplateName ? thingTemplateName : _THING_WORX_THING_TEMPLATE_DEFAULT
        };
        _processRequest("POST", _THING_WORX_CREATE_THING_PATH, body, function (error) {
            if (error) {
                _invokeDefaultCallback(callback, error);
            } else {
                _activateThing(thingName, callback);
            }
        }.bindenv(this));
    }
    
    // Checks if Thing with the specified name exists.
    //
    // Parameters:
    //     thingName : string        Name of the Thing.
    //     callback : function       Optional callback function executed once the operation
    //         (optional)            is completed.
    //                               The callback signature:
    //                               callback(error), where
    //                                   error :               Error details,
    //                                     ThingWorxError      or null if the operation succeeds.
    //                                   exist :               true if the Thing exists;
    //                                     boolean             false if the Thing does not exist
    //                                                         or the operation fails.
    //
    // Returns:                      Nothing
    function existThing(thingName, callback) {
        if (!_validateNonEmptyArg(thingName, "thingName", callback, _invokeExistCallback)) {
            return;
        }
        _processRequest("GET", format(_THING_WORX_THING_PATH, thingName), null, function (error) {
            local exist = error ? false : true;
            if (error && error.type == THING_WORX_ERROR.REQUEST_FAILED && error.httpStatus == 404) {
                error = null;
            }
            _invokeExistCallback(callback, error, exist);
        }.bindenv(this));
    }
    
    // Deletes Thing with the specified name.
    //
    // Parameters:
    //     thingName : string        Name of the Thing.
    //     callback : function       Optional callback function executed once the operation
    //         (optional)            is completed.
    //                               The callback signature:
    //                               callback(error), where
    //                                   error :               Error details,
    //                                     ThingWorxError      or null if the operation succeeds.
    //
    // Returns:                      Nothing
    function deleteThing(thingName, callback = null) {
        if (!_validateNonEmptyArg(thingName, "thingName", callback)) {
            return;
        }
        _processRequest("DELETE", format(_THING_WORX_THING_PATH, thingName), null, callback);
    }
    
    // This method creates a new Property of the specified Thing and restarts the Thing.
    // See https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/use-rest-api-add-property-thing
    //
    // Parameters:
    //     thingName : string        Name of the Thing.
    //     propertyName : string     Name of the new Property.
    //                               Must be unique across the specified Thing.
    //     propertyType : string     Type of the new Property.
    //                               One of the types described here:
    //                               https://support.ptc.com/cs/help/thingworx_hc/thingworx_7.0_hc/index.jspx?id=ThingProperties&action=show
    //     callback : function       Optional callback function executed once the operation
    //         (optional)            is completed.
    //                               The callback signature:
    //                               callback(error), where
    //                                   error :               Error details,
    //                                     ThingWorxError      or null if the operation succeeds.
    //
    // Returns:                      Nothing
    function createThingProperty(thingName, propertyName, propertyType, callback = null) {
        if (!_validateNonEmptyArgs({
                "thingName" : thingName,
                "propertyName" : propertyName,
                "propertyType" : propertyType
            }, callback)) {
            return;
        }
        local body = {
            "name" : propertyName,
            "type": propertyType
        };
        _processRequest("POST", format(_THING_WORX_CREATE_THING_PROPERTY_PATH, thingName), body, function (error) {
            if (error) {
                _invokeDefaultCallback(callback, error);
            } else {
                _restartThing(thingName, callback);
            }
        }.bindenv(this));
    }

    // This method sets a new value of the specified Property.
    // See https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/use-rest-api-set-property-value
    //
    // Parameters:
    //     thingName : string        Name of the Thing.
    //     propertyName : string     Name of the Property.
    //     propertyValue :           New value of the Property.
    //         boolean, integer,
    //         float, string,
    //         table or blob
    //     callback : function       Optional callback function executed once the operation
    //         (optional)            is completed.
    //                               The callback signature:
    //                               callback(error), where
    //                                   error :               Error details,
    //                                     ThingWorxError      or null if the operation succeeds.
    //
    // Returns:                      Nothing
    function setPropertyValue(thingName, propertyName, propertyValue, callback = null) {
        if (!_validateNonEmptyArgs({ "thingName" : thingName, "propertyName" : propertyName }, callback)) {
            return;
        }
        local body = {};
        body[propertyName] <- typeof propertyValue == "blob" ? http.base64encode(propertyValue) : propertyValue;
        _processRequest("PUT", format(_THING_WORX_SET_PROPERTY_VALUE_PATH, thingName, propertyName), body, callback);
    }

    // Enables/disables the library debug output (including errors logging).
    // Disabled by default.
    //
    // Parameters:
    //     value : boolean             true to enable, false to disable
    function setDebug(value) {
        _debug = value;
    }

    // -------------------- PRIVATE METHODS -------------------- //

    // Activates Thing: enables and restarts it.
    function _activateThing(thingName, callback) {
        _processRequest("POST", format(_THING_WORX_ENABLE_THING_PATH, thingName), null, function (error) {
            if (error) {
                _invokeDefaultCallback(callback, error);
            } else {
                _restartThing(thingName, callback);
            }
        }.bindenv(this));
    }
    
    // Restarts Thing.
    function _restartThing(thingName, callback) {
        _processRequest("POST", format(_THING_WORX_RESTART_THING_PATH, thingName), null, callback);
    }

    // Sends an http request to ThingWorx.
    function _processRequest(method, path, body, callback) {
        if (!_validateNonEmptyArgs({ "endpoint" : _endpoint, "appKey" : _appKey }, callback)) {
            return;
        }
        local url = format("%s/Thingworx/%s", _endpoint, path);
        local encodedBody = http.jsonencode(body);
        _logDebug(format("Doing the request: %s %s, body: %s", method, url, encodedBody));
        
        local headers = {
            "Content-Type" : "application/json",
            "Accept" : "application/json",
            "appKey" : _appKey
        };
        local request = http.request(method, url, headers, encodedBody);
        request.sendasync(function (response) {
            _processResponse(response, callback);
        }.bindenv(this));
    }

    // Processes http response from ThingWorx and executes callback if specified.
    function _processResponse(response, callback) {
        _logDebug(format("Response status: %d, body: %s", response.statuscode, response.body));
        local errType = null;
        local errDetails = null;
        local httpStatus = response.statuscode;
        if (httpStatus < 200 || httpStatus >= 300) {
            errType = THING_WORX_ERROR.REQUEST_FAILED;
            errDetails = format("%s: %i", THING_WORX_REQUEST_FAILED, httpStatus);
            try {
                response.body = (response.body == "") ? {} : http.jsondecode(response.body);
            } catch (e) {
                _logError(e);
            }
        }

        local error = errType ? ThingWorxError(errType, errDetails, httpStatus, response.body) : null;
        _invokeDefaultCallback(callback, error);
    }

    // Validates the argument is not empty. Invokes callback with THING_WORX_ERROR.LIBRARY_ERROR if the check failed.
    function _validateNonEmptyArg(arg, argName, callback, invokeCallback = null) {
        if (arg == null || typeof arg == "string" && arg.len() == 0) {
            local error = ThingWorxError(
                THING_WORX_ERROR.LIBRARY_ERROR,
                format("%s: %s", THING_WORX_NON_EMPTY_ARG, argName));
            if (!invokeCallback) {
                invokeCallback = _invokeDefaultCallback;
            }
            invokeCallback(callback, error);
            return false;
        }
        return true;
    }

    // Validates the arguments are not empty. Invokes callback with THING_WORX_ERROR.LIBRARY_ERROR if the check failed.
    function _validateNonEmptyArgs(args, callback, invokeCallback = null) {
        foreach (argName, arg in args) {
            if (!_validateNonEmptyArg(arg, argName, callback, invokeCallback)) {
                return false;
            }
        }
        return true;
    }

    // Logs error occurred and invokes default callback with single error parameter.
    function _invokeDefaultCallback(callback, error) {
        if (error) {
            _logError(error.details);
        }
        if (callback) {
            imp.wakeup(0, function () {
                callback(error);
            });
        }
    }

    // Invokes existThing method callback.
    function _invokeExistCallback(callback, error, exist = false) {
        if (callback) {
            imp.wakeup(0, function () {
                callback(error, exist);
            });
        }
    }

    // Logs error occurred during the library methods execution.
    function _logError(message) {
        if (_debug) {
            server.error("[ThingWorx] " + message);
        }
    }

    // Logs debug messages occurred during the library methods execution.
    function _logDebug(message) {
        if (_debug) {
            server.log("[ThingWorx] " + message);
        }
    }
}

// Auxiliary class, represents error returned by the library.
class ThingWorxError {
    // error type, one of the THING_WORX_ERROR enum values
    type = null;

    // human readable details of the error (string)
    details = null;

    // HTTP status code (integer),
    // null if type is THING_WORX_ERROR.LIBRARY_ERROR
    httpStatus = null;

    // Response body of the failed request (table),
    // null if type is THING_WORX_ERROR.LIBRARY_ERROR
    httpResponse = null;

    constructor(type, details, httpStatus = null, httpResponse = null) {
        this.type = type;
        this.details = details;
        this.httpStatus = httpStatus;
        this.httpResponse = httpResponse;
    }
}
