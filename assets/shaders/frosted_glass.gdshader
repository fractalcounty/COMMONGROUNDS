shader_type canvas_item;

// Uniforms for customization
uniform float blur_amount : hint_range(-2.0, 10.0); // Blur intensity
uniform float mix_amount : hint_range(0.0, 1.0); // Mix between original and blurred image
uniform vec4 color_over : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	vec4 fin = mix(blurred, color_over, mix_amount);
	COLOR = fin;
}