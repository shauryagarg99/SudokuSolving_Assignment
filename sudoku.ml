open Stdlib
open Converter
open Formula
open Dpll

type cell = int * int (* a particular cell *)

type starting = (cell * int) list (* Some pre-filled values *)

type cell_fill = (cell * int) (* A number assignment to a cell *)

let var_to_cell_fill (n:int) (v:int) : cell_fill = 
  assert(v >= 0);
  assert(v <= ((n*n*n) -1));

  let row = v/(n*n) in
  let v' = v - (row*(n*n)) in

  assert(v' >= 0);
  assert(v' <= ((n*n) -1));

  let col = v'/n in
  let v'' = v' - (col*n) in
  ((row,col),v'')

let cell_fill_to_var (n:int) (s:cell_fill) : int = 
  match s with
  | ((row,col),num) -> (num + (col*n) + (row*n*n))


(* CONSTRAINT 1 from assignment specs. n is the size of the grid. *)
let build_constraint_1 (n:int) (x:starting) : cnf = 
  failwith "TODO"


(* Take a variable v, and a list of variables xs, and create a cnf where each 
clause is [~v;~e], where e is an element of xs. 
*)
let rec func1 (v:variable) (xs:variable list) : cnf = 
  failwith "TODO"

(* Take a list of variables, and construct a cnf such that no two of those 
   variables can be true. That is, atmost one of the variables can be true. *)
let rec func2 (xs:variable list) : cnf = 
  failwith "TODO"

(* Take a list of variables, and construct a clause where all variables are true *)
let rec all_true_clause (xs:variable list) : clause = 
  failwith "TODO"


(* For a particular cell, atmost 1 element can occur. That is for variable 
Vcn, where c is the cell and n is the corresponding value, it cannot be the case that
Vc1 and Vc2 are both true. So on for every pair of numbers. *)
let build_sub_constraint_2 (n:int) (c:cell): cnf = 
  failwith "TODO"

(* The above must be true for all cells *)
let build_constraint_2 (n:int) : cnf = 
  failwith "TODO"


(* Return a cnf which for row number "row" and number "num", guarantees that 
"num" appears atleast once and atmost once. *)
let build_sub_constraint_3 (n:int) (row:int) (num:int) : cnf = 
  failwith "TODO"

let build_constraint_3 (n:int): cnf = 
  failwith "TODO"



(* Return a cnf which for col number "col" and number "num", guarantees that 
"num" appears atleast once and atmost once. *)
let build_sub_constraint_4 (n:int) (col:int) (num:int) : cnf = 
  failwith "TODO"

let build_constraint_4 (n:int): cnf = 
  failwith "TODO"


(* Given the topmost row number and the leftmost column number of a square, 
   ensure that number num appears exactly once *)
  let build_sub_constraint_5 (n:int) (row:int) (col:int) (num:int) : cnf = 
    let n_sqrt = int_of_float (sqrt (float_of_int n)) in
    let rec build_vars_rows i c = 
      (match i with
      | -1 -> []
      | _ -> (cell_fill_to_var n ((row+i,col+c),num))::(build_vars_rows (i-1) c))

    in
    let rec build_vars_cols j = 
      (match j with
      | -1 -> []
      | _ -> (build_vars_rows (n_sqrt-1) j)@(build_vars_cols (j-1))
      )
    in
    let var_list = build_vars_cols (n_sqrt-1) in
    let clause0 = all_true_clause var_list in (clause0::(func2 var_list))

  let rec block_to_rowcol (n:int) (block:int) : (int * int) = 
    let n_sqrt = int_of_float (sqrt (float_of_int n)) in
    let row = block/n_sqrt in
    let col = block - (row*n_sqrt) in
    (row*n_sqrt,col*n_sqrt)


  let build_constraint_5 (n:int): cnf = 
    let rec aux1 block =
      (match block with
      | -1 -> []
      | b -> 
          let (r,c) = block_to_rowcol n b in
          let cnf1 = 
          (let rec aux2 num = 
            (match num with
            | -1 -> []
            | i -> (build_sub_constraint_5 n r c i)@(aux2 (i-1))
            )
          in
          aux2 (n-1)
          )
          in
          cnf1@(aux1 (b-1))
      )
      in
      aux1 (n-1)


let rec convert_sol (n:int) (sol:solution) : (cell_fill*bool) list = 
  match sol with
  | [] -> []
  | (v,b)::tl -> ((var_to_cell_fill n v),b)::(convert_sol n tl)

let rec convert_cnf (n:int) (cnf:cnf) : (cell_fill*bool) list list = 
  match cnf with
  | [] -> []
  | hd::tl -> (convert_sol n hd)::(convert_cnf n tl)



let rec extract_true (xs: ('a * bool) list) : 'a list = 
  match xs with
  | [] -> []
  | (x,b)::tl ->
    if (b) then x::(extract_true tl)
    else
    (extract_true tl)


let solve_sudoku (n:int) (x:starting) : (cell_fill list) option = 
  let c1 = build_constraint_1 n x in
  let c2 = build_constraint_2 n in
  let c3 = build_constraint_3 n in
  let c4 = build_constraint_4 n in
  let c5 = build_constraint_5 n in
  let ans = dpll (c1@(c2@(c3@(c4@c5)))) in
  match ans with
  | None -> None
  | Some xs -> 
    let f' = extract_true (convert_sol n xs) in
    assert(List.length f' = n*n);
    Some f'


let rec extract_row (xs: (cell_fill list)) (row:int) : (cell_fill list) = 
  let rec col_compare_cell_fills (a:cell_fill) (b:cell_fill) : int = 
    let ((r1,c1),n1) = a in
    let ((r2,c2),n2) = b in
    c1 - c2
  in
  let rec aux xs' = 
    match xs' with
    | [] -> []
    | ((r,c),n)::tl -> 
      if (r = row) then ((r,c),n)::(aux tl) else (aux tl)
  in
  List.sort col_compare_cell_fills (aux xs)



let rec print_sudoku (n:int) (xs:(cell_fill list)) = 
  let rec string_row (xs: cell_fill list) = 
    match xs with
    | [] -> "\n"
    | ((r,c),n)::tl -> (string_of_int (n+1)) ^ " " ^ (string_row tl)
  in
  let rec aux i =
    (match i with
    | 0 -> ()
    | _ -> 
    print_string (string_row (extract_row xs (n-i))); aux (i-1))
  in
  aux n 
    

let read_whole_file filename =
  let ch = open_in filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s


let rec create_sudoku (xs:string list) : starting = 
  let parse_row (row:int) (s:string) : starting = 
    let s = String.split_on_char ' ' s in
    let s' = List.map int_of_string s in
    let rec aux xs col : starting = 
      match xs with
      | [] -> []
      | hd::tl -> 
      if (hd != 0) then ((row,col),hd-1)::(aux tl (col+1))
      else
      (aux tl (col+1))
    in
    aux s' 0
  in
  let rec aux xs' row = 
    (match xs' with
    | [] -> []
    | hd::tl -> (parse_row row hd)@(aux tl (row + 1)))
  in aux xs 0


let solve_and_print (filename:string) = 
  let s = read_whole_file filename in
  let _ = print_string s in 
  let _ = print_string "\n\n" in
  let lines_list = String.split_on_char '\n' s in
  let n = List.length lines_list in
  let starting1 = create_sudoku lines_list in
  let solved = solve_sudoku n starting1 in
  match solved with
  | None -> failwith "impossible"
  | Some x -> print_sudoku n x

(* Run this when you are done! *)
(* let _ = solve_and_print "sudokus/sudoku3.txt" *)