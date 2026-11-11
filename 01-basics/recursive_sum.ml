(* Recursive sum function example *)

(* A recursive function to sum all elements in a list *)
let rec sum_of list =
  match list with
  | [] -> 0
  | head :: tail -> head + sum_of tail;;

(* Test data *)
let test_list_1 = [1; 4; 4; 2; 6; 7];;
let test_list_2 = [0; 2; 4; 9; -4; -5];;

(* Calculate sums *)
let sum1 = sum_of test_list_1;;
let sum2 = sum_of test_list_2;;

(* Print results *)
let () = Printf.printf "Sum of [1;4;4;2;6;7] = %d\n" sum1;;
let () = Printf.printf "Sum of [0;2;4;9;-4;-5] = %d\n" sum2;;

(* Explanation of how the recursive function works:
   For list [1;4;4;2;6;7]:
   
   = 1 + sum_of [4;4;2;6;7]
   = 1 + (4 + sum_of [4;2;6;7])
   = 1 + (4 + (4 + sum_of [2;6;7]))
   = 1 + (4 + (4 + (2 + sum_of [6;7])))
   = 1 + (4 + (4 + (2 + (6 + sum_of [7]))))
   = 1 + (4 + (4 + (2 + (6 + (7 + sum_of [])))))
   = 1 + (4 + (4 + (2 + (6 + (7 + 0)))))
   = 1 + (4 + (4 + (2 + (6 + 7))))
   = 1 + (4 + (4 + (2 + 13)))
   = 1 + (4 + (4 + 15))
   = 1 + (4 + 19)
   = 1 + 23
   = 24
*)
