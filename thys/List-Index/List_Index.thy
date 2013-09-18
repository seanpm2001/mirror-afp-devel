(* Author: Tobias Nipkow *)

theory List_Index imports Main begin

text {* \noindent
This theory collects functions for index-based manipulation of lists.
*}

subsection {* Finding an index *}

text{*
This subsection defines three functions for finding the index of items in a list:
\begin{description}
\item[@{text "find_index P xs"}] finds the index of the first element in
 @{text xs} that satisfies @{text P}.
\item[@{text "index xs x"}] finds the index of the first occurrence of
 @{text x} in @{text xs}.
\item[@{text "last_index xs x"}] finds the index of the last occurrence of
 @{text x} in @{text xs}.
\end{description}
All functions return @{term "length xs"} if @{text xs} does not contain a
suitable element.

The argument order of @{text find_index} follows the function of the same
name in the Haskell standard library. For @{text index} (and @{text
last_index}) the order is intentionally reversed: @{text index} maps
lists to a mapping from elements to their indices, almost the inverse of
function @{text nth}. *}

primrec find_index :: "('a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> nat" where
"find_index _ [] = 0" |
"find_index P (x#xs) = (if P x then 0 else find_index P xs + 1)"

definition index :: "'a list \<Rightarrow> 'a \<Rightarrow> nat" where
"index xs = (\<lambda>a. find_index (\<lambda>x. x=a) xs)"

definition last_index :: "'a list \<Rightarrow> 'a \<Rightarrow> nat" where
"last_index xs x =
 (let i = index (rev xs) x; n = size xs
  in if i = n then i else n - (i+1))"

lemma find_index_le_size: "find_index P xs <= size xs"
by(induct xs) simp_all

lemma index_le_size: "index xs x <= size xs"
by(simp add: index_def find_index_le_size)

lemma last_index_le_size: "last_index xs x <= size xs"
by(simp add: last_index_def Let_def index_le_size)

lemma index_Nil[simp]: "index [] a = 0"
by(simp add: index_def)

lemma index_Cons[simp]: "index (x#xs) a = (if x=a then 0 else index xs a + 1)"
by(simp add: index_def)

lemma index_append: "index (xs @ ys) x =
  (if x : set xs then index xs x else size xs + index ys x)"
by (induct xs) simp_all

lemma index_conv_size_if_notin[simp]: "x \<notin> set xs \<Longrightarrow> index xs x = size xs"
by (induct xs) auto

lemma find_index_eq_size_conv:
  "size xs = n \<Longrightarrow> (find_index P xs = n) = (ALL x : set xs. ~ P x)"
by(induct xs arbitrary: n) auto

lemma size_eq_find_index_conv:
  "size xs = n \<Longrightarrow> (n = find_index P xs) = (ALL x : set xs. ~ P x)"
by(metis find_index_eq_size_conv)

lemma index_size_conv: "size xs = n \<Longrightarrow> (index xs x = n) = (x \<notin> set xs)"
by(auto simp: index_def find_index_eq_size_conv)

lemma size_index_conv: "size xs = n \<Longrightarrow> (n = index xs x) = (x \<notin> set xs)"
by (metis index_size_conv)

lemma last_index_size_conv:
  "size xs = n \<Longrightarrow> (last_index xs x = n) = (x \<notin> set xs)"
apply(auto simp: last_index_def index_size_conv)
apply(drule length_pos_if_in_set)
apply arith
done

lemma size_last_index_conv:
  "size xs = n \<Longrightarrow> (n = last_index xs x) = (x \<notin> set xs)"
by (metis last_index_size_conv)

lemma find_index_less_size_conv:
  "(find_index P xs < size xs) = (EX x : set xs. P x)"
by (induct xs) auto

lemma index_less_size_conv:
  "(index xs x < size xs) = (x \<in> set xs)"
by(auto simp: index_def find_index_less_size_conv)

lemma last_index_less_size_conv:
  "(last_index xs x < size xs) = (x : set xs)"
by(simp add: last_index_def Let_def index_size_conv length_pos_if_in_set
        del:length_greater_0_conv)

lemma index_less[simp]:
  "x : set xs \<Longrightarrow> size xs <= n \<Longrightarrow> index xs x < n"
apply(induct xs) apply auto
apply (metis index_less_size_conv less_eq_Suc_le less_trans_Suc)
done

lemma last_index_less[simp]:
  "x : set xs \<Longrightarrow> size xs <= n \<Longrightarrow> last_index xs x < n"
by(simp add: last_index_less_size_conv[symmetric])

lemma last_index_Cons: "last_index (x#xs) y =
  (if x=y then
      if x \<in> set xs then last_index xs y + 1 else 0
   else last_index xs y + 1)"
using index_le_size[of "rev xs" y]
apply(auto simp add: last_index_def index_append Let_def)
apply(simp add: index_size_conv)
done

lemma last_index_append: "last_index (xs @ ys) x =
  (if x : set ys then size xs + last_index ys x
   else if x : set xs then last_index xs x else size xs + size ys)"
by (induct xs) (simp_all add: last_index_Cons last_index_size_conv)

lemma last_index_Snoc[simp]:
  "last_index (xs @ [x]) y =
  (if x=y then size xs
   else if y : set xs then last_index xs y else size xs + 1)"
by(simp add: last_index_append last_index_Cons)

lemma nth_find_index: "find_index P xs < size xs \<Longrightarrow> P(xs ! find_index P xs)"
by (induct xs) auto

lemma nth_index[simp]: "x \<in> set xs \<Longrightarrow> xs ! index xs x = x"
by (induct xs) auto

lemma nth_last_index[simp]: "x \<in> set xs \<Longrightarrow> xs ! last_index xs x = x"
by(simp add:last_index_def index_size_conv Let_def rev_nth[symmetric])

lemma index_eq_index_conv[simp]: "x \<in> set xs \<or> y \<in> set xs \<Longrightarrow>
  (index xs x = index xs y) = (x = y)"
by (induct xs) auto

lemma last_index_eq_index_conv[simp]: "x \<in> set xs \<or> y \<in> set xs \<Longrightarrow>
  (last_index xs x = last_index xs y) = (x = y)"
by (induct xs) (auto simp:last_index_Cons)

lemma inj_on_index: "inj_on (index xs) (set xs)"
by (simp add:inj_on_def)

lemma inj_on_last_index: "inj_on (last_index xs) (set xs)"
by (simp add:inj_on_def)

lemma index_conv_takeWhile: "index xs x = size(takeWhile (\<lambda>y. x\<noteq>y) xs)"
by(induct xs) auto

lemma index_take: "index xs x >= i \<Longrightarrow> x \<notin> set(take i xs)"
apply(subst (asm) index_conv_takeWhile)
apply(subgoal_tac "set(take i xs) <= set(takeWhile (op \<noteq> x) xs)")
 apply(blast dest: set_takeWhileD)
apply(metis set_take_subset_set_take takeWhile_eq_take)
done

lemma last_index_drop:
  "last_index xs x < i \<Longrightarrow> x \<notin> set(drop i xs)"
apply(subgoal_tac "set(drop i xs) = set(take (size xs - i) (rev xs))")
 apply(simp add: last_index_def index_take Let_def split:split_if_asm)
apply (metis rev_drop set_rev)
done


subsection {* Map with index *}

primrec map_index' :: "nat \<Rightarrow> (nat \<Rightarrow> 'a \<Rightarrow> 'b) \<Rightarrow> 'a list \<Rightarrow> 'b list" where
  "map_index' n f [] = []"
| "map_index' n f (x#xs) = f n x # map_index' (Suc n) f xs"

lemma length_map_index'[simp]: "length (map_index' n f xs) = length xs"
  by (induct xs arbitrary: n) auto

lemma map_index'_map_zip: "map_index' n f xs = map (split f) (zip [n ..< n + length xs] xs)"
proof (induct xs arbitrary: n)
  case (Cons x xs)
  hence "map_index' n f (x#xs) = f n x # map (split f) (zip [Suc n ..< n + length (x # xs)] xs)" by simp
  also have "\<dots> =  map (split f) (zip (n # [Suc n ..< n + length (x # xs)]) (x # xs))" by simp
  also have "(n # [Suc n ..< n + length (x # xs)]) = [n ..< n + length (x # xs)]" by (induct xs) auto
  finally show ?case by simp
qed simp

abbreviation "map_index \<equiv> map_index' 0"

lemmas map_index = map_index'_map_zip[of 0, simplified]

lemma take_map_index: "take p (map_index f xs) = map_index f (take p xs)"
  unfolding map_index by (auto simp: min_def take_map take_zip)

lemma drop_map_index: "drop p (map_index f xs) = map_index' p f (drop p xs)"
  unfolding map_index'_map_zip by (cases "p < length xs") (auto simp: drop_map drop_zip)

lemma map_map_index[simp]: "map g (map_index f xs) = map_index (\<lambda>n x. g (f n x)) xs"
  unfolding map_index by auto

lemma map_index_map[simp]: "map_index f (map g xs) = map_index (\<lambda>n x. f n (g x)) xs"
  unfolding map_index by (auto simp: map_zip_map2)

lemma set_map_index[simp]: "x \<in> set (map_index f xs) = (\<exists>i < length xs. f i (xs ! i) = x)"
  unfolding map_index by (auto simp: set_zip intro!: image_eqI[of _ "split f"])

lemma set_map_index'[simp]: "x\<in>set (map_index' n f xs) 
  \<longleftrightarrow> (\<exists>i<length xs. f (n+i) (xs!i) = x) "
  unfolding map_index'_map_zip 
  by (auto simp: set_zip intro!: image_eqI[of _ "split f"])


lemma nth_map_index[simp]: "p < length xs \<Longrightarrow> map_index f xs ! p = f p (xs ! p)"
  unfolding map_index by auto

lemma map_index_cong:
  "\<forall>p < length xs. f p (xs ! p) = g p (xs ! p) \<Longrightarrow> map_index f xs = map_index g xs"
  unfolding map_index by (auto simp: set_zip)

lemma map_index_id: "map_index (curry snd) xs = xs"
  unfolding map_index by auto

lemma map_index_no_index[simp]: "map_index (\<lambda>n x. f x) xs = map f xs"
  unfolding map_index by (induct xs rule: rev_induct) auto

lemma map_index_congL:
  "\<forall>p < length xs. f p (xs ! p) = xs ! p \<Longrightarrow> map_index f xs = xs"
  by (rule trans[OF map_index_cong map_index_id]) auto

lemma map_index'_is_NilD: "map_index' n f xs = [] \<Longrightarrow> xs = []"
  by (induct xs) auto

declare map_index'_is_NilD[of 0, dest!]

lemma map_index'_is_ConsD:
  "map_index' n f xs = y # ys \<Longrightarrow> \<exists>z zs. xs = z # zs \<and> f n z = y \<and> map_index' (n + 1) f zs = ys"
  by (induct xs arbitrary: n) auto

lemma map_index'_eq_imp_length_eq: "map_index' n f xs = map_index' n g ys \<Longrightarrow> length xs = length ys"
proof (induct ys arbitrary: xs n)
  case (Cons y ys) thus ?case by (cases xs) auto
qed (auto dest!: map_index'_is_NilD)

lemmas map_index_eq_imp_length_eq = map_index'_eq_imp_length_eq[of 0]

lemma map_index'_comp[simp]: "map_index' n f (map_index' n g xs) = map_index' n (\<lambda>n. f n o g n) xs"
  by (induct xs arbitrary: n) auto

lemma map_index'_append[simp]: "map_index' n f (a @ b) 
  = map_index' n f a @ map_index' (n + length a) f b"
  by (induct a arbitrary: n) auto

lemma map_index_append[simp]: "map_index f (a @ b) 
  = map_index f a @ map_index' (length a) f b"
  using map_index'_append[where n=0]
  by (simp del: map_index'_append)


subsection {* Insert at position *}

primrec insert_nth :: "nat \<Rightarrow> 'a \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "insert_nth 0 x xs = x # xs"
| "insert_nth (Suc n) x xs = (case xs of [] \<Rightarrow> [x] | y # ys \<Rightarrow> y # insert_nth n x ys)"

lemma insert_nth_take_drop[simp]: "insert_nth n x xs = take n xs @ [x] @ drop n xs"
proof (induct n arbitrary: xs)
  case Suc thus ?case by (cases xs) auto
qed simp

lemma length_insert_nth: "length (insert_nth n x xs) = Suc (length xs)"
  by (induct xs) auto

text {* Insert several elements at given (ascending) positions *}

lemma length_fold_insert_nth:
  "length (fold (\<lambda>(p, b). insert_nth p b) pxs xs) = length xs + length pxs"
  by (induct pxs arbitrary: xs) auto

lemma invar_fold_insert_nth:
  "\<lbrakk>\<forall>x\<in>set pxs. p < fst x; p < length xs; xs ! p = b\<rbrakk> \<Longrightarrow>
    fold (\<lambda>(x, y). insert_nth x y) pxs xs ! p = b"
  by (induct pxs arbitrary: xs) (auto simp: nth_append)

lemma nth_fold_insert_nth:
  "\<lbrakk>sorted (map fst pxs); distinct (map fst pxs); \<forall>(p, b) \<in> set pxs. p < length xs + length pxs;
    i < length pxs; pxs ! i = (p, b)\<rbrakk> \<Longrightarrow>
  fold (\<lambda>(p, b). insert_nth p b) pxs xs ! p = b"
proof (induct pxs arbitrary: xs i p b)
  case (Cons pb pxs)
  show ?case
  proof (cases i)
    case 0
    with Cons.prems have "p < Suc (length xs)"
    proof (induct pxs rule: rev_induct)
      case (snoc pb' pxs)
      then obtain p' b' where "pb' = (p', b')" by auto
      with snoc.prems have "\<forall>p \<in> fst ` set pxs. p < p'" "p' \<le> Suc (length xs + length pxs)"
        by (auto simp: image_iff sorted_Cons sorted_append le_eq_less_or_eq)
      with snoc.prems show ?case by (intro snoc(1)) (auto simp: sorted_Cons sorted_append)
    qed auto
    with 0 Cons.prems show ?thesis unfolding fold.simps o_apply
    by (intro invar_fold_insert_nth) (auto simp: sorted_Cons image_iff le_eq_less_or_eq nth_append)
  next
    case (Suc n) with Cons.prems show ?thesis unfolding fold.simps
      by (auto intro!: Cons(1) simp: sorted_Cons)
  qed
qed simp

end
