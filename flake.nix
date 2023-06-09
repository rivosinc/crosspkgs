# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License; see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  description = "cross-compilation flake modules";

  inputs = {
    nixpkgs.url = "github:rivosinc/nixpkgs/rivos/nixos-22.11?allRefs=1";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-filter.url = "github:numtide/nix-filter";

    gcc.url = "github:rivosinc/gcc/rivos/releases/gcc-12";
    gcc.inputs.nixpkgs.follows = "nixpkgs";

    llvm.url = "github:rivosinc/llvm-project/rivos/release/16.x";
    llvm.inputs.nixpkgs.follows = "nixpkgs";

    binutils-gdb.url = "github:rivosinc/binutils-gdb/rivos/binutils-2_40-branch";
    binutils-gdb.inputs.nixpkgs.follows = "nixpkgs";

    glibc.url = "github:rivosinc/glibc/rivos/release/2.37/master";
    glibc.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./modules/stdenv-modules.nix
      ];
      flake = {
        flakeModules.default = ./modules/stdenv-modules.nix;
        overlays.rivosAdapters = import ./overlays/adapters.nix;
      };
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];
    };
}
