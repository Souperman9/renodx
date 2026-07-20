#include "./shared.h"
Texture2D<float4> Texture : register(t0);

cbuffer GUIConstant : register(b0) {
  row_major float4x4 guiViewMatrix : packoffset(c000.x);
  row_major float4x4 guiProjMatrix : packoffset(c004.x);
  row_major float4x4 guiWorldMat : packoffset(c008.x);
  float guiIntensity : packoffset(c012.x);
  float guiSaturation : packoffset(c012.y);
  float guiSoftParticleDist : packoffset(c012.z);
  float guiFilterParam : packoffset(c012.w);
  float4 guiScreenSizeRatio : packoffset(c013.x);
  float2 guiCaptureSizeRatio : packoffset(c014.x);
  float2 guiDistortionOffset : packoffset(c014.z);
  float guiFilterMipLevel : packoffset(c015.x);
  float guiStencilScale : packoffset(c015.y);
  uint guiDepthTestTargetStencil : packoffset(c015.z);
  uint guiShaderCommonFlag : packoffset(c015.w);
  float4 guiAdjustAddColor : packoffset(c016.x);
  float guiTextureSampleGradScale : packoffset(c017.x);
};

cbuffer UserMaterial : register(b1) {
  float VAR_Num : packoffset(c000.x);
  float VAR_Intensity : packoffset(c000.y);
  float CAPCOM_MATERIAL_RESERVE0 : packoffset(c000.z);
  float CAPCOM_MATERIAL_RESERVE1 : packoffset(c000.w);
};

SamplerState AutomaticWrap : register(s0);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

float4 main(
  precise noperspective float4 SV_Position : SV_Position,
  linear float3 POSITION : POSITION,
  linear float4 COLOR : COLOR,
  linear float2 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target;
  float4 _19;
  float _30;
  float _31;
  float _32;
  float _33;
  float _40;
  float _41;
  float _42;
  float _43;
  int _44;
  float _69;
  float _70;
  float _71;
  float _72;
  float _191;
  float _34;
  float _47;
  float4 _56;
  float _61;
  float _62;
  float _63;
  float _64;
  int _65;
  float _120;
  bool _122;
  float _124;
  float _126;
  float _128;
  float _129;
  bool _131;
  float _132;
  float _141;
  float _142;
  float _143;
  float _165;
  float _167;
  float _181;
  int __loop_jump_target = -1;
  _19 = Texture.Sample(AutomaticWrap, float2(TEXCOORD.x, TEXCOORD.y));
  if (!(VAR_Num == 1.0f)) {
    if (VAR_Num > 0.0f) {
      _40 = _19.x;
      _41 = _19.y;
      _42 = _19.z;
      _43 = _19.w;
      _44 = 0;
      while(true) {
        _47 = (6.2831854820251465f / VAR_Num) * float((int)(_44));
        _56 = Texture.Sample(AutomaticWrap, float2(((sin(_47) * VAR_Intensity) + TEXCOORD.x), ((cos(_47) * VAR_Intensity) + TEXCOORD.y)));
        _61 = _56.x + _40;
        _62 = _56.y + _41;
        _63 = _56.z + _42;
        _64 = _56.w + _43;
        _65 = _44 + 1;
        if (float((int)(_65)) < VAR_Num) {
          _40 = _61;
          _41 = _62;
          _42 = _63;
          _43 = _64;
          _44 = _65;
          continue;
        }
        while(true) {
          _30 = _61;
          _31 = _62;
          _32 = _63;
          _33 = _64;
          break;
        }
        break;
      }
    } else {
      _30 = _19.x;
      _31 = _19.y;
      _32 = _19.z;
      _33 = _19.w;
    }
    _34 = VAR_Num + 1.0f;
    _69 = (_30 / _34);
    _70 = (_31 / _34);
    _71 = (_32 / _34);
    _72 = (_33 / _34);
  } else {
    _69 = _19.x;
    _70 = _19.y;
    _71 = _19.z;
    _72 = _19.w;
  }
  _120 = 1.0f / ((((float)((uint)((uint)(((uint)((uint)(guiShaderCommonFlag)) >> 8) & 1)))) * (1.0f - _72)) + _72);
  _122 = ((_72 + -9.999999747378752e-05f) < 0.0f);
  if (_122) discard;
  _124 = (_120 * COLOR.x) * (((((pow(_69, 0.4166666567325592f)) * 1.0549999475479126f) + -0.054999999701976776f) * ((float)((bool)((uint)(!(_69 <= 0.0031308000907301903f)))))) + ((_69 * 12.920000076293945f) * ((float)((bool)(uint)(_69 <= 0.0031308000907301903f)))));
  _126 = (_120 * COLOR.y) * (((((pow(_70, 0.4166666567325592f)) * 1.0549999475479126f) + -0.054999999701976776f) * ((float)((bool)((uint)(!(_70 <= 0.0031308000907301903f)))))) + ((_70 * 12.920000076293945f) * ((float)((bool)(uint)(_70 <= 0.0031308000907301903f)))));
  _128 = (_120 * COLOR.z) * (((((pow(_71, 0.4166666567325592f)) * 1.0549999475479126f) + -0.054999999701976776f) * ((float)((bool)((uint)(!(_71 <= 0.0031308000907301903f)))))) + ((_71 * 12.920000076293945f) * ((float)((bool)(uint)(_71 <= 0.0031308000907301903f)))));
  _129 = _72 * COLOR.w;
  _131 = ((_129 + -9.999999747378752e-05f) < 0.0f);
  if (_131) discard;
  _132 = dot(float4(_124, _126, _128, _129), float4(0.2989000082015991f, 0.5866000056266785f, 0.1145000010728836f, 0.0f));
  _141 = (guiSaturation * (_132 - _124)) + _124;
  _142 = (guiSaturation * (_132 - _126)) + _126;
  _143 = (guiSaturation * (_132 - _128)) + _128;
  if ((_129 < 1.0f) && ((guiShaderCommonFlag & 2) != 0)) {
    _165 = (exp2(log2((_129 + 0.054999999701976776f) * 0.9478673338890076f) * 2.4000000953674316f) * ((float)((bool)((uint)(!(_129 <= 0.040449999272823334f)))))) + ((_129 * 0.07739938050508499f) * ((float)((bool)(uint)(_129 <= 0.040449999272823334f))));
    if ((guiShaderCommonFlag & 4) == 0) {
      _167 = 1.0f - _129;
      _181 = (1.0f - ((_167 * 0.07739938050508499f) * ((float)((bool)(uint)(_167 <= 0.040449999272823334f))))) - (exp2(log2((1.0549999475479126f - _129) * 0.9478673338890076f) * 2.4000000953674316f) * ((float)((bool)((uint)(!(_167 <= 0.040449999272823334f))))));
      _191 = ((((_165 - _181) * 0.3333333432674408f) * (((_142 + _141) + _143) / guiIntensity)) + _181);
    } else {
      _191 = _165;
    }
  } else {
    _191 = _129;
  }
  SV_Target.x = ((guiAdjustAddColor.x + _141) * _191);
  SV_Target.y = ((guiAdjustAddColor.y + _142) * _191);
  SV_Target.z = ((guiAdjustAddColor.z + _143) * _191);
  SV_Target.w = (_191 * ((float)((uint)((uint)(((uint)((uint)(guiShaderCommonFlag)) >> 7) & 1)))));
  SV_Target.xyz = renodx::color::srgb::DecodeSafe(SV_Target.xyz);
  SV_Target.xyz = renodx::draw::RenderIntermediatePass(SV_Target.xyz);
  return SV_Target;
}