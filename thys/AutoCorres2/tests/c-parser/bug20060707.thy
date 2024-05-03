(*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 * Copyright (c) 2022 Apple Inc. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *)

theory bug20060707
imports "AutoCorres2.CTranslation"
begin

install_C_file "bug20060707.c"

context bug20060707_simpl
begin

  thm f_body_def
  thm f_invs_body_def
end

end
