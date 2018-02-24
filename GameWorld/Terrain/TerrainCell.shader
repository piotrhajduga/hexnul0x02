shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back;

uniform float terrain_height_scale : hint_range(1.0,100.0);

uniform float stone_min_angle;
uniform vec4 stone_albedo : hint_color;
uniform sampler2D stone_texture_albedo : hint_albedo;
uniform float stone_roughness : hint_range(0,1);
uniform sampler2D stone_texture_roughness : hint_white;
uniform sampler2D stone_texture_normal : hint_normal;
uniform float stone_normal_scale : hint_range(-16,16);

uniform float snow_height;
uniform vec4 snow_albedo : hint_color;
uniform sampler2D snow_texture_albedo : hint_albedo;
uniform float snow_roughness : hint_range(0,1);
uniform sampler2D snow_texture_roughness : hint_white;
uniform sampler2D snow_texture_normal : hint_normal;
uniform float snow_normal_scale : hint_range(-16,16);

uniform float gravel_height;
uniform vec4 gravel_albedo : hint_color;
uniform sampler2D gravel_texture_albedo : hint_albedo;
uniform float gravel_roughness : hint_range(0,1);
uniform sampler2D gravel_texture_roughness : hint_white;
uniform sampler2D gravel_texture_normal : hint_normal;
uniform float gravel_normal_scale : hint_range(-16,16);

uniform float grass_height;
uniform vec4 grass_albedo : hint_color;
uniform sampler2D grass_texture_albedo : hint_albedo;
uniform float grass_roughness : hint_range(0,1);
uniform sampler2D grass_texture_roughness : hint_white;
uniform sampler2D grass_texture_normal : hint_normal;
uniform float grass_normal_scale : hint_range(-16,16);

uniform float sand_height;
uniform vec4 sand_albedo : hint_color;
uniform sampler2D sand_texture_albedo : hint_albedo;
uniform float sand_roughness : hint_range(0,1);
uniform sampler2D sand_texture_roughness : hint_white;
uniform sampler2D sand_texture_normal : hint_normal;
uniform float sand_normal_scale : hint_range(-16,16);

uniform float water_height;
uniform vec4 water_albedo : hint_color;
uniform sampler2D water_texture_albedo : hint_albedo;
uniform float water_roughness : hint_range(0,1);
uniform sampler2D water_texture_roughness : hint_white;
uniform sampler2D water_texture_normal : hint_normal;
uniform float water_normal_scale : hint_range(-16,16);

uniform sampler2D cell_texture_mask;

//uniform vec4 roughness_texture_channel;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

varying float stone_weight;
varying float snow_weight;
varying float gravel_weight;
varying float grass_weight;
varying float sand_weight;
varying float water_weight;
varying highp float angle;

uniform float PI = 3.1415;

void vertex() {
	float height = sqrt((WORLD_MATRIX * vec4(VERTEX,1.0)).y / terrain_height_scale) * (1.0 - water_height) + water_height;
	vec3 base_normal = normalize((WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	angle = acos(dot(vec3(0.0,1.0,0.0),base_normal));
	COLOR = vec4(angle/PI,1.00-angle/PI,0.00,1.00);
	
	UV=UV*uv1_scale.xy+uv1_offset.xy;

	stone_weight = 0.0;
	snow_weight = 0.0;
	gravel_weight = 0.0;
	grass_weight = 0.0;
	sand_weight = 0.0;
	water_weight = 0.0;
	
	if (acos(dot(NORMAL,vec3(0.0,1.0,0.0))) > stone_min_angle) {
		stone_weight = 1.0;
	} else if (height > snow_height) {
		snow_weight = 1.0;
	} else if (height > gravel_height) {
		gravel_weight = 1.0;
	} else if (height > grass_height) {
		grass_weight = 1.0;
	} else if (height > sand_height) {
		sand_weight = 1.0;
	} else {
		water_weight = 1.0;
	}
}

void fragment() {
	float weights_sum = 0.0;

	vec3 albedo = vec3(0.0);
	float roughness = 0.0;
	vec3 normalmap = vec3(0.0);
	float normalmap_depth = 0.0;

	//stone
	albedo += stone_albedo.rgb * texture(stone_texture_albedo,UV).rgb * stone_weight;
	roughness += stone_roughness * stone_weight;
	normalmap += texture(stone_texture_normal,UV).rgb * stone_weight;
	normalmap_depth += stone_normal_scale * stone_weight;
	weights_sum += stone_weight;

	//snow
	albedo += snow_albedo.rgb * texture(snow_texture_albedo,UV).rgb * snow_weight;
	roughness += snow_roughness * snow_weight;
	normalmap += texture(snow_texture_normal,UV).rgb * snow_weight;
	normalmap_depth += snow_normal_scale * snow_weight;
	weights_sum += snow_weight;

	//gravel
	albedo += gravel_albedo.rgb * texture(gravel_texture_albedo,UV).rgb * gravel_weight;
	roughness += gravel_roughness * gravel_weight;
	normalmap += texture(gravel_texture_normal,UV).rgb * gravel_weight;
	normalmap_depth += gravel_normal_scale * gravel_weight;
	weights_sum += gravel_weight;

	//grass
	albedo += grass_albedo.rgb * texture(grass_texture_albedo,UV).rgb * grass_weight;
	roughness += grass_roughness * grass_weight;
	normalmap += texture(grass_texture_normal,UV).rgb * grass_weight;
	normalmap_depth += grass_normal_scale * grass_weight;
	weights_sum += grass_weight;

	//sand
	albedo += sand_albedo.rgb * texture(sand_texture_albedo,UV).rgb * sand_weight;
	roughness += sand_roughness * sand_weight;
	normalmap += texture(sand_texture_normal,UV).rgb * sand_weight;
	normalmap_depth += sand_normal_scale * sand_weight;
	weights_sum += sand_weight;

	//water
	albedo += water_albedo.rgb * texture(water_texture_albedo,UV).rgb * water_weight;
	roughness += water_roughness * water_weight;
	normalmap += texture(water_texture_normal,UV).rgb * water_weight;
	normalmap_depth += water_normal_scale * water_weight;
	weights_sum += water_weight;

	// set values:
	ALBEDO = (albedo / weights_sum);
	
	float radius = length(UV - vec2(0.5,0.5));
	ALPHA = (radius<0.3) ? 1.0 : (1.3 - radius);
	
	ROUGHNESS = roughness / weights_sum;
	NORMALMAP = normalmap / weights_sum;
	NORMALMAP_DEPTH = normalmap_depth / weights_sum;
}
