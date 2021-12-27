augroup Terminal_gf_mapping
  autocmd!
  autocmd TermOpen * nnoremap <silent> <buffer> gf :call better_gf#OpenfileInNormalBuffer( expand('<cWORD>') )<CR>
  autocmd TermOpen * vnoremap <silent> <buffer> gf :call better_gf#OpenfileInNormalBuffer( better_gf#GetVisualSelection() )<CR>

  " with a capital is to create if it doesn't exist yet
  autocmd TermOpen * nnoremap <silent> <buffer> gF :call better_gf#CreatefileInNormalBuffer( expand('<cWORD>') )<CR>
  autocmd TermOpen * vnoremap <silent> <buffer> gF :call better_gf#CreatefileInNormalBuffer( better_gf#GetVisualSelection() )<CR>
augroup END

vnoremap <silent> gf :call better_gf#Openfile( better_gf#GetVisualSelection(), v:false, getline('.') )<CR>
nnoremap <silent> gf :call better_gf#Openfile( expand('<cWORD>'), v:false, getline('.') )<CR>

" with a capital is to create if it doesn't exist yet
nnoremap <silent> gF :call better_gf#Createfile( expand('<cWORD>'), v:false, getline('.') )<CR>
vnoremap <silent> gF :call better_gf#Createfile( better_gf#GetVisualSelection(), v:false, getline('.') )<CR>
