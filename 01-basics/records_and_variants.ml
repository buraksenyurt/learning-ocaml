(* Records and Variant types examples *)

(* Record type definitions *)
type address = {host: string; port: int; route: string};;

type service = {
  name: string;
  is_active: bool;
  kind: string;
  path: address
};;

(* Create record instances *)
let cust_get = {
  host = "localhost";
  port = 5001;
  route = "api/v1/customer/get"
};;

let customer_service = {
  name = "Get customers";
  is_active = true;
  kind = "REST";
  path = cust_get
};;

(* Variant types with records *)
type location = {x: float; y: float};;

type button = {title: string; position: location};;
type label = {title: string; position: location};;
type drop_down = {items: string list; position: location; is_enabled: bool};;

(* Variant type combining different components *)
type component =
  | Button of button
  | Label of label
  | DropDown of drop_down;;

let origin = {x = 0.0; y = 0.0};;

(* Function to get item count from a component *)
let get_item_count (c: component) : int =
  match c with
  | Button _ -> 0
  | Label _ -> 0
  | DropDown d -> List.length d.items;;

(* Create a dropdown component *)
let left_menu = DropDown {
  items = ["Save"; "Load"; "Exit"];
  position = origin;
  is_enabled = true
};;

(* Function to show component details *)
let show_component_details (c: component) : unit =
  match c with
  | Button b ->
      Printf.printf "Button: %s\n" b.title
  | Label l ->
      Printf.printf "Label: %s\n" l.title
  | DropDown d ->
      Printf.printf "DropDown containing:\n";
      List.iter (fun item -> Printf.printf " - %s\n" item) d.items;;

(* Test the functions *)
let () = Printf.printf "\n=== Service Information ===\n";;
let () = Printf.printf "Service: %s\n" customer_service.name;;
let () = Printf.printf "Active: %b\n" customer_service.is_active;;
let () = Printf.printf "Type: %s\n" customer_service.kind;;
let () = Printf.printf "Host: %s\n" customer_service.path.host;;
let () = Printf.printf "Port: %d\n" customer_service.path.port;;
let () = Printf.printf "Route: %s\n" customer_service.path.route;;

let () = Printf.printf "\n=== Component Information ===\n";;
let () = Printf.printf "Item count in left_menu: %d\n" (get_item_count left_menu);;
let () = Printf.printf "\nComponent details:\n";;
let () = show_component_details left_menu;;

(* Create more components for testing *)
let save_button = Button {
  title = "Save";
  position = {x = 10.0; y = 20.0}
};;

let title_label = Label {
  title = "Welcome!";
  position = {x = 100.0; y = 50.0}
};;

let () = Printf.printf "\nOther components:\n";;
let () = show_component_details save_button;;
let () = show_component_details title_label;;
