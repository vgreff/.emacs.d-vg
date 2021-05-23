execute pathogen#infect()
:Helptags
let g:airline#extensions#tabline#enabled = 1

" commenet line

" set number
syntax on
set tabstop=4
set autoindent
set expandtab
set softtabstop=4

" Use Ctrl+Tab / Ctrl+Shift+Tab to cycle through buffers
nnoremap <silent> <c-tab> :bn<cr>
nnoremap <silent><c-s-tab> :bp<cr>
