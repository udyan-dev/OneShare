//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <s2n_quic/s2n_quic_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  S2nQuicPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("S2nQuicPluginCApi"));
}
