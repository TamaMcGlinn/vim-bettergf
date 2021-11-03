# Better gf - open files at position

I run terminals inside vim. Often commands output file locations in, for example,
search or error messages.

e.g. `foobar.adb:27:2: "X" not declared in "Y"`

results in opening foobar.adb in some non-terminal buffer (so it keeps the terminal open
if you executed this from a terminal buffer)
and jumping to the place mentioned by issuing '27G2|' (i.e. it also goes to the right column)

`gf` opens files by default in (neo)vim, and `vt:<C-W>gf` is okay but:
1) you have to visually select the filename yourself
2) including the [colon][linenumber] suffix does not work as intended in NeoVim
3) this does not include the column, 
4) it opens in the terminal window, which is inconvenient

`gF` is also mapped, to create the file at exactly that location. For instance,
you could write `source ~/vimrc/newfile.vim` and then immediately gF on that to create the file.

See also https://github.com/TamaMcGlinn/vim-sanergx for a similar fix for gx,
opening URLs in the browser.

