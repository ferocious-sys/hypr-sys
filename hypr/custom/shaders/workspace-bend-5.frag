#version 300 es
precision highp float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    const float strength = 0.008887;
    float x = 2.0 * v_texcoord.x - 1.0;
    float inset = strength * max(0.0, 1.0 - x * x);
    float y = (v_texcoord.y - inset) / (1.0 - 2.0 * inset);
    float edge = min(v_texcoord.y, 1.0 - v_texcoord.y) - inset;
    float visibility = smoothstep(-0.0004, 0.0004, edge);
    vec3 color = texture(tex, vec2(v_texcoord.x, clamp(y, 0.0, 1.0))).rgb;
    fragColor = vec4(color * visibility, 1.0);
}
