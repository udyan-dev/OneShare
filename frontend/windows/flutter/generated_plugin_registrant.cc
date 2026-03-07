//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_windows.h>
#include <s2n_quic_flutter/s2n_quic_flutter_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  S2nQuicFlutterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("S2nQuicFlutterPluginCApi"));
}
