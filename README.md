# lorebase

Aplicativo Flutter de descoberta e acompanhamento pessoal de obras de entretenimento.

## Getting Started

```bash
flutter pub get       # instala dependências
cp .env.example .env  # config local; o pubspec declara .env como asset (gitignored)
make codegen          # gera código (build_runner + slang) — obrigatório antes de compilar
make test             # testes unitários/widget (roda o codegen antes)
make check            # codegen + analyze + cobertura + goldens
```

Os arquivos gerados (`*.g.dart`, `*.freezed.dart` e `lib/l10n/strings*.g.dart`) **não são
versionados**: rode `make codegen` depois de clonar, trocar de branch ou alterar
modelos/viewmodels. O loop de desenvolvimento é
`dart run build_runner watch --delete-conflicting-outputs`.

`flutter test` cru não é o fluxo suportado — sem o codegen a árvore não compila. Se a IDE ou
`flutter run` reclamar de `Target of URI doesn't exist: '…g.dart'`, falta o codegen; não existe
hook de build nesses caminhos.

Política completa em `AGENTS.md` > Conventions.
