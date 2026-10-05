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
    [[vk::location(2)]] float4 fs_in_attr2 : TEXCOORD2;
    [[vk::location(3)]] float4 fs_in_attr3 : TEXCOORD3;
    [[vk::location(4)]] float4 fs_in_attr4 : TEXCOORD4;
};

struct PsOutput
{
    float4 frag_color0 : SV_Target0;
};

float Parameter(uint buffer_offset, uint parameter_offset)
{
    return asfloat(ssbo_1_1.data[buffer_offset + parameter_offset]);
}

float4 ApplyToneMap(PsInput IN, bool use_extended_output)
{
    uint buffer_offset = (push_data.buf_offsets0.x & 0xFFu) >> 2u;

    float3 scene_sample = fs_img24.Sample(fs_sampsgpr_44, IN.fs_in_attr3.xy).zyx;
    float4 modulation_sample = fs_img4.SampleLevel(fs_sampsgpr_12, IN.fs_in_attr0.xy, 0.0);
    float3 modulation_color = modulation_sample.zyx;
    float3 bloom_sample = fs_img16.SampleLevel(fs_sampsgpr_40, IN.fs_in_attr1.xy, 0.0).zyx;
    float output_strength = fs_img32.SampleLevel(fs_sampsgpr_48, IN.fs_in_attr4.xy, 0.0).x;

    // Kos applies the response only inside this fourth-power radial mask.
    float radial_mask = saturate(1.0 - dot(IN.fs_in_attr2.xy, IN.fs_in_attr2.xy));
    float response_mask = radial_mask * radial_mask;
    response_mask *= response_mask;

    float3 primary_color = scene_sample * Parameter(buffer_offset, 752u) + Parameter(buffer_offset, 753u);
    float primary_average = (primary_color.x + primary_color.y + primary_color.z) * 0.3333333432674407958984375;
    primary_color = (primary_color - primary_average) * Parameter(buffer_offset, 756u) + primary_average;
    primary_color = primary_color * Parameter(buffer_offset, 754u) + Parameter(buffer_offset, 755u);

    float3 secondary_color = scene_sample * Parameter(buffer_offset, 744u) + Parameter(buffer_offset, 745u);
    float secondary_average = (secondary_color.x + secondary_color.y + secondary_color.z) * 0.3333333432674407958984375;
    secondary_color = (secondary_color - secondary_average) * Parameter(buffer_offset, 748u) + secondary_average;
    float3 bloom_color_scale = secondary_color * Parameter(buffer_offset, 754u) + Parameter(buffer_offset, 755u);
    float3 bloom_color_offset = saturate(secondary_color) * Parameter(buffer_offset, 746u) + Parameter(buffer_offset, 747u);

    float3 response_input = primary_color * (modulation_color * Parameter(buffer_offset, 616u) * response_mask);
    float response_strength = Parameter(buffer_offset, 832u);
    float3 scene_response;
    if (use_extended_output) {
        scene_response = ApplyExtendedVanillaResponse(response_input, response_strength);
    } else {
        scene_response = 1.0 - exp2(1.44269502162933349609375 * (-max(6.103515625e-05, response_input) * response_strength));
    }

    float3 response_scale = Parameter(buffer_offset, 833u) * (scene_response - 1.0) + 1.0;
    float3 scene_color = scene_response * response_scale * response_scale;
    float3 bloom_color = Parameter(buffer_offset, 617u) * (bloom_sample * bloom_color_scale + bloom_color_offset);

    float3 composite_color;
    if (use_extended_output) {
        composite_color = scene_color + bloom_color;
    } else {
        float3 scene_sdr = saturate(scene_color);
        float3 bloom_sdr = saturate(bloom_color);
        composite_color = scene_sdr + bloom_sdr - scene_sdr * bloom_sdr;
    }

    float3 matrix_color = float3(
        Parameter(buffer_offset, 842u) * composite_color.x + Parameter(buffer_offset, 841u) * composite_color.y + Parameter(buffer_offset, 840u) * composite_color.z + Parameter(buffer_offset, 843u),
        Parameter(buffer_offset, 846u) * composite_color.x + Parameter(buffer_offset, 845u) * composite_color.y + Parameter(buffer_offset, 844u) * composite_color.z + Parameter(buffer_offset, 847u),
        Parameter(buffer_offset, 850u) * composite_color.x + Parameter(buffer_offset, 849u) * composite_color.y + Parameter(buffer_offset, 848u) * composite_color.z + Parameter(buffer_offset, 851u));

    float3 output_color;
    if (use_extended_output) {
        output_color = max(matrix_color + 2.384185791015625e-07, 0.0);
        output_color = Parameter(buffer_offset, 810u) + Parameter(buffer_offset, 809u) * output_strength + pow(output_color, Parameter(buffer_offset, 808u));
    } else {
        output_color = saturate(matrix_color + 2.384185791015625e-07);
        output_color = Parameter(buffer_offset, 810u) + Parameter(buffer_offset, 809u) * output_strength + exp2(Parameter(buffer_offset, 808u) * log2(output_color));
    }

    float alpha = modulation_sample.x * Parameter(buffer_offset, 620u);
    alpha += modulation_sample.y * Parameter(buffer_offset, 621u);
    alpha += modulation_sample.z * Parameter(buffer_offset, 622u);
    alpha += modulation_sample.w * Parameter(buffer_offset, 623u);

    return float4(output_color.zyx, saturate(alpha));
}

[shader("fragment")]
PsOutput main(PsInput IN)
{
    PsOutput OUT;
    OUT.frag_color0 = ApplyToneMap(IN, RENODX_TONE_MAP_TYPE != 0);
    return OUT;
}
