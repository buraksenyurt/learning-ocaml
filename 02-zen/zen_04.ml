(*
  CURRENCY isimli bir modül tanımladık ama bunu bir sözleşme/contract gibi düşünelim.

  Bu sözleşmeye göre var olan bir t tipi için,
  create fonksiyonu float türünden bir değer alarak t türünden bir değer döndürmeli,
  value fonksiyonu t türünden bir değer alarak float türünden bir değer döndürmeli,
  add fonksiyonu ise iki t türünden değer alarak t türünden bir değer döndürmeli.

  Biraz generic constraint'leri hatırlatıyor gibi ;)
*)
module type CURRENCY = sig
  type t
  val create : float -> t
  val value : t -> float
  val add : t -> t -> t
end

(*
  Para birimi için CURRENCY isimli bir sözleşmemiz var.
  Buna göre Euro, Dolar ve Sterlin implementasyonları yapabiliriz.
*)
module Euro : CURRENCY = struct
  type t = float
  let create x = x
  let value x = x
  let add x y = x +. y
end

module Dollar : CURRENCY = struct
  type t = float
  let create x = x
  let value x = x
  let add x y = x +. y
end

module Sterlin : CURRENCY = struct
  type t = float
  let create x = x
  let value x = x
  let add x y = x +. y
end

(*
  Şimdi bu para birimlerinden birkaç değer tanımlayalım
  birbirleriyle toplama işlemi yapmaya çalışalım.
*)
let payment_limit = Euro.create 1000.0
let payment_limit2 = Dollar.create 750.0 
let payment_limit3 = Sterlin.create 650.0

let () =
  (* Aşağıdaki satır derlenmeyecektir çünkü farklı türler birbirleriyle toplanamaz *)
  (* let total_payment = Euro.add payment_limit payment_limit2 *)

  (* Ancak aşağıdaki kodlar sorunsuz bir şekilde çalışacaktır *)

  let total_payment_euro = Euro.add payment_limit (Euro.create 200.0) in
  Printf.printf "Total payment in Euro: %.2f\n" (Euro.value total_payment_euro);
  let total_payment_dollar = Dollar.add payment_limit2 (Dollar.create 150.0) in
  Printf.printf "Total payment in Dollar: %.2f\n" (Dollar.value total_payment_dollar)
