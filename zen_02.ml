let big_data = [|10.4; 20.5; 30.6; 1.0; 3.14 |]

let scale_data factor data =
  for i = 0 to Array.length data - 1 do
    data.(i) <- data.(i) *. factor
  done

let () =
  print_endline "Original data:";
  Array.iter (Printf.printf "%.2f ") big_data;
  print_endline "\nScaling data by a factor of 2.0...";
  scale_data 2.0 big_data;
  print_endline "Scaled data:";
  Array.iter (Printf.printf "%.2f ") big_data;
  print_endline ""
