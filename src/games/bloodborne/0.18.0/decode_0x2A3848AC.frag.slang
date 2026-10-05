#version 450

layout(push_constant, std430) uniform settings
{
    float gamma;
    uint hdr;
} pp;

layout(set = 0, binding = 0) uniform sampler2D texSampler;

layout(location = 0) in vec2 uv;
layout(location = 0) out vec4 color;

vec3 gamma(vec3 rgb)
{
    return mix((pow(rgb, vec3(1.0 / (3.400000095367431640625 - pp.gamma))) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875), (rgb * 12.9200000762939453125) / vec3(pp.gamma), lessThan(rgb, vec3(0.003130800090730190277099609375)));
}

void main()
{
    vec4 color_linear = texture(texSampler, uv);
    if (pp.hdr != 0u)
    {
        color = color_linear;
    }
    else
    {
        vec3 param = color_linear.xyz;
        color = vec4(gamma(param), color_linear.w);
        color.xyz = color_linear.xyz;
    }
}

