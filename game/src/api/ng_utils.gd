extends Node
class_name NGUtils

func get_session_id_from_url() -> String:
	var js : String = 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	var result : String  = str(JavaScriptBridge.eval(js, true))
	return result

func encrypt_data(data: String, AES_KEY: String) -> String:
	var aes: AESContext = AESContext.new()
	var key: PackedByteArray = Marshalls.base64_to_raw(AES_KEY)
	var iv: PackedByteArray = generate_random_iv(16)

	var data_bytes: PackedByteArray = data.to_utf8_buffer()
	data_bytes = pad_buffer(data_bytes)

	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	var encrypted: PackedByteArray = aes.update(data_bytes)
	aes.finish()

	var combined: PackedByteArray = iv + encrypted
	return Marshalls.raw_to_base64(combined)

func generate_random_iv(size: int) -> PackedByteArray:
	var crypto : Crypto = Crypto.new()
	return crypto.generate_random_bytes(size)

func pad_buffer(data: PackedByteArray) -> PackedByteArray:
	var padding_needed: int = (16 - data.size() % 16) % 16
	for i in range(padding_needed):
		data.push_back(padding_needed)  # PKCS#7 padding
	return data
