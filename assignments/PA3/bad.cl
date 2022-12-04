(* no error *)
class A {
};

(* error:  x is not a type identifier *)
Class x inherits A {
};

(* error:  y is not a type identifier *)
Class C inherits y {
};

(* error:  keyword inherits is misspelled *)
Class P inhts Q {
};

(* error:  keyword class is misspelled *)
Clas P inhts Q {
};

(* error:  closing brace is missing *)
Class P inherits Q {
;

(* error:  opening brace is missing *)
Class E inherits A }
;

class Main inherits A2I {

	main() : Object {
		(let x:Int <- 1 in 2)+3
	};

(* error:  Int as int *)
	getSum (number: Int) : int {

		let sum: Int <- 0 in {

(* error:  Typo in while)
			whlie (not(number = 0)) loop
				{
					sum <- if (sum < 100) then sum + number else 0 fi;
					number <- number - 1;
				}
			pool;
			sum;
		}
	};
};

