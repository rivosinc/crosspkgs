# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
# Additional args passed into modules.
{
  inputs,
  lib,
  ...
}: let
  nix-filter = lib.mkOptionDefault (inputs.nix-filter or inputs.crosspkgs.nix-filter);
in {
  _module.args.nix-filter = nix-filter;
  perSystem._module.args.nix-filter = nix-filter;
}
