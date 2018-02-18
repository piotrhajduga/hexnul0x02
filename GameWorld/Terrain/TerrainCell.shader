shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

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

uniform float specular;
uniform float metallic;
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;

uniform vec4 metallic_texture_channel;
uniform vec4 roughness_texture_channel;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

varying float height;
varying vec3 base_normal;

uniform vec3 up = vec3(0.0,1.0,0.0);

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	height = sqrt((WORLD_MATRIX * vec4(VERTEX,1.0)).y / terrain_height_scale) * (1.0 - water_height) + water_height;
	base_normal = (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void fragment() {
	if (acos(dot(up,base_normal)) > stone_min_angle) {
		ALBEDO = stone_albedo.rgb * texture(stone_texture_albedo,UV).rgb;
		float roughness_tex = dot(texture(stone_texture_roughness,UV),roughness_texture_channel);
		ROUGHNESS = roughness_tex * stone_roughness;
		NORMALMAP = texture(stone_texture_normal,UV).rgb;
		NORMALMAP_DEPTH = stone_normal_scale;
	} else {
		if (height >= snow_height) {
			ALBEDO = snow_albedo.rgb * texture(snow_texture_albedo,UV).rgb;
			float roughness_tex = dot(texture(snow_texture_roughness,UV),roughness_texture_channel);
			ROUGHNESS = roughness_tex * snow_roughness;
			NORMALMAP = texture(snow_texture_normal,UV).rgb;
			NORMALMAP_DEPTH = snow_normal_scale;
		} else if (height >= gravel_height) {
			ALBEDO = gravel_albedo.rgb * texture(gravel_texture_albedo,UV).rgb;
			float roughness_tex = dot(texture(gravel_texture_roughness,UV),roughness_texture_channel);
			ROUGHNESS = roughness_tex * gravel_roughness;
			NORMALMAP = texture(gravel_texture_normal,UV).rgb;
			NORMALMAP_DEPTH = gravel_normal_scale;
		} else if (height >= grass_height) {
			ALBEDO = grass_albedo.rgb * texture(grass_texture_albedo,UV).rgb;
			float roughness_tex = dot(texture(grass_texture_roughness,UV),roughness_texture_channel);
			ROUGHNESS = roughness_tex * grass_roughness;
			NORMALMAP = texture(grass_texture_normal,UV).rgb;
			NORMALMAP_DEPTH = grass_normal_scale;
		} else if (height >= sand_height) {
			ALBEDO = sand_albedo.rgb * texture(sand_texture_albedo,UV).rgb;
			float roughness_tex = dot(texture(sand_texture_roughness,UV),roughness_texture_channel);
			ROUGHNESS = roughness_tex * sand_roughness;
			NORMALMAP = texture(sand_texture_normal,UV).rgb;
			NORMALMAP_DEPTH = sand_normal_scale;
		} else {
			ALBEDO = water_albedo.rgb * texture(water_texture_albedo,UV).rgb;
			float roughness_tex = dot(texture(water_texture_roughness,UV),roughness_texture_channel);
			ROUGHNESS = roughness_tex * water_roughness;
			NORMALMAP = texture(water_texture_normal,UV).rgb;
			NORMALMAP_DEPTH = water_normal_scale;
		}
	}
	SPECULAR = 0.5;
	float metallic_tex = dot(texture(texture_metallic,UV),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
}
