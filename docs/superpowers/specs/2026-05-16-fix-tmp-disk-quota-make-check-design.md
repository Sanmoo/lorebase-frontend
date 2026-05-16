# Fix: `make check` Travando por Disk Quota Exceeded no `/tmp`

## Problem

`make check` demora >8 minutos e não completa. O erro real está oculto no meio do output:

```
FileSystemException: Cannot copy file to '/tmp/flutter_tools.XXXX/.../listener.dart.dill'
(OS Error: Disk quota exceeded, errno = 122)
```

## Root Cause

O `/tmp` é montado como `tmpfs` com 7.7GB. Cada execução do `flutter test` cria um diretório
`/tmp/flutter_tools.XXXXXX` de ~300-400MB. Execuções anteriores acumularam **15+ diretórios**
(~5GB), deixando apenas ~1.7GB livres. Quando um novo `flutter test` tenta compilar os testes,
o test compiler falha ao copiar o `.dill` para `/tmp` — disparando o `Disk quota exceeded`.

O test runner tenta se recuperar mas opera extremamente devagar com pouco espaço em disco,
resultando no timeout de 8+ minutos observado pelo usuário.

## Solution

### 1. Novo target `clean-tmp` no Makefile

Target manual que o usuário executa quando necessário:

```makefile
clean-tmp:
	@echo "🧹 Cleaning stale Flutter temp directories..."
	find /tmp -maxdepth 1 -name 'flutter_tools.*' -type d -mmin +60 \
	  -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Done. /tmp usage: $$(df -h /tmp | tail -1 | awk '{print $$5}')"
```

- Remove apenas diretórios `flutter_tools.*` com mais de 60 minutos
- `-mmin +60` protege diretórios de execuções ativas
- `|| true` para nunca gerar erro

### 2. Alerta de disco no `check`

Adicionar target `check-disk` antes de `test-coverage` no fluxo `check`:

```makefile
check: analyze check-disk test-coverage golden-test

check-disk:
	@usage=$$(df /tmp | tail -1 | awk '{print $$5}' | tr -d '%'); \
	if [ "$$usage" -gt 70 ]; then \
		echo "⚠️  /tmp is $$usage% full. Consider 'make clean-tmp' for faster tests."; \
	fi
```

- Apenas informativo, não bloqueante
- O `check` continua rodando mesmo com disco cheio
- Dá visibilidade ao usuário sobre por que os testes estão lentos

## Edge Cases

| Caso                                | Comportamento                                 |
| ----------------------------------- | --------------------------------------------- | --- | -------------------------------- |
| `/tmp` vazio de flutter_tools       | `clean-tmp` não encontra nada, não falha      |
| Diretório em uso por processo ativo | `-mmin +60` protege execuções recentes (< 1h) |
| `find` sem permissão                | `2>/dev/null` + `                             |     | true` → ignorado silenciosamente |
| `df` não disponível                 | `check-disk` continua sem falha               |

## Files Modified

- `Makefile` — adicionar targets `clean-tmp` e `check-disk`, modificar target `check`

## Out of Scope

- Limpeza automática no `check` (risco de deletar algo em uso)
- Aumentar o tmpfs (mascara o problema)
- Mudar `FLUTTER_TMPDIR` (mais complexo e pode ter efeitos colaterais)
- Limpeza de outros diretórios no `/tmp` (ex: `pi-subagents-*`)
