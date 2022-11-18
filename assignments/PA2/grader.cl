class Main inherits A2I{
        main() : Object {
                {
                        while(true)
                        loop{
                                (new IO).out_string("Enter marks: ");
                                (new IO).out_string(gradeCalculator(a2i((new IO).in_string())).concat("\n"));
                        }pool;
                }
        };

        fact(i: Int): Int {
                if(i=0) then 1 else i* fact(i-1) fi
        };
        gradeCalculator(i: Int): String {
                if(i<35) then  "E"
                else
                        if (i<50) then "C-"
                        else
                                if (i<55) then "C"
                                else
                                        if (i<60) then "C+"
                                        else
                                                if (i<65) then "B-"
                                                else
                                                        if (i<70) then "B+"
                                                        else
                                                                if (i<75) then "A-"
                                                                else
                                                                        if (i<80) then "A"
                                                                        else "A+"
                                                                        fi
                                                                fi
                                                        fi
                                                fi
                                        fi
                                fi
                        fi
                fi
        };
};