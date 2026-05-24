# Corrigir feedback ao salvar perfil social

## Contexto

A tela `EditSocialProfilePage` permite alterar o perfil social, mas após clicar em **Salvar alterações** o usuário não recebe feedback claro. A chamada ao backend pode concluir com sucesso, porém a tela não volta para a página anterior e o perfil exibido antes da edição pode continuar com dados stale.

## Objetivos

- Em sucesso, retornar para a tela anterior usando navegação de pilha.
- Garantir que a tela anterior recarregue o perfil social atualizado, especialmente o nome de exibição.
- Em falha, permanecer na tela de edição e mostrar uma mensagem genérica via `SnackBar`.
- Evitar que o usuário fique sem feedback após clicar em **Salvar alterações**.

## Abordagem escolhida

Usar a página de edição como ponto de orquestração do feedback pós-save:

1. `EditSocialProfilePage._submit()` continua chamando `socialOnboardingViewModelProvider.notifier.saveProfile(...)`.
2. Após o await, a página lê o estado do view model.
3. Se houver perfil salvo e não houver erro/validação:
   - invalidar `mySocialProfileProvider`;
   - invalidar `socialProfileViewModelProvider('me')`;
   - voltar pela pilha de navegação.
4. Se houver erro:
   - permanecer em `EditSocialProfilePage`;
   - exibir `SnackBar` genérico: `Não foi possível salvar o perfil. Tente novamente.`

Essa opção é intencionalmente simples: não introduz atualização otimista nem muda o fluxo de navegação para callbacks. A invalidação força os providers relevantes a buscarem dados atuais e evita stale data na página anterior.

## Componentes afetados

- `lib/features/social/pages/edit_social_profile_page.dart`
  - Importar/usar `GoRouter` se necessário para voltar pela pilha.
  - Importar `social_profile_viewmodel.dart` para invalidar `socialProfileViewModelProvider('me')`.
  - Mostrar `SnackBar` em falha.
  - Navegar de volta após sucesso.

- `test/features/social/pages/social_pages_test.dart`
  - Adicionar cobertura de sucesso: salvar perfil editado volta para a rota anterior e a tela anterior recarrega dados atualizados.
  - Adicionar cobertura de erro: falha no save mantém usuário na edição e mostra `SnackBar` genérico.

## Fluxo de dados

Em sucesso:

`EditSocialProfilePage` → `SocialOnboardingViewModel.saveProfile` → `SocialRepository.updateMyProfile` → estado com `profile` salvo → invalidar providers do perfil → `pop()` → tela anterior reconstrói/lê dados atualizados.

Em falha:

`EditSocialProfilePage` → `SocialOnboardingViewModel.saveProfile` → exceção no repositório → estado com `errorMessage` → página mostra `SnackBar` e não navega.

## Tratamento de erro

A mensagem exibida ao usuário será genérica para cobrir erro de rede, erro de servidor ou resposta inesperada. Detalhes internos continuam encapsulados no repositório/view model.

## Testes

A implementação deve seguir TDD:

1. Criar teste widget de sucesso e confirmar falha antes da implementação.
2. Implementar a menor mudança para passar.
3. Criar teste widget de falha e confirmar falha antes da implementação.
4. Implementar a menor mudança para passar.
5. Rodar testes focados e análise antes de concluir.

## Fora de escopo

- Refatorar a arquitetura do onboarding/edit profile.
- Alterar contratos do backend.
- Atualização otimista do estado em memória.
- Edição de arquivos gerados (`*.g.dart`, `*.freezed.dart`).
