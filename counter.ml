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