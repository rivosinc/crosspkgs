# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License; see LICENSE for details.
# SPDX-License-Identifier: MIT

# adapters should be after any glibc overrides to ensure that makeStatic
# picks up the right package.
final: prev: rec {
  # Don't use callPackage here! Look at how stdenvAdapters is imported in
  # top-level/stage.nix.
  rivosAdapters = import ../lib/stdenv-adapters.nix {
    inherit (prev) lib config;
    pkgs = prev;
  };

  rivosWorkloadStdenv = rivosAdapters.modifyStdenv final.stdenv [
    rivosAdapters.disableHardening
    rivosAdapters.embedDebugInfo
    rivosAdapters.makeStatic
  ];

  stdenvNoCC = prev.stdenvNoCC.override (
    {
      cc = null;
      hasCC = false;
    }
    // final.lib.optionalAttrs (prev.stdenv.hostPlatform != prev.stdenv.buildPlatform) {
      # RIVOS: avoid infinite recursion when bootstrapping a cross glibc
      # environment. Otherwise, linux-headers will use glibc.static.
      extraBuildInputs = [];
    }
  );
}
