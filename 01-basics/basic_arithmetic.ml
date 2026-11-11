(* Basic arithmetic operations and variable assignments *)

(* Float arithmetic operations *)
let float_addition = 3.14 +. 2.1;;
let int_addition = 10 + 2;;
let float_proper = 10. +. 2.;;
let large_numbers = 1_000_000 * 10_000;;

(* Boolean comparisons *)
let comparison_1 = (2 * 5) <= 10;;
let comparison_2 = (2 * 6) <= 10;;

(* Variable assignments *)
let xValue = 10;;
let y_value = 5;;
let result = xValue + y_value;;

(* Print results *)
let () = Printf.printf "Float addition: %.2f\n" float_addition;;
let () = Printf.printf "Int addition: %d\n" int_addition;;
let () = Printf.printf "Float proper: %.0f\n" float_proper;;
let () = Printf.printf "Large numbers: %d\n" large_numbers;;
let () = Printf.printf "Comparison 1 (2*5 <= 10): %b\n" comparison_1;;
let () = Printf.printf "Comparison 2 (2*6 <= 10): %b\n" comparison_2;;
let () = Printf.printf "Result (xValue + y_value): %d\n" result;;
