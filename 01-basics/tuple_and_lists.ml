(* Tuple and List examples *)

(* Tuple examples *)
let config = ("He-Man, Gölgelerin gücü adına", 1920, 1080, true);;
let (title, width, height, is_active) = config;;

(* Function returning a tuple *)
let move (x, y) speed =
  (x + speed, y + speed);;

let (new_x, new_y) = move (11, 16) 5;;

(* List examples *)
let colors = ["Red"; "Green"; "Blue"];;
let numbers = [1; 2; 3; 4; 5];;
let points = [0.40; 0.25; 0.55; 0.45];;

(* List operations *)
let colors_length = List.length colors;;
let extended = "Black" :: "White" :: colors;;

let origin = 0, 0;;

(* Combining lists *)
let left_side = [1; 2; 3];;
let right_side = [4; 5; 6; 7; 8];;
let combine = left_side @ right_side;;

(* Pattern matching with lists *)
let first_or_default values =
  match values with
  | first :: the_rest -> first
  | [] -> 0;;

(* Generic version *)
let first_or default values =
  match values with
  | first :: the_rest -> first
  | [] -> default;;

(* Test outputs *)
let () = Printf.printf "Config title: %s\n" title;;
let () = Printf.printf "Config dimensions: %dx%d\n" width height;;
let () = Printf.printf "Config is_active: %b\n" is_active;;
let () = Printf.printf "New position: (%d, %d)\n" new_x new_y;;
let () = Printf.printf "Colors length: %d\n" colors_length;;
let () = Printf.printf "Extended list length: %d\n" (List.length extended);;
let () = Printf.printf "Combined list length: %d\n" (List.length combine);;
let () = Printf.printf "first_or_default []: %d\n" (first_or_default []);;
let () = Printf.printf "first_or_default [12;0;23;9;14]: %d\n" (first_or_default [12; 0; 23; 9; 14]);;
let () = Printf.printf "first_or \"\" []: %s\n" (first_or "" []);;
let () = Printf.printf "first_or 1 []: %d\n" (first_or 1 []);;
let () = Printf.printf "first_or 0 [12;2;6;9]: %d\n" (first_or 0 [12; 2; 6; 9]);;
