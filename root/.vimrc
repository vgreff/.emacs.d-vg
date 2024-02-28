execute pathogen#infect()
:Helptags

let g:airline#extensions#tabline#enabled = 1

set runtimepath^=~/.vim/bundle/ctrlp.vim
" :helptags ~/.vim/bundle/ctrlp.vim/doc



" commenet line

" set number
set nu
" set nu rnu
" set rnu! to turn off

syntax on
set tabstop=4
set autoindent
set expandtab
set softtabstop=4

" :augroup numbertoggle
" :  autocmd!
" :  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
" :  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
" :augroup END
