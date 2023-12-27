/*
©Lunar Candor
https://lunarcandor.itch.io/
This work is licensed under a Creative Commons Attribution 4.0 International (CC-BY 4.0 Intl.) License.
https://creativecommons.org/licenses/by/4.0/
*/

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 blur_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float blur_amount: hint_range(0.0, 5.0) = 1.0;

void fragment(){
	vec3 color_mix = texture(SCREEN_TEXTURE, SCREEN_UV, blur_amount).rgb;
	color_mix = mix(color_mix, blur_color.rgb, blur_color.a);
	COLOR = vec4(color_mix, 1.0);
}
