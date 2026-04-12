type payment_type =
  | Cash
  | CreditCard of string * float
  | Crypto of string * bool (*Vault adresi ile ağ onayını tutar*)

let process_payment pay_t =
  match pay_t with
  | Cash -> "Processing cash payment"
  | CreditCard (number, amount) -> Printf.sprintf "Processing credit card payment of %.2f for card %s" amount number
  | Crypto (address, confirmed) ->
      if confirmed then
        Printf.sprintf "Processing crypto payment to address %s" address
      else
        Printf.sprintf "Crypto payment to address %s is pending confirmation" address

let bills_payment = CreditCard ("1234-5678-9012-3456", 150.00);;
let () = 
  process_payment bills_payment
  |> print_endline