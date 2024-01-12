# Newgrounds.io Component List

Below is a comprehensive list of available components.

## App

Used to get and validate information associated with your app, including user sessions.

### App.checkSession

Checks the validity of a session id and returns the results in a Session object.

**Requires a session ID.**

Parameters:

- This component does not take any parameters

Result:

- session — Session Object

### App.endSession

Ends the current session, if any.

**Requires a session ID.**

Parameters:

- This component does not take any parameters

### App.getCurrentVersion

Gets the version number of the app as defined in your "Version Control" settings.

Parameters:

- version — string (default = "0.0.0")
    - The version number (in "X.Y.Z" format) of the client-side app.

Result:

- client_deprecated — boolean
    - Notes whether the client-side app is using a lower version number.
- current_version — string
    - The version number of the app as defined in your "Version Control" settings.

### App.getHostLicense

Checks a client-side host domain against domains defined in your "Game Protection" settings.

Parameters:

- host — string
    - The host domain to check (e.g., somesite.com).

Result:

- host_approved — boolean

### App.logView

Increments "Total Views" statistic.

Parameters:

- host* — string
    - The domain hosting your app. Examples: "www.somesite.com", "localHost"

### App.startSession

Starts a new session for the application.

Parameters:

- force — boolean
    - If true, will create a new session even if the user already has an existing one.
    - Note: Any previous session ids will no longer be valid if this is used.

Result:

- session — Session Object

## CloudSave

Handles loading and saving of game states.

### CloudSave.clearSlot

Deletes all data from a save slot.

**Requires a session ID.**

Parameters:

- id* — int
    - The slot number.

Result:

- slot — SaveSlot Object
    - A SaveSlot object.

### CloudSave.loadSlot

Returns a specific saveslot object.

**Requires a session ID.**

Parameters:

- app_id — string
    - The App ID of another, approved app to load slot data from.
- id* — int
    - The slot number.

Result:

- app_id — string
    - The App ID of another, approved app to load scores from.
- slot — SaveSlot Object
    - A SaveSlot object.

### CloudSave.loadSlots

Returns a list of saveslot objects.

**Requires a session ID.**

Parameters:

- app_id — string
    - The App ID of another, approved app to load slot data from.

Result:

- app_id — string
    - The App ID of another, approved app to load scores from.
- slots — Array( SaveSlot )
    - An array of SaveSlot objects.

## CloudSave.setData

Saves data to a save slot. Any existing data will be replaced.

**Requires a session ID.**

Parameters:

- data* — string
    - The data you want to save.
- id* — int
    - The slot number.

Result:

- slot — SaveSlot Object

## Event

Handles logging of custom events.

### Event.logEvent

Logs a custom event to your API stats.

Parameters:

- event_name* — string
    - The name of your custom event as defined in your Referrals & Events settings.
- host* — string
    - The domain hosting your app. Example: "newgrounds.com", "localHost"

Result:

- event_name — string

## Gateway

Provides information about the gateway server.

### Gateway.getDatetime

Loads the current date and time from the Newgrounds.io server.

Parameters:

- This component does not take any parameters

Result:

- datetime — string
    - The server's date and time in ISO 8601 format.
- timestamp — int
    - The current UNIX timestamp on the server.

### Gateway.getVersion

Returns the current version of the Newgrounds.io gateway.

Parameters:

- This component does not take any parameters

Result:

- version — string
    - The version number (in X.Y.Z format).

### Gateway.ping

Pings the Newgrounds.io server.

Parameters:

- This component does not take any parameters

Result:

- pong — string
    - Will always return a value of 'pong'

## Loader

This class handles loading various URLs and tracking referral stats.

Note: These calls do not return any JSON packets (unless the redirect param is set to false). Instead, they redirect to the appropriate URL. These calls should be executed in a browser window vs using AJAX or any other internal loaders.

### Loader.loadAuthorUrl

Loads the official URL of the app's author (as defined in your "Official URLs" settings), and logs a referral to your API stats.

Parameters:

- `host*` — string
    - The domain hosting your app. Example: "www.somesite.com", "localHost"
- `log_stat` — boolean
    - Set this to false to skip logging this as a referral event.
- `redirect` — boolean
    - Set this to false to get a JSON response containing the URL instead of doing an actual redirect.

* Required parameter

Result:

- `url` — string

### Loader.loadMoreGames

Loads the Newgrounds game portal, and logs the referral to your API stats.

Parameters:

- `host*` — string
    - The domain hosting your app. Example: "www.somesite.com", "localHost"
- `log_stat` — boolean
    - Set this to false to skip logging this as a referral event.
- `redirect` — boolean
    - Set this to false to get a JSON response containing the URL instead of doing an actual redirect.

* Required parameter

Result:

- `url` — string

### Loader.loadNewgrounds

Loads Newgrounds, and logs the referral to your API stats.

Parameters:

- `host*` — string
    - The domain hosting your app. Example: "www.somesite.com", "localHost"
- `log_stat` — boolean
    - Set this to false to skip logging this as a referral event.
- `redirect` — boolean
    - Set this to false to get a JSON response containing the URL instead of doing an actual redirect.

* Required parameter

Result:

- `url` — string

### Loader.loadOfficialUrl

Loads the official URL where the latest version of your app can be found (as defined in your "Official URLs" settings), and logs a referral to your API stats.

Parameters:

- `host*` — string
    - The domain hosting your app. Example: "www.somesite.com", "localHost"
- `log_stat` — boolean
    - Set this to false to skip logging this as a referral event.
- `redirect` — boolean
    - Set this to false to get a JSON response containing the URL instead of doing an actual redirect.

* Required parameter

Result:

- `url` — string

### Loader.loadReferral

Loads a custom referral URL (as defined in your "Referrals & Events" settings), and logs the referral to your API stats.

Parameters:

- `host*` — string
    - The domain hosting your app. Example: "www.somesite.com", "localHost"
- `log_stat` — boolean
    - Set this to false to skip logging this as a referral event.
- `redirect` — boolean
    - Set this to false to get a JSON response containing the URL instead of doing an actual redirect.
- `referral_name*` — string
    - The name of the referral (as defined in your "Referrals & Events" settings).

* Required parameter

Result:

- `url` — string

## Medal

Handles loading and unlocking of medals.

### Medal.getList

Loads a list of Medal objects.

Parameters:

- `app_id` — string
    - The App ID of another, approved app to load medals from.

Result:

- `app_id` — string
    - The App ID of any external app these medals were loaded from.
- `medals` — Array( Medal )
    - An array of medal objects.

### Medal.getMedalScore

Loads the user's current medal score.

Requires a session ID.

Parameters:

- This component does not take any parameters

Result:

- `medal_score` — int
    - The user's medal score.

### Medal.unlock

Unlocks a medal.

Requires a session ID.
User must be logged in.
If encryption is enabled, must be sent in a secure call.

Parameters:

- `id*` — int
    - The numeric ID of the medal to unlock.

* Required parameter

Result:

- `medal` — Medal Object
    - The Medal that was unlocked.
- `medal_score` — int
    - The user's new medal score.

## ScoreBoard

Handles loading and posting of high scores and scoreboards.

### ScoreBoard.getBoards

Returns a list of available scoreboards.

Parameters:

- This component does not take any parameters

Result:

- `scoreboards` — Array( ScoreBoard )
    - An array of ScoreBoard objects.

### ScoreBoard.getScores

Loads a list of Score objects from a scoreboard. Use 'skip' and 'limit' for getting different pages.

Parameters:

- `app_id` — string
    - The App ID of another, approved app to load scores from.
- `id*` — int
    - The numeric ID of the scoreboard.
- `limit` — int
    - An integer indicating the number of scores to include in the list. Default = 10.
- `period` — string
    - The time-frame to pull scores from (see notes for acceptable values).
- `skip` — int
    - An integer indicating the number of scores to skip before starting the list. Default = 0.
- `social` — boolean
    - If set to true, only social scores will be loaded (scores by the user and their friends). This param will be ignored if there is no valid session id and the 'user' param is absent.
- `tag` — string
    - A tag to filter results by.
- `user` — mixed
    - A user's ID or name. If 'social' is true, this user and their friends will be included. Otherwise, only scores for this user will be loaded. If this param is missing and there is a valid session id, that user will be used by default.

* Required parameter

Result:

- `app_id` — string
    - The App ID of any external app these scores were loaded from.
- `limit` — int
    - The query skip that was used.
- `period` — string
    - The time-frame the scores belong to. See notes for acceptable values.
- `scoreboard` — ScoreBoard Object
    - The ScoreBoard being queried.
- `scores` — Array( Score )
    - An array of Score objects.
- `social` — boolean
    - Will return true if scores were loaded in social context ('social' set to true and a session or 'user' were provided).
- `user` — User Object
    - The User the score list is associated with (either as defined in the 'user' param, or extracted from the current session when 'social' is set to true)

Notes:

Acceptable 'period' values:
- "D" = current day (default)
- "W" = current week
- "M" = current month
- "Y" = current year
- "A" = all-time

### ScoreBoard.postScore

Posts a score to the specified scoreboard.

Requires a session ID.
User must be logged in.
If encryption is enabled, must be sent in a secure call.

Parameters:

- `id*` — int
    - The numeric ID of the scoreboard.
- `tag` — string
    - An optional tag that can be used to filter scores via ScoreBoard.getScores
- `value*` — int
    - The int value of the score.

* Required parameter

Result:

- `score` — Score Object
    - The Score that was posted to the board.
- `scoreboard` — ScoreBoard Object
    - The ScoreBoard that was posted to.

Notes:

If this board uses incremental scores, the new total score value will be returned.