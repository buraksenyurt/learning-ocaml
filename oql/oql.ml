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

type operator =
  | Eq
  | Neq

type value = 
  | VString of string
  | VInt of int

type condition = {
  column: string;
  op:operator;
  target: value;
}

type query = {
  table_name:string;
  is_get_all: bool;
  condition: condition option;
}

let () =
  print_endline "Welcome to the You ain't gonna needed query language! Type 'exit' or 'quit' to leave.";
