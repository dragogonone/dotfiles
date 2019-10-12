noremap j gj
noremap k gk
noremap <S-h>   ^
noremap <S-j>   }
noremap <S-k>   {
noremap <S-l>   $l

set clipboard+=unnamed

:syntax on

" vimplug
call plug#begin('~/.vim/plugged')
call plug#end()