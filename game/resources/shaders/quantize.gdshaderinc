/*
 * This is the quantize shader-include file. Please make a copy in a
 * separate file, and update the #include in the dither shader-include to match.
*/

uniform bool align_center;
uniform float quantize_size : hint_range(0,100, 1.0) = 1;

varying mat4 g_model_matrix;
varying mat4 g_world_to_clip;
varying vec2 g_world_vertex;
varying vec2 g_texture_size;

vec2 getTextureVertex(mat4 in_model_matrix, vec2 in_uv, vec2 in_texture_size) {
    vec2 vert = in_uv;

    if (align_center) {
        vert -= 0.5;
    }

    vert = vert * in_texture_size;
    return (in_model_matrix * vec4(vert, 0, 1)).xy;
}

vec4 quantizeTexture(sampler2D in_texture, vec2 in_uv) {
    if (quantize_size == 0.) {
        return texture(in_texture, in_uv);
    }

    vec2 out_uv = g_world_vertex;
    out_uv /= quantize_size;
    out_uv = floor(out_uv) + 0.5;
    out_uv *= quantize_size;
    out_uv = (inverse(g_model_matrix) * vec4(out_uv, 0, 1)).xy;
    out_uv /= g_texture_size;

    if (align_center) {
        out_uv += 0.5;
    }

    return texture(in_texture, out_uv);
}

vec4 quantizeScreen(sampler2D screen_texture, vec2 screen_uv) {
    if (quantize_size == 0.) {
        return texture(screen_texture, screen_uv);
    }

    vec2 out_uv = g_world_vertex;
    out_uv /= quantize_size;
    out_uv = floor(out_uv) + 0.5;
    out_uv *= quantize_size;
    out_uv = (g_world_to_clip * vec4(out_uv, 0, 1)).xy;
    out_uv = out_uv * 0.5 + 0.5;
    return texture(screen_texture, out_uv);
}