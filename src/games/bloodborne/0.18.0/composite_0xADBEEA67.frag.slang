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

[[vk::push_constant]] ConstantBuffer<AuxData> push_data;

[[vk::binding(0, 0)]] Texture2D<float4> fs_img4;
[[vk::binding(1, 0)]] SamplerState fs_sampsgpr_12;

struct PsInput
{
    [[vk::location(0)]] float4 fs_in_attr0 : TEXCOORD0;
};

struct PsOutput
{
    float4 frag_color0 : SV_Target0;
};

[shader("fragment")]
PsOutput main(PsInput IN)
{
    PsOutput OUT;
    float4 _100 = fs_img4.SampleLevel(fs_sampsgpr_12, IN.fs_in_attr0.xy, 0.0);
    OUT.frag_color0.x = max(0.0, _100.x);
    OUT.frag_color0.y = max(0.0, _100.y);
    OUT.frag_color0.z = max(0.0, _100.z);
    OUT.frag_color0.w = max(0.0, _100.w);
    return OUT;
}

