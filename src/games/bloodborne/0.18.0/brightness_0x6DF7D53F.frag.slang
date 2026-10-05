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
[[vk::binding(1, 0)]] Texture1DArray<float4> fs_img16;
[[vk::binding(2, 0)]] SamplerState fs_sampsgpr_12;

struct PsInput
{
    float4 position : SV_Position;
};

struct PsOutput
{
    float4 frag_color0 : SV_Target0;
};

[shader("fragment")]
PsOutput main(PsInput IN)
{
    // swizzle required
    // this is the in-game brightness setting, we just ignore it lol
    PsOutput OUT;
    float4 _77 = fs_img4.Load(int3(int2(floor(IN.position.xy)), 0));
    // OUT.frag_color0.x = fs_img16.Sample(fs_sampsgpr_12, float2(_77.z, 2.0)).x;
    // OUT.frag_color0.y = fs_img16.Sample(fs_sampsgpr_12, float2(_77.y, 1.0)).x;
    // OUT.frag_color0.z = fs_img16.Sample(fs_sampsgpr_12, float2(_77.x, 0.0)).x;
    OUT.frag_color0.w = _77.w;
    OUT.frag_color0.xyz = _77.zyx;
    return OUT;
}

