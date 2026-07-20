cbuffer GUIConstantUBO : register(b0, space0)
{
    float4 GUIConstant_m0[18] : packoffset(c0);
};

cbuffer UserMaterialUBO : register(b1, space0)
{
    float4 UserMaterial_m0[1] : packoffset(c0);
};

Texture2D<float4> Texture : register(t0, space0);
SamplerState AutomaticWrap : register(s0, space0);

static float3 POSITION;
static float4 COLOR;
static float2 TEXCOORD;
static float2 TEXCOORD_1;
static float4 SV_Target;

struct SPIRV_Cross_Input
{
	float4 projectedPosition : SV_Position;
    float3 POSITION : POSITION0;
    float4 COLOR : COLOR0;
    float2 TEXCOORD : TEXCOORD0;
    float2 TEXCOORD_1 : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 SV_Target : SV_Target0;
};

static bool discard_state;

void discard_cond(bool _300)
{
    if (_300)
    {
        discard_state = true;
    }
}

void discard_exit()
{
    if (discard_state)
    {
        discard;
    }
}

void frag_main()
{
    discard_state = false;
    float4 _64 = Texture.Sample(AutomaticWrap, float2(TEXCOORD.x, TEXCOORD.y));
    float _66 = _64.x;
    float _67 = _64.y;
    float _68 = _64.z;
    float _69 = _64.w;
    float _74;
    float _76;
    float _78;
    float _80;
    if (UserMaterial_m0[0u].x != 1.0f)
    {
        float _183;
        float _185;
        float _187;
        float _189;
        if (UserMaterial_m0[0u].x > 0.0f)
        {
            float _237;
            float _238;
            float _239;
            float _240;
            uint _241;
            _237 = _66;
            _238 = _67;
            _239 = _68;
            _240 = _69;
            _241 = 0u;
            float _184;
            float _186;
            float _188;
            float _190;
            for (;;)
            {
                float _246 = (6.283185482025146484375f / UserMaterial_m0[0u].x) * float(int(_241));
                float4 _256 = Texture.Sample(AutomaticWrap, float2((sin(_246) * UserMaterial_m0[0u].y) + TEXCOORD.x, (cos(_246) * UserMaterial_m0[0u].y) + TEXCOORD.y));
                _184 = _256.x + _237;
                _186 = _256.y + _238;
                _188 = _256.z + _239;
                _190 = _256.w + _240;
                uint _242 = _241 + 1u;
                if (float(int(_242)) < UserMaterial_m0[0u].x)
                {
                    _237 = _184;
                    _238 = _186;
                    _239 = _188;
                    _240 = _190;
                    _241 = _242;
                }
                else
                {
                    break;
                }
            }
            _183 = _184;
            _185 = _186;
            _187 = _188;
            _189 = _190;
        }
        else
        {
            _183 = _66;
            _185 = _67;
            _187 = _68;
            _189 = _69;
        }
        float _191 = UserMaterial_m0[0u].x + 1.0f;
        _74 = _183 / _191;
        _76 = _185 / _191;
        _78 = _187 / _191;
        _80 = _189 / _191;
    }
    else
    {
        _74 = _66;
        _76 = _67;
        _78 = _68;
        _80 = _69;
    }
    float _140 = 1.0f / ((float((asuint(GUIConstant_m0[15u]).w >> 8u) & 1u) * (1.0f - _80)) + _80);
    discard_cond((_80 + (-9.9999997473787516355514526367188e-05f)) < 0.0f);
    float _148 = (_140 * COLOR.x) * ((((exp2(log2(_74) * 0.4166666567325592041015625f) * 1.05499994754791259765625f) + (-0.054999999701976776123046875f)) * float(_74 > 0.003130800090730190277099609375f)) + ((_74 * 12.9200000762939453125f) * float(_74 <= 0.003130800090730190277099609375f)));
    float _150 = (_140 * COLOR.y) * ((((exp2(log2(_76) * 0.4166666567325592041015625f) * 1.05499994754791259765625f) + (-0.054999999701976776123046875f)) * float(_76 > 0.003130800090730190277099609375f)) + ((_76 * 12.9200000762939453125f) * float(_76 <= 0.003130800090730190277099609375f)));
    float _152 = (_140 * COLOR.z) * ((((exp2(log2(_78) * 0.4166666567325592041015625f) * 1.05499994754791259765625f) + (-0.054999999701976776123046875f)) * float(_78 > 0.003130800090730190277099609375f)) + ((_78 * 12.9200000762939453125f) * float(_78 <= 0.003130800090730190277099609375f)));
    float _153 = _80 * COLOR.w;
    discard_cond((_153 + (-9.9999997473787516355514526367188e-05f)) < 0.0f);
    float _156 = dot(float4(_148, _150, _152, _153), float4(0.29890000820159912109375f, 0.586600005626678466796875f, 0.11450000107288360595703125f, 0.0f));
    float _172 = (GUIConstant_m0[12u].y * (_156 - _148)) + _148;
    float _173 = (GUIConstant_m0[12u].y * (_156 - _150)) + _150;
    float _174 = (GUIConstant_m0[12u].y * (_156 - _152)) + _152;
    uint4 _177 = asuint(GUIConstant_m0[15u]);
    uint _178 = _177.w;
    float _213;
    if ((_153 < 1.0f) && ((_178 & 2u) != 0u))
    {
        float _212 = (exp2(log2((_153 + 0.054999999701976776123046875f) * 0.947867333889007568359375f) * 2.400000095367431640625f) * float(_153 > 0.040449999272823333740234375f)) + ((_153 * 0.077399380505084991455078125f) * float(_153 <= 0.040449999272823333740234375f));
        float frontier_phi_6_5_ladder;
        if ((_178 & 4u) == 0u)
        {
            float _264 = 1.0f - _153;
            float _278 = (1.0f - ((_264 * 0.077399380505084991455078125f) * float(_264 <= 0.040449999272823333740234375f))) - (exp2(log2((1.05499994754791259765625f - _153) * 0.947867333889007568359375f) * 2.400000095367431640625f) * float(_264 > 0.040449999272823333740234375f));
            frontier_phi_6_5_ladder = (((_212 - _278) * 0.3333333432674407958984375f) * (((_173 + _172) + _174) / GUIConstant_m0[12u].x)) + _278;
        }
        else
        {
            frontier_phi_6_5_ladder = _212;
        }
        _213 = frontier_phi_6_5_ladder;
    }
    else
    {
        _213 = _153;
    }
    SV_Target.x = (GUIConstant_m0[16u].x + _172) * _213;
    SV_Target.y = (GUIConstant_m0[16u].y + _173) * _213;
    SV_Target.z = (GUIConstant_m0[16u].z + _174) * _213;
    SV_Target.w = _213 * float((_178 >> 7u) & 1u);
    discard_exit();
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    POSITION = stage_input.POSITION;
    COLOR = stage_input.COLOR;
    TEXCOORD = stage_input.TEXCOORD;
    TEXCOORD_1 = stage_input.TEXCOORD_1;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.SV_Target = SV_Target;
    return stage_output;
}
