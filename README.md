# smucd

A fuzzy + typo-tolerant `cd` replacement for Zsh.

It improves directory navigation by allowing:
- Partial name matching
- Case-insensitive search
- Character fuzzing (handles typos)
- Space-robust input
- Subsequence matching
- Interactive selection when multiple matches exist

## Features

- Overrides `cd`
- Fuzzy directory resolution (no exact typing required)
- Handles messy input like:

cd TTEseststetsetsetstTTEsestsdtEst

and still resolves likely matches
- Works with paths containing spaces
- Interactive selector when multiple matches are found
- Scrollable UI for large result sets


## Installation
Clone the repository into the custom plugins directory:

git clone https://github.com/pro555161rblxs/smucd.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/smucd

Enable the plugin by adding it to your .zshrc:

plugins=(... smucd)

Reload Zsh:

source ~/.zshrc

## Usage

After installing and sourcing the plugin:


cd <folder-name-or-approximation>

Examples:

cd Downloads
cd downlods
cd te
cd ProjctFlder

If multiple matches exist, a selector UI opens where you can:

↑ / ↓ navigate
Enter to select
Esc to cancel

Notes
This overrides the default cd function.
