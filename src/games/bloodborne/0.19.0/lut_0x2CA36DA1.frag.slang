#define USE_19_PUSHCONSTANTS
#include "../shared.slang"
struct AuxData {
  float xoffset;
  float yoffset;
  float xscale;
  float yscale;
  uint4 buf_offsets0;
  uint4 buf_offsets1;
  uint2 buf_offsets2;
};

[[vk::push_constant]]
ConstantBuffer<AuxData> push_data;

[[vk::binding(0, 0)]]
Texture2D<float4> fs_img4;
[[vk::binding(1, 0)]]
Texture3D<float4> fs_img16;
[[vk::binding(2, 0)]]
SamplerState fs_sampsgpr_12;
[[vk::binding(3, 0)]]
SamplerState lutSample;

struct PsInput {
  [[vk::location(0)]]
  float4 fs_in_attr0 : TEXCOORD0;
};

struct PsOutput {
  float4 frag_color0 : SV_Target0;
};

[shader("fragment")]
PsOutput main(PsInput IN) {
  

  // bgr in
  PsOutput OUT;
  float4 scene = fs_img4.SampleLevel(fs_sampsgpr_12, IN.fs_in_attr0.xy, 0.0);
  scene.xyz /= scene.a;
  float3 color = scene.xyz;
  if (LUT_STRENGTH != 0) {
    float scale = renodx::tonemap::c_infinity_rolloff::ComputeMaxChannelScale(scene.xyz, 1);
    color = fs_img16.Sample(lutSample, scene.xyz * scale * 0.9375 + 0.03125).xyz;
    color /= scale;
    if (LUT_STRENGTH != 100) color = lerp(scene.xyz, color, LUT_STRENGTH);
  }
  color = renodx::color::srgb::DecodeSafe(color);
  color = ApplyColorGrade(color);
  color = DisplayMap(color);
  OUT.frag_color0.xyz = renodx::draw::RenderIntermediatePass(color);
  OUT.frag_color0.w = 0;
  // OUT.frag_color0.xyz = (scene.xyz);
  //  OUT.frag_color0.xyz = OUT.frag_color0.zyx;
  //  OUT.frag_color0 = scene.xyzw;
  // OUT.frag_color0.xyz = renodx::draw::RenderIntermediatePass(OUT.frag_color0.xyz);
  // OUT.frag_color0.xyz = RENODX_DIFFUSE_WHITE_NITS;
  return OUT;
}

