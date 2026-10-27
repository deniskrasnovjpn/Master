# Master

Общие настройки для облачных сессий Claude Code, не привязанные к конкретному проекту.

- `CLAUDE.md` — глобальные правила облачных сессий.
- `skills/` — глобальные скиллы, которые хранятся прямо здесь.
- `skills-upstream.txt` — скиллы, которые берутся прямо из их GitHub-репозиториев (сейчас десять
  скиллов из [mattpocock/skills](https://github.com/mattpocock/skills)): при каждом старте сессии
  подтягивается их текущая версия, копий здесь нет. При совпадении имён побеждает `skills/`.
- `setup.sh` — настройка облачного окружения: ставит общие инструменты (pandoc, шрифты Liberation,
  Tesseract OCR с языками deu/rus/eng, PyMuPDF, zstandard — для чтения экспортов Anki
  `.colpkg`/`.apkg`; npm-пакеты defuddle и knap для скиллов плагина Obsidian; Codex CLI
  `@openai/codex` для плагина codex), базовую копию правил и скиллов в `~/.claude/` и hook
  SessionStart из `hooks/`.
- `setup-stub.sh` — текст для поля **Setup script** облачного окружения: клонирует этот репозиторий
  и запускает `setup.sh`. Ошибка любого шага — предупреждение, сессия всё равно запускается.
- `hooks/bootstrap.sh` — hook SessionStart, `setup.sh` кладёт его в
  `~/.claude/hooks/master-session-start.sh`; при каждом старте сессии он обновляет копию этого
  репозитория в `~/.local/share/claude-master` и запускает из неё `hooks/session-start.sh`.
- `hooks/session-start.sh` — сама работа hook'а: синхронизирует скиллы через `hooks/sync-skills.sh`,
  а если `CLAUDE.md` отличается от `~/.claude/CLAUDE.md`, передаёт Claude его свежий текст.
  С `--skills-only` (локальные сессии на Windows) только синхронизирует скиллы.
- `hooks/sync-skills.sh` — собирает скиллы из `skills/` и `skills-upstream.txt` (клоны upstream-репозиториев
  кэшируются в `~/.local/share/claude-master-upstream`), копирует изменённые в `~/.claude/skills/`
  и удаляет те, что поставил раньше, а теперь их в Master нет. Скиллы из других источников не трогает.
  Если репозиторий не скачался, берётся кэш или остаётся установленная копия.

## Локальные сессии (Windows)

Тот же hook стоит и локально: `hooks/bootstrap.sh` скопирован в `~/.claude/hooks/master-session-start.sh`,
а в `~/.claude/settings.json` есть запись SessionStart (matcher `startup`, `async`) с командой
`bash ~/.claude/hooks/master-session-start.sh --skills-only`. Hook асинхронный, потому что в Git Bash
он работает около десяти секунд и иначе задерживал бы старт сессии; изменённые скиллы Claude Code
подхватывает сам. При первом запуске hook сам клонирует Master в `~/.local/share/claude-master`. Локально синхронизируются только скиллы; правила остаются
локальным `~/.claude/CLAUDE.md`.

## Когда что обновляется

Поле Setup script платформа выполняет только при сборке снимка окружения: в первой сессии,
после изменения поля или списка разрешённых доменов и когда снимок истекает, примерно через
семь дней. Новые сессии стартуют из снимка, не выполняя его.

- Правки `CLAUDE.md`, скиллов, `skills-upstream.txt`, `hooks/session-start.sh` и `hooks/sync-skills.sh`,
  а также новые версии upstream-скиллов доходят до следующей же сессии сами,
  через hook. Сам `~/.claude/CLAUDE.md` остаётся версией из снимка; если hook не сработает
  (например, нет сети), действуют правила из снимка.
- Правки инструментов в `setup.sh` и `hooks/bootstrap.sh` требуют пересборки снимка: сменить
  строку `# rev` в поле Setup script.
- `CLAUDE.md` держать короче 9 500 символов: hook передаёт не больше 10 000 символов, а более
  длинные правила придут только ссылкой на файл.

Скилл `find-skills` взят из [vercel-labs/skills](https://github.com/vercel-labs/skills) (MIT, лицензия
лежит рядом); лицензии upstream-скиллов — в их собственных репозиториях.
