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
const TEST_THING_TEMPLATE_NAME = "__imptest_unknown_template";

// Test case for Thing methods of ThingWorx library (createThing, existThing, deleteThing)
class ThingsTestCase extends ImpTestCase {
    _thingWorxClient = null;

    function setUp() {
        _thingWorxClient = ThingWorx(THING_WORX_ENDPOINT, THING_WORX_APPLICATION_KEY);
        // clean up Things to be created, if exists
        return tearDown();
    }

    function tearDown() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.deleteThing(TEST_THING_NAME, function (error) {
                return resolve();
            });
        }.bindenv(this));
    }

    function testCreateExistDeleteThing() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThing(TEST_THING_NAME, null, function (error) {
                if (error) {
                    return reject("createThing failed: " + error.details);
                }
                _thingWorxClient.existThing(TEST_THING_NAME, function (error, exist) {
                    if (error) {
                        return reject("existThing failed: " + error.details);
                    }
                    if (!exist) {
                        return reject("Wrong exist value of existThing");
                    }
                    _thingWorxClient.deleteThing(TEST_THING_NAME, function (error) {
                        if (error) {
                            return reject("deleteThing failed: " + error.details);
                        }
                        return resolve();
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }

    function testCreateDuplicatedThing() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThing(TEST_THING_NAME, function (error) {
                if (error) {
                    return reject("createThing failed: " + error.details);
                }
                _thingWorxClient.createThing(TEST_THING_NAME, function (error) {
                    if (!error) {
                        return reject("Duplicated things are created successfully");
                    }
                    else if (error && error.type != THING_WORX_ERROR.REQUEST_FAILED) {
                        return reject("Wrong error type for create duplicated things");
                    }
                    _thingWorxClient.existThing(TEST_THING_NAME, function (error, exist) {
                        if (error) {
                            return reject("existThing failed: " + error.details);
                        }
                        if (!exist) {
                            return reject("Wrong exist value of existThing");
                        }
                        _thingWorxClient.deleteThing(TEST_THING_NAME, function (error) {
                            if (error) {
                                return reject("deleteThing failed: " + error.details);
                            }
                            return resolve();
                        }.bindenv(this));
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }

    function testCreateThingWithUnknownTemplate() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.createThing(TEST_THING_NAME, TEST_THING_TEMPLATE_NAME, function (error) {
                if (!error) {
                    return reject("Thing with unknown template is created successfully");
                }
                else if (error && error.type != THING_WORX_ERROR.REQUEST_FAILED) {
                    return reject("Wrong error type for create thing with unknown template");
                }
                return resolve();
            }.bindenv(this));
        }.bindenv(this));
    }

    function testExistNonexistentThing() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.existThing(TEST_THING_NAME, function (error, exist) {
                if (error) {
                    return reject("Unexpected existThing error: " + error.details);
                }
                if (exist) {
                    return reject("Wrong exist value of existThing");
                }
                return resolve();
            }.bindenv(this));
        }.bindenv(this));
    }

    function testDeleteNonexistentThing() {
        return Promise(function (resolve, reject) {
            _thingWorxClient.deleteThing(TEST_THING_NAME, function (error) {
                if (!error || error.type != THING_WORX_ERROR.REQUEST_FAILED || error.httpStatus != 404) {
                    return reject("Wrong deleteThing error: " + (error ? error.details : "null"));
                }
                return resolve();
            }.bindenv(this));
        }.bindenv(this));
    }
}
