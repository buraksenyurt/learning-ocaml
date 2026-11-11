(*
  math.ml modülündeki fonksiyonlar için birim testler içerir.
*)

let test_factorial () =
  let value = 5 in
  let expected = 120 in
  let result = Math.factorial value in
  Alcotest.(check int) "factorial of 5" expected result

let test_power () =
  let base = 2 in
  let exp = 3 in
  let expected = 8 in
  let result = Math.power base exp in
  Alcotest.(check int) "power of 2^3" expected result

let test_factorial_negative () =
  let value = -1 in
  Alcotest.check_raises "factorial of negative number" (Failure "Negative input not allowed for factorial")
    (fun () -> ignore (Math.factorial value))

let () =
  let open Alcotest in
  run "Math Tests" [
    "Math Tests", [
       test_case "factorial of 5" `Quick test_factorial;
       test_case "power of 2^3" `Quick test_power;
       test_case "factorial of negative number" `Quick test_factorial_negative;   
    ];
  ];