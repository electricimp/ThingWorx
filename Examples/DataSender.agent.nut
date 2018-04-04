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

#require "ThingWorx.agent.lib.nut:1.0.0"

// ThingWorx library example.
// Creates a ThingWorx Thing with two predefined Properties if it does not exist
// (thing name is specified as constructor argument) and periodically updates the properties values.
// Properties contain integer incremental value, converted to string and data measurement time 
// in seconds since the epoch.
// Properties values are updated every 10 seconds.

const UPDATE_DATA_PERIOD = 10.0;

const THING_NAME = "test_thing";
const THING_PROPERTY_DATA_NAME = "data";
const THING_PROPERTY_DATA_TYPE = "STRING";
const THING_PROPERTY_MEASURE_TIME_NAME = "measure_time";
const THING_PROPERTY_MEASURE_TIME_TYPE = "INTEGER";

class DataSender {
    _counter = 0;
    _thingWorxClient = null;
    _thingName = null;

    constructor(endpoint, appKey, thingName) {
        _thingWorxClient = ThingWorx(endpoint, appKey);
        _thingName = thingName;
    }

    // Creates ThingWorx client, creates Thing if it doesn't exist and starts properties values update
    function start() {
        _thingWorxClient.existThing(_thingName, function (error, exist) {
            if (error) {
                server.error("ThingWorx existThing failed: " + error.details);
            } else if (!exist) {
                createThing(updatePropertiesValues);
            } else {
                updatePropertiesValues();
            }
        }.bindenv(this));
    }

    // Creates ThingWorx Thing
    function createThing(callback) {
        _thingWorxClient.createThing(_thingName, null, function (error) {
            if (error) {
                server.error("ThingWorx createThing failed: " + error.details);
            } else {
                createThingProperties(callback);
            }
        }.bindenv(this));
    }

    // Creates ThingWorx Thing Properties
    function createThingProperties(callback) {
        createThingProperty(THING_PROPERTY_DATA_NAME, THING_PROPERTY_DATA_TYPE, function () {
            createThingProperty(THING_PROPERTY_MEASURE_TIME_NAME, THING_PROPERTY_MEASURE_TIME_TYPE, callback);
        }.bindenv(this));
    }

    function createThingProperty(propertyName, propertyType, callback) {
        _thingWorxClient.createThingProperty(_thingName, propertyName, propertyType, function (error) {
            if (error) {
                server.error("ThingWorx createThingProperty failed: " + error.details);
            } else {
                callback();
            }
        }.bindenv(this));
    }

    // Returns a data to be set for ThingWorx Properties
    function getData() {
        _counter++;
        local result = {};
        result[THING_PROPERTY_DATA_NAME] <- _counter.tostring();
        result[THING_PROPERTY_MEASURE_TIME_NAME] <- time();
        return result;
    }

    // Periodically updates Properties values
    function updatePropertiesValues() {
        local values = getData();
        setPropertyValue(THING_PROPERTY_DATA_NAME, values[THING_PROPERTY_DATA_NAME], function() {
            setPropertyValue(THING_PROPERTY_MEASURE_TIME_NAME, values[THING_PROPERTY_MEASURE_TIME_NAME], function() {
                server.log("Property values updated successfully: " + http.jsonencode(values));
            }.bindenv(this));
        }.bindenv(this));

        imp.wakeup(UPDATE_DATA_PERIOD, function () {
            updatePropertiesValues();
        }.bindenv(this));
    }

    // Updates value of the specified ThingWorx property
    function setPropertyValue(propertyName, propertyValue, callback) {
        _thingWorxClient.setPropertyValue(_thingName, propertyName, propertyValue, function (error) {
            if (error) {
                server.error("ThingWorx setPropertyValue failed: " + error.details);
            } else {
                callback();
            }
        }.bindenv(this));
    }
}

// RUNTIME
// ---------------------------------------------------------------------------------

// ThingWorx constants
// ---------------------------------------------------------------------------------
const THING_WORX_ENDPOINT = "<YOUR_THING_WORX_ENDPOINT>";
const THING_WORX_APPLICATION_KEY = "<YOUR_THING_WORX_APPLICATION_KEY>";

// Start application
dataSender <- DataSender(THING_WORX_ENDPOINT, THING_WORX_APPLICATION_KEY, THING_NAME);
dataSender.start();
