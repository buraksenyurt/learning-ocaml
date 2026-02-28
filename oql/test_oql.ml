(*
  Oql modülündeki fonksiyonlara ait birim testlerini içeren modül.
*)

let pp_value fmt v =
  match v with
  | Db.VString s -> Format.fprintf fmt "VString(%s)" s
  | Db.VInt n    -> Format.fprintf fmt "VInt(%d)" n

let value = Alcotest.testable pp_value ( = )

let mock_db : Db.database = [
  ("Products", [
    [("Id", Db.VInt 1); ("Name", Db.VString "Laptop"); ("CategoryId", Db.VInt 1)];
    [("Id", Db.VInt 2); ("Name", Db.VString "Phone"); ("CategoryId", Db.VInt 1)];
    [("Id", Db.VInt 3); ("Name", Db.VString "Table"); ("CategoryId", Db.VInt 2)];
  ]);
  ("Categories", [
    [("Id", Db.VInt 1); ("Name", Db.VString "Electronics")];
    [("Id", Db.VInt 2); ("Name", Db.VString "Furniture")];
  ]);
]

let pp_token fmt t =
  match t with
  | Oql.TTable        -> Format.fprintf fmt "TTable"
  | Oql.TGet          -> Format.fprintf fmt "TGet"
  | Oql.TAll          -> Format.fprintf fmt "TAll"
  | Oql.TWhere        -> Format.fprintf fmt "TWhere"
  | Oql.TAssign       -> Format.fprintf fmt "TAssign"
  | Oql.TString s     -> Format.fprintf fmt "TString(%s)" s
  | Oql.TInt n        -> Format.fprintf fmt "TInt(%d)" n
  | Oql.TEq           -> Format.fprintf fmt "TEq"
  | Oql.TNeq          -> Format.fprintf fmt "TNeq"
  | Oql.TEOF          -> Format.fprintf fmt "TEOF"
  | Oql.TIdentifier s -> Format.fprintf fmt "TIdentifier(%s)" s

let token       = Alcotest.testable pp_token ( = )
let token_list  = Alcotest.list token

let check_tokens label input expected =
  Alcotest.check token_list label expected (Oql.tokenize input)

let test_empty_string () =
  check_tokens "empty string produces no tokens" "" []

let test_whitespace_only () =
  check_tokens "whitespace-only produces no tokens" "   \t\n" []

let test_semicolon () =
  check_tokens "semicolon becomes TEOF" ";" [ Oql.TEOF ]

let test_assign_operator () =
  check_tokens "single = becomes TAssign" "=" [ Oql.TAssign ]

let test_eq_operator () =
  check_tokens "== becomes TEq" "==" [ Oql.TEq ]

let test_neq_operator () =
  check_tokens "!= becomes TNeq" "!=" [ Oql.TNeq ]

let test_string_literal () =
  check_tokens "single-quoted string becomes TString"
    "'hello'" [ Oql.TString "hello" ]

let test_string_with_spaces () =
  check_tokens "single-quoted string with spaces"
    "'hello world'" [ Oql.TString "hello world" ]

let test_integer_literal () =
  check_tokens "integer literal becomes TInt"
    "42" [ Oql.TInt 42 ]

let test_keyword_table () =
  check_tokens "keyword 'table' becomes TTable"
    "table" [ Oql.TTable ]

let test_keyword_get () =
  check_tokens "keyword 'get' becomes TGet"
    "get" [ Oql.TGet ]

let test_keyword_all () =
  check_tokens "keyword 'all' becomes TAll"
    "all" [ Oql.TAll ]

let test_keyword_where () =
  check_tokens "keyword 'where' becomes TWhere"
    "where" [ Oql.TWhere ]

let test_keywords_case_insensitive () =
  check_tokens "keywords are case-insensitive"
    "TABLE GET ALL WHERE"
    [ Oql.TTable; Oql.TGet; Oql.TAll; Oql.TWhere ]

let test_identifier () =
  check_tokens "unknown word becomes TIdentifier"
    "foo_bar" [ Oql.TIdentifier "foo_bar" ]

let test_full_query_with_eq () =
  check_tokens "full query with == tokenises correctly"
    "table='Products' get all where 'CategoryId' == 1;"
    [ Oql.TTable; Oql.TAssign; Oql.TString "Products";
      Oql.TGet; Oql.TAll;
      Oql.TWhere; Oql.TString "CategoryId"; Oql.TEq; Oql.TInt 1;
      Oql.TEOF ]

let test_full_query_with_neq () =
  check_tokens "full query with != tokenises correctly"
    "table='Orders' get all where 'Status' != 0;"
    [ Oql.TTable; Oql.TAssign; Oql.TString "Orders";
      Oql.TGet; Oql.TAll;
      Oql.TWhere; Oql.TString "Status"; Oql.TNeq; Oql.TInt 0;
      Oql.TEOF ]

let test_query_no_where () =
  check_tokens "query without WHERE clause"
    "table='Users' get all;"
    [ Oql.TTable; Oql.TAssign; Oql.TString "Users";
      Oql.TGet; Oql.TAll;
      Oql.TEOF ]

let test_invalid_char_raises () =
  let f () = ignore (Oql.tokenize "@invalid") in
  Alcotest.check_raises
    "invalid character raises Failure"
    (Failure "Invalid character @")
    f

let test_invalid_exclamation_raises () =
  let f () = ignore (Oql.tokenize "!x") in
  Alcotest.check_raises
    "lone '!' raises Failure"
    (Failure "Unexpected character '!' at index 0")
    f

let test_multiple_integers () =
  check_tokens "multiple integers separated by spaces"
    "1 22 333"
    [ Oql.TInt 1; Oql.TInt 22; Oql.TInt 333 ]

let test_mixed_tokens () =
  check_tokens "mixed keywords, strings and integers"
    "get 'name' == 99"
    [ Oql.TGet; Oql.TString "name"; Oql.TEq; Oql.TInt 99 ]

let test_is_letter_lowercase () =
  Alcotest.(check bool) "lowercase letter" true (Oql.is_letter 'a')

let test_is_letter_uppercase () =
  Alcotest.(check bool) "uppercase letter" true (Oql.is_letter 'Z')

let test_is_letter_digit_false () =
  Alcotest.(check bool) "digit is not a letter" false (Oql.is_letter '5')

let test_is_digit_true () =
  Alcotest.(check bool) "digit char" true (Oql.is_digit '7')

let test_is_digit_letter_false () =
  Alcotest.(check bool) "letter is not a digit" false (Oql.is_digit 'a')

let test_evaluator () =
  let sql = "table='Products' get all where 'CategoryId' == 1;" in
  let tokens = Oql.tokenize sql in
  let query = Oql.parse tokens in
  let results = Oql.execute query mock_db in
  let expected = [
    [("Id", Db.VInt 1); ("Name", Db.VString "Laptop"); ("CategoryId", Db.VInt 1)];
    [("Id", Db.VInt 2); ("Name", Db.VString "Phone"); ("CategoryId", Db.VInt 1)];
  ] in
  Alcotest.(check (list (list (pair string value)))) "evaluator returns correct rows" expected results

let tokenizer_tests = [
  Alcotest.test_case "empty string"                    `Quick test_empty_string;
  Alcotest.test_case "whitespace only"                 `Quick test_whitespace_only;
  Alcotest.test_case "semicolon → TEOF"               `Quick test_semicolon;
  Alcotest.test_case "single = → TAssign"             `Quick test_assign_operator;
  Alcotest.test_case "== → TEq"                       `Quick test_eq_operator;
  Alcotest.test_case "!= → TNeq"                      `Quick test_neq_operator;
  Alcotest.test_case "quoted string → TString"         `Quick test_string_literal;
  Alcotest.test_case "quoted string with spaces"       `Quick test_string_with_spaces;
  Alcotest.test_case "integer → TInt"                  `Quick test_integer_literal;
  Alcotest.test_case "keyword table"                   `Quick test_keyword_table;
  Alcotest.test_case "keyword get"                     `Quick test_keyword_get;
  Alcotest.test_case "keyword all"                     `Quick test_keyword_all;
  Alcotest.test_case "keyword where"                   `Quick test_keyword_where;
  Alcotest.test_case "keywords case-insensitive"       `Quick test_keywords_case_insensitive;
  Alcotest.test_case "unknown word → TIdentifier"      `Quick test_identifier;
  Alcotest.test_case "full query with =="              `Quick test_full_query_with_eq;
  Alcotest.test_case "full query with !="              `Quick test_full_query_with_neq;
  Alcotest.test_case "query without WHERE"             `Quick test_query_no_where;
  Alcotest.test_case "invalid character raises"        `Quick test_invalid_char_raises;
  Alcotest.test_case "lone ! raises"                   `Quick test_invalid_exclamation_raises;
  Alcotest.test_case "multiple integers"               `Quick test_multiple_integers;
  Alcotest.test_case "mixed tokens"                    `Quick test_mixed_tokens;
]

let evaluator_tests = [
  Alcotest.test_case "evaluator returns correct rows" `Quick test_evaluator;
]

let helper_tests = [
  Alcotest.test_case "is_letter lowercase"             `Quick test_is_letter_lowercase;
  Alcotest.test_case "is_letter uppercase"             `Quick test_is_letter_uppercase;
  Alcotest.test_case "is_letter rejects digit"         `Quick test_is_letter_digit_false;
  Alcotest.test_case "is_digit recognises digit"       `Quick test_is_digit_true;
  Alcotest.test_case "is_digit rejects letter"         `Quick test_is_digit_letter_false;
]

let () =
  Alcotest.run "OQL Tests"
    [ ("Tokenizer", tokenizer_tests)
    ; ("Helpers", helper_tests)
    ; ("Evaluator", evaluator_tests)
    ]
