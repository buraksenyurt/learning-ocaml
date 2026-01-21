(* 
    Bu bir hello world uygulaması ve burası da bir yorum satırı.
    Bu kodu doğrudan çalıştırmak için komut satırından;
    
    ocaml hello-world.ml

    yazmak yeterli.
*)
let () = print_endline "Hello from OCAML world!"
let my_name = "Burak Selim"
let () = Printf.printf "Welcome a board '%s'\n" my_name