shader_type canvas_item;

const int MAX_BLOBS = 32;
uniform int blob_count : hint_range(1, 32) = 12;
// per blob: x = horizontal pos (0..1), y = radius, z = speed multiplier, w = phase offset
uniform vec4 blob_data[MAX_BLOBS];

uniform vec4 bg_top : source_color = vec4(0.08, 0.02, 0.25, 1.0);
uniform vec4 bg_bottom : source_color = vec4(0.30, 0.02, 0.20, 1.0);
uniform vec4 blob_low : source_color = vec4(1.0, 0.25, 0.15, 1.0);
uniform vec4 blob_high : source_color = vec4(1.0, 0.75, 0.25, 1.0);
uniform float speed : hint_range(0.1, 2.0) = 0.5;
uniform float bounce : hint_range(0.0, 1.0) = 0.45;   // how far globs travel vertically
uniform float threshold : hint_range(0.5, 2.0) = 1.0; // higher = smaller, tighter blobs
uniform float softness : hint_range(0.01, 0.3) = 0.06;

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 p = vec2(UV.x * aspect, UV.y);

	float field = 0.0;
	for (int i = 0; i < MAX_BLOBS; i++) {
		if (i >= blob_count) break;
		vec4 b = blob_data[i];

		float t = TIME * speed * b.z + b.w;
		float x = b.x * aspect + sin(t * 0.7) * 0.05;
		float y = 0.5 + bounce * (sin(t) + 0.25 * sin(t * 2.3)) * 0.8;
		float r = b.y;

		float d = length(p - vec2(x, y));
		field += (r * r) / (d * d + 0.0001);
	}

	vec4 bg = mix(bg_top, bg_bottom, UV.y);
	vec4 blob = mix(blob_high, blob_low, UV.y);

	float body = smoothstep(threshold - softness, threshold + softness, field);
	float glow = smoothstep(0.3, threshold, field) * 0.25;

	COLOR = mix(bg, blob, body) + blob * glow * (1.0 - body);
}