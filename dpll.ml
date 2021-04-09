open Formula

(*
  Some helper function definitions have been given to you. MOST HAVE NOT!
  So define your helpers whenever you need to!
*)

(* Does the cnf contain an empty clause *)
let rec contains_empty_list (cnf:'a list list) : bool = 
  failwith "TODO"

(* Pick the smallest clause in the cnf *)
let rec pick_smallest_sublist (cnf:'a list list) : 'a list = 
  failwith "TODO"


(* For every occurence of variable var in cnf, assign it the truth 
   value value, simplify the cnf, and return it. *)
let rec substitute_in_cnf (cnf:cnf) (var:variable) (value:bool) : cnf = 
  failwith "TODO"


(* The following functions are for pure literal elimination *)
(* Does this literal occur with the same polarity across the cnf? *)
let rec is_literal_pure_in_cnf (lit:literal) (cnf:cnf) : bool = 
  failwith "TODO"

(* Take the union of two lists *)
let rec union (l1:'a list) (l2:'a list) : 'a list = 
  failwith "TODO"

(* Returns a list of all the distinct variables in a cnf. *)
let rec get_vars_in_cnf (cnf:cnf) : variable list = 
  failwith "TODO"


(* eliminate all pure literals in the cnf *)
let rec pure_literal_elim (cnf:cnf) : cnf = 
  failwith "TODO"


(* It returns None if the cnf is not satisfiable, and Some sol if 
   the cnf is satisfiable and sol is a particular solution that 
   satisfies the cnf. *)
let rec dpll (cnf':cnf) : solution option = 
  let rec aux (cnf:cnf) (env:solution) : solution option = 
    (match cnf with
    | [] -> Some env
    | _ -> failwith "TODO"
    )
  in 
  aux cnf' [] 

