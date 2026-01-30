" ┌───────────────────────────────────────────────────────────────────────────┐
" │                              Vim Configuration                             │
" └───────────────────────────────────────────────────────────────────────────┘

" Line numbers
set number
set relativenumber

" Indentation
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent

" Visual
set cursorline
set scrolloff=5
set showmatch
syntax on
set background=dark
colorscheme default

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Behavior
set backspace=indent,eol,start
set mouse=a
set clipboard=unnamedplus

" Performance
set lazyredraw
set ttyfast
