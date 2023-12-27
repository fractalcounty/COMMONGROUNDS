/*
 * This is the dither shader-include file. Please make a copy in a
 * separate file, and update the #include in the main shader to match.
*/

// This file relies on a quantize shader include file, listed further down.
// The paths must match your file's location.
#include "res://resources/shaders/quantize.gdshaderinc"
uniform bool dither_enabled = true;
// The Bayer matrix pattern to use
// 1 -> 2x2, 2 -> 4x4, 3 -> 8x8
uniform float bayer_pattern : hint_range(1, 3, 1.0) = 1;
uniform float divisions : hint_range(1, 16, 1.0) = 1.0;
uniform float contrast : hint_range(0, 4) = 1.0;
uniform float shift : hint_range (-1, 1) = 0;
uniform bool grayscale;
uniform bool use_palette;
uniform sampler2D palette;

const int matrix2[4] = {
    0, 2,
    3, 1
};
const int matrix4[16] = {
    0,  8,  2,  10,
    12, 4,  14, 6,
    3,  11, 1,  9,
    15, 7,  13, 5
};
const int matrix8[64] = {
    0,  32, 8,  40, 2,  34, 10, 42,
    48, 16, 56, 24, 50, 18, 58, 26,
    12, 44, 4,  36, 14, 46, 6,  38,
    60, 28, 52, 20, 62, 30, 54, 22,
    3,  35, 11, 43, 1,  33, 9,  41,
    51, 19, 59, 27, 49, 17, 57, 25,
    15, 47, 7,  39, 13, 45, 5,  37,
    63, 31, 55, 23, 61, 29, 53, 21
};

int getBayerValue(float dSize) {
    int iDSize = int(dSize);
    float qSize = quantize_size == 0. ? 1. : quantize_size;
    ivec2 iv = ivec2(mod(g_world_vertex, dSize * qSize));
    iv /= int(qSize);
    int index = iv.x + (iv.y * iDSize);

    switch (iDSize) {
        case 2:
            return matrix2[index];
        case 4:
            return matrix4[index];
        default:
            return matrix8[index];
    }
}

vec4 dither_internal(vec4 in_c, bool cut_alpha) {
    if (!dither_enabled) {
        return in_c;
    }

    vec3 c = in_c.rgb;

    if (cut_alpha) {
        c = vec3(1. - in_c.a);
    }

    // Get dither size based on matrix selected
    float dSize = pow(2.0, bayer_pattern);
    float dSquared = dSize * dSize;
    // Get space between divisions
    float div = divisions;

    if (use_palette) {
        ivec2 pSize = textureSize(palette, 0);
        pSize /= pSize.y;
        div = float(pSize.x) - 1.0;

        c = vec3((c.r * 0.299) + (c.g * 0.587) + (c.b * 0.114));
    }

    // add contrast and shift
    c = (c - 0.5 + shift) * contrast + 0.5;
    c = clamp(c, 0.0, 1.0);

    // get dither value
    int d = getBayerValue(dSize);

    // normalize the dither value
    float dN = (float(d) / dSquared) - 0.5;
    // get the normalizing value for the division gap
    float r = 1.0 / div;
    float l = r / (dSquared * 2.);

    c += r * dN + l; // add dither value to color
    c *= div; // convert normalized color to quantized range
    c = round(c); // round to nearest available color
    c /= div; // normalize again

    c = mix(c, texture(palette, vec2(c.r, 0.5)).rgb, float(use_palette));
    c = mix(c, vec3((c.r + c.g + c.b) / 3.0), float(grayscale));

    return vec4(c.rgb, in_c.a);
}

vec4 ditherTexture(sampler2D in_texture, vec2 in_uv) {
    vec4 out_c = quantizeTexture(in_texture, in_uv);
    return dither_internal(out_c, false);
}

vec4 ditherScreen(sampler2D in_texture, vec2 in_uv) {
    vec4 out_c = quantizeScreen(in_texture, in_uv);
    return dither_internal(out_c, false);
}