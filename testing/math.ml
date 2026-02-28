(*
  Birim testlerini yazacağımız birkaç matematiksel fonksiyonun 
  yer aldığı kobay modülümüz.
  Klasik dört işlem yerine, bir sayının faktöriyelini hesaplayan bir fonksiyon ve
  bir sayının n'inci kuvvetini hesaplayan bir fonksiyon tanımlayalım.
*)

(* Faktöriyel hesaplama fonksiyonu *)
let rec factorial n =
  if n < 0 then failwith "Negative input not allowed for factorial"
  else if n = 0 then 1
  else n * factorial (n - 1)

(* Üs alma fonksiyonu *)
let rec power base exp =
  if exp < 0 then failwith "Negative exponent not allowed"
  else if exp = 0 then 1
  else base * power base (exp - 1)
