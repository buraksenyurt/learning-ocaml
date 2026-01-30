# Learning OCaml

OCaml programlama dili ile ilgili maceralarımın yer aldığı kod deposudur.

## OCaml ile İlgili Merak Ettiğim Sorular

**OCaml ismi nerden geliyor?:**
**Geliştiricileri kim?:**
**İlk versiyonu ne zaman çıktı?:**
**Dilin kullanım amacı:**
**Hangi dillerden esinlenmiş:**
**Hangi dillere esin kaynağı olmuş:** Bir tanesi *Rust* ki bende uğraştığım için biliyorum.
**OCaml ile kendi programlama dilini yazabilir miyim?:**
**Kaynak olarak hangi kitabı tavsiye ederim?:** Real World OCaml, Functional Programming for the Masses, Anıl Madhavapeddy, Yaron Minsky, Cambridge University Press

## Kurulumlar

İlk olarak resmi [OCaml web sitesinden](https://ocaml.org/docs/installing-ocaml) gerekli kurulumları yaptım. Ayrıca VS Code editörüne OCaml eklentisini yükledim. Ancak komut satırından ocaml ile kod çalıştırmakta sorun yaşadım. Bunun kalıcı çözümü içinse aşağıdaki komutu işlettim.

```bash
Add-Content $PROFILE "`n# Initialize opam environment`n(& opam env) -split '\r?\n' | ForEach-Object { Invoke-Expression `$_ }"

#Sonrasında PowerShell'i yeniden başlattım
#Kısa bir versiyon kontrolü yaptım
ocaml -version

#ve örneğin hello-world.ml dosyasını doğrudan aşağıdaki komutla çalıştırabildim
ocaml hello-world.ml

#Ocaml' ı interaktif modda kullanmak için ise aşağıdaki komutu kullanmak yeterli
ocaml
```

İşte ilk programın çıktısı,

![hello_world](./images/hello_world.png)

## Interaktif Mod Örnekleri

Aşağıdaki kod örnekleri için komut satırından `ocaml` komutu çalıştırılarak ilerlenebilir. `ocaml` aracı ile çalışırken kullanılabilecek komutlar için aşağıdaki komut kullanılabilir.

```text
# #help;;
```

### Basit aritmetik işlemler, değişken atamaları ve isimlendirmeler

İlk olarak float değerler ile ilgili aritmetik birkaç işleme bakalım.

```text
# 3.14 +. 2.1;;
- : float = 5.24
# 10+2;;
- : int = 12
# 10+.2;;
Line 1, characters 0-2:
1 | 10+.2;;
    ^^
Error: The constant 10 has type int but an expression was expected of type
         float
Hint: Did you mean 10.?
# 10. +. 2;;
Line 1, characters 7-8:
1 | 10. +. 2;;
           ^
Error: The constant 2 has type int but an expression was expected of type
         float
Hint: Did you mean 2.?
# 10. +. 2.;;
- : float = 12.
# 1_000_000 * 10_000;;
- : int = 10000000000
# (2 * 5) <= 10;;
- : bool = true
# (2 * 6) <= 10;;
- : bool = false
# let xValue = 10;;
val xValue : int = 10
# let y_value = 5;;
val y_value : int = 5
# let result = xValue + y_value;;
val result : int = 15
# let MaxUserCount = 8;;
Line 1, characters 4-16:
1 | let MaxUserCount = 8;;
        ^^^^^^^^^^^^
Error: Unbound constructor MaxUserCount
# let 7even = 7;;
Line 1, characters 4-9:
1 | let 7even = 7;;
        ^^^^^
Error: Invalid literal 7even
# let screen-width = 1024;;
Line 1, characters 11-16:
1 | let screen-width = 1024;;
               ^^^^^
Error: Syntax error
```

- **;;** ile toplevel'a *(bu ne demek?)* ilgili satırı bir ifade olarak ele alması gerektiğini, yani hemen çalıştırmasını belirtmek için kullanılıyor. *(Evaluate Expression)*
- İki **float** değeri toplamak için **+.** operatörü kullanılmalı. Ayrıca **float** ve **int** toplanacak küsürat olmasa bile . ile sayının **float** olarak ele alınacağı ifade edilmeli.
- İfade çalıştırıldığında sadece sonuç değil tür bilgisi de dönülüyor.
- Büyük sayılar **_** karakteri ile daha okunabilir yazılabilir.
- Değişkenleri **let** anahtar kelimesi ile tanımlayabilir ilk değerleri atayabiliriz.
- Değişken isimlendirme kurallarına göre büyük harfle, sayıyla başlayan değişken adları verilemez *(MaxUserCount, 7even)* gibi. Büyük harf kullanılmama sebebi, modül adlarının büyük harfle başlaması olabilir.
- Hatta değişken isimlendirmelerinde **-** operatörü de kullanılamaz.

### let'in Gücü ve Fonksiyon Tanımlamaları

Başla işlemlerle devam edelim. **let** çok güçlü bir operatör. Değişkenleri bağlayabildiğimiz gibi, fonksiyonları da bağlayabiliriz.

```text
# let total x y = x + y;;
val total : int -> int -> int = <fun>
# total 1 5;;
- : int = 6
# total -5 5;;
Line 1, characters 0-5:
1 | total -5 5;;
    ^^^^^
Error: The value total has type int -> int -> int
       but an expression was expected of type int
# total (-5) 5;;
- : int = 0
# total 1.2 3.4;;
Line 1, characters 6-9:
1 | total 1.2 3.4;;
          ^^^
Error: The constant 1.2 has type float but an expression was expected of type
         int
# total 128 (8 * 1024);;
- : int = 8320
```

Burada **total** isimli iki parametre alan ve varsayılan olaran **int** türünde değerleri toplayan bir fonksiyon tanımladık. Fonksiyon çağrılırken parametreler arasında parantez kullanımı önemli. Aksi halde eksi işareti operatör olarak algılanıyor. Ayrıca doğru türlerde işlem yapmak lazım.

![ocaml_00.png](./images/ocaml_00.png)

```text
# let total_1 x y = x + y;;
val total_1 : int -> int -> int = <fun>
# let total_2 x y = (x * x) + (y * y);;
val total_2 : int -> int -> int = <fun>
# total_1 3 4 + total_2 5 1;;
- : int = 33
# let div x y = Float.from_int x / Float.from_int y;;
Line 1, characters 14-28:
1 | let div x y = Float.from_int x / Float.from_int y;;
                  ^^^^^^^^^^^^^^
Error: Unbound value Float.from_int
Hint:   Did you mean Float.of_int or Float.to_int?
# let div x y = Float.of_int x / Float.of_int y;;
Line 1, characters 14-28:
1 | let div x y = Float.of_int x / Float.of_int y;;
                  ^^^^^^^^^^^^^^
Error: This expression has type float but an expression was expected of type
         int
# let div x y = Float.of_int x /. Float.of_int y;;
val div : int -> int -> float = <fun>
# div 1 3
  ;;
- : float = 0.33333333333333331
# div 3.14 2.
  ;;
Line 1, characters 4-8:
1 | div 3.14 2.
        ^^^^
Error: The constant 3.14 has type float
       but an expression was expected of type int
# div 3 2;;
- : float = 1.5
```

> div fonksiyonunun yorumlanma şekli dikkat çekmiştir. int -> int -> float. Düşününce int,int->float gibi bir şey yazar diye bekliyor insan.

Yukarıdaki örnekte, div isimli fonksiyonu tanımlamaya çalışıyorum. Fonksiyondan beklenti **int** türünden gelen iki sayıyı bölmek ama bunları **float** türünden ele almasını sağlamak. İlk denemede kitaptaki fonksiyon adını unuttum ve **of_int** yerine **from_int** yazdım. **Rust** günlüklerim geldi aklıma, yorumlayıcı *acaba şunu mu demek istedin* derken. Fonksiyonları düzelttikten sonra **/** operatörü ile **/.** arasındaki farka tosladım. **float** türler arasında bir bölme işlemi söz konusu olacağı için **/.** operatörünün kullanılması gerekiyor. Bölme operatörünün tipe özel versiyonlandığını ifade edebiliriz. Ayrıca **Float** bir Ocaml modülü.

Burada rahatsız edici nokta belki de **Float.of_int** kullanımı olabilir ama bunu kolaylaştırmak için OCaml ekosisteminde yazılmış bir başka [modül](https://ocaml.janestreet.com/ocaml-core/v0.13/doc/base/Base/Float/O/) var. Bu modüldeki amaçlardan birisi **float** değerler ile çalışırken +., /. operatörleri yerine +, / ile de çalışabilmek ve bunu **float-safe** modda yapabilmek. Ben şu an için standart kütüphane ile devam etmek istiyorum. Ekosistemdeki diğer modüllere sonradan odaklanırım. Standart kütühane aynı fonksiyonu aşağıdaki gibi yazmamıza da izin veriyor.

```text
# let div x y =
        float_of_int x /. float_of_int y
  ;;
val div : int -> int -> float = <fun>
# div 1 5;;
- : float = 0.2
```

#### Yine de Float.0 ile Çalışmak Gerekirse

Bir noktada Float.O ile çalışmak gerekirse şöyle ilerlemek gerekiyor. Öncelikle komut satırından **utop** başlatılır. Ardından, toplevel, Base modülünü destekleyecek şekilde başlatılır. Bu işlemin ardından ilgili fonksiyon yazılabilir. Aşağıdaki ekran görüntüsünü geleceğe not olarak bırakayım.

![ocaml_01.png](./images/ocaml_01.png)

### Zihin Yakan Bir Fonksiyon Kullanımı

Şimdi, int türünden değer dönen bir fonksiyonu parametre olarak alan, ve diğer parametrede gelen int değer ile toplayan bir fonksiyon tanımlayalım.

```text
# let more_add f x y = f * x + y;;
val more_add : int -> int -> int -> int = <fun>
# let square n = n * n;;
val square : int -> int = <fun>
# more_add (square 1) 1 1;;
- : int = 2
# more_add (square 2) 3 5;;
- : int = 17
```

İlk olarak **more_add** fonksiyonuna bir bakalım. **f** in bir fonksiyonu işaret ettiğini nereden anladı? Yorumlama kısmına baktığımızda int -> int -> int -> int şeklinde bir tanım var. **\<fun\>** tabii ki bunun bir fonksiyon olduğunu ifade etmekte. f çıktısını x ile çarpıp y ile toplatıyoruz. Saçma bir fonksiyon ancak dinamiğini öğrenmek açısından kayda değer. Sonrasında **square** isimli bir fonksiyon tanımlıyoruz. Bu fonksiyon tek parametre alıyor ve karesini döndürüyor. Şimdi **more_add** fonksiyonunu çağırırken ilk parametre olarak **square 2** ifadesini veriyoruz. Bu ifade **4** değerini döndürecek ve bu değer **f** parametresine bağlanacak. Sonrasında ise 3 ve 5 değerleri sırasıyla x ve y parametrelerine bağlanacak. Yani fonksiyonun işleyişi şu şekilde olacak, 4 * 3 + 5 = 12 + 5 = 17. Ancak asıl zihin yakıcı örnek kitaptaki örnekten esinlenilerek geliyor;

```text
# let condition f first_arg second_arg =
        (if f first_arg then first_arg else 0)
        +
        (if f second_arg then second_arg else 0);;
val condition : (int -> bool) -> int -> int -> int = <fun>
# let check_point value = value > 50;;
val check_point : int -> bool = <fun>
# condition check_point 28 76;;
- : int = 76
```

**condition** isimli fonksiyonun kullandığı **f** parametresi bir fonksiyonu işaret etmekte ve bu fonksiyonun türü **int -> bool**. Yani bir **int** alıp **bool** döndüren bir fonksiyon. Peki yorumlayıcı buna nasıl karar verdi ya da bu tür tahminini *(type inference)* neye göre yaptı? Burada **if** koşuluna odaklanmakta fayda var. Nitekim **else** kısımlarında 0 değeri kullanılmakta ki bu bir **int** türü. Buna göre **then** kısımlarında da **int** türü döndüren ifadeler olmalı. Sonuç olarak **f** fonksiyonu **int -> bool** türünde bir fonksiyon olmalı.

![ocaml_02.png](./images/ocaml_02.png)

**OCaml** uzmanlarına göre bu yazım stiline ve yorumlayıcının tip tahmini mekanizmasına alışmak zaman alabilir. Diğer yandan dilin çok güçlü bir yanını ispat eden bu yazım stiline alışamayanlar için *Annotations* yani tür açıklamaları ile fonksiyonları tanımlamak da mümkün. Aynı fonksiyonu aşağıdaki gibi de yazabiliriz.

```text
# let condition (f: int -> bool) (first_arg:int) (second_arg:int) : int =
        (if f first_arg then first_arg else 0)
        +
        (if f second_arg then second_arg else 0);;
val condition : (int -> bool) -> int -> int -> int = <fun>
# let check_point value = value > 50;;
val check_point : int -> bool = <fun>
# condition check_point 28 76;;
- : int = 76
```

![ocaml_03.png](./images/ocaml_03.png)

> TO BE CONTINUED
