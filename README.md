# Learning OCaml

OCaml programlama dili ile ilgili maceralarımın yer aldığı kod deposudur.

## Kurulumlar

İlk olarak resmi [OCaml web sitesinden](https://ocaml.org/docs/installing-ocaml) gerekli kurulumları yaptım. Ayrıca VS Code editörüne OCaml eklentisini yükledim. Ancak komut satırından ocaml ile kod çalıştırmakta sorun yaşadım. Bunun kalıcı çözümü içinse aşağıdaki komutu işlettim.

```bash
Add-Content $PROFILE "`n# Initialize opam environment`n(& opam env) -split '\r?\n' | ForEach-Object { Invoke-Expression `$_ }"

#Sonrasında PowerShell'i yeniden başlattım
#Kısa bir versiyon kontrolü yaptım
ocaml -version

#ve örneğin hello-world.ml dosyasını doğrudan aşağıdaki komutla çalıştırabildim
ocaml hello-world.ml
```

İşte ilk programın çıktısı,

![hello_world](./images/hello_world.png)
