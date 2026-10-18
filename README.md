# whisper.cpp — Windows x64 CPU build (vendored binaries)

> **This is not the whisper.cpp project.** It is an unmodified copy of the prebuilt Windows binaries
> from **[ggml-org/whisper.cpp](https://github.com/ggml-org/whisper.cpp)** (MIT, © The ggml authors),
> kept here so [second-brain](https://github.com/adamkopelman/second-brain) can pin them as a git
> submodule at `vendor/whisper-cpp`. All credit for whisper.cpp goes to its authors; report bugs and
> get newer builds upstream.

Local, fully offline speech-to-text used by second-brain's `scripts/transcribe_meetings.py` (and,
through it, the `record-meeting` Obsidian plugin, the local dashboard's *Record a meeting* and the
`gtd-transcribe-meeting` skill). No Python packages, no ffmpeg, no network at use time.

## The model is a separate download

Whisper models are too big for git, so **no model is committed** (`models/*.bin` is git-ignored).
Download the one second-brain expects — `ggml-tiny.bin`, multilingual, ~74 MB — into
`models/ggml-tiny.bin`:

```powershell
powershell -ExecutionPolicy Bypass -File download-model.ps1     # Windows
```
```sh
sh download-model.sh                                            # Git Bash / WSL / macOS / Linux
```

Both scripts fetch https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin, verify
its SHA-256 and only then move it into place; re-running is a no-op once it's there. Or download it
by hand from <https://huggingface.co/ggerganov/whisper.cpp> and save it as `models/ggml-tiny.bin`
(inside second-brain: `vendor/whisper-cpp/models/ggml-tiny.bin`).

| Model | sha256 |
| --- | --- |
| `ggml-tiny.bin` (multilingual) | `be07e048e1e599ad46341c8d2a135645097a538221678b7acdd1b1919c6e1b21` |

Keep it a **multilingual** model (not an `.en` one) unless every recording is English — the meetings
this was set up for are usually in Hebrew, which an English-only model cannot transcribe. A bigger
multilingual model (`ggml-base.bin`, `ggml-small.bin`, …) is more accurate; pass it with
`transcribe_meetings.py --model <path>`.

## What's here

- **Source:** whisper.cpp release [`b4938`](https://github.com/ggml-org/whisper.cpp/releases/tag/b4938),
  asset `whisper-bin-x64.zip` (CPU-only, Windows x64) — every file below is byte-identical to the
  file of the same name in that zip's `Release/` folder.
- **Files:** `whisper-cli.exe` + `whisper.dll`, `ggml.dll`, `ggml-base.dll`, and all `ggml-cpu-*.dll`
  variants (the exe picks the one matching the running CPU's features — keep all of them, the machine
  that runs this may differ from the one that vendored it). `SDL2.dll`, `llama.dll`, `parakeet*` and
  the other demo tools from the same zip are not needed and were left out.
- **Platform:** Windows x86-64 only. second-brain's `transcribe_meetings.py` fails with a clear
  message if the binary or the model is missing (or use `--remote-url` for an OpenAI-compatible
  transcription server instead).
- **sha256:** `whisper-cli.exe` `800a0fd754afa75e109c7248286ad735670fb6b23d92ca5d12604647ef638a65`,
  `whisper.dll` `0a29e5824c7495185b833ad07df7ab9cadf130a9be848f967c6b88aeca971566`
- **Usage:** `whisper-cli.exe -m models/ggml-tiny.bin -f <audio> -oj -of <out> -np -l auto`
  (`-l auto` detects each recording's language).

## Updating

Download a newer `whisper-bin-x64.zip` from <https://github.com/ggml-org/whisper.cpp/releases>,
replace the files listed above with the ones from its `Release/` folder, update the release and
hashes in this README, commit, and bump the submodule in second-brain.

## License

whisper.cpp is MIT-licensed — see [`LICENSE`](LICENSE), copied verbatim from
[ggml-org/whisper.cpp at `b4938`](https://github.com/ggml-org/whisper.cpp/blob/b4938/LICENSE).
The ggml Whisper models on Hugging Face are conversions of
[OpenAI's Whisper](https://github.com/openai/whisper) models (MIT).
