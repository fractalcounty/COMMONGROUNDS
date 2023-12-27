shader_type canvas_item;

uniform float INTENSITY : hint_range(0.0, 1.0) = 0.075;
uniform float MEAN : hint_range(-1.0, 1.0) = 0.0; // Gray level noise should tend to
uniform float VARIANCE : hint_range(0.0, 1.0) = 0.5; // Contrast/variance of noise.

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    color.rgb = pow(color.rgb, vec3(2.2)); // simulating global srgb

    // Noise generation
    float timeFactor = TIME * 0.1;
    vec2 uv = SCREEN_UV;
    float seed = dot(uv, vec2(12.9898, 78.233)) + timeFactor;
    float noise = fract(sin(seed) * 43758.5453);
    noise = (1.0 / (VARIANCE * sqrt(2.0 * 3.1415))) * exp(-(((noise - MEAN) * (noise - MEAN)) / (2.0 * (VARIANCE * VARIANCE))));

    vec3 grain = vec3(noise) * (1.0 - color.rgb);
    color.rgb += grain * INTENSITY;
 
    color.rgb = pow(color.rgb, vec3(1.0 / 2.2)); // simulating global srgb 

    COLOR = color;
}