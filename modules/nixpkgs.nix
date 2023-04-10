# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  system,
  lib,
  inputs,
  ...
}: {
  perSystem = {
    system,
    lib,
    ...
  }: let
    inherit (inputs) nixpkgs crosspkgs;
    inherit (crosspkgs.inputs) binutils-gdb gcc glibc llvm;
  in {
    _module.args.pkgs = lib.mkDefault (import nixpkgs {
      localSystem = system;
      overlays = [
        binutils-gdb.overlays.cross
        gcc.overlays.cross
        glibc.overlays.cross
        llvm.overlays.cross
        (import ../overlays/adapters.nix)
      ];
    });
  };
}
