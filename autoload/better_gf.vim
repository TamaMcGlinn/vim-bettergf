fu! better_gf#HandleCustomReplacements(s) abort
  let l:s = a:s
  let l:replacements = get(g:, 'bettergf_magic_replacements', [])
  for l:r in l:replacements
    let l:s = substitute(l:s, l:r[0], l:r[1], l:r[2])
  endfor
  return l:s
endfunction

fu! better_gf#GetFileLocation(s, line='') abort
  " e.g. lua require('yank_and_paste')
  if a:line =~# "^lua require([\'\"][^\'\"]*[\'\"]).*$"
    let l:lua_config = substitute(a:line, "lua require([\'\"]\\\([^\'\"]*\\\).*$", '\1', '')
    return ["~/vimrc/lua/" . l:lua_config . ".lua"]
  endif
  " e.g. Plug 'TamaMcGlinn/CurtineIncSw.vim'
  if a:line =~# "^\"* *Plug '[^/~][^/~]*/[^/]*'"
    let l:plugin_dir = substitute(substitute(a:line, "^\"* *Plug '.*/", '~/.vim/plugged/', ''), "'.*$", '/', '')
    return [l:plugin_dir]
  endif

  let l:selection=a:s
  " Strip trailing ;
  let l:selection=substitute(l:selection, ";$", '', '')
  " Strip trailing characters ).";'
  let l:selection=substitute(l:selection, "[)\.\";']*$", '', '')
  " Strip leading .*=
  let l:selection=substitute(l:selection, ".*=", '', '')
  " Strip leading .*[]
  let l:selection=substitute(l:selection, ".*[\]\[]", '', '')
  " Strip leading (
  let l:selection=substitute(l:selection, "^(", '', '')
  " Strip leading .*|
  let l:selection=substitute(l:selection, "^.*|", '', '')
  " Strip leading and trailing single quotes
  let l:selection=substitute(l:selection, "^'", '', '')
  let l:selection=substitute(l:selection, "'$", '', '')
  " Strip one leading double quote, some trailing quotes and commas
  let l:selection=substitute(l:selection, '^"\?\([^,"]*\)\([",]*\)\?$', '\1', '')
  " Strip leading ./ if present
  let l:selection=substitute(l:selection, '^\./', '', '')
  " Replace filename(30) with filename:30
  let l:selection=substitute(l:selection, '(\([0-9][0-9]*\))', ':\1', '')
  " Replace `` around filenames
  let l:selection=substitute(l:selection, '^.*`\([^`]*\)`.*$', '\1', '')

  " TODO strip common parts of current path so that when I am somewhere deeper
  " in my project, I can still gf to a file path specified from the root of that
  " project
  
  let l:selection=better_gf#HandleCustomReplacements(l:selection)
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
  call better_gf#Openfile(a:s, v:true, l:line)
endfunction

" Jump to buffer open in same window that
" is not a terminal, or create a split if there is none
" prefer splits with given extension
fu! better_gf#JumpToNormalBuffer(preferred_extension = '') abort
  " if current buffer is normal (non-fugitive, non-terminal) buffer
  let current_buffer_is_normal = v:false
  if &buftype !=# 'terminal' && !exists('b:fugitive_status')
    let current_buffer_is_normal = v:true
    let current_extension = expand("%:t:e")
    " and has same extension
    if current_extension ==? a:preferred_extension
      " done; don't switch at all
      return
    endif
  endif

  " get non-fugitive, non-terminal windows in current tab
  let current_tab = tabpagenr()
  let windows = map(filter(getwininfo(),
        \ 'has_key(v:val["variables"], "fugitive_status") == 0 && v:val["terminal"] == 0 && v:val["tabnr"] == ' .. l:current_tab), 
        \ '{"winid": v:val["winid"], "bufname": bufname(v:val["bufnr"])}')
  let same_extension = filter(copy(l:windows), 'substitute(v:val["bufname"], "^.*\\.", "", "") ==? "' .. a:preferred_extension .. '"')
  if !empty(same_extension)
    let winid = same_extension[0]["winid"]
    call win_gotoid(winid)
  elseif l:current_buffer_is_normal
    " current buffer is option, and there was no preferred_extension
    " option to choose instead
    return
  elseif !empty(windows)
    let winid = windows[0]["winid"]
    call win_gotoid(winid)
  else
    " Unable to find non-terminal window in current tab, create a new split
    execute 'sp'
  endif
endfunction

" https://vi.stackexchange.com/questions/29056/how-to-find-first-item-that-satisfies-predicate
function! s:FindItem(object, Fn) abort
    return get(filter(copy(a:object), "a:Fn(v:val)"), 0, v:null)
endfunction

" https://vi.stackexchange.com/a/29063/18875
fu! s:EndsWith(longer, shorter) abort
  return a:longer[len(a:longer)-len(a:shorter):] ==# a:shorter
endfunction

fu! s:Contains(longer, short) abort
  return stridx(a:longer, a:short) >= 0
endfunction

fu! better_gf#Openfile(s, fromterminal=v:false, line='') abort
  if &ft == 'lspinfo'
    execute 'bd'
  endif
  let l:target = better_gf#ParseTarget(a:s, a:fromterminal, a:line)
  let l:preferred_extension_for_window = substitute(l:target["filename"], "^.*\\.", "", "")
  call better_gf#JumpToNormalBuffer(l:preferred_extension_for_window)
  " get rid of localdir if present
  if haslocaldir()
    execute 'cd' getcwd(-1)
  endif
  call better_gf#JumpToTarget(l:target)
endfunction

fu! better_gf#JumpToTarget(target)
  let l:exact_location = expand("%:h") . "/" . a:target["filename"]
  let l:newtarget = substitute(a:target["filename"], "^\\(\\.\\./\\)\\+", "", "")
  " let l:dirs_up = (len(a:target["filename"]) - len(l:newtarget)) / 3
  if filereadable(l:exact_location)
    let l:command = 'edit ' . fnameescape(l:exact_location)
  else
    let l:command = 'find ' . l:newtarget
  endif

  " find the file 
  if a:target["line"] isnot v:null
    " keepjumps ensures the top of the file is not added to the jumplist
    silent execute 'keepjumps ' . l:command
  else
    silent execute l:command
    " if no line, then also no column so we are done
    return
  endif

  if a:target["column"] isnot v:null
    " go to the indicated line and column
    silent execute 'normal! ' . a:target["line"] . 'G' . a:target["column"] . '|'
  else " l:line must also be defined
    " go to the indicated line
    silent execute 'normal! ' . a:target["line"] . 'G'
  endif
endfunction

fu! better_gf#ParseTarget(s, fromterminal=v:false, line='') abort
  let l:filename = a:s
  if a:fromterminal || &ft == 'git'
    " fugitive buffers sometimes mention files with a/ or b/ prefix
    " but if there is a directory or file with exactly this name,
    " we still prefer that, so we skip this prefix-stripping
    if !isdirectory(l:filename) && !filereadable(l:filename)
      let l:filename = substitute(l:filename, '^[ab]/', '', '')
    endif
  endif
  let l:elements=better_gf#GetFileLocation(l:filename, a:line)
  let l:elementlen=len(l:elements)
  if l:elementlen == 0
    return
  endif
  let l:filename=l:elements[0]
  let l:line = v:null
  let l:column = v:null
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
  if exists('*MruGetFiles')
    let l:mru = MruGetFiles()
    let l:cwd = getcwd(-1) . "/"
    let l:match = s:FindItem(l:mru, {item -> s:Contains(item, l:cwd) && s:EndsWith(item, '/' .. l:filename)})
    if l:match isnot v:null
      let l:filename = l:match
    endif
  endif
  return {"filename": l:filename, "line": l:line, "column": l:column}
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
  let target_extension = substitute(a:a, "^.*\\.", "", "")
  call better_gf#JumpToNormalBuffer(target_extension)
  call better_gf#Createfile(a:s)
endfunction

function! better_gf#Createfile(s)
  let l:elements = better_gf#GetFileLocation(a:s) 
  let l:filename=l:elements[0]
  silent execute 'e ' . l:filename
endfunction

