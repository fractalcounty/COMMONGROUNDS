/*
Squish Sprite Shader by Garmelon (https://github.com/Garmelon)
Documented by Mateus-Carmo31
*/

shader_type canvas_item;

uniform bool uv_mode = false;
uniform float x_factor = 2.0;
uniform float bulge : hint_range(-1,1);

void vertex()
{
	// Stretches the sprite along the x axis by the x_factor.
	// This essentially increases the bounds in which the sprite can be drawn,
	// allowing the sprite to bulge outwards appropriately.
	VERTEX.x *= x_factor;
}

// Describes how the sprite bulges. Right now, it's a simple half-circle function.
// Changing it modifies how the bulges will look like.
// Must be a function in which the x will be between 0 and 1 for y between -1 and 1.
float bulge_function(float y)
{
	return sqrt(1.0 - y*y);
}

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    uv.x *= x_factor;

    float displacement = 1.0 + bulge * bulge_function(uv.y);
    uv.x /= displacement;
    uv = (uv + 1.0) / 2.0;

    if (uv_mode) {
        COLOR = uv.x >= 0.0 && uv.x <= 1.0 ? vec4(uv, 0.0, 1.0) : vec4(vec3(0.0), 1.0);
    } else {
        // Checks for uv values outside the texture, and draws them as transparent,
        // allowing the "indentation" effect when bulge = 0.0 && uv.x <= 1.0)
        if (uv.x < 0.0 || uv.x > 1.0) {
            COLOR = vec4(0.0);
        } else {
            COLOR = texture(TEXTURE, uv);
        }
    }
}
