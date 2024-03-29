augroup Terminal_gf_mapping
  autocmd!
  if has('nvim')
    autocmd TermOpen * nnoremap <silent> <buffer> gf :call better_gf#OpenfileInNormalBuffer( expand('<cWORD>') )<CR>
    autocmd TermOpen * vnoremap <silent> <buffer> gf :call better_gf#OpenfileInNormalBuffer( better_gf#GetVisualSelection() )<CR>

    " with a capital is to create if it doesn't exist yet
    autocmd TermOpen * nnoremap <silent> <buffer> gF :call better_gf#CreatefileInNormalBuffer( expand('<cWORD>') )<CR>
    autocmd TermOpen * vnoremap <silent> <buffer> gF :call better_gf#CreatefileInNormalBuffer( better_gf#GetVisualSelection() )<CR>
  else
    autocmd TerminalOpen * nnoremap <silent> <buffer> gf :call better_gf#OpenfileInNormalBuffer( expand('<cWORD>') )<CR>
    autocmd TerminalOpen * vnoremap <silent> <buffer> gf :call better_gf#OpenfileInNormalBuffer( better_gf#GetVisualSelection() )<CR>

    " with a capital is to create if it doesn't exist yet
    autocmd TerminalOpen * nnoremap <silent> <buffer> gF :call better_gf#CreatefileInNormalBuffer( expand('<cWORD>') )<CR>
    autocmd TerminalOpen * vnoremap <silent> <buffer> gF :call better_gf#CreatefileInNormalBuffer( better_gf#GetVisualSelection() )<CR>
  endif
augroup END

vnoremap <silent> gf :call better_gf#Openfile( better_gf#GetVisualSelection(), v:false, getline('.') )<CR>
nnoremap <silent> gf :call better_gf#Openfile( expand('<cWORD>'), v:false, getline('.') )<CR>

" with a capital is to create if it doesn't exist yet
nnoremap <silent> gF :call better_gf#Createfile( expand('<cWORD>') )<CR>
vnoremap <silent> gF :call better_gf#Createfile( better_gf#GetVisualSelection() )<CR>
