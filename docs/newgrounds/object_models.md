# Newgrounds.io Object Models

## ScoreBoard
Contains information about a scoreboard.

### Properties:
- id: int
    - The numeric ID of the scoreboard.
- name: string
    - The name of the scoreboard.

## Session
Contains information about the current user session.

### Properties:
- expired: boolean
    - If true, the session_id is expired. Use App.startSession to get a new one.
- id: string
    - A unique session identifier.
- passport_url: string
    - If the session has no associated user but is not expired, this property will provide a URL that can be used to sign the user in.
- remember: boolean
    - If true, the user would like you to remember their session id.
- user: User object
    - If the user has not signed in, or granted access to your app, this will be null.

NOTES: Remembered sessions will expire after 30 days of inactivity. All other sessions will expire after one hour of inactivity.
Session expirations get renewed with every call. You could use 'Gateway.ping' every 5 minutes to keep sessions alive.

## User
Contains information about a user.

### Properties:
- icons: UserIcons object
    - The user's icon images.
- id: int
    - The user's numeric ID.
- name: string
    - The user's textual name.
- supporter: boolean
    - Returns true if the user has a Newgrounds Supporter upgrade.

## UserIcons
Contains any icons associated with this user.

### Properties:
- large: string
    - The URL of the user's large icon.
- medium: string
    - The URL of the user's medium icon.
- small: string
    - The URL of the user's small icon.

## Debug
Contains extra debugging information.

### Properties:
- exec_time: string
    - The time, in milliseconds, that it took to execute a request.
- request: Request object
    - A copy of the request object that was posted to the server.

NOTES: This object is only used in debug mode.

## Error
Contains information about an error.

### Properties:
- code: int
    - A code indicating the error type.
- message: string
    - Contains details about the error.

## Execute
Contains all the information needed to execute an API component.

### Properties:
- component*: string
    - The name of the component you want to call, e.g., 'App.connect'. (Only required if 'secure' is not set.)
- echo: mixed
    - An optional value that will be returned, verbatim, in the Result object.
- parameters: object or array of objects
    - An object of parameters you want to pass to the component.
- secure*: string
    - An encrypted Execute object or array of Execute objects. (Only required if 'component' is not set.)

* Required property

NOTES: For secure calls using encryption, you only need to pass the 'secure' property. For all other calls, you only need to use the 'component' and 'parameters' properties.

## Medal
Contains information about a medal.

### Properties:
- description: string
    - A short description of the medal.
- difficulty: int
    - The difficulty id of the medal.
- icon: string
    - The URL for the medal's icon.
- id: int
    - The numeric ID of the medal.
- name: string
    - The name of the medal.
- secret: boolean
- unlocked: boolean
    - This will only be set if a valid user session exists.
- value: int
    - The medal's point value.

NOTES: Medal Difficulties:
- 1 = Easy
- 2 = Moderate
- 3 = Challenging
- 4 = Difficult
- 5 = Brutal

## Request
A top-level wrapper containing any information needed to authenticate the application/user and any component calls being made.

### Properties:
- app_id*: string
    - Your application's unique ID.
- debug: boolean
    - If set to true, calls will be executed in debug mode.
- echo: mixed
    - An optional value that will be returned, verbatim, in the Response object.
- execute*: Execute object or array of Execute objects
    - A Execute object, or array of one-or-more Execute objects.
- session_id: string
    - An optional login session id.

* Required property

## Response
Contains all return output from an API request.

### Properties:
- api_version: string
    - If there was an error, this will contain the current version number of the API gateway.
- app_id: string
    - Your application's unique ID.
- debug: Debug object
    - Contains extra information you may need when debugging (debug mode only).
- echo: mixed
    - If you passed an 'echo' value in your request object, it will be echoed here.
- error: Error object
    - This will contain any error info if the success property is false.
- help_url: string
    - If there was an error, this will contain the URL for our help docs.
- result: Result object or array of Result objects
    - This will be a Result object, or an array containing one-or-more Result objects (this will match the structure of the execute property in your Request object).
- success: boolean
    - If false, there was a problem with your 'request' object. Details will be in the error property.

## Result
Contains information returned by an API component.

### Properties:
- component: string
    - The name of the component that was executed (e.g., 'Medal.unlock').
- data: object or array of objects
    - An object, or array of one-or-more objects (follows the structure of the corresponding 'execute' property), containing any returned properties or errors.
- echo: mixed
    - If you passed an 'echo' value in your execute object, it will be echoed here.
- error: Error object
    - This will contain any error info if the success property is false.
- success: boolean
    - If false, there was a problem with your 'request' object. Details will be in the error property.

NOTES: The 'data' object will always contain a 'success' property. If the call was unsuccessful, there will also be an 'error' property.

## SaveSlot
Contains information about a CloudSave slot.

### Properties:
- datetime: string
    - A date and time (in ISO 8601 format) representing when this slot was last saved.
- id: int
    - The slot number.
- size: int
    - The size of the save data in bytes.
- timestamp: int
    - A Unix timestamp representing when this slot was last saved.
- url: string
    - The URL containing the actual save data for this slot, or null if this slot has no data.

## Score
Contains information about a score posted to a scoreboard.

### Properties:
- formatted_value: string
    - The score value in the format selected in your scoreboard settings.
- tag: string
    - The tag attached to this score (if any).
- user: User object
    - The user who earned the score. If this property is absent, the score belongs to the active user.
- value: int
    - The integer value of the score.
## ScoreBoard
Contains information about a scoreboard.

### Properties:
- id: int
    - The numeric ID of the scoreboard.
- name: string
    - The name of the scoreboard.

## Session
Contains information about the current user session.

### Properties:
- expired: boolean
    - If true, the session_id is expired. Use App.startSession to get a new one.
- id: string
    - A unique session identifier.
- passport_url: string
    - If the session has no associated user but is not expired, this property will provide a URL that can be used to sign the user in.
- remember: boolean
    - If true, the user would like you to remember their session id.
- user: User object
    - If the user has not signed in, or granted access to your app, this will be null.

NOTES: Remembered sessions will expire after 30 days of inactivity. All other sessions will expire after one hour of inactivity.
Session expirations get renewed with every call. You could use 'Gateway.ping' every 5 minutes to keep sessions alive.

## User
Contains information about a user.

### Properties:
- icons: UserIcons object
    - The user's icon images.
- id: int
    - The user's numeric ID.
- name: string
    - The user's textual name.
- supporter: boolean
    - Returns true if the user has a Newgrounds Supporter upgrade.

## UserIcons
Contains any icons associated with this user.

### Properties:
- large: string
    - The URL of the user's large icon.
- medium: string
    - The URL of the user's medium icon.
- small: string
    - The URL of the user's small icon.
