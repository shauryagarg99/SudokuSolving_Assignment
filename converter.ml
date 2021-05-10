open Formula 

type input_1 = 
  | Var of int
  | Not of input_1
  | Or of input_1 * input_1
  | And of input_1 * input_1

type input_2 = 
  | Literal of int * bool
  | Or_ of input_2 * input_2
  | And_ of input_2 * input_2
  
(* Creates a new input type that removes all Not's from input_1 *)
let rec demorgan (f:input_1) : input_2 = 
  failwith "TODO" 


(* A function that takes two lists of lists, and returns a list with all possible 
     combinations of appending. Look at assignment specs. The order of the lists,
     or the order of the elements in each sublist, does NOT matter).
     Example:
    supermerge [[1;2];[3;4]] [[5;6];[7;8];[9]] = 
    [[5; 6; 1; 2]; [7; 8; 1; 2]; [9; 1; 2]; [5; 6; 3; 4]; [7; 8; 3; 4]; [9; 3; 4]] *)

let rec supermerge (ls1: 'a list list) (ls2: 'a list list) : 'a list list = 
  failwith "TODO"

(* Creates a cnf from input_2 type. It may be useful to define helper 
   functions. *)
let rec distribute (f:input_2) : cnf = 
  failwith "TODO"

let rec prop_to_cnf (x:input_1) : cnf = distribute (demorgan x)



(* Testing code.  TODO!*)

(* Evaluate an input of type input_1 for a particular assignment of variables *)
let rec evaluate (input:input_1) (assignment:solution) : bool = 
  failwith "TODO"


(* Return a truth table. The outermost list has length 2^n 
   and each inner list has length n. 
   Example: 
   truth_table 2 = [[true; true]; [true; false]; [false; true]; [false; false]] *)
let rec truth_table (n:int) : bool list list = 
  failwith "TODO"


(* Check that for every row in the truth_table, i1 and cnf have the same evaluation *)
let rec check_equivalence (i1:input_1) (cnf:cnf) : bool = 
  failwith "TODO"

