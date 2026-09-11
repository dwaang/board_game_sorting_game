shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

/** Retro pixel size (0.0 disables pixelation) */
uniform float pixel_size : hint_range(0.0, 4.0) = 0.0;

/** Screen background blur amount */
uniform float lod_blur : hint_range(0.0, 1.0) = 0.0;

/** Chromatic aberration color offset in pixels */
uniform float chroma_offset_px : hint_range(0.0, 3.0) = 0.1;

/** Image color saturation */
uniform float saturation : hint_range(0.0, 2.0) = 1.1;

/** Image contrast level */
uniform float contrast : hint_range(0.5, 1.5) = 1.2;

/** Brightness lift for darkest shadow areas */
uniform float shadow_lift : hint_range(0.0, 0.25) = 0.16;

/** Horizontal scanline strength */
uniform float scanline_strength : hint_range(0.0, 0.50) = 0.005;

/** Vertical aperture grille strength (CRT grid) */
uniform float grille_strength : hint_range(0.0, 0.50) = 0.1;

/** Width of a single vertical grille line in pixels */
uniform float grille_size : hint_range(1.0, 4.0) = 1.0;

/** Vignette screen corner darkening strength */
uniform float vignette_strength : hint_range(0.0, 0.5) = 0.10;

/** Static analog noise and grain intensity */
uniform float noise_strength : hint_range(0.0, 0.12) = 0.0;

/** Speed of animated noise */
uniform float noise_speed : hint_range(0.0, 60.0) = 0.0;

/** Horizontal line jitter offset in pixels */
uniform float base_jitter_px : hint_range(0.0, 1.0) = 0.4;

/** Jitter animation speed */
uniform float base_jitter_speed : hint_range(0.0, 40.0) = 10.0;

/** Frequency and chance of glitch bursts */
uniform float glitchiness : hint_range(0.0, 1.0) = 0.0;

/** Glitch phase update rate */
uniform float glitch_rate : hint_range(0.0, 20.0) = 0.0;

/** Maximum horizontal line shift during glitch in pixels */
uniform float glitch_shift_px : hint_range(0.0, 8.0) = 0.0;

/** Minimum glitch distortion window height */
uniform float glitch_window_min : hint_range(0.0, 1.0) = 0.0;

/** Maximum glitch distortion window height */
uniform float glitch_window_max : hint_range(0.2, 1.0) = 0.0;

/** Starting Y coordinate for the tracking blue band */
uniform float blue_band_start_y : hint_range(0.0, 1.0) = 0.0;

/** Vertical speed of the tracking band */
uniform float blue_band_speed : hint_range(-2.0, 2.0) = 0.5;

/** Width of the tracking band distortion area */
uniform float blue_band_width : hint_range(0.001, 0.20) = 0.003;

/** Blue tint color strength in the band */
uniform float blue_band_strength : hint_range(0.0, 1.0) = 0.01;

/** Band jumpiness and instability */
uniform float blue_band_glitch : hint_range(0.0, 1.0) = 0.0;

/** Screen distortion inside the tracking band in pixels */
uniform float blue_band_distort_px : hint_range(0.0, 10.0) = 5.0;

float hash11(float p) {
	return fract(sin(p * 127.1) * 43758.5453123);
}

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec3 sat_adjust(vec3 c, float s) {
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	return mix(vec3(l), c, s);
}

vec3 sample_screen(vec2 uv, float lod) {
	return textureLod(screen_texture, clamp(uv, vec2(0.0), vec2(1.0)), lod).rgb;
}

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	vec2 uv = SCREEN_UV;
	float t = TIME;
	float line_id = floor(FRAGCOORD.y);

	if (pixel_size > 0.001) {
		vec2 block = px * pixel_size;
		uv = floor(uv / block) * block;
	}

	float line_wobble = hash21(vec2(line_id, floor(t * base_jitter_speed)));
	uv.x += (line_wobble - 0.5) * base_jitter_px * px.x;

	float burst_id = floor(t * glitch_rate);
	float burst_rand = hash11(burst_id + 3.17);
	float burst_on = step(1.0 - glitchiness, burst_rand);

	float glitch_center = hash11(burst_id + 8.41);
	float glitch_half_height = mix(glitch_window_min, glitch_window_max, hash11(burst_id + 11.72));
	float glitch_mask = burst_on * (1.0 - smoothstep(0.0, glitch_half_height, abs(SCREEN_UV.y - glitch_center)));

	float glitch_line = hash21(vec2(line_id, burst_id + 31.3));
	uv.x += (glitch_line - 0.5) * glitch_shift_px * px.x * glitch_mask;

	float band_tick = floor(t * 10.0);
	float band_jump = (hash11(band_tick + 55.2) - 0.5) * blue_band_glitch * 0.25;
	float band_center = fract(blue_band_start_y + t * blue_band_speed + band_jump);

	float band_dist = abs(SCREEN_UV.y - band_center);
	band_dist = min(band_dist, 1.0 - band_dist);

	float band_mask = exp(
		-(band_dist * band_dist) /
		max(blue_band_width * blue_band_width, 0.000001)
	);

	float band_line = hash21(vec2(line_id, floor(t * 22.0) + 77.0));
	uv.x += (band_line - 0.5) * blue_band_distort_px * px.x * band_mask;

	vec2 chroma_off = vec2(chroma_offset_px * px.x, 0.0);
	float r = sample_screen(uv + chroma_off, lod_blur).r;
	float g = sample_screen(uv, lod_blur).g;
	float b = sample_screen(uv - chroma_off, lod_blur).b;

	vec3 col = vec3(r, g, b);

	col = sat_adjust(col, saturation);
	col = (col - vec3(0.5)) * contrast + vec3(0.5);
	col += shadow_lift;

	col += vec3(0.02, 0.07, 0.18) * band_mask * blue_band_strength;

	float grain = hash21(
		floor(FRAGCOORD.xy * 0.75) +
		vec2(floor(t * noise_speed), floor(t * noise_speed * 0.73))
	);

	float line_snow = hash21(vec2(line_id, floor(t * noise_speed * 0.5) + 100.0));

	col += ((grain - 0.5) * 0.7 + (line_snow - 0.5) * 0.3) * noise_strength;

	float scan = sin((FRAGCOORD.y + t * 8.0) * 1.1) * 0.5 + 0.5;
	col *= 1.0 - scan * scanline_strength;

	float grille = sin((FRAGCOORD.x / grille_size) * 3.1415926) * 0.5 + 0.5;
	col *= 1.0 - grille * grille_strength;

	vec2 centered = SCREEN_UV * 2.0 - 1.0;
	float vig = dot(centered, centered);
	col *= 1.0 - vig * vignette_strength;

	COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), 1.0);
}
