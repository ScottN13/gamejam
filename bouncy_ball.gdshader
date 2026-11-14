shader_type canvas_item;

uniform vec4 bg_top : source_color = vec4(0.10, 0.12, 0.30, 1.0);
uniform vec4 bg_bottom : source_color = vec4(0.35, 0.20, 0.45, 1.0);
uniform vec4 floor_color : source_color = vec4(0.06, 0.05, 0.14, 1.0);
uniform vec4 ball_color : source_color = vec4(1.0, 0.35, 0.30, 1.0);
uniform vec4 ball_highlight : source_color = vec4(1.0, 0.85, 0.75, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

uniform float ball_radius : hint_range(0.02, 0.2) = 0.07;
uniform float floor_y : hint_range(0.5, 0.98) = 0.88;
uniform float bounce_height : hint_range(0.1, 0.8) = 0.55; // fraction of screen height
uniform float bounce_speed : hint_range(0.2, 3.0) = 0.8;   // bounces per second
uniform float drift_speed : hint_range(0.0, 1.0) = 0.12;   // side-to-side travel
uniform float squash_amount : hint_range(0.0, 0.8) = 0.4;
uniform float stretch_amount : hint_range(0.0, 0.5) = 0.15;

void fragment() {
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 p = vec2(UV.x * aspect, UV.y);

	// Parabolic bounce: h is 0 on the floor, 1 at the apex
	float u = fract(TIME * bounce_speed);
	float h = 4.0 * u * (1.0 - u);

	// Squash near the floor, stretch when moving fast
	float contact = pow(1.0 - h, 6.0);
	float fast = pow(abs(1.0 - 2.0 * u), 2.0);
	float squash = contact * squash_amount;
	float stretch = (1.0 - contact) * fast * stretch_amount;
	vec2 sc = vec2(1.0 + squash - stretch, 1.0 - squash + stretch);

	// Horizontal ping-pong between the screen edges
	float tx = abs(fract(TIME * drift_speed) * 2.0 - 1.0);
	float margin = ball_radius * 1.6;
	float cx = mix(margin, aspect - margin, tx);

	// Keep the ball's bottom on the floor while squashing
	vec2 r = ball_radius * sc;
	vec2 c = vec2(cx, floor_y - h * bounce_height - r.y);

	// Background and floor
	vec3 col = mix(bg_top.rgb, bg_bottom.rgb, UV.y);
	col = mix(col, floor_color.rgb, smoothstep(floor_y - 0.003, floor_y + 0.003, UV.y));

	// Shadow shrinks and fades as the ball rises
	float sh_scale = 1.0 - h * 0.6;
	vec2 sd = (p - vec2(cx, floor_y + 0.012)) /
		vec2(ball_radius * 1.3 * sh_scale, ball_radius * 0.25 * sh_scale);
	float shadow = (1.0 - smoothstep(0.0, 1.0, length(sd))) * (1.0 - h * 0.6);
	col = mix(col, shadow_color.rgb, shadow * shadow_color.a);

	// Ball (stretched ellipse) with a simple highlight
	vec2 d = (p - c) / r;
	float dist = length(d);
	float mask = 1.0 - smoothstep(0.97, 1.0, dist);
	float spec = smoothstep(0.55, 0.0, length(d - vec2(-0.35, -0.35)));
	vec3 ball = mix(ball_color.rgb, ball_highlight.rgb, spec * 0.8);
	ball *= 1.0 - 0.3 * smoothstep(0.5, 1.0, dist);
	col = mix(col, ball, mask);

	COLOR = vec4(col, 1.0);
}