# .dotfiles

My dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start

```sh
git clone git@github.com:jvmsangkal/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

That symlinks every package into `$HOME`. If `install.sh` reports a conflict, see
[Conflicts](#conflicts).

## Layout

Each top-level directory is a stow _package_. Inside a package, the directory
structure mirrors `$HOME`, so stow can recreate it as symlinks.

```
.dotfiles/
├── claude/
│   └── .claude/CLAUDE.md      ->  ~/.claude/CLAUDE.md
└── ghostty/
    └── .config/ghostty/config ->  ~/.config/ghostty/config
```

| Package   | Installs to         |
| --------- | ------------------- |
| `claude`  | `~/.claude`         |
| `ghostty` | `~/.config/ghostty` |

## install.sh

```sh
./install.sh                  # link all packages
./install.sh claude ghostty   # link only the named packages
./install.sh --dry-run        # print what would change, touch nothing
./install.sh --adopt          # move existing $HOME files into the repo, then link
./install.sh --delete         # unlink packages
```

It installs stow via Homebrew if it's missing, discovers packages automatically,
and uses `stow --restow` so re-running it is safe.

## Using stow directly

The script is a thin wrapper. The equivalent raw commands, run from `~/.dotfiles`:

```sh
stow ghostty            # link one package into $HOME
stow -R ghostty         # restow: unlink then relink (use after adding files)
stow -D ghostty         # unlink
stow -n -v ghostty      # dry run, verbose
```

Stow defaults its target to the parent of the current directory, which is `$HOME`
when the repo lives at `~/.dotfiles`. From anywhere else, be explicit:

```sh
stow --dir ~/.dotfiles --target ~ ghostty
```

## Adding a new package

1. Make the directory with the path it should have relative to `$HOME`:

   ```sh
   mkdir -p ~/.dotfiles/nvim/.config/nvim
   ```

2. Move the real config in, then link it back:

   ```sh
   mv ~/.config/nvim/init.lua ~/.dotfiles/nvim/.config/nvim/
   cd ~/.dotfiles && stow nvim
   ```

   Or let stow do the move for you with `stow --adopt nvim`, which replaces the
   repo's copy with whatever is currently in `$HOME`. Check `git diff` afterwards,
   since adopt overwrites tracked files.

3. Commit.

## Conflicts

Stow refuses to overwrite a real file that already exists in `$HOME`. Two ways out:

- Back it up and let stow win: `mv ~/.config/ghostty/config{,.bak}` then re-run.
- Keep the existing file as the source of truth: `./install.sh --adopt`, which
  moves it into the repo and links it back.
