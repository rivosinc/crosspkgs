# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License; see LICENSE for details.
# SPDX-License-Identifier: MIT
# Systems we're interested in building for.
{
  aarch64 = {
    generic = {
      system = "aarch64-linux";
    };
  };

  riscv64 = let
    system = "riscv64-linux";
  in {
    generic = {
      inherit system;
      gcc.arch = "rv64gc";
    };
  };

  x86_64 = let
    system = "x86_64-linux";
  in {
    x86_64_v2 = {
      inherit system;
      gcc.arch = "x86-64-v2";
    };
    x86_64_v3 = {
      inherit system;
      gcc.arch = "x86-64-v3";
    };
    x86_64_v4 = {
      inherit system;
      gcc.arch = "x86-64-v4";
    };
    icelake_server = {
      inherit system;
      gcc.arch = "icelake-server";
    };
    sapphirerapids = {
      inherit system;
      gcc.arch = "sapphirerapids";
    };
    zen4 = {
      inherit system;
      gcc.arch = "znver4";
    };
  };
}
