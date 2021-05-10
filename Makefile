all: formula converter dpll test sudoku

formula: formula.byte

converter: converter.byte

dpll: dpll.byte

test: test.byte

sudoku: sudoku.byte

formula.byte: formula.ml
	ocamlbuild formula.byte

converter.byte: converter.ml
	ocamlbuild converter.byte

dpll.byte: dpll.ml
	ocamlbuild dpll.byte

test.byte: test.ml
	ocamlbuild -package qcheck test.byte

sudoku.byte: sudoku.ml
	ocamlbuild sudoku.byte

clean: 
	ocamlbuild -clean