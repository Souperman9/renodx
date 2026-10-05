
#include "./shared.h"

struct AuxData
{
    float xoffset;
    float yoffset;
    float xscale;
    float yscale;
    uint4 ud_regs0;
    uint4 ud_regs1;
    uint4 ud_regs2;
    uint4 ud_regs3;
    uint4 buf_offsets0;
    uint4 buf_offsets1;
    uint2 buf_offsets2;
};

[[vk::binding(0, 0)]] StructuredBuffer<uint> ssbo_1_1;
[[vk::push_constant]] ConstantBuffer<AuxData> push_data;
[[vk::binding(1, 0)]] Texture2D<float4> fs_img4;
[[vk::binding(2, 0)]] SamplerState fs_sampsgpr_12;

struct PsInput
{
    [[vk::location(0)]] float4 fs_in_attr0 : TEXCOORD0;
    [[vk::location(1)]] float4 fs_in_attr1 : TEXCOORD1;
    [[vk::location(2)]] float4 fs_in_attr2 : TEXCOORD2;
};

struct PsOutput
{
    float4 frag_color0 : SV_Target0;
};

float4 LoadWeights(uint offset)
{
    return float4(
        asfloat(ssbo_1_1[offset]),
        asfloat(ssbo_1_1[offset + 1u]),
        asfloat(ssbo_1_1[offset + 2u]),
        asfloat(ssbo_1_1[offset + 3u]));
}

[shader("fragment")]
PsOutput main(PsInput IN)
{
    PsOutput OUT;
    uint buf0_dword_off = (push_data.buf_offsets0.x & 0xFFu) >> 2u;
    float chromatic_strength = CUSTOM_CA;
    float2 center_uv = IN.fs_in_attr0.xy;
    float2 chromatic_uv_1 = center_uv + (IN.fs_in_attr1.xy - center_uv) * chromatic_strength;
    float2 chromatic_uv_2 = center_uv + (IN.fs_in_attr2.xy - center_uv) * chromatic_strength;

    float4 color = LoadWeights(620u + buf0_dword_off) * fs_img4.SampleLevel(fs_sampsgpr_12, chromatic_uv_1, 0.0);
    color = LoadWeights(616u + buf0_dword_off) * fs_img4.SampleLevel(fs_sampsgpr_12, center_uv, 0.0) + color;
    color = LoadWeights(624u + buf0_dword_off) * fs_img4.SampleLevel(fs_sampsgpr_12, chromatic_uv_2, 0.0) + color;

    OUT.frag_color0 = color;
    return OUT;
}
