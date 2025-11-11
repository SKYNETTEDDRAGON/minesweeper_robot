shader_type spatial;

render_mode unshaded, cull_disabled;

uniform float time_speed = 0.5;
uniform vec4 lava_color_1 : source_color = vec4(1.0, 0.3, 0.0, 1.0);
uniform vec4 lava_color_2 : source_color = vec4(0.8, 0.1, 0.0, 1.0);
uniform float glow_intensity = 2.0;
uniform sampler2D noise_tex : source_color;

// Optional emissive strength control
uniform float emissive_strength = 2.5;

void fragment() {
    // Move the noise texture over time
    vec2 uv = UV;
    uv.x += TIME * 0.1 * time_speed;
    uv.y += sin(TIME * 0.5) * 0.05;

    // Sample noise twice for depth-like pattern
    float n1 = texture(noise_tex, uv * 2.0).r;
    float n2 = texture(noise_tex, uv * 4.0 + vec2(TIME * 0.1, 0.0)).r;
    float lava_mix = (n1 + n2) * 0.5;

    // Mix colors to simulate molten lava movement
    vec4 color = mix(lava_color_1, lava_color_2, lava_mix);

    // Make it glow — strong emissive output
    EMISSION = color.rgb * emissive_strength * (lava_mix + 0.5);

    // Set albedo (base color)
    ALBEDO = color.rgb;

    // Optional: make it shimmer based on brightness
    ALPHA = 1.0;
}
