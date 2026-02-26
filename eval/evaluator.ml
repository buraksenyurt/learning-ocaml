(*
  Örneğimizde çok basit bir yorumlayıcı(Interpretter) yazmaya çalışıyoruz.
  Klasik örnek olarak dört işlemi ele alabiliriz.
*)

(*
  expression dört işlemli bir ifade ağacını tanımlanıyor. 
  Recursive olarak tanımlanmış bir veri yapısı olduğundan bir ifadenin bir alt ifadesi de başka bir ifade olabilir.
  Böylece sonsuz sayıda işlemi içeren karmaşık ifadeler oluşturulabilir.
*)
type expression = 
  | Value of int
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
  dune exec ./evaluator.exe
*)
let rec eval expr =
  match expr with
  | Value n -> n
  | Add (e1, e2) -> eval e1 + eval e2
  | Sub (e1, e2) -> eval e1 - eval e2
  | Mul (e1, e2) -> eval e1 * eval e2
  | Div (e1, e2) ->
      let denominator = eval e2 in
      if denominator = 0 then
        failwith "Division by zero"
      else
        eval e1 / denominator

(*
  3 + 4 * (2 - 1) ifadesini, expression veri yapısı ile belirttiğimiz AST'te dönüştürmek için
  bir Lexical Analysis ve Parsing adımlarına gerek var. Öncelikle metinsel ifade parçlarını birer token
  olarak ele almamız lazım.

  Yani sayılar bir token, +, -, *, /, (, ) gibi semboller de ayrı token'lar olarak tanımlanmalı.
  Bu veri yapsını aşağıdaki gibi bir tip olarak tanımlayabiliriz.
*)
type token =
  |TNumber of int
  |TPlus
  |TMinus
  |TStar
  |TSlash
  |TLParen
  |TRParen

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
    if pos >=length then List.rev acc (* Eğer tüm karakterler işlendi ise, token listesini ters çevirip döndürür. *)
    else match str.[pos] with
      | ' ' | '\t'| '\n' -> aux (pos + 1) acc (* Eğer boşluk, tab veya yeni satır karakteri ise, atla ve devam et *)
      | '+' -> aux (pos + 1) (TPlus :: acc)
      | '-' -> aux (pos + 1) (TMinus :: acc)
      | '*' -> aux (pos + 1) (TStar :: acc)
      | '/' -> aux (pos + 1) (TSlash :: acc)
      | '(' -> aux (pos + 1) (TLParen :: acc)
      | ')' -> aux (pos + 1) (TRParen :: acc)
      | '0'..'9' -> 
        (*
          Tabi sayısal bir ifade ile karşılaştıysak tüm basamaklarını okumak gerekiyor.
          Örneğin "123" ifadesi tek bir token olarak ele alınmalı, üç ayrı token olarak değil.
          Bu yüzden sayısal karakterler okundukça bir sonraki karakterin sayı olup olmadığını kontrol eden 
          bir başka recursive fonksiyon söz konusu.
        *)
          let rec read_number digit = 
            if digit<length && str.[digit] >= '0' && str.[digit] <= '9' then
              read_number (digit + 1)
            else
              digit
            in
          let end_pos = read_number pos in
          let number_str = String.sub str pos (end_pos - pos) in
          let number = int_of_string number_str in
          aux end_pos (TNumber number :: acc)
      | c -> failwith (Printf.sprintf "Unexpected character: '%c'" c)
  in
  aux 0 []

(*
  Ana program kodumuz da burada başlıyor.
*)
let () =
  (* Birkaç örnek ifade oluşturup eval ile değerlendirelim *)
  let expr1 = Add (Value 4, Value 5) in
  let expr2 = Sub (Value 10, Value 3) in
  let expr3 = Mul (Value 2, Value 6) in
  let expr4 = Div (Value 8, Value 2) in
  let expr5 = Add (Mul (Value 3, Value 4), Sub (Value 10, Value 2)) in

  Printf.printf "4 + 5 = %d\n" (eval expr1);
  Printf.printf "10 - 3 = %d\n" (eval expr2);
  Printf.printf "2 * 6 = %d\n" (eval expr3);
  Printf.printf "8 / 2 = %d\n" (eval expr4);
  Printf.printf "3 * 4 + (10 - 2) = %d\n" (eval expr5);

  (* let expr5 = Div (Value 8, Value 0) in*)
  (* Aşağıdaki ifade sıfıra bölme hatası verir *)
  (* Printf.printf "8 / 0 = %d\n" (eval expr5) *)

  (*
    Pek tabi kullanıcılar AST formatında değil aşağıdaki gibi metinsel ifadeler girer.
  *)
  let input = "3 + 4 * (2 - 1)" in
  Printf.printf "Input: %s\n" input;
  
  (* Tokenları alıyoruz*)
  let tokens = tokenizer input in
  
  Printf.printf "Tokens: ";
  List.iter (function 
    | TNumber n -> Printf.printf "TNumber(%d) " n
    | TPlus -> Printf.printf "TPlus "
    | TMinus -> Printf.printf "TMinus "
    | TStar -> Printf.printf "TStar "
    | TSlash -> Printf.printf "TSlash "
    | TLParen -> Printf.printf "TLParen "
    | TRParen -> Printf.printf "TRParen ") tokens;
  Printf.printf "\n"