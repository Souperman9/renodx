#include "./shared.h"
Texture2D<float4> tSrc : register(t0);

SamplerState BilinearClamp : register(s5, space32);

float4 main(
    noperspective float4 SV_Position: SV_Position,
    linear float2 TEXCOORD: TEXCOORD
) : SV_Target {
  float4 SV_Target;
  float4 _7 = tSrc.Sample(BilinearClamp, float2(TEXCOORD.x, TEXCOORD.y));
  SV_Target.x = _7.x;
  SV_Target.y = _7.y;
  SV_Target.z = _7.z;
  SV_Target.w = _7.w;

  SV_Target.xyz = renodx::draw::SwapChainPass(SV_Target.xyz);
  //SV_Target.xyz = renodx::color::srgb::DecodeSafe(SV_Target.xyz);
  return SV_Target;
}
