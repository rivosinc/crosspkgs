# SPDX-FileCopyrightText: Copyright (c) 2022 by Rivos Inc.
# SPDX-FileCopyrightText: Copyright (c) 2003-2022 Eelco Dolstra and the Nixpkgs/NixOS contributors
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  lib,
  pkgs,
  config,
}: let
  # It would be nice not to go behind nixpkgs's back to get this, but stdenvAdapters isn't overridable.
  defaultMkDerivationFromStdenv = import (pkgs.path + "/pkgs/stdenv/generic/make-derivation.nix") {inherit lib config;};
  inherit (pkgs.stdenvAdapters) makeStaticBinaries makeStaticLibraries makeStaticDarwin overrideInStdenv propagateBuildInputs;
  # Low level function to help with overriding `mkDerivationFromStdenv`. One
  # gives it the old stdenv arguments and a "continuation" function, and
  # underneath the final stdenv argument it yields to the continuation to do
  # whatever it wants with old `mkDerivation` (old `mkDerivationFromStdenv`
  # applied to the *new, final* stdenv) provided for convenience.
  withOldMkDerivation = stdenvSuperArgs: k: stdenvSelf: let
    mkDerivationFromStdenv-super = stdenvSuperArgs.mkDerivationFromStdenv or defaultMkDerivationFromStdenv;
    mkDerivationSuper = mkDerivationFromStdenv-super stdenvSelf;
  in
    k stdenvSelf mkDerivationSuper;

  # Wrap the original `mkDerivation` providing extra args to it.
  extendMkDerivationArgs = old: f:
    withOldMkDerivation old (_: mkDerivationSuper: args:
      (mkDerivationSuper args).overrideAttrs f);
in rec {
  # Set linker-only flags. Like withCFlags.
  withLinkFlags = linkFlags: stdenv:
    stdenv.override (old: {
      mkDerivationFromStdenv = extendMkDerivationArgs old (args: {
        NIX_CFLAGS_LINK = toString (args.NIX_CFLAGS_LINK or "") + " ${toString linkFlags}";
      });
    });

  # Makes a stdenv produce static binaries and libraries by default.
  # Note: this _cannot_ be used to override the main stdenv for nixpkgs when using glibc!
  # Use isStatic = true for the crossSystem when instantiating nixpkgs for that.
  makeStatic = stdenv:
    modifyStdenv stdenv (
      lib.optional stdenv.hostPlatform.isDarwin makeStaticDarwin
      ++ [makeStaticLibraries propagateBuildInputs]
      # Apple does not provide a static version of libSystem or crt0.o
      # So we can’t build static binaries without extensive hacks.
      ++ lib.optional (!stdenv.hostPlatform.isDarwin) makeStaticBinaries
      # Glibc doesn’t come with static runtimes by default.
      # Uncomment if using upstream nixpkgs.
      #++ lib.optional (stdenv.hostPlatform.libc == "glibc") ((lib.flip overrideInStdenv) [
      #  (
      #    if stdenv.buildPlatform != stdenv.targetPlatform
      #    then pkgs.glibcCross.static
      #    else pkgs.glibc.static
      #  )
      #])
    );

  # Undo the effects of makeStatic.
  makeDynamic = stdenv0:
    stdenv0.override (old: {
      mkDerivationFromStdenv = withOldMkDerivation old (stdenv: mkDerivationSuper: args:
        (mkDerivationSuper args).overrideAttrs (oldAttrs: {
          NIX_CFLAGS_LINK = lib.concatStringsSep " " (lib.remove "-static" (lib.splitString " " (oldAttrs.NIX_CFLAGS_LINK or "")));
          configureFlags = lib.subtractLists ["--disable-shared" "--enable-static"] oldAttrs.configureFlags or [];
        }));
      extraBuildInputs = builtins.filter (d: d.pname != "glibc") (old.extraBuildInputs or []);
    });

  # Like stdenvAdapters.keepDebugInfo, but doesn't mess with optimization and
  # ensures debug info remains built-in.
  embedDebugInfo = stdenv:
    stdenv.override (old: {
      mkDerivationFromStdenv = extendMkDerivationArgs old (args: {
        dontStrip = true;
        separateDebugInfo = false;
        NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") + " -ggdb";
      });
    });

  # Disables all hardening flags.
  disableHardening = stdenv:
    stdenv.override (old: {
      mkDerivationFromStdenv = extendMkDerivationArgs old (args: {
        hardeningDisable = ["all"];
      });
    });

  # Applies a list of adapters to a stdenv.
  modifyStdenv = stdenv: adapters: lib.foldl (lib.flip lib.id) stdenv adapters;
}
