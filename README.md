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
- Değişken isimlendirme kurallarına göre büyük harfle, sayıyla başlayan değişken adları verilemez *(MaxUserCount, 7even)* gibi.
- Hatta değişken isimlendirmelerinde **-** operatörü de kullanılamaz.

Başla işlemlerle devam edelim. **let** çok güçlü bir operatör. Değişkenleri bağlayabildiğimiz gibi, fonksiyonları da bağlayabiliriz.

```text

```
