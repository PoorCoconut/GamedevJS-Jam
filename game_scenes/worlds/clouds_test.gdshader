shader_type canvas_item;

// 1. Absolute Sizing Parameters
uniform vec2 rect_size = vec2(18137.0, 5724.0); // Enter your ColorRect's exact X and Y size here
uniform float pixel_block_size = 1.0; // 1.0 = true 1:1 pixels. 2.0 = chunky 2x2 blocks, etc.
uniform vec2 noise_texture_size = vec2(512.0, 512.0); // The size of your Cloud Noise images

// 2. Add : repeat_enable so Godot knows to tile the texture endlessly
uniform sampler2D cloud_noise1 : repeat_enable; 
uniform vec2 scroll_speed1 = vec2(0.02, 0.007); 

uniform sampler2D cloud_noise2 : repeat_enable; 
uniform vec2 scroll_speed2 = vec2(-0.015, -0.004); 

uniform vec2 center_pos = vec2(0.5, 0.0); 
uniform float position_impact : hint_range(0.0, 1.0, 0.01) = 0.75;
uniform sampler2D color_gardient; 

void fragment() {
	// Convert the 0-1 UV into absolute pixel coordinates based on the rect size
	vec2 absolute_pixel = UV * rect_size;
	
	// Snap the coordinates to create the pixelated block effect
	vec2 snapped_pixel = floor(absolute_pixel / pixel_block_size) * pixel_block_size;
	
	// Convert back to a UV scale specifically for the noise texture to force tiling
	vec2 noise_uv = snapped_pixel / noise_texture_size;

	// Apply the scrolling time offset
	vec2 noise1uv = noise_uv + TIME * scroll_speed1;
	vec2 noise2uv = noise_uv + TIME * scroll_speed2;
	
	// Sample both noises and average them
	vec4 noise_col = (texture(cloud_noise1, noise1uv) + texture(cloud_noise2, noise2uv)) * 0.5;
	
	// Calculate the center distance for the radial gradient
	// We use the original 0-1 UV space here so the gradient stays anchored to the rectangle
	vec2 pixel_uv = floor(UV * (rect_size / pixel_block_size)) / (rect_size / pixel_block_size);
	float dist = distance(pixel_uv, center_pos);
	vec2 furthest = vec2(-min(sign(center_pos.x - 0.5), 0.0), -min(sign(center_pos.y - 0.5), 0.0));
	float max_dist = distance(center_pos, furthest);
	dist /= max_dist;
		// Mix and apply the final color ramp
	float final = mix(1.0 - noise_col.r, dist, position_impact);
	COLOR = texture(color_gardient, vec2(final, final));
}