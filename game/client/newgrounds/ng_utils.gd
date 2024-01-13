extends Node
class_name NGEncrypt

static func encrypt(content: String, AES_KEY: String) -> String:
	Log.debug("CryptoHelper.gd encrypting data input: {content}".format({"content": content}))
	var aes = AESContext.new()
	var iv = generate_iv()
	var aes_key_bytes = Marshalls.base64_to_raw(AES_KEY)
	
	var error = aes.start(AESContext.MODE_CBC_ENCRYPT, aes_key_bytes, iv)
	if error != OK:
		Log.error("CryptoHelper.gd Error starting AES context: " + str(error))
		return "Error starting AES encryption"

	var contentBuffer = content.to_utf8_buffer()
	padding(contentBuffer)
	
	var encrypted = aes.update(contentBuffer)
	aes.finish()
	
	var res = iv
	res.append_array(encrypted)
	var encoded = Marshalls.raw_to_base64(res)
	Log.debug("CryptoHelper.gd encrypted data output (base64): " + encoded)
	return encoded

static func padding(content: PackedByteArray):
	var contentSize = content.size()
	var padding = 16 - contentSize % 16
	if padding > 0:
		var newSize = contentSize + padding
		content.resize(newSize);
		var pbyte = padding;
		for i in range(padding):
			content.set(newSize - i - 1, pbyte)

static func generate_iv() -> PackedByteArray:
	var arr = PackedByteArray()
	arr.resize(16)
	for i in range(16):
		arr.set(i, randi() % 0xff)
	return arr
