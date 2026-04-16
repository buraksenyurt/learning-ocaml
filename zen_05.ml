(*
  Öncelikle bir loglayıcının nasıl olması gerektiğini tarifleyelim.
  Bunu bir modül tanımı aracılığı ile yapabiliriz.
  Sözleşme üç fonksiyonu içeriyor: info, error ve warning.
  Ve üretilen diğer modüllerin bu fonksiyonları yazması gerekiyor.
*)
module type LOGGER = sig (* sig kelimesi signature' ın kısaltması *)
  val info : string -> unit
  val error : string -> unit
  val warning : string -> unit
end

(*
  Şimdi bu loglayıcıdan örnek iki loglayıcı hazırlayalım.
  Aslında LOGGER modülünden bir başka modül türetiyoruz gibi.

  ConsoleLogger bir struct 
  İçinde info, error ve warning isimli fonksiyonların asıl iş yapan sürümleri var.
*)
module ConsoleLogger : LOGGER = struct
  let info message = Printf.printf "[INFO] %s\n" message
  let error message = Printf.printf "[ERROR] %s\n" message
  let warning message = Printf.printf "[WARNING] %s\n" message

end

(*
  Aşağıdaki FileLogger modülü de LOGGER sözleşmesini uygulayan bir başka modül
  ve bu sefer log mesajlarını bir dosyaya yazacak şekilde tasarlanmış durumda.
*)
module FileLogger : LOGGER = struct
  let log_file = "log.txt"

  let log message =
    let oc = open_out_gen [Open_append; Open_creat] 0o666 log_file in
    output_string oc (message ^ "\n");
    close_out oc

  let info message = log ("[INFO] " ^ message)
  let error message = log ("[ERROR] " ^ message)
  let warning message = log ("[WARNING] " ^ message)
end

(*
  Elimizde bir soyutlama modülü ve bunu uygulayan iki farklı modül var.
  Öyleyse başka bir modüle bu bağımlılığı enjekte edelim.

  AppTracer, FUNCTOR (Fabrika) modülüdür. Bir Logger modülünü 
  parametre olarak alır ve bir servis verir.
*)
module AppTracer (L : LOGGER) = struct
  let log_data message =
    L.info ("Processing data: " ^ message);
    (* Veri işleme kodları burada olabilir *)
    L.info "Data processed successfully."
end

(*
  Şimdi bu servisi ConsoleLogger ve FileLogger ile çalıştırabiliriz.
  Burada modül bazında gerekli birleştirmeler yapılır ama çalışma zamanında değil
  derleme zamanında gerçekleşir.
*)
module ConsoleAppTracer = AppTracer(ConsoleLogger)
module FileAppTracer = AppTracer(FileLogger)

let () =
  ConsoleAppTracer.log_data "This is a console log message.";
  FileAppTracer.log_data "This is a file log message."