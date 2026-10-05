#include "./shared.h"

// float3 ColourCorrect(float3 colour, float3 reference) {
//   float3 corrected = renodx::color::correct::ChrominanceOKLab(colour, reference, RENODX_TONE_MAP_BLOWOUT);
//   return renodx::color::correct::HueOKLab(corrected, reference, RENODX_HUE_SHIFT);
// }

/// Piecewise rolloff: identity below anchor, asymptotic to peak above it.
/// C denotes differentiability class; C-infinity preserves continuity of all derivatives at the join.
/// Monotonic and concave down; compression_strength controls departure from identity.
/// Requires anchor < peak and compression_strength >= 1.

// shoutout musa!
#define C_INFINITY_ROLLOFF_GENERATOR(T)                                                      \
  T CInfinityRollOff(T color, T peak, T anchor = 0.18f, float compression_strength = 1.5f) { \
    T shoulder_range = peak - anchor;                                                        \
    T distance_from_anchor = max(color - anchor, (T)0.f);                                    \
    T inverse_position = shoulder_range * rcp(compression_strength * distance_from_anchor);  \
    T flat_weight = exp2(-inverse_position);                                                 \
    T response_denominator = mad(compression_strength, inverse_position, flat_weight);       \
    return mad(shoulder_range, rcp(response_denominator), color - distance_from_anchor);     \
  }

C_INFINITY_ROLLOFF_GENERATOR(float)
C_INFINITY_ROLLOFF_GENERATOR(float3)

#undef C_INFINITY_ROLLOFF_GENERATOR

float3 ApplyColorGrade(float3 color)
{
  renodx::color::grade::Config config = renodx::color::grade::config::Create();
  config.exposure = RENODX_TONE_MAP_EXPOSURE;
  config.highlights = RENODX_TONE_MAP_HIGHLIGHTS;
  config.shadows = RENODX_TONE_MAP_SHADOWS;
  config.contrast = RENODX_TONE_MAP_CONTRAST;
  config.flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f);
  config.saturation = RENODX_TONE_MAP_SATURATION;
  config.blowout = -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);
  return renodx::color::grade::config::ApplyUserColorGrading(color, config);
}

float3 ApplyExtendedVanillaResponse(float3 color, float response_strength)
{
  const float midgray_input = 0.18f;

  float3 vanilla_response = 1.0f - exp(-response_strength * color);
  float midgray_response = 1.0f - exp(-response_strength * midgray_input);
  float midgray_slope = response_strength * exp(-response_strength * midgray_input);
  float3 linear_response = midgray_response + midgray_slope * (color - midgray_input);

  return lerp(vanilla_response, linear_response, step(midgray_input, color));
}

float3 DisplayMap(float3 color, bool ui = false)
{
  float peakRatio = RENODX_PEAK_WHITE_NITS / (ui ? RENODX_GRAPHICS_WHITE_NITS : RENODX_DIFFUSE_WHITE_NITS);
  [branch]
  if (RENODX_GAMMA_CORRECTION != 0.f) {
    peakRatio = renodx::color::correct::Gamma(
        peakRatio,
        true,
        renodx::math::Select(RENODX_GAMMA_CORRECTION == 1.f, 2.2f, 2.4f));
  }

  // return renodx::tonemap::neutwo::PerChannel(color, peakRatio);
  return CInfinityRollOff(color, peakRatio);
}
