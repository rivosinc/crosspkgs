<!--
SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.

SPDX-License-Identifier: CC-BY-SA-4.0
-->

# crosspkgs

[![REUSE status](https://api.reuse.software/badge/github.com/rivosinc/crosspkgs)](https://api.reuse.software/info/github.com/rivosinc/crosspkgs)

Cross-compile your nix flake with your own toolchain.

## How to use

1. Add `crosspkgs` to your nix flake:

```nix
inputs.crosspkgs.url = "github:rivosinc/crosspkgs";
```

2. Write your flake with [flake-parts](https://flake.parts/).

3. In your top-level `mkFlake` configuration, add `crosspkgs.flakeModules.default`

4. Either write an overlay named `default`, or add
   `flake-parts.flakeModules.easyOverlay` to the list of imports. This will
   automatically be added to the cross-compiled package sets, so your package
   will show up under, for example, `pkgsRVA22.foo`.

```nix
...
flake-parts.lib.mkFlake {inherit inputs;}
{
  imports = [
    crosspkgs.flakeModules.default
    flake-parts.flakeModules.easyOverlay
  ];
  ...
}
```

## TODO

-  Expose package sets as config options.
   Right now these are hardcoded in crosspkgs.
-  Make bootable cross-compiled VMs.
   qemu-user is great, but sometimes you really need a native gdb.
-  Better handling of RISC-V ISA extensions.
   It should be possible to pick individual extensions and produce valid
   `-march` strings. And do a basic check that a given compiler version
   actually supports an extension.
