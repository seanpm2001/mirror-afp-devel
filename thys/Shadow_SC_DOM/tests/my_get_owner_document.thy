(***********************************************************************************
 * Copyright (c) 2016-2020 The University of Sheffield, UK
 *               2019-2020 University of Exeter, UK
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 ***********************************************************************************)

(* This file is automatically generated, please do not modify! *)

section\<open>Testing my\_get\_owner\_document\<close>
text\<open>This theory contains the test cases for my\_get\_owner\_document.\<close>

theory my_get_owner_document
imports
  "Shadow_DOM_BaseTest"
begin

definition my_get_owner_document_heap :: "heap\<^sub>f\<^sub>i\<^sub>n\<^sub>a\<^sub>l" where
  "my_get_owner_document_heap = create_heap [(cast (document_ptr.Ref 1), cast (create_document_obj html (Some (cast (element_ptr.Ref 1))) [])),
    (cast (element_ptr.Ref 1), cast (create_element_obj ''html'' [cast (element_ptr.Ref 2), cast (element_ptr.Ref 3)] fmempty None)),
    (cast (element_ptr.Ref 2), cast (create_element_obj ''head'' [] fmempty None)),
    (cast (element_ptr.Ref 3), cast (create_element_obj ''body'' [cast (element_ptr.Ref 4), cast (element_ptr.Ref 8)] fmempty None)),
    (cast (element_ptr.Ref 4), cast (create_element_obj ''div'' [cast (element_ptr.Ref 5)] (fmap_of_list [(''id'', ''test'')]) None)),
    (cast (element_ptr.Ref 5), cast (create_element_obj ''div'' [cast (element_ptr.Ref 6)] (fmap_of_list [(''id'', ''host'')]) (Some (cast (shadow_root_ptr.Ref 1))))),
    (cast (element_ptr.Ref 6), cast (create_element_obj ''div'' [] (fmap_of_list [(''id'', ''c1''), (''slot'', ''slot1'')]) None)),
    (cast (shadow_root_ptr.Ref 1), cast (create_shadow_root_obj Open [cast (element_ptr.Ref 7)])),
    (cast (element_ptr.Ref 7), cast (create_element_obj ''slot'' [] (fmap_of_list [(''id'', ''s1''), (''name'', ''slot1'')]) None)),
    (cast (element_ptr.Ref 8), cast (create_element_obj ''script'' [cast (character_data_ptr.Ref 1)] fmempty None)),
    (cast (character_data_ptr.Ref 1), cast (create_character_data_obj ''%3C%3Cscript%3E%3E''))]"

definition my_get_owner_document_document :: "(unit, unit, unit, unit, unit, unit) object_ptr option" where "my_get_owner_document_document = Some (cast (document_ptr.Ref 1))"


text \<open>'ownerDocument inside shadow tree returns the outer document.'\<close>

lemma "test (do {
  tmp0 \<leftarrow> my_get_owner_document_document . getElementById(''test'');
  n \<leftarrow> createTestTree(tmp0);
  tmp1 \<leftarrow> n . ''s1'';
  tmp2 \<leftarrow> tmp1 . ownerDocument;
  assert_equals(tmp2, my_get_owner_document_document)
}) my_get_owner_document_heap"
  by eval


text \<open>'ownerDocument outside shadow tree returns the outer document.'\<close>

lemma "test (do {
  tmp0 \<leftarrow> my_get_owner_document_document . getElementById(''test'');
  n \<leftarrow> createTestTree(tmp0);
  tmp1 \<leftarrow> n . ''c1'';
  tmp2 \<leftarrow> tmp1 . ownerDocument;
  assert_equals(tmp2, my_get_owner_document_document)
}) my_get_owner_document_heap"
  by eval


end