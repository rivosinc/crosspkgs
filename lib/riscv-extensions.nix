# SPDX-FileCopyrightText: Copyright (c) 2023 by Rivos Inc.
# Licensed under the MIT License; see LICENSE for details.
# SPDX-License-Identifier: MIT
# Support code for dealing with RISC-V extensions.
{lib}: {
  RVA20U64 = {
    isaString = "rv64gc";
    marchString = "rv64gc";
    qemuCpu = "rv64,g=true,c=true";
  };
  RVA22U64 = {
    isaString = "rv64gc_Zba_Zbb_Zbs_Zihintpause_Zicbom_Zicbop_Zicboz_Zfhmin_Zkt";
    marchString = "rv64gc_zba_zbb_zbs_zihintpause_zicbom_zicbop_zicboz_zfhmin_zkt";
    qemuCpu = "rv64,g=true,c=true,zba=true,zbb=true,zbs=true,Zihintpause=true,zicbom=true,zicboz=true,Zfhmin=true,zkt=true";
  };
  RVA22U64Full = {
    isaString = "rv64gcv_Zba_Zbb_Zbs_Zihintpause_Zicbom_Zicbop_Zicboz_Zfh_Zkn_Zks_Zkt";
    marchString = "rv64gcv_zba_zbb_zbs_zihintpause_zicbom_zicbop_zicboz_zfh_zkn_zks_zkt";
    qemuCpu = "rv64,g=true,c=true,v=true,vext_spec=v1.0,zba=true,zbb=true,zbs=true,Zihintpause=true,zicbom=true,zicboz=true,Zfh=true,zkn=true,zks=true,zkt=true";
  };
}
