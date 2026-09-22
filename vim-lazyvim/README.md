# vim-lazyvim

Personal [LazyVim](https://www.lazyvim.org/) configuration for Neovim, backed up from
`~/.config/nvim`.

## Requirements

- Neovim >= 0.11 (tested on 0.11.5)
- git
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal
- Node.js/npm — required by several Mason-installed language servers
  (`pyright`, `vtsls`, `json-lsp`). Install via `brew install node` if missing.
- `ripgrep` and `fd` (used by the Snacks picker)
- `rust-analyzer` on `PATH` — for Rust support. Install via
  `rustup component add rust-analyzer` (not Mason-managed; see below).

## Installing

```sh
git clone <this-repo> ~/.config/nvim
nvim
```

Neovim will bootstrap `lazy.nvim` on first launch and install all plugins and
Mason tools automatically.

## Layout

This mirrors the standard [LazyVim starter](https://github.com/LazyVim/starter)
layout:

```
.
├── init.lua                 -- bootstraps config.lazy
├── lazy-lock.json           -- pinned plugin commits (committed for reproducibility)
├── lazyvim.json              -- enabled LazyVim "extras" (see below)
├── stylua.toml               -- Lua formatter config
├── .neoconf.json             -- neodev/neoconf settings for editing this config's own Lua
└── lua
    ├── config
    │   ├── autocmds.lua      -- empty; only LazyVim's defaults are active
    │   ├── keymaps.lua       -- empty; only LazyVim's defaults are active
    │   ├── lazy.lua          -- lazy.nvim bootstrap + plugin spec entrypoint
    │   └── options.lua       -- empty; only LazyVim's defaults are active
    └── plugins
        └── example.lua       -- all personal plugin overrides live here
```

## What's customized

Everything is stock LazyVim defaults except for `lua/plugins/example.lua` and
the `extras` list in `lazyvim.json`.

### Colorscheme

- [`gruvbox.nvim`](https://github.com/ellisonleao/gruvbox.nvim) is added and
  set as the active LazyVim colorscheme (`example.lua`).

### LSP / language servers

- **Python** — `pyright`, wired up directly in `example.lua` via the
  `neovim/nvim-lspconfig` spec. Installed automatically by Mason.
- **TypeScript** — enabled via the `lazyvim.plugins.extras.lang.typescript`
  extra (uses `vtsls`, not the old/unmaintained
  `jose-elias-alvarez/typescript.nvim`).
- **JSON** — enabled via the `lazyvim.plugins.extras.lang.json` extra
  (`json-lsp` + schemastore + JSON treesitter grammar).
- **Rust** — enabled via the `lazyvim.plugins.extras.lang.rust` extra. This
  pulls in [`rustaceanvim`](https://github.com/mrcjkb/rustaceanvim) (which
  drives `rust-analyzer` itself instead of going through `nvim-lspconfig`
  directly) and [`crates.nvim`](https://github.com/Saecki/crates.nvim) for
  `Cargo.toml` completion/hover. **`rust-analyzer` is *not* Mason-managed by
  this extra** — it must already be on `PATH` (install via `rustup component
  add rust-analyzer`); `rustaceanvim` prints an error on attach if it isn't
  found. Mason does install `codelldb` for debugging via `nvim-dap`.
- **Lua** — handled entirely by LazyVim's defaults (`lua_ls`), plus
  `.neoconf.json` enabling `neodev` so this config's own Lua is properly
  typed against Neovim's runtime API.

### Mason-managed tools

Declared in the `mason-org/mason.nvim` spec in `example.lua`:

- `stylua` (Lua formatter)
- `shellcheck` / `shfmt` (shell linting/formatting)
- `flake8` (Python linting)

(`pyright`, `vtsls`, and `json-lsp` are also Mason-managed, but installed
implicitly by their respective LSP specs/extras rather than listed here.)

### Treesitter

`ensure_installed` is extended (not overwritten — see the comment in
`example.lua` about `vim.tbl_deep_extend` only merging tables, not lists) to
add: `bash`, `html`, `javascript`, `json`, `lua`, `markdown`,
`markdown_inline`, `python`, `query`, `regex`, `tsx`, `typescript`, `vim`,
`yaml`.

### UI

- **Dashboard**: `mini.starter` is used instead of the default Snacks
  dashboard, enabled via the `ui.mini-starter` entry in `lazyvim.json`'s
  `extras` list (**not** imported directly from a plugins file — see
  "Gotchas" below).
- **Trouble**: diagnostic signs enabled via `use_diagnostic_signs = true`
  (a second spec then disables Trouble entirely — last one wins; edit
  `example.lua` if you want Trouble back).
- **Lualine**: has two competing example overrides in `example.lua` (one adds
  an emoji segment, one returns an empty override) — the second wins and
  effectively no-ops. Left in place as reference; edit if you actually want a
  custom lualine.

### Picker / completion

Both `nvim-cmp` and `telescope.nvim` overrides were removed from this config.
Current LazyVim defaults to `blink.cmp` for completion and the Snacks picker
for fuzzy finding — those older plugins aren't part of the default plugin set
anymore, so keeping override specs for them just installed unused plugins. To
switch back, see `lazyvim.plugins.extras.coding.nvim-cmp` /
`lazyvim.plugins.extras.editor.telescope`.

## Gotchas / lessons learned

These came up while restoring this config from backup and are worth knowing
before editing further:

1. **Enable LazyVim "extras" via `lazyvim.json`, not by importing them
   directly from a file under `lua/plugins/`.** LazyVim enforces an import
   order (`lazyvim.plugins` → `lazyvim.plugins.extras.*` → your own
   `plugins`). Importing an extra from inside your own `plugins/*.lua` puts
   it *after* your plugins in the merge order instead of before, which:
   - trips LazyVim's own "order of your lazy.nvim imports is incorrect"
     warning, and
   - for `ui.mini-starter` specifically, causes a hard crash
     (`vim/shared.lua:0: dst: expected table, got nil`) because a default
     extra (`editor.snacks_picker`) patches `mini.starter`'s `opts.items` and
     expects it to already exist.

   Use `:LazyExtras` (or hand-edit the `extras` array in `lazyvim.json`)
   instead.

2. **`jose-elias-alvarez/typescript.nvim` is dead.** The repo was deleted by
   its author years ago; a manual `dependencies` entry pointing at it fails
   to clone with a confusing `could not read Username for 'https://github.com/'`
   error (looks like an auth problem, isn't one). Use the built-in
   `lazyvim.plugins.extras.lang.typescript` extra instead, which uses
   `vtsls`.

3. **`williamboman/mason.nvim` was renamed to `mason-org/mason.nvim`.** Old
   configs/examples referencing the old name still work but print a
   deprecation warning on every startup.

4. **Mason-installed servers need Node.js.** `pyright`, `vtsls`, and
   `json-lsp` are npm packages under the hood. If `npm` isn't on `PATH`,
   Mason fails to install them with `ENOENT: no such file or directory`, and
   because Mason retries pending installs on LSP-related events, the failure
   notification can show up when opening an unrelated file (e.g. a `.rs`
   file) rather than when you'd expect it.

5. **This directory is not itself a git repo** (`~/.config/nvim/.git` doesn't
   exist) — it's tracked here in `dotfiles` instead. The stock LazyVim
   starter's own `LICENSE` and `README.md` were intentionally *not* copied
   into this repo (they describe the upstream starter template, not this
   config); this file replaces them.
