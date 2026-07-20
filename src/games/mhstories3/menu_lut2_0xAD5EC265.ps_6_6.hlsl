#include "./shared.h"
#include "./common.hlsli"

Texture2D<float> ReadonlyDepth : register(t0);

Texture2D<float4> SrcTexture : register(t1);

Texture3D<float4> SrcLUT : register(t2);

cbuffer SceneInfo : register(b0) {
  row_major float4x4 viewProjMat : packoffset(c000.x);
  row_major float3x4 transposeViewMat : packoffset(c004.x);
  row_major float3x4 transposeViewInvMat : packoffset(c007.x);
  float4 projElement[2] : packoffset(c010.x);
  float4 projInvElements[2] : packoffset(c012.x);
  row_major float4x4 viewProjInvMat : packoffset(c014.x);
  row_major float4x4 prevViewProjMat : packoffset(c018.x);
  float3 ZToLinear : packoffset(c022.x);
  float subdivisionLevel : packoffset(c022.w);
  float2 screenSize : packoffset(c023.x);
  float2 screenInverseSize : packoffset(c023.z);
  float2 cullingHelper : packoffset(c024.x);
  float cameraNearPlane : packoffset(c024.z);
  float cameraFarPlane : packoffset(c024.w);
  float4 viewFrustum[8] : packoffset(c025.x);
  float4 clipplane : packoffset(c033.x);
  float2 vrsVelocityThreshold : packoffset(c034.x);
  uint GPUVisibleMask : packoffset(c034.z);
  uint resolutionRatioPacked : packoffset(c034.w);
  float3 worldOffset : packoffset(c035.x);
  uint sceneInfoMisc : packoffset(c035.w);
  uint4 rayTracingParams : packoffset(c036.x);
  float4 sceneExtendedData : packoffset(c037.x);
  float2 projectionSpaceJitterOffset : packoffset(c038.x);
  float tessellationParam : packoffset(c038.z);
  float SceneInfo_Reserve2 : packoffset(c038.w);
};

cbuffer ImageSizeInfo : register(b1) {
  float2 readOnlyDepthSize : packoffset(c000.x);
  float2 reserve : packoffset(c000.z);
  float4 chromaKeyColor : packoffset(c001.x);
  float chromaKeyWeightMultiplier : packoffset(c002.x);
  uint chromaKeySetting : packoffset(c002.y);
};

cbuffer OCIOTransformMatrix : register(b2) {
  row_major float4x4 OCIO_TransformMatrix : packoffset(c000.x);
};

SamplerState PointBorder : register(s2, space32);

SamplerState TrilinearClamp : register(s9, space32);

float3 lut(float3 source, bool extended = false) {
  const float blackCodeValue = -0.35844698548316956f;
  const float linearThreshold = 3.0517578125e-05f;
  const float logScale = 0.05707760155200958f;
  const float logOffset = 0.5547950267791748f;

  float scale = extended ? renodx::tonemap::neutwo::ComputeMaxChannelScale(source) : 1.0f;
  float3 scaledSource = source * scale;
  float3 positiveSource = max(scaledSource, 0.0f);
  float3 lowRange = log2(positiveSource * 0.5f + linearThreshold * 0.5f) * logScale + logOffset;
  float3 highRange = log2(max(positiveSource, linearThreshold)) * logScale + logOffset;
  float3 encoded = lerp(highRange, lowRange, 1.0f - step(linearThreshold, positiveSource));
  encoded = lerp(blackCodeValue, encoded, float3(scaledSource > 0.0f));

  float3 lutCoordinates = encoded * 0.984375f + 0.0078125f;
  float3 lutColor = SrcLUT.SampleLevel(TrilinearClamp, lutCoordinates, 0.0f).rgb;
  return renodx::color::srgb::DecodeSafe(lerp(source, lutColor / renodx::color::srgb::Encode(scale), LUT_STRENGTH));
}

float chroma_key_alpha(float3 source) {
  float3x3 ocioTransform = float3x3(OCIO_TransformMatrix[0].xyz, OCIO_TransformMatrix[1].xyz, OCIO_TransformMatrix[2].xyz);
  float3 transformedSource = mul(source, ocioTransform);
  float chromaU = dot(transformedSource, float3(-0.148f, -0.291f, 0.493f)) + 0.5f;
  float chromaV = dot(transformedSource, float3(0.439f, -0.368f, -0.071f));
  float chromaDistance = length(float2(chromaU - chromaKeyColor.y, chromaV + 0.5f - chromaKeyColor.z));

  if ((chromaKeySetting & 1u) == 0u) return chromaDistance < chromaKeyColor.w ? 0.0f : 1.0f;

  float keyDistance = chromaDistance;
  if ((chromaKeySetting & 2u) != 0u) {
    float luminance = dot(transformedSource, float3(0.257f, 0.504f, 0.098f));
    keyDistance += min(abs(chromaKeyColor.x - 0.0625f - luminance), 1.0f);
  }

  float weight = saturate((keyDistance - chromaKeyColor.w) * chromaKeyWeightMultiplier);
  return weight * weight * (3.0f - 2.0f * weight);
}


float4 main(
  precise noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float2 sourceCoordinates = TEXCOORD * screenInverseSize * (screenSize - 0.5009999871253967f);
  float3 source = SrcTexture.SampleLevel(PointBorder, sourceCoordinates, 0.0f).rgb;

  float3 color = lut(source);
  float3 hdr = lut(source, true);
  if (RENODX_TONE_MAP_TYPE != 0) color = ColorCorrect(hdr, color);
  color = DisplayMap(color, true);
  color = renodx::draw::RenderIntermediatePass(color);

  int2 depthCoordinates = int2(TEXCOORD * readOnlyDepthSize);
  float depthAlpha = ReadonlyDepth.Load(int3(depthCoordinates, 0)) > 0.0f ? 1.0f : 0.0f;
  float alpha = max(depthAlpha, chroma_key_alpha(source));
  return float4(color, alpha);
}