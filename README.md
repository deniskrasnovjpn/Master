# Master

Общие настройки для облачных сессий Claude Code, не привязанные к конкретному проекту.

- `CLAUDE.md` — глобальные правила облачных сессий.
- `skills/` — глобальные скиллы.
- `setup.sh` — настройка облачного окружения: ставит общие инструменты (pandoc, шрифты Liberation,
  Tesseract OCR с языками deu/rus/eng, PyMuPDF, zstandard — для чтения экспортов Anki
  `.colpkg`/`.apkg`), базовую копию правил и скиллов в `~/.claude/` и hook SessionStart из `hooks/`.
- `setup-stub.sh` — текст для поля **Setup script** облачного окружения: клонирует этот репозиторий
  и запускает `setup.sh`. Ошибка любого шага — предупреждение, сессия всё равно запускается.
- `hooks/bootstrap.sh` — hook SessionStart, `setup.sh` кладёт его в
  `~/.claude/hooks/master-session-start.sh`; при каждом старте сессии он обновляет копию этого
  репозитория в `~/.local/share/claude-master` и запускает из неё `hooks/session-start.sh`.
- `hooks/session-start.sh` — сама работа hook'а: копирует изменённые скиллы (и удаляет убранные
  отсюда), а если `CLAUDE.md` отличается от `~/.claude/CLAUDE.md`, передаёт Claude его свежий текст.

## Когда что обновляется

Поле Setup script платформа выполняет только при сборке снимка окружения: в первой сессии,
после изменения поля или списка разрешённых доменов и когда снимок истекает, примерно через
семь дней. Новые сессии стартуют из снимка, не выполняя его.

- Правки `CLAUDE.md`, скиллов и `hooks/session-start.sh` доходят до следующей же сессии сами,
  через hook. Сам `~/.claude/CLAUDE.md` остаётся версией из снимка; если hook не сработает
  (например, нет сети), действуют правила из снимка.
- Правки инструментов в `setup.sh` и `hooks/bootstrap.sh` требуют пересборки снимка: сменить
  строку `# rev` в поле Setup script.
- `CLAUDE.md` держать короче 9 500 символов: hook передаёт не больше 10 000 символов, а более
  длинные правила придут только ссылкой на файл.

Скиллы `grill-me`, `grilling` взяты из [mattpocock/skills](https://github.com/mattpocock/skills),
`find-skills` — из [vercel-labs/skills](https://github.com/vercel-labs/skills) (MIT, лицензии лежат рядом).
