let generate_random_list n =
  Random.self_init ();
  let numbers = ref [] in
  for _ = 1 to n do
    let random_number = Random.int 100 in
    numbers := random_number :: !numbers
  done;
  !numbers

let () = 
  let random_numbers = generate_random_list 10 in
  Printf.printf "Random numbers: %s\n" (String.concat "; " (List.map string_of_int random_numbers))
