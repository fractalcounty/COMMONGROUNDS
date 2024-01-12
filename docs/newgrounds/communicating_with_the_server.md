# Newgrounds.io Help: Communicating with the Server

All calls to the API are done by posting to the Newgrounds.io Gateway at [newgrounds.io/gateway_v3.php](newgrounds.io/gateway_v3.php). This 'gateway' processes any data you post to it, and responds with a JSON-encoded object.

Go ahead and load the gateway in your browser, and you will immediately see how it responds with a JSON object containing an error about missing required request.

The gateway script expects a single query parameter named 'request', and expects to receive it using the POST method.

If you were to load [newgrounds.io/gateway_v3.php?request=test](newgrounds.io/gateway_v3.php?request=test) (GET method) in your browser, you would see the same 'Missing required request' error as before. However, if we use the POST method, we get a different result:

```json
{
    "success": false,
    "error": {
        "message": "Missing required request",
        "code": 100
    },
    "api_version": "3.0.0",
    "help_url": "http://www.newgrounds.com/wiki/creator-resources/newgrounds-apis/newgrounds-io"
}
```

We still get an error, but now it says 'Invalid JSON object in request'. This is because the request value is expected to be a JSON-encoded object, which we call the 'request object' (see below).

## A proper JSON-encoded example
Let's do one more quick example, using a proper JSON-encoded request object.

#### Request:

```json
{
    "app_id": "test",
    "debug": true,
    "execute": {
        "component": "Gateway.getDatetime",
        "parameters": {},
        "echo": "Hello World!"
    }
}
```

#### Response:

```json
{
    "success": true,
    "app_id": "test",
    "result": {
        "echo": "Hello World!",
        "component": "Gateway.getDatetime",
        "data": {
            "success": true,
            "datetime": "2024-01-10T13:44:53-05:00",
            "timestamp": 1704912293,
            "debug": true
        }
    },
    "debug": {
        "exec_time": "0.0047750473022461",
        "request": {
            "app_id": "39685:NJ1KkPGb",
            "debug": true,
            "execute": {
                "component": "Gateway.getDatetime",
                "parameters": {},
                "echo": "Hello World!"
            }
        }
    }
}
```

The above example posts a valid request object, calling the Gateway.getTime component (see components list for more information on components).

## The Request Object

The gateway script will always expect a request object. This object is a container that tells the API what application is calling it, who the end-user is (if known), and what components we want to execute.

### Properties of Secure Calls

A request object can have any, or all, of the following properties:

#### `app_id` (required)

This is the App ID found on your Newgrounds.com Project/API Tools dashboard. Refer to the Getting Started page for details.

#### `execute` (required)

This can be either an 'execute object' or an array of up-to-ten execute objects if you want to call multiple components in a single post. If you are using encryption, some components will expect a 'secure execute' object. Refer to the 'Secure Executions' section for more details.

#### `session_id`

This is a session ID string associated with your end user. Refer to the Newgrounds Passport page for information on obtaining session IDs.

#### `debug`

Set this boolean to true to operate in debug mode. Responses will contain more data, and some features will only simulate posting.

#### `echo`

You can set this to ANY value, and it will be returned, verbatim, in the server response.

## The Execute Object

The execute object defines which component to run, and what parameters to call it with.

### Properties of Secure Calls

An execute object can have any, or all, of the following properties:

#### `component` (required)

This is the name of the server component you want to call, ie Gateway.getDatetime.

#### `parameters`

This is an object of parameters you want to call the component with. Refer to the components list for details on what parameters each component expects.

#### `echo`

You can set this to ANY value, and it will be returned, verbatim, in the server response.

## Secure Executions

Some components can use encryption to obfuscate what gets sent over the network. Refer to the Encryption help page for more details.

If you have encryption enabled on your Newgrounds.com Project/API Tools dashboard (this is enabled by default), you will need to convert 'call objects' to 'secure call' objects.

### Properties of Secure Calls

Secure calls have the following properties:

#### `secure` (required)

This is a regular 'execute object', that has been encoded into a JSON string, encrypted using a cipher, and encoded to a hexadecimal or base64 string, depending on your encryption settings. Refer to the Getting Started page for details.

**Note:** You will only need to do this for components that indicate they support encryption, and only if you have encryption enabled on your Newgrounds.com Project/API Tools dashboard. Encryption is 100% optional if you are not using a pre-made library.

## Putting it all together

Earlier in the page, we made a test POST using the Gateway.getDatetime component. Let's break that down using what we now know.

The execute object for our post looks like this:

```json
{
    "component": "Gateway.getDatetime",
    "parameters": {},
    "echo": "Hello World!"
}
```

We have defined the component we want to call (Gateway.getDatetime), and added an echo just because we can. This component does not require any parameters, so we could have left that property out if we wanted.

We then wrap the execute object inside a request object, and end up with this:

```json
{
    "app_id": "test",
    "debug": true,
    "execute": {
        "component": "Gateway.getDatetime",
        "parameters": {},
        "echo": "Hello World!"
    }
}
```

Our request object is using the handy 'test' app_id, and running in debug mode.

Finally, we POST a value named 'request' to the gateway, using our JSON-encoded input object as the value.

## Handling the Server Response

In our example, at the top of the page, we posted a call to the `Gateway.getDatetime` component, and we should have seen the following result (or thereabouts):

```json
{
    "success": true,
    "app_id": "test",
    "result": {
        "echo": "Hello World!",
        "component": "Gateway.getDatetime",
        "data": {
            "success": true,
            "datetime": "2016-07-29T16:33:55-04:00",
            "debug": true
        }
    },
    "debug": {
        "exec_time": 0.002817,
        "request": {
            "app_id": "39685:NJ1KkPGb",
            "debug": true,
            "execute": {
                "component": "Gateway.getDatetime",
                "parameters": {},
                "echo": "Hello World!"
            }
        }
    }
}
```

## The Response Object

Response objects contain the results of any components that were executed and/or any errors that may have occurred.

### Properties of the Response Object

Response objects may have the following properties:

#### `success` (always)

If this is true, you were successful in posting to the gateway, and should have a result object.

#### `app_id`

The App ID that was used in your 'request object'.

#### `error` (if `success` is false)

This will be an object with 2 properties: `code` and `message`. These objects contain information about anything that may have gone wrong.

#### `api_version` (if `success` is false)

If there was a problem, the server will let you know what version it is at in case you've hit a deprecation issue.

#### `result` (if `success` is true)

This will be a 'result object' (See 'The Result Object' below) or an array of multiple result objects if you used an array as your request object's 'call' property.

#### `echo`

If your 'request object' had an echo value, this will be exactly the same.

#### `debug`

If your 'input object' had debug set to true, this object will contain an 'exec_time' value indicating how long it took the component to run, and a 'request' value containing a copy of the 'request object' you posted.

In our example, the `success` property is true, and we have a.... (continued in next section)

## The Response Object

Response objects contain the results of any components that were executed and/or any errors that may have occurred.

Response objects may have the following properties:

### `success` (always)

If this is true, you were successful in posting to the gateway, and should have a result object.

### `app_id`

The App ID that was used in your 'request object'.

### `error` (if `success` is false)

This will be an object with 2 properties: `code` and `message`. These objects contain information about anything that may have gone wrong.

### `api_version` (if `success` is false)

If there was a problem, the server will let you know what version it is at in case you've hit a deprecation issue.

### `result` (if `success` is true)

This will be a 'result object' (See 'The Result Object' below) or an array of multiple result objects if you used an array as your request object's 'call' property.

### `echo`

If your 'request object' had an echo value, this will be exactly the same.

### `debug`

If your 'input object' had debug set to true, this object will contain an 'exec_time' value indicating how long it took the component to run, and a 'request' value containing a copy of the 'request object' you posted.

In our example, the `success` property is true, and we have a.... (cont.)

## The Result Object

Result objects are the counterpart of execute objects. They contain information about what the component returned.

### Properties of the Result Object

A result object will have the following properties:

#### `component` (always)

This will be the name of the component that was called.

#### `data`

The results from the component. This object will always have a 'success' value. If 'success' is true, it will also contain all of the expected properties associated with the component that was called. If 'success' is false, it will also have an 'error' object with 'code' and 'message' values. If the component was called in debug mode, there will also be a debug property.

In our example post, we received a successful result with a 'data' value of:

```json
"data": {
    "success": true,
    "datetime": "2016-07-29T16:33:55-04:00",
    "debug": true
}
```

## Multitasking

To help keep your games snappy, you can call up to 10 components in a single post. This is done by using an array as the 'execute' value in your 'request object'.

Let's look at two separate calls, and what they return:

Calling `Gateway.getVersion` with...

```json
{
    "app_id": "test",
    "call": {
        "component": "Gateway.getVersion"
    }
}
```

...returns

```json
{
    "success": true,
    "app_id": "test",
    "result": {
        "component": "Gateway.getVersion",
        "data": {
            "success": true,
            "version": "3.0.0"
        }
    }
}
```
And calling Gateway.getDatetime with...
```json
{
    "app_id": "test",
    "call": {
        "component": "Gateway.getDatetime"
    }
}
```
...returns
```json
{
    "success": true,
    "app_id": "test",
    "result": {
        "component": "Gateway.getDatetime",
        "data": {
            "success": true,
            "datetime": "2016-07-29T17:37:24-04:00"
        }
    }
}
```
In both examples, the 'execute' property and corresponding 'result' property are flat objects.

By using an array in the 'call' property (to call BOTH components) like so...

```json
{
    "app_id": "test",
    "execute": [
        {
            "component": "Gateway.getVersion"
        },{
            "component": "Gateway.getDatetime"
        }
    ]
}
```

... we get an array back in the 'result' property:

```json
{
    "success": true,
    "app_id": "test",
    "result": [
        {
            "component": "Gateway.getVersion",
            "data": {
                "success": true,
                "version": "3.0.0"
            }
        },
        {
            "component": "Gateway.getDatetime",
            "data": {
                "success": true,
                "datetime": "2016-07-29T17:37:24-04:00"
            }
        }
    ]
}
```

## Request Spamming
Because many users of the Newgrounds.io API are novices, we have taken measures to handle things like bad loops, excessive packet sizes, and so on. If your app spams our gateway, it will be treated like any other DDOS attack, and the end user will be blocked.

For this reason, we strongly encourage you to only make API calls when they are necessary (you don't need to save your game, or post your current score on every single iteration of your game loop!).