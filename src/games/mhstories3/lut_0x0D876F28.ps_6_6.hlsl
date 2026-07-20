#include "./shared.h"
#include "./common.hlsli"
Texture2D<float4> SrcTexture : register(t0);

Texture3D<float4> SrcLUT : register(t1);

SamplerState PointBorder : register(s2, space32);

SamplerState TrilinearClamp : register(s9, space32);

float3 lut(float3 source, float2 TEXCOORD, bool extended = false) {
  const float blackCodeValue = -0.35844698548316956f;
  const float linearThreshold = 3.0517578125e-05f;
  const float logScale = 0.05707760155200958f;
  const float logOffset = 0.5547950267791748f;

  float scale = 1.f;
  if (extended) scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(source);
  float3 positiveSource = max(source * scale, 0.0f);
  float3 lowRange = log2(positiveSource * 0.5f + linearThreshold * 0.5f) * logScale + logOffset;
  float3 highRange = log2(max(positiveSource, linearThreshold)) * logScale + logOffset;

  float3 lowRangeMask = 1.0f - step(linearThreshold, positiveSource);
  float3 positiveMask = float3(source * scale > 0.0f);
  float3 encoded = lerp(highRange, lowRange, lowRangeMask);
  encoded = lerp(blackCodeValue, encoded, positiveMask);

  float3 lutCoordinates = encoded * 0.984375f + 0.0078125f;
  float3 lut = SrcLUT.SampleLevel(TrilinearClamp, lutCoordinates, 0.0f).rgb / renodx::color::srgb::Encode(scale);
  lut = renodx::color::srgb::DecodeSafe(lut);
  return lerp(source, lut, LUT_STRENGTH);
}

float4 main(
    precise noperspective float4 SV_Position: SV_Position,
    linear float2 TEXCOORD: TEXCOORD) : SV_Target {

  float3 source = SrcTexture.SampleLevel(PointBorder, TEXCOORD, 0.0f).rgb;
  float3 color = lut(source, TEXCOORD);
  float3 hdr = lut(source, TEXCOORD, true);
  if (RENODX_TONE_MAP_TYPE != 0) color = ColorCorrect(hdr, color);
  //color = renodx::color::srgb::DecodeSafe(color);
  color = DisplayMap(color);
  color = renodx::draw::RenderIntermediatePass(color);
  return float4(color, 1.0f);
}
