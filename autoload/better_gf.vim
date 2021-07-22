" Open file at position from compiler error on the terminal
" e.g. foobar.adb:27:2: "X" not declared in "Y"
" results in opening foobar.adb in the top buffer (not the terminal), and issuing '27G2|'
" Default vim comes close with 'vt:<C-W>gf' - but:
" 1) including the [colon][linenumber] suffix does not work as intended in NeoVim
" 2) this does not include the column, 
" 3) you cannot reuse the top window.

" TODO strip common parts of current path so that when I am somewhere deeper
" in my project, I can still gf to a file path specified from the root of that
" project
fu! better_gf#OpenfileInTopBuffer(s)
  let selection=a:s
  if selection[0]=='"'
    let selection=selection[1:]
  endif
  if selection[-1]==','
    let selection=selection[:-1]
  endif
  if selection[-1]=='"'
    let selection=selection[:-1]
  endif
  if selection[1:1]==':'
    " One letter directory assumed to be drivename under windows
    let elements=split(selection[2:], ':')
    let elements[0]=selection[0:1]..elements[0]
  else
    let elements=split(selection, ':')
  endif
  let elementlen=len(elements)
  let filename=elements[0]
  if matchstr(filename, "^.*\\..*$")=="" " doesn't look like filename (. missing)
    if input("Really open "..filename.."? (y/n)")!="y"
      return
    endif
  endif
  if elementlen > 1
    let line=elements[1]
    if matchstr(line, "^[0-9]*$")=="" " line is not a number
      let elementlen=1
    endif
    if elementlen > 2
      let column=elements[2]
      if matchstr(column, "^[0-9]*$")=="" " column is not a number
        let elementlen=2
      endif
    endif
  endif
  " switch to top buffer
  silent execute 'wincmd k'
  " get rid of localdir if present
  if haslocaldir()
    execute 'cd' getcwd(-1)
  endif
  try
    " find the file 
    if elementlen > 1
      " keepjumps ensures the top of the file is not added to the jumplist
      silent execute 'keepjumps find ' . filename
    else
      silent execute 'find ' . filename
      return
    endif
    if elementlen >= 3
      " go to the indicated line and column
      silent execute 'normal! ' . line . 'G' . column . '|'
    else " elementlen == 2
      " go to the indicated line
      silent execute 'normal! ' . line . 'G'
    endif
  endtry
endfunction

function! better_gf#GetVisualSelection()
  let reg = '"'
  let [save_reg, save_type] = [getreg(reg), getregtype(reg)]
  normal! gv""y
  let text = @"
  call setreg(reg, save_reg, save_type)
  return text
endfunction

