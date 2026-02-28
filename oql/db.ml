(* Tablo adı gibi metinsel ve kategori numarası gibi tam sayıları karşılayan tipimiz. 
Şimdilik sadece string ve int türlerini destekliyor. *)
type value =
  | VString of string
  | VInt of int

(* Bir tablo satırını tarifledik. value türünden bir liste olarak temsil ediliyor. *)
type row = (string * value) list

(* Bir veritabanını tarifledik. tablo adı ve tablo satırlarının listesi olarak temsil ediliyor. *)
type database = (string * row list) list