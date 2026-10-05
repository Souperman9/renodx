#define USE_19_PUSHCONSTANTS

#include "../shared.slang"

struct AuxData
{
  float xoffset;
  float yoffset;
  float xscale;
  float yscale;
  uint4 buf_offsets0;
  uint4 buf_offsets1;
  uint2 buf_offsets2;
};

[[vk::binding(0, 0)]] StructuredBuffer<uint> ssbo_1_1;
[[vk::push_constant]] ConstantBuffer<AuxData> push_data;
[[vk::binding(1, 0)]] Texture2D<float4> fs_img0;
[[vk::binding(2, 0)]] Texture2D<float4> fs_img1;
[[vk::binding(3, 0)]] Texture2D<float4> fs_img2;
[[vk::binding(4, 0)]] Texture2D<float4> fs_img3;
[[vk::binding(5, 0)]] Texture2D<float4> fs_img4;
[[vk::binding(6, 0)]] Texture2D<float4> fs_img5;
[[vk::binding(7, 0)]] Texture2D<float4> fs_img6;
[[vk::binding(8, 0)]] Texture2D<float4> fs_img7;
[[vk::binding(9, 0)]] SamplerState fs_samp0;
[[vk::binding(10, 0)]] SamplerState fs_samp1;
[[vk::binding(11, 0)]] SamplerState fs_samp2;
[[vk::binding(12, 0)]] SamplerState fs_samp3;
[[vk::binding(13, 0)]] SamplerState fs_samp4;
[[vk::binding(14, 0)]] SamplerState fs_samp5;
[[vk::binding(15, 0)]] SamplerState fs_samp6;
[[vk::binding(16, 0)]] SamplerState fs_samp7;

struct PsInput
{
  [[vk::location(0)]] float4 fs_in_attr0 : TEXCOORD0;
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
  float2 uv = IN.fs_in_attr0.xy;

  // Keep the original accumulation order to preserve floating-point results.
  float4 combined = LoadWeights(620u + buf0_dword_off) * fs_img0.SampleLevel(fs_samp0, uv, 0.0);
  combined = LoadWeights(616u + buf0_dword_off) * fs_img1.SampleLevel(fs_samp1, uv, 0.0) + combined;
  combined = LoadWeights(624u + buf0_dword_off) * fs_img2.SampleLevel(fs_samp2, uv, 0.0) + combined;
  combined = LoadWeights(628u + buf0_dword_off) * fs_img3.SampleLevel(fs_samp3, uv, 0.0) + combined;
  combined = LoadWeights(632u + buf0_dword_off) * fs_img4.SampleLevel(fs_samp4, uv, 0.0) + combined;
  combined = LoadWeights(636u + buf0_dword_off) * fs_img5.SampleLevel(fs_samp5, uv, 0.0) + combined;
  combined = LoadWeights(640u + buf0_dword_off) * fs_img6.SampleLevel(fs_samp6, uv, 0.0) + combined;
  combined = LoadWeights(644u + buf0_dword_off) * fs_img7.SampleLevel(fs_samp7, uv, 0.0) + combined;

  OUT.frag_color0 = combined * CUSTOM_BLOOM;
  return OUT;
}