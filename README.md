# Master

Общие настройки для облачных сессий Claude Code, не привязанные к конкретному проекту.

- `CLAUDE.md` — глобальные правила; при старте сессии копируется в `~/.claude/CLAUDE.md`.
- `skills/` — глобальные скиллы; при старте сессии копируются в `~/.claude/skills/`.
- `setup.sh` — настройка облачной сессии: копирует правила и скиллы и ставит общие
  инструменты (pandoc, шрифты Liberation, Tesseract OCR с языками deu/rus/eng, PyMuPDF,
  zstandard — для чтения экспортов Anki `.colpkg`/`.apkg`). Все команды настройки — здесь.
- `setup-stub.sh` — текст для поля **Setup script** облачного окружения, вставляется один раз:
  клонирует этот репозиторий и запускает `setup.sh`. Ошибка любого шага — предупреждение,
  сессия всё равно запускается.

Изменения в этом репозитории, включая `setup.sh`, подхватываются новыми сессиями
автоматически; поле Setup script менять не нужно.

Скиллы `grill-me`, `grilling` взяты из [mattpocock/skills](https://github.com/mattpocock/skills),
`find-skills` — из [vercel-labs/skills](https://github.com/vercel-labs/skills) (MIT, лицензии лежат рядом).
