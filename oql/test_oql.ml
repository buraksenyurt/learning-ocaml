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
  | Oql.TSemicolon    -> Format.fprintf fmt "TSemicolon"
  | Oql.TIdentifier s -> Format.fprintf fmt "TIdentifier(%s)" s

let token       = Alcotest.testable pp_token ( = )
let token_list  = Alcotest.list token

(* tokenize artık (token list, string) result döndürüyor *)
let tokenize_result = Alcotest.result token_list Alcotest.string

let check_tokens label input expected =
  Alcotest.check tokenize_result label (Ok expected) (Oql.tokenize input)

let check_tokenize_error label input message =
  Alcotest.check tokenize_result label (Error message) (Oql.tokenize input)

let test_empty_string () =
  check_tokens "empty string produces no tokens" "" []

let test_whitespace_only () =
  check_tokens "whitespace-only produces no tokens" "   \t\n" []

let test_semicolon () =
  check_tokens "semicolon becomes TSemicolon" ";" [ Oql.TSemicolon ]

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
      Oql.TSemicolon ]

let test_full_query_with_neq () =
  check_tokens "full query with != tokenises correctly"
    "table='Orders' get all where 'Status' != 0;"
    [ Oql.TTable; Oql.TAssign; Oql.TString "Orders";
      Oql.TGet; Oql.TAll;
      Oql.TWhere; Oql.TString "Status"; Oql.TNeq; Oql.TInt 0;
      Oql.TSemicolon ]

let test_query_no_where () =
  check_tokens "query without WHERE clause"
    "table='Users' get all;"
    [ Oql.TTable; Oql.TAssign; Oql.TString "Users";
      Oql.TGet; Oql.TAll;
      Oql.TSemicolon ]

let test_invalid_char_error () =
  check_tokenize_error "invalid character returns Error" "@invalid" "Invalid character @"

let test_invalid_exclamation_error () =
  check_tokenize_error "lone '!' returns Error" "!x" "Unexpected character '!' at index 0"

let test_unterminated_string_error () =
  check_tokenize_error "unterminated string returns Error" "'abc"
    "Unterminated string starting at index 0"

let test_empty_string_literal () =
  check_tokens "empty quoted string" "''" [ Oql.TString "" ]

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

let laptop = [("Id", Db.VInt 1); ("Name", Db.VString "Laptop"); ("CategoryId", Db.VInt 1)]
let phone  = [("Id", Db.VInt 2); ("Name", Db.VString "Phone"); ("CategoryId", Db.VInt 1)]
let table  = [("Id", Db.VInt 3); ("Name", Db.VString "Table"); ("CategoryId", Db.VInt 2)]

let rows = Alcotest.(list (list (pair string value)))
let run_result = Alcotest.result rows Alcotest.string

let check_run label input expected =
  Alcotest.check run_result label expected (Oql.run mock_db input)

let test_evaluator () =
  check_run "int equality" "table='Products' get all where 'CategoryId' == 1;"
    (Ok [ laptop; phone ])

let test_neq_int () =
  check_run "int inequality" "table='Products' get all where 'CategoryId' != 1;"
    (Ok [ table ])

let test_string_eq () =
  check_run "string equality" "table='Products' get all where 'Name' == 'Phone';"
    (Ok [ phone ])

let test_string_neq () =
  check_run "string inequality" "table='Products' get all where 'Name' != 'Phone';"
    (Ok [ laptop; table ])

let test_no_where () =
  check_run "query without WHERE returns all rows" "table='Categories' get all;"
    (Ok [ [("Id", Db.VInt 1); ("Name", Db.VString "Electronics")];
          [("Id", Db.VInt 2); ("Name", Db.VString "Furniture")] ])

let test_no_match () =
  check_run "no matching rows" "table='Products' get all where 'CategoryId' == 99;" (Ok [])

let test_unknown_column () =
  check_run "unknown column matches nothing" "table='Products' get all where 'Price' == 10;" (Ok [])

let test_unknown_table () =
  check_run "unknown table" "table='Orders' get all;"
    (Error "Table 'Orders' not found in database!")

let test_type_mismatch () =
  check_run "type mismatch" "table='Products' get all where 'Name' == 1;"
    (Error "Type mismatch in condition for column 'Name'")

(* Parser hata dalları *)
let test_missing_semicolon () =
  check_run "missing ';'" "table='Products' get all"
    (Error "Syntax error: Missing ';' at the end of the query!")

let test_missing_semicolon_after_where () =
  check_run "missing ';' after WHERE" "table='Products' get all where 'Id' == 1"
    (Error "Syntax error: Missing ';' at the end of the query!")

let test_wrong_operator () =
  check_run "single '=' in WHERE" "table='Products' get all where 'Id' = 1;"
    (Error "Syntax error in WHERE clause: Expected '==' or '!='!")

let test_wrong_value () =
  check_run "keyword as value" "table='Products' get all where 'Id' == all;"
    (Error "Syntax error in WHERE clause: Expected a number or a quoted string!")

let test_unquoted_column () =
  check_run "unquoted column" "table='Products' get all where Id == 1;"
    (Error "Syntax error in WHERE clause: Column names must be quoted, e.g. 'Id'")

let test_bad_prefix () =
  check_run "missing 'get all'" "table='Products' where 'Id' == 1;"
    (Error "Syntax error: Expected 'table=...' followed by 'get all' and optional 'where' clause!")

let test_tokenizer_error_propagates () =
  check_run "tokenizer error stops the pipeline" "table='Products get all;"
    (Error "Unterminated string starting at index 6")

let test_parse_query () =
  match Oql.parse [ Oql.TTable; Oql.TAssign; Oql.TString "Products"; Oql.TGet; Oql.TAll;
                    Oql.TWhere; Oql.TString "Name"; Oql.TEq; Oql.TString "Pen"; Oql.TSemicolon ] with
  | Ok q ->
      Alcotest.(check string) "table name" "Products" q.Oql.table_name;
      Alcotest.(check bool) "condition" true
        (q.Oql.condition = Some { Oql.column = "Name"; op = Oql.Eq; target = Db.VString "Pen" })
  | Error msg -> Alcotest.fail msg

let tokenizer_tests = [
  Alcotest.test_case "empty string"                    `Quick test_empty_string;
  Alcotest.test_case "whitespace only"                 `Quick test_whitespace_only;
  Alcotest.test_case "semicolon → TSemicolon"         `Quick test_semicolon;
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
  Alcotest.test_case "invalid character → Error"       `Quick test_invalid_char_error;
  Alcotest.test_case "lone ! → Error"                  `Quick test_invalid_exclamation_error;
  Alcotest.test_case "unterminated string → Error"     `Quick test_unterminated_string_error;
  Alcotest.test_case "empty quoted string"             `Quick test_empty_string_literal;
  Alcotest.test_case "multiple integers"               `Quick test_multiple_integers;
  Alcotest.test_case "mixed tokens"                    `Quick test_mixed_tokens;
]

let parser_tests = [
  Alcotest.test_case "parse builds query"              `Quick test_parse_query;
  Alcotest.test_case "missing ;"                       `Quick test_missing_semicolon;
  Alcotest.test_case "missing ; after WHERE"           `Quick test_missing_semicolon_after_where;
  Alcotest.test_case "single = in WHERE"               `Quick test_wrong_operator;
  Alcotest.test_case "keyword as value"                `Quick test_wrong_value;
  Alcotest.test_case "unquoted column"                 `Quick test_unquoted_column;
  Alcotest.test_case "missing get all"                 `Quick test_bad_prefix;
  Alcotest.test_case "tokenizer error propagates"      `Quick test_tokenizer_error_propagates;
]

let evaluator_tests = [
  Alcotest.test_case "evaluator returns correct rows" `Quick test_evaluator;
  Alcotest.test_case "int inequality"                 `Quick test_neq_int;
  Alcotest.test_case "string equality"                `Quick test_string_eq;
  Alcotest.test_case "string inequality"              `Quick test_string_neq;
  Alcotest.test_case "no WHERE"                       `Quick test_no_where;
  Alcotest.test_case "no matching rows"               `Quick test_no_match;
  Alcotest.test_case "unknown column"                 `Quick test_unknown_column;
  Alcotest.test_case "unknown table"                  `Quick test_unknown_table;
  Alcotest.test_case "type mismatch"                  `Quick test_type_mismatch;
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
    ; ("Parser", parser_tests)
    ; ("Evaluator", evaluator_tests)
    ]
