
#include "./shared.slang"
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

struct Ssbo
{
    StructuredBuffer<uint> data;
};

[[vk::binding(0, 0)]] Ssbo ssbo_1_1;
[[vk::push_constant]] ConstantBuffer<AuxData> push_data;

[[vk::binding(1, 0)]] Texture2D<float4> fs_img24;
[[vk::binding(2, 0)]] Texture2D<float4> fs_img4;
[[vk::binding(3, 0)]] Texture2D<float4> fs_img16;
[[vk::binding(4, 0)]] Texture2D<float4> fs_img32;
[[vk::binding(5, 0)]] SamplerState fs_sampsgpr_44;
[[vk::binding(6, 0)]] SamplerState fs_sampsgpr_12;
[[vk::binding(7, 0)]] SamplerState fs_sampsgpr_40;
[[vk::binding(8, 0)]] SamplerState fs_sampsgpr_48;

struct PsInput
{
    [[vk::location(0)]] float4 fs_in_attr0 : TEXCOORD0;
    [[vk::location(1)]] float4 fs_in_attr1 : TEXCOORD1;
    [[vk::location(3)]] float4 fs_in_attr2 : TEXCOORD3;
    [[vk::location(4)]] float4 fs_in_attr3 : TEXCOORD4;
};

struct PsOutput
{
    float4 frag_color0 : SV_Target0;
};

float4 ApplyToneMap(PsInput IN, bool use_extended_output)
{
    const float input_scale = 1.363636;
    const float output_exponent = 0.451459;
    const float lut_strength_scale = 0.003922;
    const float output_offset = -0.001961;
    const float response_strength = 2.221729;
    const float response_scale = 0.428118;

    float4 input_sample = fs_img4.SampleLevel(fs_sampsgpr_12, IN.fs_in_attr0.xy, 0.0);
    float3 bloom = fs_img16.SampleLevel(fs_sampsgpr_40, IN.fs_in_attr1.xy, 0.0).xyz * CUSTOM_BLOOM;
    float lut_strength = fs_img32.SampleLevel(fs_sampsgpr_48, IN.fs_in_attr3.xy, 0.0).x;

    float3 response_input = input_sample.xyz * input_scale;
    float3 output_color;
    if (use_extended_output) {
        float3 scene_response = ApplyExtendedVanillaResponse(response_input, response_strength);
        float3 scene_response_scale = response_scale * (scene_response - 1.0) + 1.0;
        float3 scene_extended = scene_response * scene_response_scale * scene_response_scale;
        output_color = max(scene_extended + bloom, 0.0);
    } else {
        float3 scene_response = 1.0 - exp(-response_strength * response_input);
        float3 scene_response_scale = response_scale * (scene_response - 1.0) + 1.0;
        float3 scene_sdr = saturate(scene_response * scene_response_scale * scene_response_scale);
        float3 bloom_sdr = saturate(bloom);
        output_color = saturate(scene_sdr + bloom_sdr - scene_sdr * bloom_sdr + 2.384185791015625e-07);
    }

    float3 graded_output = lut_strength * lut_strength_scale + pow(output_color, output_exponent);
    graded_output = output_offset + graded_output;
    return float4(graded_output.zyx, saturate(input_sample.w));
}

[shader("fragment")]
PsOutput main(PsInput IN)
{
    PsOutput OUT;
    OUT.frag_color0 = ApplyToneMap(IN, RENODX_TONE_MAP_TYPE != 0);
    return OUT;
}

