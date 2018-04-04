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
const TEST_PROPERTY_NAME = "__imptest_property";

// Test case for wrong parameters of ThingWorx library methods
class WrongParamsTestCase extends ImpTestCase {
    
    _thingWorxClient = null;

    function setUp() {
        _thingWorxClient = ThingWorx(THING_WORX_ENDPOINT, THING_WORX_APPLICATION_KEY);
    }

    function testWrongConstructorEndpoint() {
        return Promise.all([
            _testWrongConstructorParams(null, THING_WORX_APPLICATION_KEY),
            _testWrongConstructorParams("", THING_WORX_APPLICATION_KEY),
            _testWrongConstructorParams(null, null),
            _testWrongConstructorParams("", null),
        ]);
    }

    function testWrongConstructorAppKey() {
        return Promise.all([
            _testWrongConstructorParams(THING_WORX_ENDPOINT, null),
            _testWrongConstructorParams(THING_WORX_ENDPOINT, "")
        ]);
    }

    function testWrongCreateThingNameParams() {
        return Promise.all([
            _testWrongCreateThing(null),
            _testWrongCreateThing("")
        ]);
    }

    function testWrongExistThingNameParams() {
        return Promise.all([
            _testWrongExistThing(null),
            _testWrongExistThing("")
        ]);
    }

    function testWrongDeleteThingNameParams() {
        return Promise.all([
            _testWrongDeleteThing(null),
            _testWrongDeleteThing("")
        ]);
    }

    function testWrongCreateThingPropertyParams() {
        return Promise.all([
            _testWrongCreateThingProperty(null, TEST_PROPERTY_NAME, "STRING"),
            _testWrongCreateThingProperty("", TEST_PROPERTY_NAME, "INTEGER"),
            _testWrongCreateThingProperty(TEST_THING_NAME, null, "BOOLEAN"),
            _testWrongCreateThingProperty(TEST_THING_NAME, "", "NUMBER"),
            _testWrongCreateThingProperty(TEST_THING_NAME, TEST_PROPERTY_NAME, null),
            _testWrongCreateThingProperty(TEST_THING_NAME, TEST_PROPERTY_NAME, ""),
            _testWrongCreateThingProperty(null, null, null),
            _testWrongCreateThingProperty("", "", "")
        ]);
    }

    function testWrongSetPropertyValueParams() {
        return Promise.all([
            _testWrongSetPropertyValue(null, TEST_PROPERTY_NAME),
            _testWrongSetPropertyValue("", TEST_PROPERTY_NAME),
            _testWrongSetPropertyValue(TEST_THING_NAME, null),
            _testWrongSetPropertyValue(TEST_THING_NAME, ""),
            _testWrongSetPropertyValue(null, null),
            _testWrongSetPropertyValue("", "")
        ]);
    }

    function _testWrongConstructorParams(endpoint, appKey) {
        local client = ThingWorx(endpoint, appKey);
        local thingName = TEST_THING_NAME;
        local propertyName = TEST_PROPERTY_NAME;
        return Promise.all([
            Promise(function (resolve, reject) {
                client.createThing(
                    thingName,
                    null,
                    function (error) {
                        if (!_isLibraryError(error)) {
                            return reject("Wrong initial param accepted in createThing");
                        }
                        return resolve("");
                    }.bindenv(this));
            }.bindenv(this)),
            Promise(function (resolve, reject) {
                client.existThing(
                    thingName,
                    function (error, exist) {
                        if (!_isLibraryError(error)) {
                            return reject("Wrong initial param accepted in existThing");
                        }
                        return resolve("");
                    }.bindenv(this));
            }.bindenv(this)),
            Promise(function (resolve, reject) {
                client.deleteThing(
                    thingName,
                    function (error) {
                        if (!_isLibraryError(error)) {
                            return reject("Wrong initial param accepted in deleteThing");
                        }
                        return resolve("");
                    }.bindenv(this));
            }.bindenv(this)),
            Promise(function (resolve, reject) {
                client.createThingProperty(
                    thingName, propertyName, "STRING",
                    function (error) {
                        if (!_isLibraryError(error)) {
                            return reject("Wrong initial param accepted in createThingProperty");
                        }
                        return resolve("");
                    }.bindenv(this));
            }.bindenv(this)),
            Promise(function (resolve, reject) {
                client.setPropertyValue(
                    thingName, propertyName, "abc",
                    function (error) {
                        if (!_isLibraryError(error)) {
                            return reject("Wrong initial param accepted in setPropertyValue");
                        }
                        return resolve("");
                    }.bindenv(this));
            }.bindenv(this)),
        ]);
    }

    function _testWrongCreateThing(thingName) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThing(
                thingName,
                null,
                function (error) {
                    if (!_isLibraryError(error)) {
                        return reject("Wrong param accepted in createThing");
                    }
                    return resolve("");
                }.bindenv(this));
        }.bindenv(this));
    }

    function _testWrongExistThing(thingName) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.existThing(
                thingName,
                function (error, exist) {
                    if (!_isLibraryError(error)) {
                        return reject("Wrong param accepted in existThing");
                    }
                    if (exist) {
                        return reject("Wrong exist == true returned by existThing");
                    }
                    return resolve("");
                }.bindenv(this));
        }.bindenv(this));
    }

    function _testWrongDeleteThing(thingName) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.deleteThing(
                thingName,
                function (error) {
                    if (!_isLibraryError(error)) {
                        return reject("Wrong param accepted in deleteThing");
                    }
                    return resolve("");
                }.bindenv(this));
        }.bindenv(this));
    }

    function _testWrongCreateThingProperty(thingName, propertyName, propertyType) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThingProperty(
                thingName,
                propertyName,
                propertyType,
                function (error) {
                    if (!_isLibraryError(error)) {
                        return reject("Wrong param accepted in createThingProperty");
                    }
                    return resolve("");
                }.bindenv(this));
        }.bindenv(this));
    }

    function _testWrongSetPropertyValue(thingName, propertyName) {
        return Promise(function (resolve, reject) {
            _thingWorxClient.setPropertyValue(
                thingName,
                propertyName,
                "abc",
                function (error) {
                    if (!_isLibraryError(error)) {
                        return reject("Wrong param accepted in setPropertyValue");
                    }
                    return resolve("");
                }.bindenv(this));
        }.bindenv(this));
    }

    function _isLibraryError(error) {
        return error && error.type == THING_WORX_ERROR.LIBRARY_ERROR;
    }
}
