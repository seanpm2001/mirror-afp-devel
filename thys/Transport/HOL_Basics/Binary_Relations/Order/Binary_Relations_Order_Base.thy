\<^marker>\<open>creator "Kevin Kappelmann"\<close>
subsection \<open>Order\<close>
theory Binary_Relations_Order_Base
  imports
    Binary_Relation_Functions
    HOL.Orderings
begin

lemma le_relI [intro]:
  assumes "\<And>x y. R x y \<Longrightarrow> S x y"
  shows "R \<le> S"
  using assms by (rule predicate2I)

lemma le_relD [dest]:
  assumes "R \<le> S"
  and "R x y"
  shows "S x y"
  using assms by (rule predicate2D)

lemma le_relE:
  assumes "R \<le> S"
  and "R x y"
  obtains "S x y"
  using assms by blast

lemma rel_inv_le_rel_inv_iff [iff]: "R\<inverse> \<le> S\<inverse> \<longleftrightarrow> R \<le> S"
  by blast

lemma bin_rel_restrict_left_le_self: "(R :: 'a \<Rightarrow> 'b \<Rightarrow> bool)\<restriction>\<^bsub>(P :: 'a \<Rightarrow> bool)\<^esub> \<le> R"
  by blast

lemma bin_rel_restrict_right_le_self: "(R :: 'a \<Rightarrow> 'b \<Rightarrow> bool)\<upharpoonleft>\<^bsub>(P :: 'b \<Rightarrow> bool)\<^esub> \<le> R"
  by blast

lemma bin_rel_restrict_left_top_eq [simp]: "(R :: 'a \<Rightarrow> 'b \<Rightarrow> bool)\<restriction>\<^bsub>(\<top> :: 'a \<Rightarrow> bool)\<^esub> = R"
  by (intro ext) auto

lemma bin_rel_restrict_right_top_eq [simp]: "(R :: 'a \<Rightarrow> 'b \<Rightarrow> bool)\<upharpoonleft>\<^bsub>(\<top> :: 'b \<Rightarrow> bool)\<^esub> = R"
  by (intro ext) auto


end