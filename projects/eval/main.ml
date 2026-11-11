(*
  Hesap makinesinin kullanıcıyla etkileşen kısmı.
  Tüm hesaplama mantığı evaluator.ml (kütüphane) içinde, burada sadece REPL döngüsü var.

  Çalıştırmak için;
  dune exec ./main.exe
*)

(*
  clear_screen terminal ekranını temizler.
  Windows için cls, Unix tabanlı sistemler için clear komutu kullanılabilir.
  Programın hangi işletim sisteminde çalıştığını kontrol etmek için
  Sys modülündeki os_type değerini kullandık.
  Sys modülü için -> https://ocaml.org/manual/5.4/api/Sys.html
*)
let clear_screen () =
  let command =
    if Sys.os_type = "Win32" || Sys.os_type = "Cygwin" then "cls" else "clear"
  in
  ignore (Sys.command command)

(*
  repl fonksiyonu bildiğimiz Read-Eval-Print Loop (REPL) döngüsünü sağlar.
  Böylece komut satırından sürekli hesaplama için girdi alınabilir.

  Fonksiyon recursive olarak tanımlanmıştır. Dikkat edilirse repl() çağrıları try ... with
  bloğunun DIŞINDA yapılıyor. try bloğu içinde yapılan bir recursive çağrı tail call olmaz,
  çünkü her çağrı için bir hata yakalayıcı (exception handler) yığında bekler. Çok uzun bir
  oturumda bu durum yığının büyümesine yol açardı. Bunun yerine try bloğu sadece bir sonraki
  adımın ne olacağını (Continue veya Stop) üretiyor ve recursive çağrı en sonda yapılıyor.
*)
type next = Continue | Stop

let rec repl () =
  print_string "Calculator> ";
  flush stdout;
  let next =
    try
      match String.trim (read_line ()) with
      | "exit" | "quit" -> Stop
      | "cls" | "clear" ->
          clear_screen ();
          Continue
      | "" ->
          Continue (* Boş giriş yapıldığında tekrar prompt göstermesi için *)
      | input ->
          Printf.printf "Result: %d\n" (Evaluator.evaluate input);
          Continue
    with
    (*
      Hesaplama sırasında olası hatalar olabilir.
      Örneğin sıfıra bölme veya sözdizimi hatası gibi - diyelim ki eksik parantez var veya geçersiz bir karakter.
      Böyle bir durumda programın çökmesi yerine hatayı yakalayıp kullanıcıya bir mesaj gösteriyor
      ve REPL döngüsüne devam ediyoruz.
    *)
    | Failure msg ->
        Printf.printf "Error: %s\n" msg;
        Continue
    (*
      Ctrl+D (Unix) veya Ctrl+Z (Windows) ile girdi akışı kapatıldığında read_line
      End_of_file istisnası fırlatır. Bunu yakalamazsak program çöker.
    *)
    | End_of_file ->
        print_newline ();
        Stop
  in
  match next with Continue -> repl () | Stop -> print_endline "Goodbye!"

(*
  Ana program kodu repl fonksiyonunu çağırarak
  kullanıcıdan girdi almaya başlar.
*)
let () =
  print_endline
    "Welcome to the simple OCaml calculator! Type 'exit' or 'quit' to leave.";
  repl ()
