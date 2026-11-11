(* float sayılardan oluşan bir array tanımı*)
let points = [| 45.50; 30.25; 60.75; 48.90; 80.; 0.; |];;

(* array operatörlerine erişim *)
Printf.printf "First point: %.2f\n" points.(0);;
Printf.printf "Second point: %.2f\n" points.(1);;

(* Bir array elementini değiştirmek istersek şöyle yapabiliriz *)
points.(0) <- 51.00;;
Printf.printf "Updated first point to: %.2f\n" points.(0);;

(* Array'in tamamını görüntülemek için *)
points;;

(* 
Belki bir döngü yardımıyla array elemanlarını görütülemek isteyebiriz
Hatta döngü içinde pattern match kullanıp dersten geçti, kaldı vs diyebiliriz
*)
for i = 0 to Array.length points - 1 do
  match points.(i) with
  | p when p >= 50.0 -> Printf.printf "Student %d passed with %.2f\n" (i + 1) p
  | p -> Printf.printf "Student %d failed with %.2f\n" (i + 1) p
done;;