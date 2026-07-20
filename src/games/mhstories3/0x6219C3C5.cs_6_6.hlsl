Texture2D<float4> GUIImage : register(t0);

RWTexture2D<float3> RWResult : register(u0);

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

cbuffer EnvironmentInfo : register(b1) {
  uint timeMillisecond : packoffset(c000.x);
  uint frameCount : packoffset(c000.y);
  uint isOddFrame : packoffset(c000.z);
  uint reserveEnvironmentInfo : packoffset(c000.w);
  float breakingPBRSpecularIntensity : packoffset(c001.x);
  float breakingPBRIBLReflectanceBias : packoffset(c001.y);
  float breakingPBRIBLIntensity : packoffset(c001.z);
  float breakingPBR_Reserved : packoffset(c001.w);
  uint vrsTier2Enable : packoffset(c002.x);
  uint dynamicTextureTableNullBlackHandle : packoffset(c002.y);
  uint prevTimeMillisecond : packoffset(c002.z);
  uint bindlessMaterialMaxNum : packoffset(c002.w);
  float rtLightRadius : packoffset(c003.x);
  float accurateVelocityDistanceSq : packoffset(c003.y);
  float EnvironmentInfoReserved1 : packoffset(c003.z);
  float EnvironmentInfoReserved2 : packoffset(c003.w);
  float4 userGlobalParams[32] : packoffset(c004.x);
  uint4 dynamicTextureTableHandles[256] : packoffset(c036.x);
  uint4 bakedResourceSharedTablesHandles[32] : packoffset(c292.x);
};

cbuffer OutputColorAdjustment : register(b2) {
  float fGamma : packoffset(c000.x);
  float fLowerLimit : packoffset(c000.y);
  float fUpperLimit : packoffset(c000.z);
  float fConvertToLimit : packoffset(c000.w);
  float4 fConfigDrawRect : packoffset(c001.x);
  float4 fSecondaryConfigDrawRect : packoffset(c002.x);
  float2 fConfigDrawRectSize : packoffset(c003.x);
  float2 fSecondaryConfigDrawRectSize : packoffset(c003.z);
  uint uConfigMode : packoffset(c004.x);
  float fConfigImageIntensity : packoffset(c004.y);
  float fSecondaryConfigImageIntensity : packoffset(c004.z);
  float fConfigImageAlphaScale : packoffset(c004.w);
  float fGammaForOverlay : packoffset(c005.x);
  float fLowerLimitForOverlay : packoffset(c005.y);
  float fConvertToLimitForOverlay : packoffset(c005.z);
};

cbuffer GUIConstant : register(b3) {
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

SamplerState PointClamp : register(s1, space32);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

[numthreads(256, 1, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  int16_t _14;
  int16_t _15;
  int16_t _17;
  int16_t _18;
  int16_t _19;
  int16_t _20;
  int16_t _21;
  int16_t _22;
  int16_t _23;
  int16_t _24;
  int16_t _25;
  int16_t _26;
  int16_t _27;
  int16_t _28;
  int16_t _29;
  uint16_t _30;
  int16_t _31;
  int16_t _32;
  int16_t _33;
  int16_t _34;
  uint16_t _35;
  int16_t _36;
  int16_t _37;
  int16_t _38;
  int16_t _39;
  float _40;
  float _41;
  float _42;
  float _43;
  float _47;
  float _48;
  float4 _51;
  float _56;
  bool _57;
  float _58;
  float _59;
  float _60;
  float _61;
  float _62;
  float _63;
  float _64;
  float _65;
  float _66;
  float _67;
  float _68;
  float _69;
  float _70;
  float _71;
  float _72;
  float _73;
  float _74;
  float _75;
  float _76;
  float _77;
  float _78;
  float _79;
  bool _80;
  bool _81;
  bool _82;
  float _83;
  float _84;
  float _85;
  float _86;
  float _87;
  float _88;
  float _89;
  float _90;
  float _91;
  bool _92;
  bool _93;
  bool _94;
  float _95;
  float _96;
  float _97;
  float _98;
  float _99;
  float _100;
  float _101;
  float _102;
  float _103;
  float _104;
  float _105;
  float _106;
  float _107;
  float _108;
  bool _109;
  float _110;
  float _111;
  float _112;
  bool _113;
  float _114;
  bool _115;
  float _130;
  float _187;
  float _188;
  float _189;
  float _208;
  float _219;
  float _230;
  bool _256;
  float _298;
  float _309;
  float _320;
  float _329;
  float _330;
  float _331;
  float _345;
  float _356;
  float _367;
  int _384;
  int _385;
  float _386;
  float _387;
  float _388;
  float _117;
  float _118;
  bool _120;
  float _122;
  float _123;
  float _124;
  float _126;
  float _127;
  float _128;
  float _131;
  float _132;
  float _135;
  float _136;
  float _137;
  float _138;
  float _139;
  float _140;
  float _141;
  float _142;
  float _143;
  float _144;
  float _145;
  float _146;
  float _147;
  float _148;
  float _149;
  float _150;
  float _151;
  float _152;
  float _153;
  float _154;
  float _155;
  float _156;
  float _157;
  float _158;
  float _159;
  float _160;
  float _161;
  float _162;
  float _163;
  float _164;
  float _165;
  float _166;
  float _167;
  float _168;
  float _169;
  float _170;
  bool _172;
  float _174;
  int _177;
  int _178;
  float _179;
  float _180;
  float _181;
  float _182;
  float _183;
  float _184;
  float _185;
  float _190;
  float _191;
  bool _192;
  bool _193;
  bool _194;
  bool _196;
  bool _198;
  float _200;
  float _202;
  float _203;
  float _204;
  float _205;
  float _206;
  bool _209;
  float _211;
  float _213;
  float _214;
  float _215;
  float _216;
  float _217;
  bool _220;
  float _222;
  float _224;
  float _225;
  float _226;
  float _227;
  float _228;
  float _235;
  float _236;
  float _237;
  float _238;
  float _239;
  float _240;
  float _241;
  float _242;
  float _243;
  float _244;
  float _245;
  float _246;
  float _247;
  float _248;
  float _249;
  int _250;
  int _251;
  bool _254;
  int _257;
  int _258;
  float _261;
  float _262;
  float _263;
  float _268;
  float _269;
  float _270;
  float _271;
  float _272;
  float _273;
  float _274;
  float _275;
  float _276;
  float _277;
  float _278;
  float _279;
  float _280;
  float _281;
  float _282;
  float _283;
  float _284;
  float _285;
  float _286;
  float _287;
  bool _288;
  float _290;
  float _292;
  float _293;
  float _294;
  float _295;
  float _296;
  bool _299;
  float _301;
  float _303;
  float _304;
  float _305;
  float _306;
  float _307;
  bool _310;
  float _312;
  float _314;
  float _315;
  float _316;
  float _317;
  float _318;
  float _322;
  float _323;
  float _324;
  float _325;
  float _326;
  float _327;
  float _332;
  float _333;
  float _334;
  bool _335;
  float _337;
  float _339;
  float _340;
  float _341;
  float _342;
  float _343;
  bool _346;
  float _348;
  float _350;
  float _351;
  float _352;
  float _353;
  float _354;
  bool _357;
  float _359;
  float _361;
  float _362;
  float _363;
  float _364;
  float _365;
  float _368;
  float _369;
  float _370;
  float _371;
  float _372;
  float _373;
  float _374;
  float _375;
  float _376;
  float _377;
  float _378;
  float _379;
  float _380;
  float _381;
  float _382;
  _14 = int16_t((int)(SV_GroupID.x));
  _15 = int16_t((int)(SV_GroupID.y));
  _17 = int16_t((int)(SV_GroupThreadID.x));
  _18 = _17 & 1;
  _19 = (uint16_t)(_17) >> 1;
  _20 = _19 & 1;
  _21 = _19 & 2;
  _22 = (uint16_t)(_17) >> 2;
  _23 = _22 & 2;
  _24 = _22 & 4;
  _25 = (uint16_t)(_17) >> 3;
  _26 = _25 & 4;
  _27 = _25 & 8;
  _28 = (uint16_t)(_17) >> 4;
  _29 = _28 & 8;
  _30 = _14 << 4;
  _31 = _18 | _30;
  _32 = _31 | _21;
  _33 = _32 | _24;
  _34 = _33 | _27;
  _35 = _15 << 4;
  _36 = _20 | _35;
  _37 = _36 | _23;
  _38 = _37 | _26;
  _39 = _38 | _29;
  _40 = (float)((uint16_t)_34);
  _41 = (float)((uint16_t)_39);
  _42 = _40 + 0.5f;
  _43 = _41 + 0.5f;
  _47 = _42 * screenInverseSize.x;
  _48 = _43 * screenInverseSize.y;
  _51 = GUIImage.SampleLevel(PointClamp, float2(_47, _48), 0.0f);
  _56 = _51.w + -0.003000000026077032f;
  _57 = (_56 < 0.0f);
  _58 = 1.0f / _51.w;
  _62 = _51.x * _58;
  _63 = _51.y * _58;
  _64 = _51.z * _58;

  // quite cheeky
  // _62 = saturate(_62);
  // _63 = saturate(_63);
  // _64 = saturate(_64);

  _65 = _62 + 0.054999999701976776f;
  _66 = _63 + 0.054999999701976776f;
  _67 = _64 + 0.054999999701976776f;
  _68 = _65 * 0.9478673338890076f;
  _69 = _66 * 0.9478673338890076f;
  _70 = _67 * 0.9478673338890076f;
  _71 = log2(_68);
  _72 = log2(_69);
  _73 = log2(_70);
  _74 = _71 * 2.4000000953674316f;
  _75 = _72 * 2.4000000953674316f;
  _76 = _73 * 2.4000000953674316f;
  _77 = exp2(_74);
  _78 = exp2(_75);
  _79 = exp2(_76);
  _80 = !(_62 <= 0.040449999272823334f);
  _81 = !(_63 <= 0.040449999272823334f);
  _82 = !(_64 <= 0.040449999272823334f);
  _83 = (float)((bool)_80);
  _84 = (float)((bool)_81);
  _85 = (float)((bool)_82);
  _86 = _77 * _83;
  _87 = _78 * _84;
  _88 = _79 * _85;
  _89 = _62 * 0.07739938050508499f;
  _90 = _63 * 0.07739938050508499f;
  _91 = _64 * 0.07739938050508499f;
  _92 = (_62 <= 0.040449999272823334f);
  _93 = (_63 <= 0.040449999272823334f);
  _94 = (_64 <= 0.040449999272823334f);
  _95 = (float)((bool)_92);
  _96 = (float)((bool)_93);
  _97 = (float)((bool)_94);
  _98 = _89 * _95;
  _99 = _90 * _96;
  _100 = _91 * _97;
  _101 = _86 + _98;
  _102 = _87 + _99;
  _103 = _88 + _100;
  _104 = max(_102, _103);
  _105 = max(_101, _104);
  _106 = min(_102, _103);
  _107 = min(_101, _106);
  _108 = _105 - _107;
  _109 = !(_105 == 0.0f);
  _110 = _108 / _105;
  _111 = select(_109, _110, 0.0f);
  _112 = 1.0f / _108;
  _113 = (_108 == 0.0f);
  _114 = select(_113, 0.0f, _112);
  _115 = (_101 == _105);
  bool __defer_0_390 = false;
  if (_115) {
    _117 = _102 - _103;
    _118 = _114 * _117;
    _130 = _118;
  } else {
    _120 = (_102 == _105);
    if (_120) {
      _122 = _103 - _101;
      _123 = _114 * _122;
      _124 = _123 + 2.0f;
      _130 = _124;
    } else {
      _126 = _101 - _102;
      _127 = _114 * _126;
      _128 = _127 + 4.0f;
      _130 = _128;
    }
  }
  _131 = _130 * 0.1666666716337204f;
  _132 = frac(_131);
  _135 = (userGlobalParams[10].y) * _111;
  _136 = _132 + 0.6666666865348816f;
  _137 = _132 + 0.3333333432674408f;
  _138 = frac(_132);
  _139 = frac(_136);
  _140 = frac(_137);
  _141 = _138 * 2.0f;
  _142 = _139 * 2.0f;
  _143 = _140 * 2.0f;
  _144 = _141 + -1.0f;
  _145 = _142 + -1.0f;
  _146 = _143 + -1.0f;
  _147 = abs(_144);
  _148 = abs(_145);
  _149 = abs(_146);
  _150 = _147 * 3.0f;
  _151 = _148 * 3.0f;
  _152 = _149 * 3.0f;
  _153 = _150 + -1.0f;
  _154 = _151 + -1.0f;
  _155 = _152 + -1.0f;
  _156 = saturate(_153);
  _157 = saturate(_154);
  _158 = saturate(_155);
  _159 = _156 + -1.0f;
  _160 = _157 + -1.0f;
  _161 = _158 + -1.0f;
  _162 = _159 * _135;
  _163 = _160 * _135;
  _164 = _161 * _135;
  _165 = _162 + 1.0f;
  _166 = _163 + 1.0f;
  _167 = _164 + 1.0f;
  _168 = _165 * _105;
  _169 = _166 * _105;
  _170 = _167 * _105;
  if (!(_57)) {
    _172 = (_51.w > 0.0f);
    if (_172) {
      _174 = 1.0f - _51.w;
      _177 = (uint)((uint)(guiShaderCommonFlag)) >> 8;
      _178 = _177 & 1;
      _179 = (float)((uint)_178);
      _180 = _179 * _174;
      _181 = _180 + _51.w;
      _182 = 1.0f / _181;
      _183 = _182 * _168;
      _184 = _182 * _169;
      _185 = _182 * _170;
      _187 = _183;
      _188 = _184;
      _189 = _185;
    } else {
      _187 = _168;
      _188 = _169;
      _189 = _170;
    }
    _190 = max(_187, _188);
    _191 = max(_190, _189);
    _192 = (_191 == 0.0f);
    _193 = (_51.w == 0.0f);
    _194 = _193 && _192;
    if (!(_194)) {
      _196 = (_51.w == 1.0f);
      [branch]
      if (_196) {
        _198 = !(_187 <= 0.0031308000907301903f);
        [branch]
        if (!(_198)) {
          _200 = _187 * 12.920000076293945f;
          _208 = _200;
        } else {
          _202 = log2(_187);
          _203 = _202 * 0.4166666567325592f;
          _204 = exp2(_203);
          _205 = _204 * 1.0549999475479126f;
          _206 = _205 + -0.054999999701976776f;
          _208 = _206;
        }
        _209 = !(_188 <= 0.0031308000907301903f);
        [branch]
        if (!(_209)) {
          _211 = _188 * 12.920000076293945f;
          _219 = _211;
        } else {
          _213 = log2(_188);
          _214 = _213 * 0.4166666567325592f;
          _215 = exp2(_214);
          _216 = _215 * 1.0549999475479126f;
          _217 = _216 + -0.054999999701976776f;
          _219 = _217;
        }
        _220 = !(_189 <= 0.0031308000907301903f);
        [branch]
        if (!(_220)) {
          _222 = _189 * 12.920000076293945f;
          _230 = _222;
        } else {
          _224 = log2(_189);
          _225 = _224 * 0.4166666567325592f;
          _226 = exp2(_225);
          _227 = _226 * 1.0549999475479126f;
          _228 = _227 + -0.054999999701976776f;
          _230 = _228;
        }
        _235 = log2(_208);
        _236 = log2(_219);
        _237 = log2(_230);
        _238 = _235 * fGammaForOverlay;
        _239 = _236 * fGammaForOverlay;
        _240 = _237 * fGammaForOverlay;
        _241 = exp2(_238);
        _242 = exp2(_239);
        _243 = exp2(_240);
        _244 = _241 * fConvertToLimitForOverlay;
        _245 = _242 * fConvertToLimitForOverlay;
        _246 = _243 * fConvertToLimitForOverlay;
        _247 = _244 + fLowerLimitForOverlay;
        _248 = _245 + fLowerLimitForOverlay;
        _249 = _246 + fLowerLimitForOverlay;
        _250 = (int)(min16uint)(_34);
        _251 = (int)(min16uint)(_39);
        _384 = _251;
        _385 = _250;
        _386 = _247;
        _387 = _248;
        _388 = _249;
      } else {
        if (_193) {
          _254 = !_192;
          _256 = _254;
        } else {
          _256 = false;
        }
        _257 = (int)(min16uint)(_34);
        _258 = (int)(min16uint)(_39);
        _261 = RWResult[int2(_257, _258)].x;
        _262 = RWResult[int2(_257, _258)].y;
        _263 = RWResult[int2(_257, _258)].z;
        _268 = _261 - fLowerLimitForOverlay;
        _269 = _262 - fLowerLimitForOverlay;
        _270 = _263 - fLowerLimitForOverlay;
        _271 = max(_268, 0.0f);
        _272 = max(_269, 0.0f);
        _273 = max(_270, 0.0f);
        _274 = 1.0f / fConvertToLimitForOverlay;
        _275 = _274 * _271;
        _276 = _274 * _272;
        _277 = _274 * _273;
        _278 = 1.0f / fGammaForOverlay;
        _279 = log2(_275);
        _280 = log2(_276);
        _281 = log2(_277);
        _282 = _279 * _278;
        _283 = _280 * _278;
        _284 = _281 * _278;
        _285 = exp2(_282);
        _286 = exp2(_283);
        _287 = exp2(_284);
        _288 = !(_285 <= 0.040449999272823334f);
        [branch]
        if (!(_288)) {
          _290 = _285 * 0.07739938050508499f;
          _298 = _290;
        } else {
          _292 = _285 + 0.054999999701976776f;
          _293 = _292 * 0.9478673338890076f;
          _294 = log2(_293);
          _295 = _294 * 2.4000000953674316f;
          _296 = exp2(_295);
          _298 = _296;
        }
        _299 = !(_286 <= 0.040449999272823334f);
        [branch]
        if (!(_299)) {
          _301 = _286 * 0.07739938050508499f;
          _309 = _301;
        } else {
          _303 = _286 + 0.054999999701976776f;
          _304 = _303 * 0.9478673338890076f;
          _305 = log2(_304);
          _306 = _305 * 2.4000000953674316f;
          _307 = exp2(_306);
          _309 = _307;
        }
        _310 = !(_287 <= 0.040449999272823334f);
        [branch]
        if (!(_310)) {
          _312 = _287 * 0.07739938050508499f;
          _320 = _312;
        } else {
          _314 = _287 + 0.054999999701976776f;
          _315 = _314 * 0.9478673338890076f;
          _316 = log2(_315);
          _317 = _316 * 2.4000000953674316f;
          _318 = exp2(_317);
          _320 = _318;
        }
        if (!(_256)) {
          _322 = _187 - _298;
          _323 = _188 - _309;
          _324 = _189 - _320;
          _325 = _322 * _51.w;
          _326 = _323 * _51.w;
          _327 = _324 * _51.w;
          _329 = _325;
          _330 = _326;
          _331 = _327;
        } else {
          _329 = _187;
          _330 = _188;
          _331 = _189;
        }
        _332 = _329 + _298;
        _333 = _330 + _309;
        _334 = _331 + _320;
        _335 = !(_332 <= 0.0031308000907301903f);
        [branch]
        if (!(_335)) {
          _337 = _332 * 12.920000076293945f;
          _345 = _337;
        } else {
          _339 = log2(_332);
          _340 = _339 * 0.4166666567325592f;
          _341 = exp2(_340);
          _342 = _341 * 1.0549999475479126f;
          _343 = _342 + -0.054999999701976776f;
          _345 = _343;
        }
        _346 = !(_333 <= 0.0031308000907301903f);
        [branch]
        if (!(_346)) {
          _348 = _333 * 12.920000076293945f;
          _356 = _348;
        } else {
          _350 = log2(_333);
          _351 = _350 * 0.4166666567325592f;
          _352 = exp2(_351);
          _353 = _352 * 1.0549999475479126f;
          _354 = _353 + -0.054999999701976776f;
          _356 = _354;
        }
        _357 = !(_334 <= 0.0031308000907301903f);
        [branch]
        if (!(_357)) {
          _359 = _334 * 12.920000076293945f;
          _367 = _359;
        } else {
          _361 = log2(_334);
          _362 = _361 * 0.4166666567325592f;
          _363 = exp2(_362);
          _364 = _363 * 1.0549999475479126f;
          _365 = _364 + -0.054999999701976776f;
          _367 = _365;
        }
        _368 = log2(_345);
        _369 = log2(_356);
        _370 = log2(_367);
        _371 = _368 * fGammaForOverlay;
        _372 = _369 * fGammaForOverlay;
        _373 = _370 * fGammaForOverlay;
        _374 = exp2(_371);
        _375 = exp2(_372);
        _376 = exp2(_373);
        _377 = _374 * fConvertToLimitForOverlay;
        _378 = _375 * fConvertToLimitForOverlay;
        _379 = _376 * fConvertToLimitForOverlay;
        _380 = _377 + fLowerLimitForOverlay;
        _381 = _378 + fLowerLimitForOverlay;
        _382 = _379 + fLowerLimitForOverlay;
        _384 = _258;
        _385 = _257;
        _386 = _380;
        _387 = _381;
        _388 = _382;
      }
      RWResult[int2(_385, _384)] = float3(_386, _387, _388);
    }
  }
  __defer_0_390 = true;
  if (__defer_0_390) {
  }
}