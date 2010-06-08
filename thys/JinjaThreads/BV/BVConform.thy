(*  Title:      JinjaThreads/BV/BVConform.thy
    Author:     Cornelia Pusch, Gerwin Klein, Andreas Lochbihler

The invariant for the type safety proof.
*)

header {* \isaheader{BV Type Safety Invariant} *}

theory BVConform
imports
  BVSpec
  "../JVM/JVMExec"
  "../JVM/JVMHeap"
begin

context JVM_heap_base begin

definition confT :: "'c prog \<Rightarrow> 'heap \<Rightarrow> val \<Rightarrow> ty err \<Rightarrow> bool" ("_,_ |- _ :<=T _" [51,51,51,51] 50)
where
  "P,h |- v :<=T E \<equiv> case E of Err \<Rightarrow> True | OK T \<Rightarrow> P,h \<turnstile> v :\<le> T"

notation (xsymbols) 
  confT ("_,_ \<turnstile> _ :\<le>\<^sub>\<top> _" [51,51,51,51] 50)

abbreviation confTs :: "'c prog \<Rightarrow> 'heap \<Rightarrow> val list \<Rightarrow> ty\<^isub>l \<Rightarrow> bool"
            ("_,_ |- _ [:<=T] _" [51,51,51,51] 50)
where
  "P,h |- vs [:<=T] Ts \<equiv> list_all2 (confT P h) vs Ts"

notation (xsymbols)
  confTs ("_,_ \<turnstile> _ [:\<le>\<^sub>\<top>] _" [51,51,51,51] 50)

definition conf_f :: "jvm_prog \<Rightarrow> 'heap \<Rightarrow> ty\<^isub>i \<Rightarrow> bytecode \<Rightarrow> frame \<Rightarrow> bool"
where
  "conf_f P h \<equiv> \<lambda>(ST,LT) is (stk,loc,C,M,pc). P,h \<turnstile> stk [:\<le>] ST \<and> P,h \<turnstile> loc [:\<le>\<^sub>\<top>] LT \<and> pc < size is"

primrec conf_fs :: "[jvm_prog,'heap,ty\<^isub>P,mname,nat,ty,frame list] \<Rightarrow> bool"
where
  "conf_fs P h \<Phi> M\<^isub>0 n\<^isub>0 T\<^isub>0 [] = True"

| "conf_fs P h \<Phi> M\<^isub>0 n\<^isub>0 T\<^isub>0 (f#frs) =
  (let (stk,loc,C,M,pc) = f in
  (\<exists>ST LT Ts T mxs mxl\<^isub>0 is xt.
    \<Phi> C M ! pc = Some (ST,LT) \<and> 
    (P \<turnstile> C sees M:Ts \<rightarrow> T = (mxs,mxl\<^isub>0,is,xt) in C) \<and>
    (\<exists>D Ts' T' m D'.  
       is!pc = (Invoke M\<^isub>0 n\<^isub>0) \<and> (ST!n\<^isub>0 = Class D \<and> P \<turnstile> D sees M\<^isub>0:Ts' \<rightarrow> T' = m in D' \<or> P \<turnstile> ST!n\<^isub>0\<bullet>M\<^isub>0(Ts') :: T') \<and> 
       P \<turnstile> T\<^isub>0 \<le> T') \<and>
    conf_f P h (ST, LT) is f \<and> conf_fs P h \<Phi> M (size Ts) T frs))"

primrec conf_xcp :: "jvm_prog \<Rightarrow> 'heap \<Rightarrow> addr option \<Rightarrow> instr \<Rightarrow> bool" where
  "conf_xcp P h None i = True"
| "conf_xcp P h \<lfloor>a\<rfloor>   i = (\<exists>D. typeof_addr h a = \<lfloor>Class D\<rfloor> \<and> P \<turnstile> D \<preceq>\<^sup>* Throwable \<and>
                               (\<forall>D'. P \<turnstile> D \<preceq>\<^sup>* D' \<longrightarrow> is_relevant_class i P D'))"

end

context JVM_heap_conf_base begin

definition correct_state :: "[ty\<^isub>P,thread_id,'heap jvm_state] \<Rightarrow> bool"
                  ("_ |- _:_ [ok]"  [61,0,0] 61)
where
  "correct_state \<Phi> t \<equiv> \<lambda>(xp,h,frs).
	P,h \<turnstile> t \<surd>t \<and> hconf h \<and> preallocated h \<and>
        (case frs of
             [] \<Rightarrow> True
             | (f#fs) \<Rightarrow> 
             (let (stk,loc,C,M,pc) = f
              in \<exists>Ts T mxs mxl\<^isub>0 is xt \<tau>.
                    (P \<turnstile> C sees M:Ts\<rightarrow>T = (mxs,mxl\<^isub>0,is,xt) in C) \<and>
                    \<Phi> C M ! pc = Some \<tau> \<and>
                    conf_f P h \<tau> is f \<and> conf_fs P h \<Phi> M (size Ts) T fs \<and>
                    conf_xcp P h xp (is ! pc) ))"

notation (xsymbols)
 correct_state ("_ \<turnstile> _:_ \<surd>"  [61,0,0] 61)

end

context JVM_heap_base begin

lemma conf_f_def2:
  "conf_f P h (ST,LT) is (stk,loc,C,M,pc) \<equiv>
  P,h \<turnstile> stk [:\<le>] ST \<and> P,h \<turnstile> loc [:\<le>\<^sub>\<top>] LT \<and> pc < size is"
  by (simp add: conf_f_def)

section {* Values and @{text "\<top>"} *}

lemma confT_Err [iff]: "P,h \<turnstile> x :\<le>\<^sub>\<top> Err" 
  by (simp add: confT_def)

lemma confT_OK [iff]:  "P,h \<turnstile> x :\<le>\<^sub>\<top> OK T = (P,h \<turnstile> x :\<le> T)"
  by (simp add: confT_def)

lemma confT_cases:
  "P,h \<turnstile> x :\<le>\<^sub>\<top> X = (X = Err \<or> (\<exists>T. X = OK T \<and> P,h \<turnstile> x :\<le> T))"
  by (cases X) auto

lemma confT_widen [intro?, trans]:
  "\<lbrakk> P,h \<turnstile> x :\<le>\<^sub>\<top> T; P \<turnstile> T \<le>\<^sub>\<top> T' \<rbrakk> \<Longrightarrow> P,h \<turnstile> x :\<le>\<^sub>\<top> T'"
  by (cases T', auto intro: conf_widen)

end

context JVM_heap begin

lemma confT_hext [intro?, trans]:
  "\<lbrakk> P,h \<turnstile> x :\<le>\<^sub>\<top> T; h \<unlhd> h' \<rbrakk> \<Longrightarrow> P,h' \<turnstile> x :\<le>\<^sub>\<top> T"
  by (cases T) (blast intro: conf_hext)+

end

section {* Stack and Registers *}

context JVM_heap_base begin

lemma confTs_Cons1 [iff]:
  "P,h \<turnstile> x # xs [:\<le>\<^sub>\<top>] Ts = (\<exists>z zs. Ts = z # zs \<and> P,h \<turnstile> x :\<le>\<^sub>\<top> z \<and> list_all2 (confT P h) xs zs)"
by(rule list_all2_Cons1)

lemma confTs_confT_sup:
  "\<lbrakk> P,h \<turnstile> loc [:\<le>\<^sub>\<top>] LT; n < size LT; LT!n = OK T; P \<turnstile> T \<le> T' \<rbrakk> 
  \<Longrightarrow> P,h \<turnstile> (loc!n) :\<le> T'"
  apply (frule list_all2_lengthD)
  apply (drule list_all2_nthD, simp)
  apply simp
  apply (erule conf_widen, assumption+)
  done

lemma confTs_widen [intro?, trans]:
  "P,h \<turnstile> loc [:\<le>\<^sub>\<top>] LT \<Longrightarrow> P \<turnstile> LT [\<le>\<^sub>\<top>] LT' \<Longrightarrow> P,h \<turnstile> loc [:\<le>\<^sub>\<top>] LT'"
  by (rule list_all2_trans, rule confT_widen)

lemma confTs_map [iff]:
  "(P,h \<turnstile> vs [:\<le>\<^sub>\<top>] map OK Ts) = (P,h \<turnstile> vs [:\<le>] Ts)"
  by (induct Ts arbitrary: vs) (auto simp add: list_all2_Cons2)

lemma reg_widen_Err [iff]:
  "(P \<turnstile> replicate n Err [\<le>\<^sub>\<top>] LT) = (LT = replicate n Err)"
  by (induct n arbitrary: LT) (auto simp add: list_all2_Cons1)
    
lemma confTs_Err [iff]:
  "P,h \<turnstile> replicate n v [:\<le>\<^sub>\<top>] replicate n Err"
  by (induct n) auto

end

context JVM_heap begin

lemma confTs_hext [intro?]:
  "P,h \<turnstile> loc [:\<le>\<^sub>\<top>] LT \<Longrightarrow> h \<unlhd> h' \<Longrightarrow> P,h' \<turnstile> loc [:\<le>\<^sub>\<top>] LT"
  by (fast elim: list_all2_mono confT_hext)    
  
section {* correct-frames *}

declare fun_upd_apply[simp del]

lemma conf_f_hext:
  "\<lbrakk> conf_f P h \<Phi> M f; h \<unlhd> h' \<rbrakk> \<Longrightarrow> conf_f P h' \<Phi> M f"
by(cases f, cases \<Phi>, auto simp add: conf_f_def intro: confs_hext confTs_hext)

lemma conf_fs_hext:
  "\<lbrakk> conf_fs P h \<Phi> M n T\<^isub>r frs; h \<unlhd> h' \<rbrakk> \<Longrightarrow> conf_fs P h' \<Phi> M n T\<^isub>r frs"
apply (induct frs arbitrary: M n T\<^isub>r)
 apply simp
apply clarify
apply (simp (no_asm_use))
apply clarify
apply (unfold conf_f_def)
apply (simp (no_asm_use))
apply clarify
apply (fast elim!: confs_hext confTs_hext)
done

declare fun_upd_apply[simp]

end

context JVM_heap_conf_base begin

lemmas defs1 = correct_state_def conf_f_def wt_instr_def eff_def norm_eff_def app_def xcpt_app_def

lemma correct_state_impl_Some_method:
  "\<Phi> \<turnstile> t: (None, h, (stk,loc,C,M,pc)#frs)\<surd> 
  \<Longrightarrow> \<exists>m Ts T. P \<turnstile> C sees M:Ts\<rightarrow>T = m in C"
  by(fastsimp simp add: defs1)

end

end
