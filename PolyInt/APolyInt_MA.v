(**
CoLoR, a Coq library on rewriting and termination.
See the COPYRIGHTS and LICENSE files.

- Adam Koprowski and Hans Zantema, 2007-04-25

Polynomial interpretations in the setting of monotone algebras.
*)

Require Import APolyInt.
Require Import AMonAlg.
Require Import ZUtil.
Require Import RelUtil.
Require Import PositivePolynom.
Require Import ATrs.
Require Import ListForall.
Require Import MonotonePolynom.
Require Import LogicUtil.

Module Type TPolyInt.

  Parameter sig : Signature.
  Parameter trsInt : PolyInterpretation sig.
  Parameter trsInt_wm : PolyWeakMonotone trsInt.

End TPolyInt.

Module PolyInt (PI : TPolyInt).

  Export PI.

  (* Monotone algebra instantiated to polynomials *)

  Module Export MonotoneAlgebra <: MonotoneAlgebraType.

    Definition Sig := sig.
    
    Definition I := Int_of_PI trsInt_wm.

    Definition succ := Dgt.
    Definition succeq := Dge.

    Lemma refl_succeq : reflexive succeq.

    Proof.
      intro x. unfold succeq, Dge, transp, Dle. refl.
    Qed.

    Lemma monotone_succeq : AWFMInterpretation.monotone I succeq.

    Proof.
      unfold I. apply pi_monotone_eq.
    Qed.

    Definition succ_wf := WF_Dgt.

    Lemma succ_succeq_compat : absorb succ succeq.

    Proof.
      unfold succ, succeq. intros p q pq. destruct pq as [r [pr rq]].
      unfold Dgt, Dlt, transp. apply Zlt_le_trans with (val r); auto.
    Qed.

    Definition succ' l r := 
      coef_pos (rulePoly_gt trsInt (@mkRule sig l r)).
    Definition succeq' l r := 
      coef_pos (rulePoly_ge trsInt (@mkRule sig l r)).

    Lemma succ'_sub : succ' << IR I succ.

    Proof.
      intros t u tu. unfold I, succ. set (r := mkRule t u).
      change t with (lhs r). change u with (rhs r).
      apply pi_compat_rule. hyp.
    Qed.

    Lemma succeq'_sub : succeq' << IR I succeq.

    Proof.
      intros t u tu. unfold I, succ. set (r := mkRule t u).
      change t with (lhs r). change u with (rhs r).
      apply pi_compat_rule_weak. hyp.
    Qed.

    Lemma succ'_dec : rel_dec succ'.

    Proof.
      intros l r. unfold succ', coef_pos.
      apply lforall_dec. intro p.
      destruct (fst p). 
      left. intuition.
      left. intuition.
      right. intuition.
    Defined.

    Lemma succeq'_dec : rel_dec succeq'.

    Proof.
      intros l r. unfold succeq', coef_pos.
      apply lforall_dec. intro p.
      destruct (fst p).
      left. intuition.
      left. intuition.
      right. intuition.
    Defined.

    Section ExtendedMonotoneAlgebra.

      Lemma monotone_succ : PolyStrongMonotone trsInt ->
        AWFMInterpretation.monotone I succ.

      Proof.
        unfold I. apply pi_monotone.
      Qed.

    End ExtendedMonotoneAlgebra.

    Require Import List.

    Section fin_Sig.

      Variable Fs : list Sig.
      Variable Fs_ok : forall f : Sig, In f Fs.

      Lemma fin_monotone_succ :
        forallb (fun f => bpstrong_monotone (trsInt f)) Fs = true ->
        AWFMInterpretation.monotone I succ.

      Proof.
        intro H. apply monotone_succ. intro f. rewrite <- bpstrong_monotone_ok.
        rewrite forallb_forall in H. apply H. apply Fs_ok.
      Qed.

    End fin_Sig.

  End MonotoneAlgebra.

(***********************************************************************)
(** tactics for Rainbow *)

  (*REMOVE: to be removed (used in a previous version of Rainbow)

  Module Export MAR := MonotoneAlgebraResults MonotoneAlgebra.
  Ltac prove_termination := MAR.prove_termination prove_int_monotone.

  Ltac prove_int_monotone :=
    solve [apply monotone_succ; pmonotone]
    || fail "Failed to prove monotonicity of polynomial interpretation.".

  Ltac prove_cc_succ := apply IR_context_closed; prove_int_monotone.*)

  Ltac prove_cc_succ_by_refl Fs Fs_ok :=
    apply IR_context_closed; apply (fin_monotone_succ Fs Fs_ok);
      (check_eq || fail "could not prove monotony").

End PolyInt.
