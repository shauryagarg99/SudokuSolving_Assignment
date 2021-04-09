open Stdlib
open Converter
open Formula
open Dpll
open QCheck


let leafgen = Gen.map (fun i -> Var i) Gen.small_nat

let input_gen = 
  Gen.sized_size Gen.small_nat (Gen.fix
    (fun recgen n -> 
      let n = if (n > 20) then 20 else n in
      match n with
      | 0 -> leafgen
      | n -> 
        Gen.frequency 
          [1, leafgen;
          2, Gen.map2 (fun l r -> And (l,r)) (recgen (n/2)) (recgen (n/2));
          2, Gen.map2 (fun l r -> Or (l,r)) (recgen (n/2)) (recgen (n/2));
          2, Gen.map (fun l -> Not l) (recgen (n/2)); 
          ]
  ))

let arbitrary_tree =
  let open QCheck.Iter in
  let rec print_input = function
    | Var i -> (string_of_int i)
    | Not a -> "~(" ^ print_input a ^ ")"
    | And (a,b) -> "(" ^ (print_input a) ^ " and " ^ (print_input b) ^ ")"
    | Or (a,b) -> "(" ^  (print_input a) ^ " or " ^ (print_input b) ^ ")"
  in
  let rec shrink_input input = match input with
    | Var i -> empty

    | Not a -> (shrink_input a) <+> (map (fun i' -> Not i') (shrink_input a))

    | And (a,b) ->
      of_list [a;b]
      <+>
      (map (fun a' -> And (a',b)) (shrink_input a))
      (* (shrink_input a >|= fun a' -> And (a',b)) *)
      <+>
      (map (fun b' -> And (a,b')) (shrink_input b))
      (* (shrink_input b >|= fun b' -> And (a,b')) *)

    | Or (a,b) ->
      of_list [a;b]
      <+>
      (map (fun a' -> Or (a',b)) (shrink_input a))
      (* (shrink_input a >|= fun a' -> Or (a',b)) *)
      <+>
      (map (fun b' -> Or (a,b')) (shrink_input b))
      (* (shrink_input b >|= fun b' -> Or (a,b')) *)
  in
  make input_gen ~print:print_input ~shrink:shrink_input;;

let test_cnf_conversion =
  QCheck.Test.make ~name:"cnf_conversion" ~count:500
    arbitrary_tree (fun t -> (check_equivalence t (prop_to_cnf t)));;

(* QCheck_runner.run_tests [test_cnf_conversion];; *)

let test_dpll =
  QCheck.Test.make ~name:"dpll_check" ~count:500
    arbitrary_tree
    (fun t -> 
    let cnf' = prop_to_cnf t in
    let solution_opt = dpll cnf' in
    (match solution_opt with
    | None -> true
    | Some sol -> 
      (match check_solution sol cnf' with
      | None -> false
      | Some b -> b
      )
    ));;

QCheck_runner.run_tests ~verbose:true [test_cnf_conversion;test_dpll];; 