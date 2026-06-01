# smucd

A fuzzy + typo-tolerant `cd` replacement for Zsh.

It improves directory navigation by allowing:
- Partial name matching
- Case-insensitive search
- Character fuzzing (handles typos)
- Space-robust input
- Subsequence matching
- Interactive selection when multiple matches exist

---

## Features

- Overrides `cd`
- Fuzzy directory resolution (no exact typing required)
- Handles messy input like:

```zsh
cd TTEseststetsetsetstTTEsestsdtEst
```

and still resolves likely matches

- Works with paths containing spaces
- Interactive selector when multiple matches are found
- Scrollable UI for large result sets

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/pro555161rblxs/smucd.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/smucd
```

### 2. Enable plugin

Add to your `.zshrc`:

```zsh
plugins=(... smucd)
```

### 3. Reload Zsh

```bash
source ~/.zshrc
```

---

## Usage

After installation:

```zsh
cd <folder-name-or-approximation>
```

### Examples

```zsh
cd Downloads
cd downlods
cd te
cd ProjctFlder
```

If multiple matches exist, an interactive selector opens:

- ↑ / ↓ navigate
- Enter to select
- Esc to cancel

---

## Notes

- This overrides the default `cd` function in Zsh
```
