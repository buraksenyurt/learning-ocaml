type product = {
  id: int;  
  name : string;
  price : float;
  tags : string list;
}

let write_info { id; name; price; tags } =
  Printf.sprintf "Product ID: %d\nName: %s\nPrice: %.2f\nTags: %s\n"
    id 
    name 
    price 
    (String.concat ", " tags)

let () = 
  write_info { 
    id = 1; 
    name = "Eyç Pi i9 Laptop"; 
    price = 1999.99; 
    tags = ["electronics"; "computer"; "portable"]; 
  } 
  |> print_endline
  