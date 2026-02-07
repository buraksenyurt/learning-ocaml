(*
  Bir sayaç gerçek zamanlı güncellemeyi gerektirir. Bu nedenle immutable olarak kullanmak,
  sürekli yeni bir kopya oluşturmaya neden olabilir ve bu da performans açısından iyi değildir.
  Dolayısıyla OCaml gibi varsayılan olarak immutability felsefesini benimsemiş diller için,
  sayaç mekanizması güzel bir mutable olma örneğidir.
*)
type counter = {
  mutable count: int;
};;

let tick_counter = { count = 0 };;

let increment (crt: counter) =
  crt.count <- crt.count + 1
;;

increment tick_counter;;
increment tick_counter;;
increment tick_counter;;

Printf.printf "Current count: %d\n" tick_counter.count;;

(* 
  Bir sayaç söz konusu olduğunda stdlib ile gelen ref isimli record'da kullanılabilir.
  ! , ile değer okuma ve := ile değer atama işlemi yapılır.
  Ayrıca incr ve decr fonksiyonları da ref türü için tanımlanmıştır ve bunlar sırasıyla değeri 1 artırır veya azaltır.
  Örnek kullanım;
*)
let counter = ref 0;;
Printf.printf "Counter: %d\n" !counter;;
counter := !counter + 1;;
Printf.printf "Counter: %d\n" !counter;;
incr counter;;
Printf.printf "Counter: %d\n" !counter;;
decr counter;;
Printf.printf "Counter: %d\n" !counter;;

(*
  İstersek buradaki ref record yapısını kendimiz de yapabiliriz.
  Burada polimorfik bir record yapısı tanımlayarak herhangi bir türdeki değeri mutable olarak tutabiliriz.

  'a ifadesi, OCaml'da polimorfik tür parametresini temsil eder. 
  Bu, mutable_ref türünün herhangi bir türdeki değeri tutabileceği anlamına gelir. 
  x ile başlatılan mutable_ref fonksiyonu, verilen değeri mutable_ref türünde bir record olarak döndürür.
*)
type 'a mutable_ref = {
  mutable value: 'a;
};;
let mutable_ref x = { value = x };;
let get r = r.value;;
let set r x = r.value <- x;;
let incr r = r.value <- r.value + 1;;
let decr r = r.value <- r.value - 1;;

(* Deneyelim bakalım *)
let my_counter = mutable_ref 0;;
Printf.printf "My Counter: %d\n" (get my_counter);;
incr my_counter;;
Printf.printf "My Counter: %d\n" (get my_counter);;
set my_counter 10;;
Printf.printf "My Counter: %d\n" (get my_counter);;
decr my_counter;;
Printf.printf "My Counter: %d\n" (get my_counter);;

(*
  ref türü iterasyonlarda state'in değişmesi gereken durumlarda da ele alınabilir.
  Örneğin bir listedeki elemanların ortalamasını hesaplayacak bir fonksiyon geliştirelim.
*)
let avrage lst =
  let sum = ref 0 in
  let count = ref 0 in
  List.iter (fun x -> sum := !sum + x; count := !count + 1) lst;
  if !count = 0 then None else Some (!sum / !count)

let numbers = [1; 2; 3; 4; 5; 10;];;
Printf.printf "Average: %d\n" (match avrage numbers with Some avg -> avg | None -> 0);;
