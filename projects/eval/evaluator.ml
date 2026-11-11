(*
  Örneğimizde çok basit bir yorumlayıcı(Interpretter) yazmaya çalışıyoruz.
  Klasik örnek olarak dört işlemi ele alabiliriz.

  Bu dosya bir kütüphane (library) olarak derlenir. Böylece tokenizer, parser ve eval
  fonksiyonları test_evaluator.ml içinden birim testlerle doğrulanabilir.
  Kullanıcıyla etkileşen REPL döngüsü ise main.ml dosyasındadır.
*)

(*
  expression dört işlemli bir ifade ağacını tanımlanıyor. 
  Recursive olarak tanımlanmış bir veri yapısı olduğundan bir ifadenin bir alt ifadesi de başka bir ifade olabilir.
  Böylece sonsuz sayıda işlemi içeren karmaşık ifadeler oluşturulabilir.
*)
type expression =
  | Value of int
  | Neg of expression (* Tekli eksi (unary minus). Örneğin -5 veya -(2+3) *)
  | Add of expression * expression
  | Sub of expression * expression
  | Mul of expression * expression
  | Div of expression * expression

(*
  expression isimli veri tipini parametre olarak alıp pattern-matching
  ile yorumlayan bir eval fonksiyonu.

  Dikkat edileceği üzere eval fonksiyonu rec keyword ile tanımlanmıştır.
  Bu, fonksiyonun recursive olduğunu yani kendisini çağırabileceğini belirtir.

  Kod expr ile gelen ifadeyi alır ve match bloğunda türüne göre bir işle gerçekleştirir.
  Eğer expr bir Value ise, içindeki sayıyı döndürür. 
  Dolayısıyla örneğin 4+5 ifadesi şu şekilde temsil edilir: Add (Value 4, Value 5)
  Sıfıra bölme durumunu ele almak içinse Div dalında bir başka kod bloğu ve if kontrolü eklenmiştir.

  Örneği build etmek için;
  dune build --display=verbose
  veya
  dune build
  
  Çalıştırmak için;
  dune exec ./main.exe

  Testleri çalıştırmak için;
  dune test
*)
let rec eval expr =
  match expr with
  | Value n -> n
  | Neg e -> -eval e
  | Add (e1, e2) -> eval e1 + eval e2
  | Sub (e1, e2) -> eval e1 - eval e2
  | Mul (e1, e2) -> eval e1 * eval e2
  | Div (e1, e2) ->
      let denominator = eval e2 in
      if denominator = 0 then failwith "Division by zero"
      else eval e1 / denominator

(*
  3 + 4 * (2 - 1) ifadesini, expression veri yapısı ile belirttiğimiz AST'te dönüştürmek için
  bir Lexical Analysis ve Parsing adımlarına gerek var. Öncelikle metinsel ifade parçlarını birer token
  olarak ele almamız lazım.

  Yani sayılar bir token, +, -, *, /, (, ) gibi semboller de ayrı token'lar olarak tanımlanmalı.
  Bu veri yapsını aşağıdaki gibi bir tip olarak tanımlayabiliriz.
*)
type token =
  | TNumber of int
  | TPlus
  | TMinus
  | TStar
  | TSlash
  | TLParen
  | TRParen

(* Hata mesajlarında token'ları okunabilir göstermek için yardımcı fonksiyon *)
let string_of_token = function
  | TNumber n -> string_of_int n
  | TPlus -> "+"
  | TMinus -> "-"
  | TStar -> "*"
  | TSlash -> "/"
  | TLParen -> "("
  | TRParen -> ")"

(*
  Tokenizer fonksiyonu str ile gelen String veri türünü alır ve bir token listesine dönüştürür.
  Örneğin "3 + 4 * (2 - 1)" ifadesi
  [TNumber 3; TPlus; TNumber 4; TStar; TLParen; TNumber 2; TMinus; TNumber 1; TRParen]
  şeklinde bir token listesine dönüştürülür.
*)
let tokenizer str =
  let length = String.length str in
  (* Yine recursive bir fonksiyonumuz var.
      pos parametresi şu anda hangi karakterin işlendiğini gösterir.
      acc ise şu ana kadar bulunan token'ların bir listesidir.
      aux isimli fonksiyonu herbir karakteri tek tek kontrol ederek token'ları oluşturur ve acc listesine ekler.
  *)
  let rec aux pos acc =
    if pos >= length then List.rev acc
      (* Eğer tüm karakterler işlendi ise, token listesini ters çevirip döndürür. *)
    else
      match str.[pos] with
      | ' ' | '\t' | '\n' ->
          aux (pos + 1) acc
          (* Eğer boşluk, tab veya yeni satır karakteri ise, atla ve devam et *)
      | '+' -> aux (pos + 1) (TPlus :: acc)
      | '-' -> aux (pos + 1) (TMinus :: acc)
      | '*' -> aux (pos + 1) (TStar :: acc)
      | '/' -> aux (pos + 1) (TSlash :: acc)
      | '(' -> aux (pos + 1) (TLParen :: acc)
      | ')' -> aux (pos + 1) (TRParen :: acc)
      | '0' .. '9' ->
          (*
          Tabi sayısal bir ifade ile karşılaştıysak tüm basamaklarını okumak gerekiyor.
          Örneğin "123" ifadesi tek bir token olarak ele alınmalı, üç ayrı token olarak değil.
          Bu yüzden sayısal karakterler okundukça bir sonraki karakterin sayı olup olmadığını kontrol eden 
          bir başka recursive fonksiyon söz konusu.
        *)
          let rec read_number digit =
            if digit < length && str.[digit] >= '0' && str.[digit] <= '9' then
              read_number (digit + 1)
            else digit
          in
          let end_pos = read_number pos in
          let number_str = String.sub str pos (end_pos - pos) in
          let number = int_of_string number_str in
          aux end_pos (TNumber number :: acc)
      | c -> failwith (Printf.sprintf "Unexpected character: '%c'" c)
  in
  aux 0 []

(*
  Parser fonksiyonu, token listesini expression veri yapısına dönüştürmek için kullanılmakta.
  Çok kullanılan bir örnek. Bu süreçte matematiksel işlem önceliklerini de dikkate almak gerekiyor.
  Örneğin, "3 + 4 * (2 - 1)" ifadesinde çarpma işlemi toplama işleminden önce gelmeli.
  Bunun için recursive descent parsing tekniği kullanılmakta. Burada grammer'in her bir kuralı için
  ayrı bir fonksiyon tanımlanır. Örneğin expression, term, factor gibi.
  Bir expression kuralı, term kuralını çağırabilir ve term kuralı da factor kuralını çağırabilir.
  Demek ki interpreter'ın grammer kurallarını tanımlaması ve 
  bu kurallara göre token listesini expression veri yapısına dönüştürmesi gerekiyor.
*)

let rec parser tokens =
  (* İlk olarak term kuralını çağırıyoruz. Ki term kuralı öncelikli olarak çarpma ve bölme işlemlerini ele almakta. *)
  let left_node, rest = parse_term tokens in
  parse_expr_tail left_node rest

(* parse_factor sayı, parantez ve tekli eksi gibi faktörleri ele alıyor. Bunu #1 seviye olarak düşünelim *)
and parse_factor tokens =
  match tokens with
  | TNumber n :: rest -> (Value n, rest)
  (*
    Tekli eksi: Bir faktörün başında gelen '-' işareti, ardından gelen faktörün negatifini alır.
    parse_factor'ı tekrar çağırdığımız için -5, -(2+3) ve hatta --5 gibi ifadeler de çözümlenir.
    Faktör seviyesinde olduğu için önceliği çarpma/bölmeden yüksektir: -2*3 = (-2)*3
  *)
  | TMinus :: rest ->
      let expr_node, rest_after_expr = parse_factor rest in
      (Neg expr_node, rest_after_expr)
  | TLParen :: rest -> (
      let expr_node, rest_after_expr = parser rest in
      match rest_after_expr with
      | TRParen :: final_rest -> (expr_node, final_rest)
      | _ -> failwith "Syntax error: ')' missing!")
  | _ -> failwith "Syntax error: Unexpected character or missing number!"

(* parse_term_tail çarpma ve bölme işlemlerini ele alıyor. Bunu #2 seviye olarak düşünelim *)
and parse_term tokens =
  let left_node, rest = parse_factor tokens in
  parse_term_tail left_node rest

and parse_term_tail left_node tokens =
  match tokens with
  | TStar :: rest ->
      let right_node, rest_after_right = parse_factor rest in
      parse_term_tail (Mul (left_node, right_node)) rest_after_right
  | TSlash :: rest ->
      let right_node, rest_after_right = parse_factor rest in
      parse_term_tail (Div (left_node, right_node)) rest_after_right
  | _ -> (left_node, tokens)

(* parse_expr_tail toplama ve çıkarma işlemlerini ele alıyor. Bunu #3 seviye olarak düşünelim *)
and parse_expr_tail left_node tokens =
  match tokens with
  | TPlus :: rest ->
      let right_node, rest_after_right = parse_term rest in
      parse_expr_tail (Add (left_node, right_node)) rest_after_right
  | TMinus :: rest ->
      let right_node, rest_after_right = parse_term rest in
      parse_expr_tail (Sub (left_node, right_node)) rest_after_right
  | _ -> (left_node, tokens)

(*
  parser fonksiyonu ifadenin başından itibaren okuyabildiği kadarını okur ve kalan token'ları da döndürür.
  Bu kalan token'lar parantez içi gibi alt ifadeler için gereklidir. Ancak en dış seviyede tüm girdinin
  tüketilmiş olması gerekir. Aksi halde "3 4" ifadesi 3, "(1+2))" ifadesi de 3 olarak hesaplanır ve
  fazladan yazılanlar sessizce yutulurdu. parse fonksiyonu bu kontrolü yapan giriş noktasıdır.
*)
let parse tokens =
  match parser tokens with
  | ast, [] -> ast
  | _, unexpected :: _ ->
      failwith
        (Printf.sprintf "Syntax error: Unexpected token '%s'"
           (string_of_token unexpected))

(* Metinsel bir ifadeyi tek adımda hesaplayan yardımcı fonksiyon. REPL ve testler bunu kullanır. *)
let evaluate input = input |> tokenizer |> parse |> eval
