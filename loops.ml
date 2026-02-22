(* 
  Örnek döngü kullanımları.

  Bir listeyi belli aralıktaki rastgele sayılarla doldurmak.
  İki boyutlu bir diziyi belli aralıktaki rastgele sayılarla doldurmak.
  Basit bir sayaç oluşturmak ve artırmak.
*)

(*
  En basit işlevlerle başlayalım. 
  Otomatik artan bir sayaç için for ve while döngülerini ayrı ayrı kullanalım.
*)

let count_for n =
  for i = 1 to n do
    Printf.printf "%d," i
  done;
  Printf.printf "\n"
;;

let count_while n =
  let i = ref 1 in
  while !i <= n do
    Printf.printf "%d," !i;
    i := !i + 1
  done;
  Printf.printf "\n"
;;

count_for 5;;
count_while 10;;

(* 

Bir listeyi belli aralıktaki rastgele sayılarla doldurmak. 
Bunu parametrik bir fonksiyon ile yapalım. 
Kaç elemanlı bir liste istediğimizi parametre olarak alalım ve geriye o kadar rastgele sayı içeren bir liste döndürelim.

*)

let generate_random_list n =
  Random.self_init (); (* Rastgele sayı üreteciyi başlat *)
  let numbers = ref [] in
  for i = 1 to n do
    let random_number = Random.int 100 in
    numbers := random_number :: !numbers
  done;
  !numbers

let random_numbers = generate_random_list 10;;

Printf.printf "Random numbers: %s\n" (String.concat "; " (List.map string_of_int random_numbers));;

(* Aynı fonksiyonu birde while döngüsü ile yazmaya çalışalım *)
let generate_random_list_while n =
  Random.self_init ();
  let numbers = ref [] in
  let i = ref 1 in
  while !i <= n do
    let random_number = Random.int 100 in
    numbers := random_number :: !numbers;
    i := !i + 1
  done;
  !numbers

let random_numbers_while = generate_random_list_while 10;;

Printf.printf "Random numbers (while): %s\n" (String.concat "; " (List.map string_of_int random_numbers_while));;

(*
  Bir fonksiyona parametre olarak gelen Array içerisindeki sayıların ortalamasını bulan bir fonksiyon yazalım.
  Sayı dizisini for döngüsü ile dönerek toplamını bulalım ve ardından ortalamayı hesaplayalım.
*)

let average arr = 
  let sum = ref 0 in
  for i = 0 to Array.length arr - 1 do
    sum := !sum + arr.(i)
  done;
  float_of_int !sum /. float_of_int (Array.length arr)

let arr = generate_random_list 10 |> Array.of_list;;
Printf.printf "Average: %f\n" (average arr);;

(* 
  let himm = "Bu örneklerde for ve while döngülerini kullanarak listeler ve diziler üzerinde işlemler yaptık.";;
  let avg = average himm;; 
*)

(* 
  Şimdide değerleri 0 veya 1'lerden oluşan ve verdiğimiz satır sütun sayısına göre 
  iki boyutlu dizi oluşturan bir fonksiyon yazalım.
*)

let generate_matrix row_count col_count =
  Random.self_init ();
  let matrix = Array.make_matrix row_count col_count 0 in
  for i = 0 to row_count - 1 do
    for j = 0 to col_count - 1 do
      matrix.(i).(j) <- Random.int 2
    done;
  done;
  matrix

let matrix = generate_matrix 5 8;;
Printf.printf "Generated Matrix:\n";
Array.iter (fun row ->
  Array.iter (fun value -> Printf.printf "%d " value) row;
  Printf.printf "\n"
) matrix;;