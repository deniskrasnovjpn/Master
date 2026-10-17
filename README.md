# Master

Общие настройки для облачных сессий Claude Code, не привязанные к конкретному проекту.

- `CLAUDE.md` — глобальные правила; при старте сессии копируется в `~/.claude/CLAUDE.md`.
- `skills/` — глобальные скиллы; при старте сессии копируются в `~/.claude/skills/`.
- `setup.sh` — текст для поля **Setup script** облачного окружения: копирует правила и скиллы
  и ставит общие инструменты (pandoc, шрифты Liberation, Tesseract OCR с языками deu/rus/eng, PyMuPDF, zstandard — для чтения экспортов
  Anki `.colpkg`/`.apkg`).

Изменения в этом репозитории подхватываются новыми сессиями автоматически; правка самого
Setup script нужна только при изменении `setup.sh`.

Скиллы `grill-me`, `grilling` взяты из [mattpocock/skills](https://github.com/mattpocock/skills),
`find-skills` — из [vercel-labs/skills](https://github.com/vercel-labs/skills) (MIT, лицензии лежат рядом).
