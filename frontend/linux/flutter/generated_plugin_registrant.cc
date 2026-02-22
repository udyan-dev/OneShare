//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <s2n_quic/s2n_quic_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) s2n_quic_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "S2nQuicPlugin");
  s2n_quic_plugin_register_with_registrar(s2n_quic_registrar);
}
