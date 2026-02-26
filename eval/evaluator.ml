(*
  Örneğimizde çok basit bir yorumlayıcı(Interpretter) yazmaya çalışıyoruz.
  Klasik örnek olarak dört işlemi ele alabiliriz.

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