# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
# Set the default formatter for all Rivos flakes.
{pkgs, ...}: {
  formatter = pkgs.alejandra;
}
