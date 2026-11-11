(* Saf fonksiyonel yaklaşım.
   acc (accumulator) o ana kadarki toplamı taşır. Recursive çağrı son işlem
   olduğu için bu fonksiyon tail-recursive'dir. *)
let rec sum acc = function
  | [] -> acc
  | x :: xs -> sum (acc + x) xs

(* Pragmatik yaklaşım *)
let incrementer () =
  let count = ref 0 in
  fun () -> 
    count := !count + 1;
    !count

let () =
  print_endline (string_of_int (sum 0 [1; 2; 3; 4; 5]));
  let inc = incrementer () in
  print_endline (string_of_int (inc ()));
  print_endline (string_of_int (inc ()));
  print_endline (string_of_int (inc ()))