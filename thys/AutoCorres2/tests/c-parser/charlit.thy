(*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 * Copyright (c) 2022 Apple Inc. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *)

theory charlit
imports "AutoCorres2.CTranslation"
begin

install_C_file "charlit.c"

context charlit_simpl
begin

  thm f_body_def

end

end
