call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'tomasr/molokai'
Plug 'dracula/vim'
Plug 'joshdick/onedark.vim'
call plug#end()

" カラースキームを設定
colorscheme gruvbox
set background=dark

" エンコーディング設定
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp

" シンタックスハイライトを有効化
syntax on

" 行番号を表示
set number

" タブとスペースを表示
set list
set listchars=tab:>-,trail:-
