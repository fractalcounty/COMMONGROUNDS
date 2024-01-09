extends Node
class_name NGUtils
## Newgrounds.io API autoload helper function script
##
## Provides various methods and functions for use
## in the main Newgrounds.gd autoload singleton

func get_session_id_from_url() -> String:
	var js : String = 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	var result : String  = str(JavaScriptBridge.eval(js, true))
	return result

func encrypt_data(data: String, AES_KEY: String) -> String:
	Log.debug("NGUtils.gd encrypting data input: {data}".format({"data": data}))
	var aes: AESContext = AESContext.new()
	var key: PackedByteArray = Marshalls.base64_to_raw(AES_KEY)
	if key.size() != 16 and key.size() != 32:
		Log.error("NGUtils.gd Invalid key size: " + str(key.size()))

	var iv: PackedByteArray = _generate_random_iv(16)
	if iv.size() != 16:
		Log.error("Invalid IV size: " + str(iv.size()))
	Log.debug("NGUtils.gd 16 byte iv: {iv}".format({"iv": iv}))

	var data_bytes: PackedByteArray = data.to_utf8_buffer()
	data_bytes = _pad_buffer(data_bytes)
	if data_bytes.size() % 16 != 0:
		Log.error("NGUtils.gd Data size after padding is not a multiple of 16: " + str(data_bytes.size()))

	var error = aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	if error != OK:
		Log.error("NGUtils.gd Error starting AES context: " + str(error))
		return "Error starting AES encryption"
	
	var encrypted: PackedByteArray = aes.update(data_bytes)
	aes.finish()
	
	if encrypted.is_empty():
		Log.error("NGUtils.gd Error during encryption")

	var combined: PackedByteArray = iv + encrypted
	var base64_encrypted: String = Marshalls.raw_to_base64(combined)
	Log.debug("NGUtils.gd encrypted data output (base64): " + base64_encrypted)
	return base64_encrypted

func _generate_random_iv(size: int) -> PackedByteArray:
	var crypto : Crypto = Crypto.new()
	return crypto.generate_random_bytes(size)

func _pad_buffer(data: PackedByteArray) -> PackedByteArray:
	var padding_needed: int = (16 - data.size() % 16) % 16
	for i in range(padding_needed):
		data.push_back(padding_needed)  # PKCS#7 padding
	return data
