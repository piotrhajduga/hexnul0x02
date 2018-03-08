shader_type spatial;
render_mode depth_draw_opaque,cull_back,diffuse_burley;

uniform float terrain_height_scale : hint_range(1.0,100.0);

uniform float stone_min_angle;
uniform vec4 stone_albedo : hint_color;
uniform float stone_roughness : hint_range(0,1);
uniform float stone_normal_scale : hint_range(-16,16);
uniform sampler2D stone_texture_albedo : hint_albedo;
uniform sampler2D stone_texture_roughness : hint_white;
uniform sampler2D stone_texture_normal : hint_normal;

uniform float snow_height;
uniform vec4 snow_albedo : hint_color;
uniform float snow_roughness : hint_range(0,1);
uniform float snow_normal_scale : hint_range(-16,16);
uniform sampler2D snow_texture_albedo : hint_albedo;
uniform sampler2D snow_texture_roughness : hint_white;
uniform sampler2D snow_texture_normal : hint_normal;

uniform float gravel_height;
uniform vec4 gravel_albedo : hint_color;
uniform float gravel_roughness : hint_range(0,1);
uniform float gravel_normal_scale : hint_range(-16,16);
uniform sampler2D gravel_texture_albedo : hint_albedo;
uniform sampler2D gravel_texture_roughness : hint_white;
uniform sampler2D gravel_texture_normal : hint_normal;

uniform float grass_height;
uniform vec4 grass_albedo : hint_color;
uniform float grass_roughness : hint_range(0,1);
uniform float grass_normal_scale : hint_range(-16,16);
uniform sampler2D grass_texture_albedo : hint_albedo;
uniform sampler2D grass_texture_roughness : hint_white;
uniform sampler2D grass_texture_normal : hint_normal;

uniform float sand_height;
uniform vec4 sand_albedo : hint_color;
uniform float sand_roughness : hint_range(0,1);
uniform float sand_normal_scale : hint_range(-16,16);
uniform sampler2D sand_texture_albedo : hint_albedo;
uniform sampler2D sand_texture_roughness : hint_white;
uniform sampler2D sand_texture_normal : hint_normal;

uniform float water_height;
uniform vec4 water_albedo : hint_color;
uniform float water_roughness : hint_range(0,1);
uniform float water_normal_scale : hint_range(-16,16);
uniform sampler2D water_texture_albedo : hint_albedo;
uniform sampler2D water_texture_roughness : hint_white;
uniform sampler2D water_texture_normal : hint_normal;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform float mask_radius = 0.9;
uniform float mask_weight = 0.6;
uniform vec4 mask_color : hint_color;

varying float stone_weight;
varying float snow_weight;
varying float gravel_weight;
varying float grass_weight;
varying float sand_weight;
varying float water_weight;
varying highp float angle;

uniform float PI = 3.1415;
uniform float center_weight = 2.0;

varying float mask_edge_weight;

void vertex() {
	float height = sqrt((WORLD_MATRIX * vec4(VERTEX,1.0)).y / terrain_height_scale) * (1.0 - water_height) + water_height;
	vec3 base_normal = normalize((WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	UV=UV*uv1_scale.xy+uv1_offset.xy;

	stone_weight = 0.0;
	snow_weight = 0.0;
	gravel_weight = 0.0;
	grass_weight = 0.0;
	sand_weight = 0.0;
	water_weight = 0.0;
	
	mask_edge_weight = 1.0;
	
	float weight = 1.0/center_weight;
	if (length(VERTEX.xz) < 0.5) {
		mask_edge_weight = 0.0;
		weight = 1.0;
	}

	if (acos(dot(base_normal,vec3(0.0,1.0,0.0))) > stone_min_angle) {
		stone_weight = weight;
	} else if (height > snow_height) {
		snow_weight = weight;
	} else if (height > gravel_height) {
		gravel_weight = weight;
	} else if (height > grass_height) {
		grass_weight = weight;
	} else if (height > sand_height) {
		sand_weight = weight;
	} else {
		water_weight = weight;
	}
}

void fragment() {
	float weight = 0.0;
	float weights_sum = 0.0;

	vec3 albedo = vec3(0.0);
	float roughness = 0.0;
	vec3 normalmap = vec3(0.0);
	float normalmap_depth = 0.0;
	
	//stone
	weight = smoothstep(0.0,1.0,stone_weight);
	albedo += stone_albedo.rgb * texture(stone_texture_albedo,UV).rgb * weight;
	roughness += stone_roughness * weight;
	normalmap += texture(stone_texture_normal,UV).rgb * weight;
	normalmap_depth += stone_normal_scale * weight;
	weights_sum += weight;

	//snow
	weight = smoothstep(0.0,1.0,snow_weight);
	albedo += snow_albedo.rgb * texture(snow_texture_albedo,UV).rgb * weight;
	roughness += snow_roughness * weight;
	normalmap += texture(snow_texture_normal,UV).rgb * weight;
	normalmap_depth += snow_normal_scale * weight;
	weights_sum += weight;

	//gravel
	weight = smoothstep(0.0,1.0,gravel_weight);
	albedo += gravel_albedo.rgb * texture(gravel_texture_albedo,UV).rgb * weight;
	roughness += gravel_roughness * weight;
	normalmap += texture(gravel_texture_normal,UV).rgb * weight;
	normalmap_depth += gravel_normal_scale * weight;
	weights_sum += weight;

	//grass
	weight = smoothstep(0.0,1.0,grass_weight);
	albedo += grass_albedo.rgb * texture(grass_texture_albedo,UV).rgb * weight;
	roughness += grass_roughness * weight;
	normalmap += texture(grass_texture_normal,UV).rgb * weight;
	normalmap_depth += grass_normal_scale * weight;
	weights_sum += weight;

	//sand
	weight = smoothstep(0.0,1.0,sand_weight);
	albedo += sand_albedo.rgb * texture(sand_texture_albedo,UV).rgb * weight;
	roughness += sand_roughness * weight;
	normalmap += texture(sand_texture_normal,UV).rgb * weight;
	normalmap_depth += sand_normal_scale * weight;
	weights_sum += weight;

	//water
	weight = smoothstep(0.0,1.0,water_weight);
	albedo += water_albedo.rgb * texture(water_texture_albedo,UV + vec2(sin(2.0*TIME),cos(2.0*TIME))*0.02).rgb * weight;
	roughness += water_roughness * weight;
	normalmap += texture(water_texture_normal,UV + vec2(cos(4.0*TIME),sin(4.0*TIME))*0.03).rgb * weight;
	normalmap_depth += (water_normal_scale) * weight;
	weights_sum += weight;

	// set values:
	float fragment_mask_weight = 0.0;
	if (mask_edge_weight >= mask_radius) {
		fragment_mask_weight = mask_weight * (1.0 - ((1.0 - mask_edge_weight) / (1.0 - mask_radius)));
	}
	
	ALBEDO = (albedo / weights_sum) * (1.0 - fragment_mask_weight) + mask_color.rgb * fragment_mask_weight;
	
	ROUGHNESS = roughness / weights_sum;
	NORMALMAP = normalmap / weights_sum;
	NORMALMAP_DEPTH = normalmap_depth / weights_sum;
}
