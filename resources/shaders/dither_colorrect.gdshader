/*
 * This should be your main shader file if using with a ColorRect.
*/

shader_type canvas_item;
// This file relies on a dither shader include file, listed further down.
// The paths must match your file's location.
#include "res://resources/shaders/dither.gdshaderinc"
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
    g_model_matrix = MODEL_MATRIX;
    g_world_to_clip = SCREEN_MATRIX * CANVAS_MATRIX;
    g_world_vertex = (MODEL_MATRIX * vec4(VERTEX, 0, 1)).xy;
}

void fragment() {
    COLOR = ditherScreen(SCREEN_TEXTURE, SCREEN_UV);
}