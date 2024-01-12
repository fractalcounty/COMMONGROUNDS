# Why Use Encryption?
### TLDR: It makes it harder to cheat.

## Full explanation:

As described in the 'Communicating with the Server' page, Newgrounds.io is a network API that works by POSTing http requests to a gateway server.

In most modern browsers, you can right-click any page and see an 'Inspect' option. This will open a developer toolbar, and that will typically contain a 'Network' inspector.

Any user playing a web-based game can see EXACTLY what is being posted to the gateway script. And there are applications (like Fiddler 2) that can show network traffic from native games as well.

These tools make it incredibly easy for a user to copy something like a high score post, change some values, and post it from a simple HTML form.

By using encryption, the data that gets posted to the server is completely obfuscated and incredibly hard to edit.

## Is it secure? Can it be hacked?
TLDR: It depends on how secure your source code is.

### Full explanation:

While the encryption methods we use are completely open-source, every APP that uses Newgrounds.io has a unique encryption key. This key affects how your data gets encrypted, meaning any data your game encrypts could not come from any other game.

Using encryption is very secure, as long as the end-user can not easily find your encryption key. Compiled games will be FAR more secure when using Newgrounds.io than web-based html5 games (where all your source code is completely visible and unprotected).

For these reasons, you should NEVER rely on our encryption for security (it's purely intended for network obfuscation). NEVER use Newgrounds.io to post sensitive information. We take ZERO responsibility if your games are compromised in any way.

## Do we have to use encryption?
Absolutely not. Encryption options are available purely as a courtesy for users who want to keep certain network transmissions unreadable by the naked eye.

If you CAN use encryption, and it's not a nightmare to implement, it's typically better to have it. While truly dedicated users could reverse engineer your code and cheat, most people will be too lazy to do so.

## What if someone DOES cheat in my game?
With, or without encryption, all the server components that can post information to a user account rely on a session_id (See 'Newgrounds Passport' page). This id is unique to every login meaning if a user cheats in any part of your game that posts to Newgrounds.io, you will know who they are.

Suspicious users can be moderated from your Project/API Tools pages on Newgrounds.com.

## Implementing Encryption
Before we go too far, understand that only a few components actually benefit from encryption. Anything that is read-only does not need encryption, even if you have it enabled. If you DO have encryption enabled, any calls that can post information to a user's account will REQUIRE encryption.

For example, if you have encryption enabled, calls to the Medal.getList component will not need to be secure, but calls to Medal.unlock will. If you have encryption disabled, Medal.unlock will work fine without being secured.

Check the details for any components you use on the component list page to see which ones will require encryption if it is enabled.

### Encrypting your Call:
Encryption happens in the 'execute' part of a 'request object' (see Communicating with the Server).

Lets say we want to unlock a medal. Our execute object might look like this (this is the object we will need to encrypt):

```json
{
    "component": "Medal.unlock",
    "parameters": {
        "id": 38573
    }
}
```
If we had encryption enabled and sent the request object like this:

```json
{
    "app_id": "test",
    "session_id": "USER_SESSION_ID_GOES_HERE",
    "execute": {
        "component": "Medal.unlock",
        "parameters": {
            "id": 38573
        }
    }
}
```
We would get an error because the call was not encrypted.

The first step we would take is to make sure our call object has been converted to a JSON string (which we've already done in this example)

The next step is to pass the call to our encryption cipher. Most ciphers will convert a string into a binary format.

### Using AES-128
AES encryption uses an initialization vector (IV for short) to seed the encryption. This makes the result more unique than using a key alone. It also makes it impossible to decrypt without KNOWING the IV. IVs are typically 16 byte binary value.

First you will need to generate a random IV value, then use it, along with your encryption key, to encrypt your JSON-encoded call object into a binary value. Next take the bytes from your IV object and append the bytes of your encrypted data. This adds the IV to the beginning of your encrypted data so the server will be able to decrypt it.

### Using RC4
RC4 is less secure than AES, but can often be simpler to work with. Simply encrypt your JSON-encoded call object with your encryption key to get a binary value.

## Encoding The Encrypted Data
Now that your call has been encrypted into a binary format, we need to turn it into a string value that the server can work with.

Depending on your encryption settings, you will convert to either a base64 string or a hex string.

### Using Base64
Base64 is ideal for this part as it results in smaller strings and is almost universally supported. Our encoded call would look something like this with base64:

```
xL5yiZlNXm1C+J8Z2ie3kjKSJXC89783i+sdf/OoAVHvgTUgxrzJv+LFjM//b1YDOyqGBbjclXenWWBX4oJtkN8iMDEcujcdj5lrFIwAw==
```

### Using Hexadecimal (Hex)
Hex is also known as Base16. It is widely used in HTML and CSS for setting color values, and is universally supported. Hex strings will usually be much longer than base64 strings. Our encoded call would look something like this in Hexadecimal:

```
C4BE7289994D5E6D42F89F19DA27B79232922570BCF7BF378BEB1D7FF3A80151ECBE04D4831AF326FF8B16333FFDBD580CECAA1816E37255DE9D65815F8A09B6437C88C0C472E8DC763E65AC523003
```

## Creating a Secure Execution
The request still requires an 'execute' object, however, we only need to give it one property now. Add a 'secure' property and use your encoded data as the value. Your request object should look something like this:

```json
{
    "app_id": "test",
    "session_id": "USER_SESSION_ID_GOES_HERE",
    "execute": {
        "secure": "xL5yiZlNXm1C+J8Z2ie3kjKSJXC89783i+sdf\/OoAVHvgTUgxrzJv+LFjM\/\/b1YDOyqGBbjclXenWWBX4oJtkN8iMDEcujcdj5lrFIwAw=="
    }
}
```

You can now post the packet to the gateway!