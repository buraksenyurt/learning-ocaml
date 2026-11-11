(*
  Bu seferki örnek eval programından da esinlenerek aşağıdaki ifadeyi
    yorumlayabilecek bir Read-Eval-Print Loop (REPL) döngüsü geliştirmek.

  table='Products' get all where 'CategoryId' == 1;
  table='Products' get all where 'Name' == 'Phone';

  Yine Abstract Syntax Tree (AST), Lexer ve Parser gibi bileşenler de kullanılacak.
  REPL döngüsü main.ml dosyasında yer alıyor (dune exec ./main.exe), testler ise test_oql.ml içinde (dune test).

  eval örneğinden farklı olarak burada hatalar failwith ile istisna (exception) fırlatılarak değil,
  result tipiyle ele alınıyor. Yani tokenize, parse ve execute fonksiyonları ya Ok değer ya da
  Error mesaj döndürüyor. Böylece bir fonksiyonun hata üretebileceği imzasından da anlaşılıyor:

    tokenize : string -> (token list, string) result

  Option tipinde olduğu gibi derleyici bizi her iki durumu da ele almaya zorluyor.
*)

(*
  let* operatörü (binding operator), Result.bind fonksiyonunun kısa yazımıdır.

    let* x = f () in g x

  ifadesi f () Ok x döndürürse g x'i çalıştırır, Error e döndürürse zinciri keser ve Error e döndürür.
  Bu sayede hata kontrollerini iç içe match blokları yazmadan arka arkaya sıralayabiliyoruz.
*)
let ( let* ) = Result.bind

(*
  Öncelikle sorgu ifadesinin tip güvenli bir veri modelini oluşturmamız lazım.
  Örneğin == != gibi operatörleri, string ve int gibi değer türlerini,
  where kısmını temsil edecek bir condition yapısını ve 
  tüm sorguyu temsil edecek bir query yapısını tanımlamalıyız.
  Bunların her biri birer type olarak oluşturulabilir.
*)

(* Şimdilik == ve != operatörlerini destekliyor *)
type operator = Eq | Neq

(*
  condition yapısı, bir sütun adı, bir operatör ve bir hedef değer içerir.
  Örneğin 'CategoryId' == 1 ifadesi aşağıdaki gibi temsil edilir;

  { column = "CategoryId"; op = Eq; target = Db.VInt 1 }
*)
type condition = { column : string; op : operator; target : Db.value }

(*
  Bu kısımda sorgunun tamamını temsil eder. 
  Örneğin table='Products' get all where 'CategoryId' == 1 ifadesi aşağıdaki gibi temsil edilir,
{
  table_name = "Products";
  condition = Some { column = "CategoryId"; op = Eq; target = Db.VInt 1 }
}
  Dil şu an için sadece 'get all' ifadesini desteklediğinden ayrıca bir is_get_all alanı tutmuyoruz.
  İleride 'get 'Name', 'Id'' gibi belirli sütunları seçme desteği gelirse buraya bir alan eklenebilir.
*)
type query = {
  table_name : string;
  condition : condition option;
      (* Opsiyonel bir condition tanımı. Zira where ifadesi her zaman gerekli olmayabilir.*)
}

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
  | TSemicolon
    (* ; karakterini temsil eder ki bununla ifadenin sonunu belirtiyoruz *)
  | TIdentifier of string
(* Tırnaksız yazılan ve keyword olmayan kelimeleri temsil eder. Parser bunları anlamlı bir hata mesajı vermek için kullanır *)

(*
  Lexer için bazı yardımcı fonksiyonlar lazım. Örneğin karakterin harf olup olmadığını kontrol eden bir fonksiyon gibi.
*)
let is_letter c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
let is_digit c = c >= '0' && c <= '9'

(*
  ve tabii işin en karmaşık kısımlarından olan tokenizer fonksiyonu. Yani, gelen string ifadeyi token'lara dönüştüren fonksiyon.
  Örneğin "table='Products' get all where 'CategoryId' == 1;" ifadesi
[TTable; TAssign; TString "Products"; TGet; TAll; TWhere; TString "CategoryId"; TEq; TInt 1; TSemicolon]
şeklinde bir token listesine dönüştürülebilmeli.

  Fonksiyon başarılı olursa Ok token_listesi, hatalı bir karakterle karşılaşırsa Error mesaj döndürür.
  aux fonksiyonundaki tüm recursive çağrılar son işlem olduğu için (tail call) uzun girdilerde de yığın büyümez.
*)
let tokenize str : (token list, string) result =
  let length = String.length str in

  let rec aux index acc =
    if index >= length then Ok (List.rev acc)
    else
      match str.[index] with
      | ' ' | '\t' | '\n' | '\r' -> aux (index + 1) acc
      | ';' -> aux (index + 1) (TSemicolon :: acc)
      | '!' ->
          if index + 1 < length && str.[index + 1] = '=' then
            aux (index + 2) (TNeq :: acc)
          else
            Error (Printf.sprintf "Unexpected character '!' at index %d" index)
      | '=' ->
          if index + 1 < length && str.[index + 1] = '=' then
            aux (index + 2) (TEq :: acc)
          else aux (index + 1) (TAssign :: acc)
      | '\'' ->
          let rec read_string j =
            if j < length && str.[j] <> '\'' then read_string (j + 1) else j
          in

          let end_index = read_string (index + 1) in
          (* Kapanış tırnağını bulamadan metnin sonuna geldiysek string kapatılmamış demektir *)
          if end_index >= length then
            Error
              (Printf.sprintf "Unterminated string starting at index %d" index)
          else
            let content = String.sub str (index + 1) (end_index - index - 1) in
            aux (end_index + 1) (TString content :: acc)
      | c when is_letter c ->
          let rec read_word j =
            if
              j < length
              && (is_letter str.[j] || is_digit str.[j] || str.[j] = '_')
            then read_word (j + 1)
            else j
          in

          let end_index = read_word index in
          let word = String.sub str index (end_index - index) in

          let token =
            match String.lowercase_ascii word with
            | "table" -> TTable
            | "get" -> TGet
            | "all" -> TAll
            | "where" -> TWhere
            | _ -> TIdentifier word
          in
          aux end_index (token :: acc)
      | c when is_digit c ->
          let rec read_num j =
            if j < length && is_digit str.[j] then read_num (j + 1) else j
          in

          let end_index = read_num index in
          let num = int_of_string (String.sub str index (end_index - index)) in

          aux end_index (TInt num :: acc)
      | c -> Error (Printf.sprintf "Invalid character %c" c)
  in
  aux 0 []

(*
  Token listesini alıp query veri yapısına dönüştüren parser fonksiyonları.
  Örneğin [TTable; TAssign; TString "Products"; TGet; TAll; TWhere; TString "CategoryId"; TEq; TInt 1; TSemicolon]
  token listesi aşağıdaki query yapısına dönüştürülebilmeli.
  {
    table_name = "Products";
    condition = Some { column = "CategoryId"; op = Eq; target = VInt 1 }
  }

  Önce küçük yardımcılar: Bir token'ı operatöre ve değere çeviren fonksiyonlar.
  Bunlar option döndürür; token beklenen türde değilse None.
  Değer olarak hem TInt hem de TString kabul edildiği için where 'Name' == 'Phone' gibi
  metinsel karşılaştırmalar da yapılabiliyor.
*)
let operator_of_token = function TEq -> Some Eq | TNeq -> Some Neq | _ -> None

let value_of_token = function
  | TInt n -> Some (Db.VInt n)
  | TString s -> Some (Db.VString s)
  | _ -> None

(* 'get all' sonrasında gelen kısmı (opsiyonel where ve ;) çözümler *)
let parse_where tokens : (condition option, string) result =
  match tokens with
  | [ TSemicolon ] -> Ok None
  | [] -> Error "Syntax error: Missing ';' at the end of the query!"
  | [ TWhere; TString column; op_token; value_token; TSemicolon ] -> (
      match (operator_of_token op_token, value_of_token value_token) with
      | Some op, Some target -> Ok (Some { column; op; target })
      | None, _ -> Error "Syntax error in WHERE clause: Expected '==' or '!='!"
      | _, None ->
          Error
            "Syntax error in WHERE clause: Expected a number or a quoted \
             string!")
  | [ TWhere; TString _; _; _ ] ->
      Error "Syntax error: Missing ';' at the end of the query!"
  | TWhere :: TIdentifier name :: _ ->
      Error
        (Printf.sprintf
           "Syntax error in WHERE clause: Column names must be quoted, e.g. \
            '%s'"
           name)
  | _ -> Error "Syntax error in WHERE clause!"

let parse token_list : (query, string) result =
  match token_list with
  | TTable :: TAssign :: TString table_name :: TGet :: TAll :: rest ->
      let* condition = parse_where rest in
      Ok { table_name; condition }
  | _ ->
      Error
        "Syntax error: Expected 'table=...' followed by 'get all' and optional \
         'where' clause!"

(*
  Bir satırın koşulu sağlayıp sağlamadığını kontrol eder.
  Önce sütun değeri ile hedef değerin aynı türde olduğundan emin oluyoruz. Türler uyuşuyorsa
  OCaml'ın yapısal eşitlik (=) operatörü VInt ve VString değerlerini doğrudan karşılaştırabildiği için
  her tür için ayrı bir dal yazmamıza gerek kalmıyor.
  Satırda ilgili sütun hiç yoksa satır koşulu sağlamıyor kabul edilir.
*)
let check_condition (r : Db.row) (cond : condition) : (bool, string) result =
  match List.assoc_opt cond.column r with
  | None -> Ok false
  | Some v -> (
      match (v, cond.target) with
      | Db.VInt _, Db.VInt _ | Db.VString _, Db.VString _ -> (
          match cond.op with
          | Eq -> Ok (v = cond.target)
          | Neq -> Ok (v <> cond.target))
      | _ ->
          Error
            (Printf.sprintf "Type mismatch in condition for column '%s'"
               cond.column))

(*
  Satırları koşula göre süzer. check_condition hata döndürebildiği için List.filter yerine
  List.fold_left ile ilerliyor ve ilk hatada zinciri kesiyoruz.
*)
let filter_rows cond rows : (Db.row list, string) result =
  let* kept =
    List.fold_left
      (fun acc r ->
        let* kept = acc in
        let* matches = check_condition r cond in
        Ok (if matches then r :: kept else kept))
      (Ok []) rows
  in
  Ok (List.rev kept)

let execute (q : query) (db : Db.database) : (Db.row list, string) result =
  match List.assoc_opt q.table_name db with
  | None ->
      Error (Printf.sprintf "Table '%s' not found in database!" q.table_name)
  | Some rows -> (
      match q.condition with
      | Some cond -> filter_rows cond rows
      | None -> Ok rows)

(*
  Metinsel bir sorguyu baştan sona işleyen giriş noktası.
  let* sayesinde tokenize -> parse -> execute adımları sırayla çalışır,
  herhangi biri Error döndürürse sonraki adımlar hiç çalışmaz.
*)
let run (db : Db.database) (input : string) : (Db.row list, string) result =
  let* tokens = tokenize input in
  let* query = parse tokens in
  execute query db

(* REPL ve testlerde satırları yazdırmak için yardımcı fonksiyonlar *)
let string_of_value = function
  | Db.VInt n -> string_of_int n
  | Db.VString s -> "'" ^ s ^ "'"

let string_of_row (r : Db.row) =
  r
  |> List.map (fun (column, v) -> column ^ "=" ^ string_of_value v)
  |> String.concat ", "
