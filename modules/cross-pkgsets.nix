# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License; see LICENSE for details.
# SPDX-License-Identifier: MIT
# Instantiate package sets for each cross config that we're interested in.
{
  inputs,
  config,
  lib,
  system,
  ...
}: let
  systems = import ../lib/systems.nix {inherit lib;};

  profiles = pkgs: let
    inherit (pkgs) rivosAdapters stdenvAdapters;
  in rec {
    default = [];
    perf = [
      rivosAdapters.disableHardening
      rivosAdapters.embedDebugInfo
    ];
    perfStatic = [
      rivosAdapters.disableHardening
      rivosAdapters.embedDebugInfo
      rivosAdapters.makeStatic
    ];
  };
  # Apply the adapters for a given profile.
  applyAdapterOverlay = profile: final: prev: let
    inherit (prev) rivosAdapters stdenvAdapters;
  in {
    stdenv = rivosAdapters.modifyStdenv prev.stdenv ((profiles prev).${profile});
  };
in {
  perSystem = {system, ...}: let
    inherit (inputs) nixpkgs;
    crosspkgs = inputs.crosspkgs or inputs.self;
    inherit (crosspkgs.inputs) binutils-gdb gcc glibc llvm;
    buildPkgSet = {
      crossSystem,
      profile,
    }:
      (import nixpkgs) {
        localSystem = system;
        inherit crossSystem;
        overlays = [
          binutils-gdb.overlays.cross
          gcc.overlays.cross
          glibc.overlays.cross
          llvm.overlays.cross
          (import ../overlays/adapters.nix)
        ];
        crossOverlays = [
          (applyAdapterOverlay profile)
          (config.flake.overlays.default or (final: prev: {}))
        ];
      };
  in {
    legacyPackages = {
      pkgsRiscv64 = buildPkgSet {
        crossSystem = systems.riscv64.generic;
        profile = "default";
      };
      pkgsRVA22 = buildPkgSet {
        crossSystem = systems.riscv64.rva22;
        profile = "default";
      };
      pkgsRVA22Full = buildPkgSet {
        crossSystem = systems.riscv64.rva22Full;
        profile = "default";
      };
      perfPkgsRiscv64 = buildPkgSet {
        crossSystem = systems.riscv64.generic;
        profile = "perf";
      };
      perfPkgsRVA22 = buildPkgSet {
        crossSystem = systems.riscv64.rva22;
        profile = "perf";
      };
      perfPkgsRiscv64Static = buildPkgSet {
        crossSystem = systems.riscv64.generic;
        profile = "perfStatic";
      };
      perfPkgsZen3 = buildPkgSet {
        crossSystem = systems.x86_64.zen3;
        profile = "perf";
      };
      perfPkgsZen4 = buildPkgSet {
        crossSystem = systems.x86_64.zen4;
        profile = "perf";
      };
      perfPkgsSapphireRapids = buildPkgSet {
        crossSystem = systems.x86_64.sapphirerapids;
        profile = "perf";
      };
    };
  };
}
