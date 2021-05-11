**Building a Sudoku Solver using Boolean Satisfiability in OCaml**

**Objectives**

In this assignment, you will build an application that solves a Sudoku puzzle by modeling it as a Boolean Satisfiability problem. You will get extensive practice in list processing in OCaml, an introduction to data types, and an understanding of just how powerful the functional programming paradigm can be. You will learn a famous algorithm for checking the satisfiability of a boolean formula, called the Davis-Putnam-Logemann-Loveland (DPLL) algorithm, and how to think of a sudoku puzzle as an optimization problem with constraints. You will also write code that converts between different data-types. Lastly, while you are highly encouraged to locally test your code at every step, a property-based test suite has been provided for you which uses randomized testing to find and report inputs for which your potentially buggy code fails (You will code the invariants yourself!)

**Introduction**

_Sudoku Puzzles_: **Sudoku** is a logic-based, combinatorial, number-placement puzzle. In classic sudoku, the objective is to fill a 9×9 grid with digits so that each column, each row, and each of the nine disjoint 3×3 subgrids that compose the grid contains all of the digits from 1 to 9. The puzzle setter provides a partially completed grid, which for a well-posed puzzle has a single solution (from Wikipedia). Sudokus are generalizable to _any_ nxn grid, as long as n is a perfect square.

_Variables and Literals:_ A variable in the context of this assignment is any symbol that takes values in the set {TRUE, FALSE}. We will represent variables as integers for ease of scalability. A literal is either a variable, or the negation of that variable. We will use &#39;~&#39; to represent a negation. For example, in the boolean formula &quot;(1 AND 2) OR ~1&quot;, the variables are {1,2} and there are three literals: {1, ~1, 2}.

_Boolean Satisfiability_: Also called SAT, this is a problem of checking if a particular boolean formula is satisfiable (that is, there exists an assignment of variables for which the whole formula is TRUE). SAT is NP-Complete. That is, there is no known formula for solving the problem efficiently (in poly-time). For example, the formula &quot;(1 AND 2) OR (3)&quot; is satisfiable, and the following assignment is a solution: {1:TRUE, 2:TRUE, 3:FALSE}. The formula &quot;(1 AND (~1))&quot; is not satisfiable.

_Conjunctive Normal Form (CNF):_ CNF is a particular way of representing boolean formulas. Specifically, if a boolean formula is a conjunction of clauses, where each clause is a disjunction of literals, that formula is in the CNF form. **Every boolean formula can be written in a CNF form.** We distinguish this form because the algorithm we use for SAT is easier to implement when the input is in a CNF form. For example, the formula &quot;(1 AND 2) or (3)&quot; is a valid boolean formula, but not a valid CNF. However, the equivalent formula, &quot;(1 OR 3) AND (2 OR 3)&quot;, is a valid CNF. Part of this assignment is converting any boolean formula into a CNF.

**Getting Started**

The project is split into 5 .ml files:

1. formula.ml - This file defines a representation for a Conjunctive Normal Form (CNF), and some helper code provided so students can convert between strings and the CNF representations easily to facilitate local testing. There are also some helper functions which will be explained later.

1. dpll.ml - This file has code that _solves_ a CNF. More precisely, it has a function dpll that takes as input a CNF and returns a solution option, which is None if the CNF does not have a solution and Some sol if sol satisfies the CNF. This function is complex with many components, and hence employs several helper functions.

1. converter.ml - This file defines a datatype that represents _any_ boolean formula. It defines functions that converts this general form into a CNF form defined in formula.ml

1. sudoku.ml - This file defines a representation for a sudoku board, and reduces the problem of solving a sudoku to satisfying a boolean formula. It defines constraints as boolean formulas, and uses dpll.ml to solve a particular puzzle. It also has code that can read in sudoku boards through .txt files and print the solution.

1. test.ml - This is a testing suite. It employs OCaml&#39;s property-based testing library, qcheck, to test the code in converter.ml and dpll.ml thoroughly and effectively.

_ **Running the files** _

make all to compile all files.

./test.byte to run the test suite.

**Part 1 (formula.ml)**

You are provided with the following representation of a CNF:

type variable = int

type literal = variable \* bool

type clause = literal list

type cnf = clause list

type solution = (variable \* bool) list

You are provided with two functions, string\_to\_cnf and string\_of\_cnf, that allows you to locally test your code. Look at the comments and examples to see how they work.

Use the definition of a CNF to understand this structure. Complete the following two functions (you will find it helpful to also define helper functions):

1. solution\_has\_distinct\_variables - Check if in an input of type solution, no variable is repeated.
2. check\_solution - Takes as input a cnf and a solution, and returns a bool . Returns true if the solution satisfies the cnf, and false otherwise. Note that it&#39;s _okay_ for the solution to not have all the variables from the cnf. For example, the solution {1:true} is a valid solution for the CNF (1 OR 2) AND (1 OR ~2), since the CNF is true when 1 is true, regardless of the value of 2.Hint: For a CNF to be satisfied, **every clause** must evaluate to TRUE. For a particular clause to be true, **at least one** literal in that clause should evaluate to TRUE.

**Part 2 (dpll.ml)**

The main goal of this part of the assignment is to write the function dpll, that takes as an argument a cnf, and returns a solution option. It returns None if the cnf is not satisfiable, and Some sol if the cnf is satisfiable and sol is a particular solution that satisfies the cnf. You are encouraged to write **several** helper functions for this.

The DPLL algorithm has 3 distinct components:

1. Backtracking - Pick any variable that is in the CNF, assign a truth value to it, **bind the variable and that truth value to an environment** , and recursively check if the simplified formula is satisfiable. If so, the formula is satisfiable and the **environment** is a valid solution. If not, conduct the same check with the opposite truth value.

1. Unit propagation - If the CNF contains a clause that has only one literal (known technically as a unit clause), it must be the case that that literal is TRUE for the formula to be satisfied. Bind the appropriate truth value to the environment, and simplify the CNF by substituting that truth value for everywhere that that variable occurs.

1. Pure literal elimination - If a variable occurs with the same polarity across the CNF, that is, for a particular variable x, if either all literals containing x are x or all literals containing x are ~x, then x is a pure variable. You can then assign a truth value such that that literal is TRUE everywhere, bind that value to the environment, and simplify the CNF by substituting that truth value for that variable. Consequently, every clause that contains this literal can be deleted.

_ **How to substitute?** _

You would have noticed a general pattern of binding a (variable,truth value) pair to the environment and substituting that in the cnf. You should notice that the environment is of the same type as solution! Binding is simply a way to keep track of what truth values have been assigned to variables so far. Substitution is tricky and bug-prone. Here is a general scheme you can follow when substituting a (variable, truth value) pair in a cnf. In a clause, whenever the literal is FALSE, delete that literal. If the literal is TRUE, delete the clause. (Why? A clause is a disjunction of literals. If any of the literals is TRUE, the clause is TRUE. Do this for every clause in the CNF.

_ **Stopping condition?** _

There are two stopping conditions for the DPLL algorithm:

1. The CNF is an empty list - in this case the CNF is satisfiable and the environment is a valid solution. On a high level, this means that every clause in the CNF has been satisfied.
2. The CNF contains an empty clause - in this case, the CNF is unsatisfiable. On a high level, this means that for a particular assignment of variables, a clause exists that cannot be satisfied, and therefore the CNF cannot be satisfied.

This is again tricky, and bug-prone. Make sure you understand very clearly the difference between an empty clause and an empty cnf. Make sure you substitute correctly (when to delete a clause and when to delete a literal in a clause).

This information should be sufficient to help you code the dpll function. Note that it is _highly_ recommended that you employ several helper functions. Some of the function definitions are provided for you. Test each of them before using them.

**Part 3 (converter.ml)**

Our dpll function works only on inputs of type cnf. But you want to be able to check the satisfiability of _any_ boolean formula. Look at the file converter.ml, and look at the definition of the datatype input\_1.

type input\_1 =

| Var of int

| Not of input\_1

| Or of (input\_1 \* input\_1)

| And of (input\_1 \* input\_1)

You should be convinced that this recursive datatype is able to define _any_ boolean formula. Converting the formula into a CNF will be split into two parts. There is a third part for testing that you are required to implement.

_**3(a)**_

Recall De Morgan&#39;s Law: For any two boolean formula P and Q,

~(P AND Q) = (~P) OR (~Q)

~(P OR Q) = (~P) AND (~Q)

Define a new datatype input\_2:

type input\_2 =

| Literal of (int \* bool)

| \_Or of (input\_2 \* input\_2)

| \_And of (input\_2 \* input\_2)

Use De Morgan&#39;s Law to write a recursive function demorgan, that converts from input\_1 to input\_2.

_**3(b)**_

Recall the distributive property: For any three boolean formulas P,Q,R.

P OR (Q AND R) = (P OR Q) AND (P OR R).

Use the distributive property to write a recursive function distribute, that converts from input\_2 to cnf. Here are a few hints for this part that will be very helpful:

1. If A is a valid CNF, and B is a valid CNF, then **A AND B = A@B**. Why? A is a conjunction of a set of clauses, and B is a conjunction of a set of clauses. Therefore, the conjunction of A and B is just the conjunction of all their clauses.

1. If C is a valid clause, and D is a valid clause, then C OR D = C@D. Why? C is a disjunction of literals, and B is a disjunction of literals. Therefore, the disjunction of C and D is just the disjunction of all their literals.

1. You are explicitly asked to write a helper function supermerge. Here is the motivation for it: Consider you have two CNFs, A and B, with 2 clauses each. Therefore A = [A1;A2] and B = [B1;B2], where A1, A2, B1, B2 are each clauses (or a list of literals). What is A OR B? When using the distributive property, A OR B = [(A1@B1); (A1@B2); (A2@B1); (A2@B2)]. You need to generalize this distribution for any two CNFs with m and n clauses respectively, to give a new CNF with m\*n clauses.

Finally, combine parts 3(a) and 3(b) to write a function:

prop\_to\_cnf (x:input\_1) : cnf = distribute (demorgan x)

_**3(c)**_

In order to thoroughly test your code, you are required to define a function, check\_equivalence, that checks whether two inputs of type input\_1 and cnf respectively are equivalent. We will do this using truth tables. Here are the steps:

1. Write a function evaluate that evaluates an input of type input\_1 for a particular solution.
2. First extract the list of all distinct variables in the cnf and call it var\_list.
3. Define a variable n that is the length of var\_list. We want to check all possible assignments of truth values to the variables in var\_list, and check that for each of those assignments, the cnf and input\_1 evaluate to the same boolean. For this, you will write a function called truth\_table, that takes as input an integer and returns a list of lists of bools, where the outermost list has length 2n and each inner list has length n. These are the rows of the truth table.

1. Zip the output of truth\_table with var\_list, and you will now have a solution list. For every solution in this list, check that the cnf and input\_1 have the same bool evaluation. (Use evaluate and the substitution function you defined in formula.ml. The latter returns a bool option, so you&#39;ll have to pattern-match for that).

**Part 4 (test.ml)**

Before proceeding to the final part of this assignment, you must thoroughly check your code through the testing suite provided in test.ml. This testing suite employs a property-based testing library called qcheck
**# 1**** ,** that uses randomized generation of inputs to test functions thoroughly and systematically. Essentially, the idea is to randomly generate randomly an input of a function you need to test, check whether a particular invariant of that function is satisfied on that input, and if not, shrink the input and attempt to find the smallest example that the function fails at.

_ **Test 1** _

Here we check the following invariant: for any input x of type input\_1, the following must hold:

check\_equivalence (x (prop\_to\_cnf x)). If you wrote check\_equivalence correctly, this should be a well functioning test for your function prop\_to\_cnf.

_ **Test 2** _

The exact invariant for the second test is slightly lengthier, but the idea is as follows. For any input x of type input\_1, define a cnf&#39; = prop\_to\_cnf x. Then, if dpll cnf&#39; returns Some sol, then sol should satisfy cnf&#39;.

**Part 5 (sudoku.ml)**

We now need to use all the tools we have built to solve a sudoku puzzle. A sudoku problem has an input of a _partially_ filled grid. Your goal is to fill in the rest of the grid while meeting a set of constraints.

_ **Variables** _

Let us first define the variables of this problem. Remember that a variable in this assignment must be binary. Consider an n x n grid. Our problem will have n3 variables, defined as follows:

For r,c,v = 0,..,n-1,

Xrcv= TRUE if the number in the rth row and cth column is v, FALSE otherwise. Note that rows, columns, and numbers are 0-indexed.

You should recognize that this implies that we have n3 variables, and given these variables, we can correctly construct a solved puzzle, given that the variables satisfy a particular set of constraints.

We have defined for you the following interface. You are encouraged to use it.

(\* A particular cell \*)

type cell = int \* int

(\* A starting sudoku grid \*)

type starting = (cell \* int) list

(\* An int assignment to a particular cell \*)

type cell\_fill = (cell \* int)

You have been provided with two functions, cell\_fill\_to\_var and var\_to\_cell\_fill that convert between a variable type and a cell\_fill type. For an nxn puzzle, you should have n3 variables ranging from 0 to n3-1. For any cell\_fille value ((r,c),v) you should be able to convert that into an int from 0 to n3-1, and vice-versa, using these two functions.

Now that we have a concrete definition of our variables in the problem, we will build constraints. We will directly represent these as CNFs for reasons you will understand after reading the next section.

_ **Constraints** _

For each of these constraints, we will build a cnf. At the end, you can AND all the cnfs together. Note that a lot of these constraints involve creating lists that are combinations or permutations of different lists. It will be helpful to define helper functions for those.

Constraint 1 - the starting grid constraint

You are given a starting grid as an input to the problem. Obviously, your final solution must have those numbers in their starting positions. For example, if in the starting grid, you have the number 5 in the second row and third column, then it must be the case that X235 = TRUE. You can therefore create a unit clause for each of the variables corresponding to **provided entries** in the starting grid.

Constraint 2 - a cell can contain at most one number

A cell in a sudoku must contain exactly one number. That also implies that it contains atmost one number (The exactly one number case will be taken care of later). That simply means for any cell, that is, for any given r and c, Xrci and Xrcj **cannot both be true** for any distinct and valid i and j. More precisely, for a particular cell (r,c), consider all pairs of number i and j (where i and j are not equal), and construct a clause (~Xrci OR ~Xrcj). Do this for every cell, and AND all the clauses together.

Constraint 3 - a row must contain every number exactly once

Pick a row r and a number v. We must first ensure that v appears at least once in the row, and v appears at most once in the row. That guarantees that v appears exactly once. To guarantee that v appears at least once in row r, you can construct a clause that ORs all variables Xrivfor all columns i. To guarantee that v appears at most once in row r, consider all pairs of number i and j (where i and j are not equal), and construct a clause (~Xriv OR ~Xrjv). AND all these clauses to create a cnf. Do this for every row and number, and AND all the cnfs together to create a new cnf.

Constraint 4 - a column must contain every number exactly once

This is analogous to Constraint 3.

Constraint 5 - a block must contain every number exactly once

You will have to think about how to map blocks. Iterating over them is harder than rows or columns, but the idea of constructing constraints is the same.

_ **Reconstructing the Sudoku puzzle** _

Complete the functions build\_constraint\_1, build\_constraint\_2, build\_constraint\_3, and build\_constraint\_4. Look at the starter code for which helper functions to implement.

[1](#sdfootnote1anc) https://github.com/c-cube/qcheck
