extends Node
class_name CryptoJS
## A brief description of the class's role and functionality.
##
## A helper script containing functions for encryption using
## CryptoJS with the Newgrounds.io API. Needs crypto.js file

## Static variable to track if the JavaScript library has been loaded
static var cryptojs_loaded : bool = false

## Function to load the crypto.js file
static func load_js() -> void:
	if JavaScriptBridge.eval("typeof CryptoJS !== 'undefined'"):
		_on_js_loaded(true)
		return

	var js_code : String = """
		var script = document.createElement('script');
		script.type = 'text/javascript';
		script.src = 'COMMONGROUNDS/game/exports/js/crypto.js'; // Correct path to your crypto.js
		document.head.appendChild(script);
		script.onload = function() {
			Godot.engine.call_deferred('_on_js_loaded', true);
		};
		script.onerror = function() {
			Godot.engine.call_deferred('_on_js_loaded', false);
		};
	"""
	JavaScriptBridge.eval(js_code)

## Callback for when crypto.js is loaded or fails to load
static func _on_js_loaded(success: bool) -> void:
	cryptojs_loaded = success
	if success:
		Log.debug("[CryptoJS] Loaded successfully.")
	else:
		Log.error("[CryptoJS] Failed to load.")

## Function to perform encryption using CryptoJS
static func encrypt(data: String, aes_key: String) -> String:
	if not cryptojs_loaded:
		Log.debug("[CryptoJS] Not loaded yet...")
		return ""

	var js_encrypt_code : String = """
		var iv = CryptoJS.lib.WordArray.random(16);
		var encrypted = CryptoJS.AES.encrypt('%s', CryptoJS.enc.Base64.parse('%s'), { iv: iv });
		return CryptoJS.enc.Base64.stringify(iv.concat(encrypted.ciphertext));
	""" % [JSON.stringify(data), aes_key]

	return JavaScriptBridge.eval(js_encrypt_code)

# ... [Any other JavaScript related utility functions can be added here]
