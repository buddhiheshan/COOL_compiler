(*
 *  Test Programme to test the funcitons in cool language
 *
 *  Programming Assignment 2
 *)

-- this is a single line comment

class Main inherits A2I {

	main() : Object {
		{
            while(true)
                loop{
                    (new IO).out_string("Enter value less than 10 to get the \
sum from 0 to input value: ");
					(new IO).out_string(i2a(getSum(a2i((new IO).in_string()))).concat("\n"));
            }pool;
        }
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