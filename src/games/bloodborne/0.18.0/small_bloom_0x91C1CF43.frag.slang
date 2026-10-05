#define USE_AUX_PUSHCONSTANTS
#include "../shared.slang"
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
[[vk::binding(1, 0)]] StructuredBuffer<uint> ssbo_2_1;
[[vk::binding(2, 0)]] StructuredBuffer<uint> ssbo_3_1;
[[vk::push_constant]] ConstantBuffer<AuxData> push_data;
[[vk::binding(3, 0)]] Texture2D<float4> fs_img4;
[[vk::binding(4, 0)]] SamplerState fs_sampsgpr_12;

struct PsInput
{
    [[vk::location(0)]] float4 fs_in_attr0 : TEXCOORD0;
};

struct PsOutput
{
    float4 frag_color0 : SV_Target0;
};

float Parameter(StructuredBuffer<uint> buffer, uint offset)
{
    return asfloat(buffer[offset]);
}

float3 SampleSource(float2 uv)
{
    return renodx::draw::InvertIntermediatePass(fs_img4.SampleLevel(fs_sampsgpr_12, uv, 0.0).xyz);
}

[shader("fragment")]
PsOutput main(PsInput IN)
{
    PsOutput OUT;
    uint buf0_dword_off = (push_data.buf_offsets0.x & 0xFFu) >> 2u;
    uint buf1_dword_off = ((push_data.buf_offsets0.x >> 8u) & 0xFFu) >> 2u;
    uint buf2_dword_off = ((push_data.buf_offsets0.x >> 16u) & 0xFFu) >> 2u;

    float2 uv = IN.fs_in_attr0.xy;
    float2 sample_scale = float2(
        Parameter(ssbo_2_1, 4u + buf1_dword_off),
        Parameter(ssbo_2_1, 5u + buf1_dword_off));

    float3 color = Parameter(ssbo_1_1, 6u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 4u + buf0_dword_off), Parameter(ssbo_1_1, 5u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 2u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 0u + buf0_dword_off), Parameter(ssbo_1_1, 1u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 10u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 8u + buf0_dword_off), Parameter(ssbo_1_1, 9u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 14u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 12u + buf0_dword_off), Parameter(ssbo_1_1, 13u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 18u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 16u + buf0_dword_off), Parameter(ssbo_1_1, 17u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 22u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 20u + buf0_dword_off), Parameter(ssbo_1_1, 21u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 26u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 24u + buf0_dword_off), Parameter(ssbo_1_1, 25u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 30u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 28u + buf0_dword_off), Parameter(ssbo_1_1, 29u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 34u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 32u + buf0_dword_off), Parameter(ssbo_1_1, 33u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 38u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 36u + buf0_dword_off), Parameter(ssbo_1_1, 37u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 42u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 40u + buf0_dword_off), Parameter(ssbo_1_1, 41u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 46u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 44u + buf0_dword_off), Parameter(ssbo_1_1, 45u + buf0_dword_off)));
    color += Parameter(ssbo_1_1, 50u + buf0_dword_off) * SampleSource(uv + sample_scale * float2(Parameter(ssbo_1_1, 48u + buf0_dword_off), Parameter(ssbo_1_1, 49u + buf0_dword_off)));

    OUT.frag_color0 = float4((Parameter(ssbo_3_1, buf2_dword_off) * color).zyx, 1.0);
    OUT.frag_color0 = renodx::draw::RenderIntermediatePass(OUT.frag_color0) * CUSTOM_BLOOM;
    return OUT;
}
