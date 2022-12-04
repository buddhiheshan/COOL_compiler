class A {
ana(): Int {
(let x:Int <- 1 in 2)+3
};
};

Class BB__ inherits A {
};

class Main inherits A2I {

	main() : Object {
		(let x:Int <- 1 in 2)+3
	};

	getSum (number: Int) : Int {

		let sum: Int <- 0 in {

			while (not(number = 0)) loop
				{
					sum <- if (sum < 100) then sum + number else 0 fi;
					number <- number - 1;
				}
			pool;
			sum;
		}
	};
};
