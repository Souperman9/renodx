/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#include <include/reshade_api_resource.hpp>
#define ImTextureID ImU64

#define DEBUG_LEVEL_0
#define DEBUG_LEVEL_1
#define DEBUG_LEVEL_2

#include <embed/shaders.h>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../templates/settings.hpp"
#include "../../utils/date.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"
#include "./utils/shader_hotswap.hpp"

namespace {

float draw_dof = 1.f;

renodx::mods::shader::CustomShaders custom_shaders = {
    // {
    //     0xB8E882B4,
    //     {
    //         .crc32 = 0xB8E882B4,
    //         .on_draw = [](auto*) { return draw_dof != 0.f; },
    //     },
    // },
    // {
    //     0xB36C88E9,
    //     {
    //         .crc32 = 0xB36C88E9,
    //         .on_draw = [](auto*) { return draw_dof != 0.f; },
    //     },
    // },
    __ALL_CUSTOM_SHADERS,
};

ShaderInjectData shader_injection;

renodx::utils::settings::Settings settings = renodx::templates::settings::JoinSettings({

    renodx::templates::settings::CreateDefaultSettings({
        {"ToneMapType", {.binding = &shader_injection.tone_map_type, .value_type = renodx::utils::settings::SettingValueType::INTEGER, .default_value = 1, .label = "Tone Mapper", .section = "Tone Mapping", .tooltip = "Sets the tone mapper type", .labels = {"Vanilla", "Vanilla+"}}},
    }),
    renodx::templates::settings::CreateDefaultSettings({
        {"ToneMapType", &shader_injection.tone_map_type},
        {"ToneMapPeakNits", &shader_injection.peak_white_nits},
        {"ToneMapGameNits", &shader_injection.diffuse_white_nits},
        {"ToneMapUINits", &shader_injection.graphics_white_nits},
        {"ToneMapGammaCorrection", &shader_injection.gamma_correction},
    }),
    // {
    //     new renodx::utils::settings::Setting{
    //         .key = "ColorGradeScene",
    //         .binding = &shader_injection.scene_grade_strength,
    //         .default_value = 50.f,
    //         .label = "Hue Shift",
    //         .section = "Tone Mapping",
    //         .tooltip = "Emulates SDR hue shifts to match vanilla",
    //         .max = 100.f,
    //         .is_enabled = []() { return shader_injection.tone_map_type > 0.f; },
    //         .parse = [](float value) { return value * 0.01f; },
    //         .is_visible = []() { return renodx::templates::settings::current_settings_mode > 1.f; },
    //     },
    //     new renodx::utils::settings::Setting{
    //         .key = "ColorGradeBlowout",
    //         .binding = &shader_injection.tone_map_blowout,
    //         .default_value = 50.f,
    //         .label = "SDR Blowout",
    //         .section = "Tone Mapping",
    //         .tooltip = "Emulates SDR blowout to match vanilla",
    //         .max = 100.f,
    //         .is_enabled = []() { return shader_injection.tone_map_type > 0.f; },
    //         .parse = [](float value) { return value * 0.01f; },
    //         .is_visible = []() { return renodx::templates::settings::current_settings_mode > 1.f; },
    //     },
    // },

    renodx::templates::settings::CreateDefaultSettings({
        {"ColorGradeExposure", &shader_injection.tone_map_exposure},
        {"ColorGradeHighlights", &shader_injection.tone_map_highlights},
        {"ColorGradeShadows", &shader_injection.tone_map_shadows},
        {"ColorGradeContrast", &shader_injection.tone_map_contrast},
        {"ColorGradeSaturation", &shader_injection.tone_map_saturation},
        {"ColorGradeHighlightSaturation", &shader_injection.tone_map_highlight_saturation},
        {"ColorGradeFlare", &shader_injection.tone_map_flare},
    }),
    {
        new renodx::utils::settings::Setting{
            .key = "LutStrength",
            .binding = &shader_injection.lut_strength,
            .default_value = 100.f,
            .label = "LUT Strength",
            .section = "Color Grading",
            .tooltip = "Controls intensity of LUT applied by the game.",
            .max = 100.f,
            .parse = [](float value) { return value * 0.01f; },
            .is_visible = []() { return renodx::templates::settings::current_settings_mode > 1.f; },
        },
        // new renodx::utils::settings::Setting{
        //     .key = "FxDof",
        //     .binding = &draw_dof,
        //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        //     .default_value = 1.f,
        //     .label = "Depth of Field",
        //     .section = "Effects",
        //     .tooltip = "Enables/Disables Depth of Field. May not work in all areas.",
        //     .labels = {"Off", "On"},
        // },
        new renodx::utils::settings::Setting{
            .key = "FxBloom",
            .binding = &shader_injection.custom_bloom,
            .default_value = 100.f,
            .label = "Bloom",
            .section = "Effects",
            .max = 100.f,
            .parse = [](float value) { return value * 0.01f; },
        },
        new renodx::utils::settings::Setting{
            .key = "FxCA",
            .binding = &shader_injection.chromatic_aberration,
            .default_value = 100.f,
            .label = "Chromatic Aberration",
            .section = "Effects",
            .tooltip = "Not active in all scenes",
            .max = 200.f,
            .parse = [](float value) { return value * 0.01f; },
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "My Ko-Fi!",
            .section = "Links",
            .group = "button-line-1",
            .tint = 0x6b221a,
            .parse = [](float value) { return value; },
            .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/souperman9"); },
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "RenoDX Discord",
            .section = "Links",
            .group = "button-line-2",
            .tint = 0x5865F2,
            .parse = [](float value) { return value; },
            .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/renodx", "EbcCpC"); },
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "HDR Den Discord",
            .section = "Links",
            .group = "button-line-2",
            .tint = 0x5865F2,
            .parse = [](float value) { return value; },
            .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/XUhv", "tR54yc"); },
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "Github",
            .section = "Links",
            .group = "button-line-2",
            .parse = [](float value) { return value; },
            .on_change = []() { renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx"); },
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "Ritsu's Ko-Fi",
            .section = "Links",
            .group = "button-line-3",
            .tint = 0xFF5F5F,
            .parse = [](float value) { return value; },
            .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/ritsucecil"); },
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "ShortFuse's Ko-Fi",
            .section = "Links",
            .group = "button-line-3",
            .tint = 0xFF5F5F,
            .parse = [](float value) { return value; },
            .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/shortfuse"); },
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::TEXT,
            .label = "Game mod by souperman9, RenoDX Framework by ShortFuse, RenoVK fork by Ritsu. Based on Ritsu's Bloodborne proof-of-concept",
            .section = "About",
        },
        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::TEXT,
            .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
            .section = "About",
        },
    },
});

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapType", 0.f},
      {"ToneMapPeakNits", 203.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"ToneMapGammaCorrection", 0.f},
      {"ColorGradeExposure", 1.f},
      {"ColorGradeHighlights", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"ColorGradeHighlightSaturation", 50.f},
      {"ColorGradeBlowout", 0.f},
      {"ColorGradeFlare", 0.f},
  });
}

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Bloodborne";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  auto use_resource_view_cloning = true;
  auto common_aspect_ratio = 16.f / 9.f;
  auto common_aspect_ratio_tolerance = 0.00001f;
  auto common_ignore_size = false;
  auto windowed_aspect_ratio = 2582.f / 1452.f;
  const auto target_format = reshade::api::format::r16g16b16a16_float;
  const auto view_upgrades = renodx::utils::resource::VIEW_UPGRADES_RGBA16F;
  const renodx::utils::resource::ResourceUpgradeInfo::Dimensions dimensions = {
      .width = renodx::utils::resource::ResourceUpgradeInfo::ANY,
      .height = renodx::utils::resource::ResourceUpgradeInfo::ANY,
      .depth = renodx::utils::resource::ResourceUpgradeInfo::ANY,
  };

  const renodx::utils::resource::ResourceUpgradeInfo::Dimensions min_dimensions = {
      .width = renodx::utils::resource::ResourceUpgradeInfo::ANY,
      .height = 719,
      .depth = renodx::utils::resource::ResourceUpgradeInfo::ANY,
  };

  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      // Always set to true for Vulkan
      renodx::mods::shader::allow_multiple_push_constants = true;
      renodx::mods::swapchain::use_resource_cloning = true;
      // renodx::mods::swapchain::swap_chain_proxy_vertex_shader = __swap_chain_proxy_vertex_shader;
      // renodx::mods::swapchain::swap_chain_proxy_pixel_shader = __swap_chain_proxy_pixel_shader;
      renodx::mods::swapchain::target_format = target_format;
      renodx::mods::swapchain::force_borderless = false;

      /*
        If expand_existing_constant_buffer is set to false renoDX will add new cbuffer range (instead of reusing the game's).
        This behaviour is overridden if renoDX finds a cbuffer that targets all shader_stages in minimum_constant_buffer_stages.
        e.g. If a game's cbuffer range targets all stages, renoDX will expand it regardless of expand_existing_constant_buffer value.
        Remove the stages you're not injecting to.
      */
      renodx::mods::shader::minimum_constant_buffer_stages = reshade::api::shader_stage::pixel;

      // renodx::mods::shader::use_pipeline_layout_cloning = true;
      // common_aspect_ratio = renodx::utils::resource::ResourceUpgradeInfo::ANY;
      // common_aspect_ratio_tolerance = 0.0001f;

      renodx::mods::swapchain::resource_upgrade_infos.push_back({
          .old_format = reshade::api::format::b8g8r8a8_typeless,
          .new_format = target_format,
          // .shader_hash = 0x795F09E4,
          // .use_resource_view_cloning = true,
          .dimensions = dimensions,
          .min_dimensions = min_dimensions,
      });

    //   renodx::mods::swapchain::resource_upgrade_infos.push_back({
    //       .old_format = reshade::api::format::r8g8b8a8_typeless,
    //       .new_format = target_format,
    //       // .shader_hash = 0x795F09E4,
    //       // .use_resource_view_cloning = true,
    //       .dimensions = dimensions,
    //       .min_dimensions = min_dimensions,
    //   });

      renodx_custom::utils::shader_hotswap::targets.clear();
      static std::vector<uint32_t> hashes = {0x057DC7EE, 0xB07E81D8, 0x2A3848AC, 0x6DF7D53F, 0x83B947BD, 0xE8A4B705, 0x02858BA6, 0x95FA83C3};  // 0.18.0
      hashes.insert(hashes.end(), {0xE3B54D79, 0xC4763462, 0x054E5C81, 0xB4337B61, 0x2CA36DA1, 0x3A43E8A9, 0xF379098D, 0x61130394});
      for (uint32_t hash : hashes) {
        for (int i = 0; i < 3; i++) {
          renodx_custom::utils::shader_hotswap::targets.push_back({
              .old_format = reshade::api::format::r8g8b8a8_typeless,
              .new_format = target_format,
              .shader_hash = hash,
              .use_resource_view_cloning = true,
              .dimensions = dimensions,
              .min_dimensions = min_dimensions,
          });
        }
      }

      if (!initialized) {
        // renodx::utils::random::binds.push_back(&shader_injection.swap_chain_output_dither_seed);
        initialized = true;
      }

      renodx_custom::utils::shader_hotswap::UseEarly(fdw_reason);

      break;
    case DLL_PROCESS_DETACH:
      renodx_custom::utils::shader_hotswap::UseEarly(fdw_reason);
      reshade::unregister_addon(h_module);
      break;
  }

  // renodx::utils::random::Use(DLL_PROCESS_ATTACH);
  renodx::mods::swapchain::Use(fdw_reason);
  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  renodx_custom::utils::shader_hotswap::UseLate(fdw_reason);

  return TRUE;
}
