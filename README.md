# ThingWorx #

This library allows your agent code to work with the [ThingWorx platform](https://developer.thingworx.com/) via the [ThingWorx REST API](https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart).

This version of the library supports the following functionality:

- Access ThingWorx platform (verified with [PTC hosted instance](https://www.ptc.com/en/products/iot/thingworx-platform) only).
- Thing creation and deletion.
- Thing Property creation.
- Setting a value of Thing Property.

**To add this library to your project, add** `#require "ThingWorx.agent.lib.nut:1.0.0"` **to the top of your agent code.**

## Library Usage ##

### Prerequisites ###

Before using the library you need to have:

- An endpoint of your ThingWorx platform instance (it may look like `https://PP-1802281448E8.Devportal.Ptc.Io`).
- ThingWorx Application Key (see [here](https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/create-appkey)).

### Callbacks ###

All requests that are made to the ThingWorx platform occur asynchronously. Every method that sends a request has an optional parameter which takes a callback function that will be executed when the operation is completed, whether successfully or not. The callback's parameters are listed in the corresponding method description, but every callback has at least one parameter, *error*. If *error* is `null`, the operation has been executed successfully. Otherwise, *error* is an instance of the [ThingWorxError](#thingworxerror-class) class and contains the details of the error.

## ThingWorx Class ##

### Constructor: ThingWorx(*endpoint, appKey*) ###

| Parameter | Data Type | Required? | Description |
| --- | --- | --- | --- |
| *endpoint* | String | Yes | ThingWorx platform endpoint. Must include the scheme. Example: `"https://PP-1802281448E8.Devportal.Ptc.Io"`. |
| *appKey* | String | Yes | ThingWorx Application Key. See [here](https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/create-appkey). |

This method returns a new *ThingWorx* instance.

### createThing(*thingName[, thingTemplateName][, callback]*) ###

This method creates a new Thing, enables and restarts it. See [here](https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/use-rest-api-create-new-thing).

| Parameter | Data Type | Required? | Description |
| --- | --- | --- | --- |
| *thingName* | String | Yes | Name of the new Thing. Must be unique across the ThingWorx platform instance. |
| *thingTemplateName* | String | Optional | A Thing Template which may be used for the Thing creation. See [here](https://developer.thingworx.com/resources/guides/thingworx-foundation-quickstart/thing-template). If not specified, the standard ThingWorx `"GenericThing"` template is used. |
| *callback* | Function | Optional | Executed once the operation is completed. |

This method returns nothing. The result of the operation may be obtained via the *callback* function, which has the following parameters:

| Parameter | Data Type | Description |
| --- | --- | --- |
| *error* | [ThingWorxError](#thingworxerror-class) | Error details, or `null` if the operation succeeds. |

### existThing(*thingName, callback*) ###

This method checks if Thing with the specified name exists.

| Parameter | Data Type | Required? | Description |
| --- | --- | --- | --- |
| *thingName* | String | Yes | Name of the Thing. |
| *callback* | Function | Yes | Executed once the operation is completed. |

This method returns nothing. The result of the operation may be obtained via the *callback* function, which has the following parameters:

| Parameter | Data Type | Description |
| --- | --- | --- |
| *error* | [ThingWorxError](#thingworxerror-class) | Error details, or `null` if the operation succeeds. |
| *exist* | Boolean | `true` if the Thing exists; `false` if the Thing does not exist or the operation fails. |

### deleteThing(*thingName[, callback]*) ###

This method deletes Thing with the specified name.

| Parameter | Data Type | Required? | Description |
| --- | --- | --- | --- |
| *thingName* | String | Yes | Name of the Thing. |
| *callback* | Function | Optional | Executed once the operation is completed. |

This method returns nothing. The result of the operation may be obtained via the *callback* function, which has the following parameters:

| Parameter | Data Type | Description |
| --- | --- | --- |
| *error* | [ThingWorxError](#thingworxerror-class) | Error details, or `null` if the operation succeeds. |

### createThingProperty(*thingName, propertyName, propertyType[, callback]*) ###

This method creates a new Property of the specified Thing and restarts the Thing. See [here](https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/use-rest-api-add-property-thing).

| Parameter | Data Type | Required? | Description |
| --- | --- | --- | --- |
| *thingName* | String | Yes | Name of the Thing. |
| *propertyName* | String | Yes | Name of the new Property. Must be unique across the specified Thing. |
| *propertyType* | String | Yes | Type of the new Property. One of the types described [here](https://support.ptc.com/cs/help/thingworx_hc/thingworx_7.0_hc/index.jspx?id=ThingProperties&action=show). |
| *callback* | Function | Optional | Executed once the operation is completed. |

This method returns nothing. The result of the operation may be obtained via the *callback* function, which has the following parameters:

| Parameter | Data Type | Description |
| --- | --- | --- |
| *error* | [ThingWorxError](#thingworxerror-class) | Error details, or `null` if the operation succeeds. |

### setPropertyValue(*thingName, propertyName, propertyValue[, callback]*) ###

This method sets a new value of the specified Property. See [here](https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart/use-rest-api-set-property-value).

| Parameter | Data Type | Required? | Description |
| --- | --- | --- | --- |
| *thingName* | String | Yes | Name of the Thing. |
| *propertyName* | String | Yes | Name of the Property. |
| *propertyValue* | Boolean, Integer, Float, String, Key-Value Table, Blob, Null | Yes | New value of the Property. |
| *callback* | Function | Optional | Executed once the operation is completed. |

This method returns nothing. The result of the operation may be obtained via the *callback* function, which has the following parameters:

| Parameter | Data Type | Description |
| --- | --- | --- |
| *error* | [ThingWorxError](#thingworxerror-class) | Error details, or `null` if the operation succeeds. |

### setDebug(*value*) ###

This method enables (*value* is `true`) or disables (*value* is `false`) the library debug output (including error logging). It is disabled by default. The method returns nothing.

## ThingWorxError Class ##

This class represents an error returned by the library and has the following public properties:

- *type* &mdash; The error type, which is one of the following *THING_WORX_ERROR* enum values:
    - *LIBRARY_ERROR* &mdash; The library is wrongly initialized, a method is called with invalid argument(s), or an internal error has occurred. The error details can be found in the *details* property. Usually this indicates an issue during an application development which should be fixed during debugging and therefore should not occur after the application has been deployed.
    - *REQUEST_FAILED* &mdash; An HTTP request to the ThingWorx platform failed. The error details can be found in the *details*, *httpStatus* and *httpResponse* properties. This error may occur during the normal execution of an application. The application logic should process this error.
   - *UNEXPECTED_RESPONSE* &mdash; An unexpected response from the ThingWorx platform. The error details can be found in the *details* and *httpResponse* properties.
- *details* &mdash; A string with human readable details of the error.
- *httpStatus* &mdash; An integer indicating the HTTP status code, or `null` if *type* property is *LIBRARY_ERROR*
- *httpResponse* &mdash; A table of key-value strings holding the response body of the failed request, or `null` if *type* property is *LIBRARY_ERROR*.

## Examples ##

Working examples are provided in the [Examples](./Examples) directory and described [here](./Examples/README.md).

## Testing ##

Tests for the library are provided in the [tests](./tests) directory and described [here](./tests/README.md).

## License

The ThingWorx library is licensed under the [MIT License](./LICENSE)
