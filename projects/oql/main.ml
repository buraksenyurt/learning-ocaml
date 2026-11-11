(*
  OQL sorgularını komut satırından denemek için basit bir REPL.

  Çalıştırmak için;
  dune exec ./main.exe

  Örnek sorgular;
  table='Products' get all;
  table='Products' get all where 'CategoryId' == 1;
  table='Products' get all where 'Name' != 'Phone';
*)

(* Örnek bir veritabanı. Gerçek bir veri kaynağı yerine bellekte duran listeler kullanıyoruz. *)
let sample_db : Db.database =
  [ ( "Products",
      [ [ ("Id", Db.VInt 1); ("Name", Db.VString "Laptop"); ("CategoryId", Db.VInt 1) ];
        [ ("Id", Db.VInt 2); ("Name", Db.VString "Phone"); ("CategoryId", Db.VInt 1) ];
        [ ("Id", Db.VInt 3); ("Name", Db.VString "Table"); ("CategoryId", Db.VInt 2) ] ] );
    ( "Categories",
      [ [ ("Id", Db.VInt 1); ("Name", Db.VString "Electronics") ];
        [ ("Id", Db.VInt 2); ("Name", Db.VString "Furniture") ] ] ) ]

let print_rows rows =
  match rows with
  | [] -> print_endline "(no rows)"
  | _ ->
      List.iter (fun r -> print_endline (Oql.string_of_row r)) rows;
      Printf.printf "(%d row(s))\n" (List.length rows)

(*
  Oql.run bir result döndürdüğü için hata yönetimi için try ... with gerekmiyor.
  Ok ve Error dallarını pattern matching ile ele almak yeterli.
  Sadece read_line'ın Ctrl+D (Unix) / Ctrl+Z (Windows) ile fırlattığı End_of_file istisnasını yakalıyoruz.
*)
let rec repl () =
  print_string "oql> ";
  flush stdout;
  match read_line () with
  | exception End_of_file -> print_endline "\nGoodbye!"
  | line -> (
      match String.trim line with
      | "exit" | "quit" -> print_endline "Goodbye!"
      | "" -> repl ()
      | input ->
          (match Oql.run sample_db input with
          | Ok rows -> print_rows rows
          | Error msg -> Printf.printf "Error: %s\n" msg);
          repl ())

let () =
  print_endline "Welcome to OQL! Tables: Products, Categories. Type 'exit' or 'quit' to leave.";
  repl ()
