let greetings = function
  | "" -> "Hello, World!"
  | name -> Printf.sprintf "Hello, %s!" name

let () = greetings "Van Damme" |> print_endline
let () = greetings "" |> print_endline