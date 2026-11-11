(* Options type example *)

(* A division function that returns None if division by zero *)
let div x y =
  if y = 0 then None else Some (x / y);;

(* Test cases *)
let result1 = div 10 0;;
let result2 = div 10 2;;

(* Helper function to print option results *)
let print_result description result =
  match result with
  | None -> Printf.printf "%s: None (division by zero)\n" description
  | Some value -> Printf.printf "%s: Some %d\n" description value;;

(* Print results *)
let () = print_result "div 10 0" result1;;
let () = print_result "div 10 2" result2;;
let () = print_result "div 15 3" (div 15 3);;
let () = print_result "div 7 0" (div 7 0);;

(* Working with option values *)
let () = 
  match div 20 4 with
  | None -> Printf.printf "Cannot divide\n"
  | Some v -> Printf.printf "20 / 4 = %d\n" v;;
