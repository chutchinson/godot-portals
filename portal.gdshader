shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D portal_texture: source_color;

void fragment() {
	vec4 portal = texture(portal_texture, SCREEN_UV);
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	ALBEDO = portal.rgb;
}
