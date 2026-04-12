(*Saf fonksiyonel yaklaşım*)
let rec sum list = function 
  | [] -> list 
  | x :: xs -> sum (list + x) xs

(* Pragmatik yaklaşım *)
let incrementer () =
  let count = ref 0 in
  fun () -> 
    count := !count + 1;
    !count

let () =
  let inc = incrementer () in
  print_endline (string_of_int (inc ()));
  print_endline (string_of_int (inc ()));
  print_endline (string_of_int (inc ()))