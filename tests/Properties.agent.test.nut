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

const THING_WORX_ENDPOINT = "@{THING_WORX_ENDPOINT}";
const THING_WORX_APPLICATION_KEY = "@{THING_WORX_APPLICATION_KEY}";

const TEST_THING_NAME = "__imptest_thing";
const TEST_PROPERTY_STRING = "__imptest_property_string";
const TEST_PROPERTY_INTEGER = "__imptest_property_integer";
const TEST_PROPERTY_BOOLEAN = "__imptest_property_boolean";
const TEST_PROPERTY_NUMBER = "__imptest_property_number";
const TEST_PROPERTY_JSON = "__imptest_property_json";
const TEST_PROPERTY_BLOB = "__imptest_property_blob";

// Test case for Thing property methods of ThingWorx library (createThingProperty, setPropertyValue)
class PropertiesTestCase extends ImpTestCase {
    _thingWorxClient = null;

    function setUp() {
        _thingWorxClient = ThingWorx(THING_WORX_ENDPOINT, THING_WORX_APPLICATION_KEY);
        // clean up Things to be created, if exists
        return tearDown();
    }

    function tearDown() {
        return _deleteThing();
    }

    function testCreatePropertiesAndSetValues() {
        return _createThing()
            .then(function (value) {
                return _createThingProperty(TEST_PROPERTY_STRING, "STRING");
            }.bindenv(this))
            .then(function (value) {
                return _createThingProperty(TEST_PROPERTY_INTEGER, "INTEGER");
            }.bindenv(this))
            .then(function (value) {
                return _createThingProperty(TEST_PROPERTY_BOOLEAN, "BOOLEAN");
            }.bindenv(this))
            .then(function (value) {
                return _createThingProperty(TEST_PROPERTY_NUMBER, "NUMBER");
            }.bindenv(this))
            .then(function (value) {
                return _createThingProperty(TEST_PROPERTY_JSON, "JSON");
            }.bindenv(this))
            .then(function (value) {
                return _createThingProperty(TEST_PROPERTY_BLOB, "BLOB");
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValue(TEST_PROPERTY_STRING, [ "abc", null, "" ]);
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValue(TEST_PROPERTY_INTEGER, [ 0, 10, -20 ]);
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValue(TEST_PROPERTY_BOOLEAN, [ true, false ]);
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValue(TEST_PROPERTY_NUMBER, [ 0, 2.7, -15.987 ]);
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValue(TEST_PROPERTY_JSON, [ { "p1" : "val1", "p2" : 123, "p3" : [ "a", "b" ], "p4" : true }, {} ]);
            }.bindenv(this))
            .then(function (value) {
                local blobVal = blob();
                blobVal.writestring("abcdefg");
                return _setPropertyValue(TEST_PROPERTY_BLOB, [ blobVal ]);
            }.bindenv(this))
            .then(function (value) {
                return _deleteThing();
            }.bindenv(this))
            .fail(function (reason) {
                return Promise.reject(reason);
            }.bindenv(this));
    }

    function testCreateSetPropertyWithWrongArgs() {
        return _createThing()
            .then(function (value) {
                return _createPropertyWithWrongArgs("nonexistentThingName", TEST_PROPERTY_STRING, "STRING");
            }.bindenv(this))
            .then(function (value) {
                return _createPropertyWithWrongArgs(TEST_THING_NAME, TEST_PROPERTY_STRING, "WRONG_PROPERTY_TYPE");
            }.bindenv(this))
            .then(function (value) {
                return _createThingProperty(TEST_PROPERTY_INTEGER, "INTEGER");
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValueWithWrongArgs("nonexistentThingName", TEST_PROPERTY_INTEGER, 123);
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValueWithWrongArgs(TEST_THING_NAME, "nonexistentPropertyName", 123);
            }.bindenv(this))
            .then(function (value) {
                return _setPropertyValueWithWrongArgs(TEST_THING_NAME, TEST_PROPERTY_INTEGER, "abc");
            }.bindenv(this))
            .then(function (value) {
                return _deleteThing();
            }.bindenv(this))
            .fail(function (reason) {
                return Promise.reject(reason);
            }.bindenv(this));
    }

    function _createThing() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThing(TEST_THING_NAME, function (error) {
                if (error) {
                    return reject(error.details);
                }
                return resolve();
            }.bindenv(this));
        }.bindenv(this));
    }

    function _deleteThing() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.deleteThing(TEST_THING_NAME, function (error) {
                return resolve();
            });
        }.bindenv(this));
    }

    function _createThingProperty(propertyName, propertyType) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThingProperty(TEST_THING_NAME, propertyName, propertyType, function (error) {
                if (error) {
                    return reject("Unexpected createThingProperty error: " + error.details);
                }
                return resolve();
            }.bindenv(this));
        }.bindenv(this));
    }

    function _createPropertyWithWrongArgs(thingName, propertyName, propertyType) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThingProperty(thingName, propertyName, propertyType, function (error) {
                if (error && error.type == THING_WORX_ERROR.REQUEST_FAILED) {
                    return resolve();
                }
                return reject("createThingProperty with wrong arguments executed successfully");
            }.bindenv(this));
        }.bindenv(this));
    }

    function _setPropertyValue(propertyName, propertyValues) {
        local index = 0;
        return Promise.loop(
            function () {
                return index++ < propertyValues.len();
            }.bindenv(this),
            function () {
                return Promise(function (resolve, reject) {
                    _thingWorxClient.setPropertyValue(TEST_THING_NAME, propertyName, propertyValues[index - 1], function (error) {
                        if (error) {
                            return reject(format("Unexpected setPropertyValue error for property %s: %s",
                                propertyName, error.details));
                        }
                        return resolve();
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this)
        );
    }

    function _setPropertyValueWithWrongArgs(thingName, propertyName, propertyValue) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.setPropertyValue(thingName, propertyName, propertyValue, function (error) {
                if (error && error.type == THING_WORX_ERROR.REQUEST_FAILED) {
                    return resolve();
                }
                return reject("setPropertyValue with wrong arguments executed successfully");
            }.bindenv(this));
        }.bindenv(this));
    }
}
