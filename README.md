# Better gf - open files at position

I run terminals inside vim. Often commands output file locations in, for example,
search or error messages.

e.g. `foobar.adb:27:2: "X" not declared in "Y"`

`gf` on that line results in opening foobar.adb in some non-terminal buffer
(so it keeps the terminal open if you executed this from a terminal buffer)
and jumping to the place mentioned by issuing '27G2|' (i.e. it also goes to the right column)

`gf` opens files by default in (neo)vim, and `vt:<C-W>gf` is okay but:
1) you have to visually select the filename yourself
2) including the [colon][linenumber] suffix does not work as intended in NeoVim
3) this does not include the column, 
4) it opens in the terminal window, which is inconvenient

## Features

### create files

`gF` is also mapped, to create the file at exactly that location. For instance,
you could write `source ~/vimrc/newfile.vim` and then immediately gF on that to create the file.

### open plugins

In addition, gf on a line such as:

```
Plug 'AndrewRadev/switch.vim'
```

opens `~/.vim/plugged/switch.vim`

### various built-in replacements

There's a list of regexes so that lines like:

```
Messy quoted things 'filename.txt' work
And also (in_brackets.md:500) or
file=README.md
```

automagically work. For more, use bettergf_magic_replacements (described below).

### open lua configuration files

```
lua require('file')
```

opens `~/vimrc/lua/file.lua`

## See also

[SanerGX](https://github.com/TamaMcGlinn/vim-sanergx) is a similar plugin,
opening URLs in the browser. gx on the plugin line above opens the github page for the plugin.

# Customization

You can specify custom replacements inside the path, which is useful, for example, if your
error messages are coming from a dockerized script, which has the script mounted elsewhere
than on your own machine. For instance, if you want to replace '/docker_root/' with '' before
trying to open the file, put this in your vimrc:

```
let g:bettergf_magic_replacements = [['/docker_root/', '', '']]
```

The three parameters in each replacement are simply passed on to vim's substitute() function.
