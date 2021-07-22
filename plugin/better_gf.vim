augroup Terminal_gf_mapping
  autocmd!
  autocmd TermOpen * nnoremap <silent> <buffer> gf :call better_gf#OpenfileInTopBuffer( expand('<cWORD>') )<CR>
augroup END

vnoremap <silent> gf :call better_gf#OpenfileInTopBuffer( better_gf#GetVisualSelection() )<CR>

" with a capital is to create if it doesn't exist yet
noremap gF :e <cfile><cr>
