(*
  Evaluator modülündeki fonksiyonlara ait birim testleri.
  Çalıştırmak için: dune test
*)

let evaluates_to label input expected =
  Alcotest.(check int) label expected (Evaluator.evaluate input)

let fails_with label input message =
  Alcotest.check_raises label (Failure message) (fun () ->
      ignore (Evaluator.evaluate input))

(* Temel aritmetik ve işlem önceliği *)
let test_single_number () = evaluates_to "single number" "42" 42
let test_addition () = evaluates_to "addition" "3 + 4" 7
let test_precedence () = evaluates_to "* before +" "3 + 4 * 2" 11
let test_parentheses () = evaluates_to "parentheses" "(3 + 4) * 2" 14
let test_left_assoc_sub () = evaluates_to "left associative -" "10 - 3 - 2" 5
let test_left_assoc_div () = evaluates_to "left associative /" "100 / 10 / 5" 2
let test_nested () = evaluates_to "nested parentheses" "3 + 4 * (2 - 1)" 7

(* Tekli eksi *)
let test_unary_minus () = evaluates_to "unary minus" "-5" (-5)
let test_unary_minus_expr () = evaluates_to "unary minus with parens" "-(2 + 3)" (-5)
let test_unary_minus_mul () = evaluates_to "unary minus binds tighter" "-2 * 3" (-6)
let test_unary_after_op () = evaluates_to "unary minus after operator" "4 * -2" (-8)
let test_double_unary () = evaluates_to "double unary minus" "--5" 5
let test_sub_vs_unary () = evaluates_to "binary minus still works" "5 - -3" 8

(* Hata durumları *)
let test_div_by_zero () = fails_with "division by zero" "1 / 0" "Division by zero"

let test_trailing_number () =
  fails_with "leftover number is rejected" "3 4" "Syntax error: Unexpected token '4'"

let test_extra_paren () =
  fails_with "extra ')' is rejected" "(1+2))" "Syntax error: Unexpected token ')'"

let test_missing_paren () =
  fails_with "missing ')'" "(1+2" "Syntax error: ')' missing!"

let test_dangling_operator () =
  fails_with "dangling operator" "1 +" "Syntax error: Unexpected character or missing number!"

let test_invalid_char () =
  fails_with "invalid character" "2 ^ 3" "Unexpected character: '^'"

(* AST seviyesinde birkaç kontrol *)
let test_ast_unary () =
  let ast = Evaluator.parse (Evaluator.tokenizer "-3") in
  Alcotest.(check bool) "-3 parses to Neg (Value 3)" true
    (ast = Evaluator.Neg (Evaluator.Value 3))

let test_ast_precedence () =
  let open Evaluator in
  let ast = parse (tokenizer "1 + 2 * 3") in
  Alcotest.(check bool) "1 + 2 * 3 parses to Add (1, Mul (2, 3))" true
    (ast = Add (Value 1, Mul (Value 2, Value 3)))

let () =
  let open Alcotest in
  run "Evaluator Tests"
    [ ( "Arithmetic",
        [ test_case "single number" `Quick test_single_number;
          test_case "addition" `Quick test_addition;
          test_case "precedence" `Quick test_precedence;
          test_case "parentheses" `Quick test_parentheses;
          test_case "left associative -" `Quick test_left_assoc_sub;
          test_case "left associative /" `Quick test_left_assoc_div;
          test_case "nested" `Quick test_nested ] );
      ( "Unary minus",
        [ test_case "-5" `Quick test_unary_minus;
          test_case "-(2 + 3)" `Quick test_unary_minus_expr;
          test_case "-2 * 3" `Quick test_unary_minus_mul;
          test_case "4 * -2" `Quick test_unary_after_op;
          test_case "--5" `Quick test_double_unary;
          test_case "5 - -3" `Quick test_sub_vs_unary ] );
      ( "Errors",
        [ test_case "division by zero" `Quick test_div_by_zero;
          test_case "leftover number" `Quick test_trailing_number;
          test_case "extra paren" `Quick test_extra_paren;
          test_case "missing paren" `Quick test_missing_paren;
          test_case "dangling operator" `Quick test_dangling_operator;
          test_case "invalid character" `Quick test_invalid_char ] );
      ( "AST",
        [ test_case "unary AST" `Quick test_ast_unary;
          test_case "precedence AST" `Quick test_ast_precedence ] ) ]
