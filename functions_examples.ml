(* Function definitions and type inference examples *)

(* Basic function: adding two integers *)
let total x y = x + y;;

(* More complex function examples *)
let total_1 x y = x + y;;
let total_2 x y = (x * x) + (y * y);;

(* Division function with float conversion *)
let div x y = float_of_int x /. float_of_int y;;

(* Function taking another function as parameter *)
let square n = n * n;;
let more_add f x y = f * x + y;;

(* Conditional function with function parameter *)
let condition f first_arg second_arg =
  (if f first_arg then first_arg else 0)
  +
  (if f second_arg then second_arg else 0);;

let check_point value = value > 50;;

(* Same function with type annotations *)
let condition_annotated (f: int -> bool) (first_arg:int) (second_arg:int) : int =
  (if f first_arg then first_arg else 0)
  +
  (if f second_arg then second_arg else 0);;

(* Generic functions *)
let identity value = value;;

let swap (left, right) = (right, left);;

(* Generic compare function *)
let compare f arg_1 arg_2 =
  if f arg_1 then arg_1 else arg_2;;

let str_len string = String.length string > 8;;
let is_pass score = score > 70;;

(* Test the functions *)
let () = Printf.printf "total 1 5 = %d\n" (total 1 5);;
let () = Printf.printf "total (-5) 5 = %d\n" (total (-5) 5);;
let () = Printf.printf "total_1 3 4 + total_2 5 1 = %d\n" (total_1 3 4 + total_2 5 1);;
let () = Printf.printf "div 1 3 = %.5f\n" (div 1 3);;
let () = Printf.printf "div 3 2 = %.1f\n" (div 3 2);;
let () = Printf.printf "more_add (square 2) 3 5 = %d\n" (more_add (square 2) 3 5);;
let () = Printf.printf "condition check_point 28 76 = %d\n" (condition check_point 28 76);;
let () = Printf.printf "identity 1001 = %d\n" (identity 1001);;
let () = Printf.printf "identity \"PRD-0001\" = %s\n" (identity "PRD-0001");;
let () = 
  let (s, i) = swap (4, "four") in
  Printf.printf "swap (4, \"four\") = (\"%s\", %d)\n" s i;;
let () = Printf.printf "compare str_len \"Some...\" \"Something happens\" = %s\n" 
  (compare str_len "Some..." "Something happens");;
let () = Printf.printf "compare is_pass 68 50 = %d\n" (compare is_pass 68 50);;
