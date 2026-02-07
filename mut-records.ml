(* 
  Varsayılan olarak immutable olan record üyeleri mutable yapılabilir.
  Şöyle anlamlı bir örnek düşünelim. Bir oyuncunun adı genellikle oyun sırasında değiştirilmez
  ancak canı, bulunduğu konu gibi bilgiler anlık olarak değişebilir.
*)

type player = {
  name: string;
  mutable health: int;
  mutable position: (int * int);
};;

let she_ra = { name = "She-Ra"; health = 100; position = (0, 0) };;

(* Bir fonksiyon ile de örneğin oyuncu hasar aldığında health bilgisini güncelleyebiliriz *)
let take_damage player amount = 
  player.health <- player.health - amount;
  Printf.printf "%s took %d damage and now has %d health.\n" player.name amount player.health
;;

take_damage she_ra 30;;

(* Oyuncunun pozisyonunu güncellemek için de benzer şekilde bir fonksiyon yazabiliriz *)
let move_player player new_position =
  player.position <- new_position;
  Printf.printf "%s moved to position (%d, %d).\n" player.name (fst new_position) (snd new_position)
;;

move_player she_ra (5, 10);;

(* 
  OCaml'ın immutable felsefesini anlamak için bu örneği varsayılan durumda ele alalım
  Aşağıda görüldüğü gibi normal bir record tanımı yaptık.
*)
type player = {
  name: string;
  health: int;
  position: (int * int);
};;

let she_ra = { name = "She-Ra"; health = 100; position = (0, 0) };;

(* take_damage fonksiyonu artık player record'ünün health üyesini değiştiremez.
  Bu yüzden yeni bir player record'ü oluşturarak güncellenmiş bilgileri içeren bir record döndürmemiz gerekir.
  Tabii bu durumda var olan player record' unun bir kopyasını oluşturmuş oluruz.

  Örnekte update_player oluşturulurken health bilgisi güncelleniyor,
  burada with keyword kullandığımıza dikkat edelim. in ise yeni record'ün oluşturulacağı scope'u belirtiyor.
*)
let take_damage player amount = 
  let updated_player = { player with health = player.health - amount } in
  Printf.printf "%s took %d damage and now has %d health.\n" player.name amount updated_player.health;
  updated_player
;;

let she_ra = take_damage she_ra 8;;

(* 
  Bir fonksiyon tanımlamadan değer değiştirmek istersek bu durumda aşağıdaki gibi ilerleyebiliriz. 
  Söz gelimi pozisyonu değiştrelim.
*)
Printf.printf "%s is currently at position (%d, %d).\n" she_ra.name (fst she_ra.position) (snd she_ra.position);;
let she_ra = { she_ra with position = (25, 50) };;

Printf.printf "%s moved to position (%d, %d).\n" she_ra.name (fst she_ra.position) (snd she_ra.position);;
