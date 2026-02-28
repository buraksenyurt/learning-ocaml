(*
  Bu seferki örnek eval programından da esinlenerek aşağıdaki ifadeyi
    yorumlayabilecek bir Read-Eval-Print Loop (REPL) döngüsü geliştirmek.

  table='Products' get all where 'CategoryId' == 1;

  Yine Abstract Syntax Tree (AST), Lexer ve Parser gibi bileşenler de kullanılacak.
*)

(*
  Öncelikle sorgu ifadesinin tip güvenli bir veri modelini oluşturmamız lazım.
  Örneğin == != gibi operatörleri, string ve int gibi değer türlerini,
  where kısmını temsil edecek bir condition yapısını ve 
  tüm sorguyu temsil edecek bir query yapısını tanımlamalıyız.
  Bunların her biri birer type olarak oluşturulabilir.
*)

(* Şimdilik == ve != operatörlerini destekliyor *)
type operator =
  | Eq
  | Neq
[@@warning "-37"] (* Şimdilik unused-constructor warnings uyarısını build aşamasında geçersiz kılmak için eklendi *)

(* Tablo adı gibi metinse ve kategori numarası gibi tam sayıları karşılıyor. 
Şimdilik sadece string ve int türlerini destekliyor. *)
type value = 
  | VString of string
  | VInt of int
[@@warning "-37"] (* Şimdilik unused-constructor warnings uyarısını build aşamasında geçersiz kılmak için eklendi *)

(*
  condition yapısı, bir sütun adı, bir operatör ve bir hedef değer içerir.
  Örneğin 'CategoryId' == 1 ifadesi aşağıdaki gibi temsil edilir;

  { column = "CategoryId"; op = Eq; target = VInt 1 }
*)
type condition = {
  column: string;
  op:operator;
  target: value;
}

(*
  Bu kısımda sorgunun tamamını temsil eder. 
  Örneğin table='Products' get all where 'CategoryId' == 1 ifadesi aşağıdaki gibi temsil edilir,
{
  table_name = "Products";
  is_get_all = true;
  condition = Some { column = "CategoryId"; op = Eq; target = VInt 1 }
}
*)
type query = {
  table_name:string;
  is_get_all: bool;
  condition: condition option; (* Opsiyonel bir condition tanımı. Zira where ifadesi her zaman gerekli olmayabilir.*)
}
[@@warning "-34"] (*Şimdilik build aşamasında unused-type-declaration uyarısını geçersiz kılmak için.*)

(*
  Tabii bu ifadeyi kelime kelime parçalayarak anlamlandırmak lazım. Tipik olarak bir Lexer (Tokenizer) ihtiyacımız var
    ama öncesinde sorgu diline özgü keyword'leri çıkarmalıyız. Yeni bir variant tip ekleyerek bu keyword'leri tanımlayabiliriz.
*)
type token =
  | TTable (* 'table adı' kısmını temsil eder *)
  | TGet (* 'get' keyword'ünü temsil eder *)
  | TAll (* 'all' keyword'ünü temsil eder *)
  | TWhere (* 'where' keyword'ünü temsil eder *)
  | TAssign (* atamalarda kullanabileceğimiz '=' operatörünü temsil eder *)
  | TString of string (* String değerleri temsil eder *)
  | TInt of int (* Integer değerleri temsil eder *)
  | TEq (* '==' operatörünü temsil eder *)
  | TNeq (* '!=' operatörünü temsil eder *)
  | TEOF (* ; operatörünü temsil eder ki bununla ifadenin sonunu belirtiyoruz *)
  | TIdentifier of string (* Tırnaksız yazılan ifadeleri temsil eder *)

(*
  Lexer için bazı yardımcı fonksiyonlar lazım. Örneğin karakterin harf olup olmadığını kontrol eden bir fonksiyon gibi.
*)
let is_letter c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
let is_digit c = c >= '0' && c <= '9'

(*
  ve tabii işin en karmaşık kısımlarından olan tokenizer fonksiyonu. Yani, gelen string ifadeyi token'lara dönüştüren fonksiyon.
  Örneğin "table='Products' get all where 'CategoryId' == 1;" ifadesi
[TTable; TAssign; TString "Products"; TGet; TAll; TWhere; TString "CategoryId"; TEq; TInt 1; TEOF]
şeklinde bir token listesine dönüştürülebilmeli.
*)
let tokenize str = 
  let length = String.length str in

  let rec aux index acc =
    if index>= length then List.rev acc
    else match str.[index] with
      | ' ' | '\t' | '\n' | '\r' -> aux(index +1) acc
      | ';' -> aux (index +1) (TEOF :: acc)
      | '!' ->
        if index + 1 < length && str.[index+1] = '=' then
          aux (index + 2) (TNeq :: acc)
        else
          failwith (Printf.sprintf "Unexpected character '!' at index %d" index)
      | '=' ->
        if index + 1 < length && str.[index+1] = '=' then
          aux (index +2) (TEq :: acc)
        else
          aux (index +1) (TAssign :: acc)
      | '\'' ->

        let rec read_string j = 
          if j< length && str.[j] <> '\'' then read_string (j+1)
          else j
        in

        let end_index = read_string (index + 1) in
        let content = String.sub str (index + 1) (end_index - index - 1) in

        aux (end_index+1) (TString content :: acc)
      | c when is_letter c ->

          let rec read_word j =
            if j < length && (is_letter str.[j] || is_digit str.[j] || str.[j] = '_') then read_word (j + 1)
            else j
          in

          let end_index = read_word index in
          let word = String.sub str index (end_index - index) in
        
          let token = match String.lowercase_ascii word with
            | "table" -> TTable
            | "get" -> TGet
            | "all" -> TAll
            | "where" -> TWhere
            | _ -> TIdentifier word
          in
          aux end_index (token :: acc)
       | c when is_digit c ->

          let rec read_num j =
            if j < length && is_digit str.[j] then read_num (j + 1)
            else j
          in

          let end_index = read_num index in
          let num = int_of_string (String.sub str index ( end_index - index)) in

          aux end_index (TInt  num :: acc)
      | c->failwith (Printf.sprintf "Invalid character %c" c)
  in
  aux 0 []

let print_token = function 
  | TTable -> Printf.printf "TABLE "
  | TGet -> Printf.printf "GET "
  | TAll -> Printf.printf "ALL "
  | TWhere -> Printf.printf "WHERE "
  | TAssign -> Printf.printf "ASSIGN "
  | TString s -> Printf.printf "STRING(%s) " s
  | TInt n -> Printf.printf "INT(%d) " n
  | TEq -> Printf.printf "EQ "
  | TNeq -> Printf.printf "NEQ "
  | TEOF -> Printf.printf "EOF "
  | TIdentifier id-> Printf.printf "IDENTIFIER(%s) " id

let () =
  print_endline "Welcome to the You ain't gonna needed query language! Type 'exit' or 'quit' to leave.";
  let sql = "table='Products' get all where 'CategoryId' == 1;" in
  Printf.printf "Input: %s\n" sql;
  let tokens = tokenize sql in
  Printf.printf "Tokens: ";
  List.iter print_token tokens;
  print_endline "";


