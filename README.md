# Better gf

`gf` opens files by default in (neo)vim. However, when I get a filename in the terminal,
I generally want to open that file in some other split. This plugin does that.

It also opens the line and column if specified as filename:[line]:[column] - such as a compiler
might emit.

`gF` is also mapped, to create the file at exactly that location. For instance,
you could write `source ~/vimrc/newfile.vim` and then immediately gF on that to create the file.

See also https://github.com/TamaMcGlinn/vim-sanergx for a similar fix for gx,
opening URLs in the browser.

