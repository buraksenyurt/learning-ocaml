(*  Aboneleri bir Record tipi olarak tanımladık *)
type subscriber ={
  id:int;
  name:string;
  email:string;
}

(* 
  Liste türünden hayali bir veritabanı ya da mock liste.
*)
let database = [
  {id=1001; name="John Doe"; email="john.doe@azon.com"};
  {id=1002; name="Jane Doe"; email="jane.doe@azon.com"};
  {id=1003; name="Mario"; email="mario@azon.com"};
]

(*
  Abone ID'sine göre abone arayan bir fonksiyon.
  Eğer abone bulunursa Some subscriber döner, bulunmazsa None döner.

  Özellikle fonksiyonun dönüş tipine dikkat edelim: subscriber option. 
  Bu, fonksiyonun ya bir subscriber döndüreceği ya da hiçbir şey döndürmeyeceği anlamına gelir.
*)
let rec find_subscriber_by_id id subscribers =
  match subscribers with
  | [] -> None
  | current :: rest ->
      if current.id = id then Some current
      else find_subscriber_by_id id rest

(*
  Burada derleyici bizi tüm senaryolara bakmaya zorlar.
*)
let say_hello id = let result = find_subscriber_by_id id database in
  match result with
  | Some subscriber -> Printf.sprintf "Hello, %s!" subscriber.name
  | None -> "Subscriber not found."

(* Test *)
let () =
  let message1 = say_hello 1002 in
  let message2 = say_hello 9999 in
  print_endline message1;  (* Output: Hello, Jane Doe! *)
  print_endline message2   (* Output: Subscriber not found. *) 
