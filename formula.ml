(* This is a representation of a Conjunctive Normal Form *)
type variable = int              (* 1, 2, 3 *)

type literal = variable * bool  (* (1,true), (2,false) *)

type clause = literal list      (* A clause is a disjunction of variables or
                                   just a single variable *)

type cnf = clause list          (* A cnf is a conjunction of clauses *)

type solution = (variable * bool) list (* A proposed solution to a cnf *)


(* Check that a provided solution has all distinct variables *)
let solution_has_distinct_variables (xs:solution) : bool = 
  failwith "TODO"

(* Check whether the given solution is valid. A solution that does not 
   have distincrt variables, or has a variable that the input cnf does 
   not have, the solution is invalid and you should return None. If the 
   solution is valid, check if it satisfies the input cnf. Return Some true 
   if it does, and Some false if it does not. *)
let rec check_solution (sol:solution) (problem:cnf) : bool option = 
  failwith "TODO"



(* Helper printing code *)

(* Converts any string into cnf. A variable must be inputted as a char, 
   and it is converted to an int using the int_of_char function for the 
   internal representation. Not of a variable is represented by adding 
   ' to the char. Clauses must be separated by spaces. 
   For example:
   string_to_cnf "xy x'z" = 
   [[(120, true); (121, true)]; [(120, false); (122, true)]] *)
let rec string_to_cnf str : cnf = 
  let rec stringclause_to_clause str : clause = 
    match String.length str with
    | 0 -> []
    | 1 -> [(int_of_char (String.get str 0),true)]
    | _ -> 
      if String.get str 1 = '\'' then (int_of_char (String.get str 0),false)::(stringclause_to_clause (String.sub str 2 ((String.length str) - 2)))
      else (int_of_char (String.get str 0),true)::(stringclause_to_clause (String.sub str 1 ((String.length str) - 1)))
  in
  let stringclause_list = String.split_on_char ' ' str in
  List.map stringclause_to_clause stringclause_list



(* Converts a clause to a string. The int variables are converted to chars 
   using the char_of_int function. 
   For example:
   string_of_clause [(120, false); (122, true)] = "(~x or z)" *)
let rec string_of_clause clause' = 
  let rec aux clause num : string = 
    match clause with
    | [] -> ")"
    | (v,b)::tl ->
      let var_string = Char.escaped (char_of_int v) in
      if b then 
      (
        if (num = 0) then ("(" ^ (var_string) ^ (aux tl (num+1)))
        else (" or " ^ (var_string) ^ (aux tl (num+1)))
      )
      else
      (
        if (num = 0) then ("(" ^ "~" ^ (var_string) ^ (aux tl (num+1)))
        else (" or " ^ "~" ^ (var_string) ^ (aux tl (num+1)))
      )   
  in aux clause' 0

(* Converts a cnf to a string.  
   For example:
   let ls =  [[(120, true); (121, true)]; [(120, false); (122, true)]];;
   string_of_cnf ls = "(x or y) and (~x or z)" *)
let rec string_of_cnf cnf' = 
  let rec aux cnf num : string = 
    match cnf with
    | [] -> ""
    | hd::tl ->
      let var_string = string_of_clause hd in
      (
        if (num = 0) then ((var_string) ^ (aux tl (num+1)))
        else (" and " ^ (var_string) ^ (aux tl (num+1)))
      )
  in aux cnf' 0