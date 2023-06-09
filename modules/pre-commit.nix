# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# SPDX-License-Identifier: MIT
{inputs, ...}: {
  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
  ];
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # dotnet-sdk doesn't build on riscv64.
    pre-commit.check.enable = system != "riscv64-linux";
    pre-commit.settings.hooks = {
      alejandra.enable = true;
      deadnix.enable = true;
      reuse = {
        enable = true;
        name = "reuse";
        description = "Check REUSE compliance";
        entry = "${pkgs.reuse}/bin/reuse lint";
      };
    };
  };
}
