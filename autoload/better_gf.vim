fu! better_gf#GetFileLocation(s, line='') abort
  let l:selection=a:s
  " Strip leading .*=
  let l:selection=substitute(l:selection, ".*=", '', '')
  " Strip leading .*[]
  let l:selection=substitute(l:selection, ".*[\]\[]", '', '')
  " Strip leading and trailing single quotes
  let l:selection=substitute(l:selection, "^'", '', '')
  let l:selection=substitute(l:selection, "'$", '', '')
  " Strip one leading double quote, some trailing quotes and commas
  let l:selection=substitute(l:selection, '^"\?\([^,"]*\)\([",]*\)\?$', '\1', '')
  " Strip leading ./ if present
  let l:selection=substitute(l:selection, '^\./', '', '')
  " Replace filename(30) with filename:30
  let l:selection=substitute(l:selection, '(\([0-9][0-9]*\))', ':\1', '')

  " TODO strip common parts of current path so that when I am somewhere deeper
  " in my project, I can still gf to a file path specified from the root of that
  " project

  if has('win32') && selection[1]==':'
    " One letter directory assumed to be drivename under windows
    " so we shift everything over one spot but still have the drivename
    " inside the filename
    let drivename=selection[0:1]
    let l:elements=split(selection[2:], ':')
    let l:elements[0]=drivename..l:elements[0]
  else
    let l:elements=split(selection, ':')
  endif

  let l:elementlen=len(l:elements)
  if l:elementlen == 1
    if a:line =~? '.* line [0-9]*'
      let l:line_nr=substitute(a:line, '\c.* line \([0-9]*\).*', '\1', '')
      let l:elements = l:elements + [l:line_nr]
    endif
  endif

  return l:elements
endfunction

fu! better_gf#OpenfileInNormalBuffer(s) abort
  let l:line=getline('.')
  call better_gf#JumpToNormalBuffer()
  call better_gf#Openfile(a:s, l:line)
endfunction

fu! better_gf#JumpToNormalBuffer() abort
  if &buftype !=# 'terminal'
    return
  endif
  let l:first_window_number = winnr()
  while v:true
    execute "wincmd W"
    if &buftype !=# 'terminal'
      return
    endif
    if winnr() == l:first_window_number
      break
    endif
  endwhile
  " Unable to find non-terminal window in current tab, create a new split
  execute 'sp'
endfunction

fu! better_gf#Openfile(s, line='') abort
  let l:filename = a:s
  if &ft == 'git'
    " fugitive buffers sometimes mention files with a/ or b/ prefix
    " but if there is a directory or file with exactly this name,
    " we still prefer that, so we skip this prefix-stripping
    if !isdirectory(l:filename) && !filereadable(l:filename)
      let l:filename = substitute(l:filename, '^[ab]/', '', '')
    endif
  endif
  let l:elements=better_gf#GetFileLocation(l:filename, a:line)
  let l:elementlen=len(l:elements)
  let l:filename=l:elements[0]
  if l:elementlen > 1
    let l:line=l:elements[1]
    if matchstr(l:line, "^[0-9]*$")=="" " line is not a number, ignore line & column number
      let l:elementlen=1
    endif
    if l:elementlen > 2
      let l:column=l:elements[2]
      if matchstr(l:column, "^[0-9]*$")=="" " column is not a number, only use line number
        let l:elementlen=2
      endif
    endif
  endif
  " get rid of localdir if present
  if haslocaldir()
    execute 'cd' getcwd(-1)
  endif
  try
    " find the file 
    if l:elementlen > 1
      " keepjumps ensures the top of the file is not added to the jumplist
      silent execute 'keepjumps find ' . l:filename
    else
      silent execute 'find ' . l:filename
      return
    endif
    if l:elementlen >= 3
      " go to the indicated line and column
      silent execute 'normal! ' . l:line . 'G' . l:column . '|'
    else " l:elementlen == 2
      " go to the indicated line
      silent execute 'normal! ' . l:line . 'G'
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

function! better_gf#CreatefileInNormalBuffer(s)
  call better_gf#JumpToNormalBuffer()
  call better_gf#Createfile(a:s)
endfunction

function! better_gf#Createfile(s)
  let l:elements = better_gf#GetFileLocation(a:s) 
  let l:filename=l:elements[0]
  silent execute 'e ' . l:filename
endfunction

