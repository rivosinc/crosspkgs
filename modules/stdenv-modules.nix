# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
# The top-level module that is exposed via flakeModules.default.
# This file should only include direct imports and imports via perSystem.
{
  imports = [
    ./args.nix
    ./cross-pkgsets.nix
    ./dev-systems.nix
    ./nixpkgs.nix
    ./pre-commit.nix
  ];

  perSystem = {...}: {
    imports = [
      ./formatter.nix
    ];
  };
}
