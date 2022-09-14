" Settings that must come first
set nocompatible " Use Vim settings instead of the Vi compatibility settings

" General settings
set encoding=utf-8 " ensure the encoding is set correctly
set hlsearch " highlight search results
set incsearch " enable incremental search with /
set laststatus=2 " always show the status line
set noautoindent " stop vim from autoindenting pasted code
set nowrap " do not wrap long lines
set number " show non-relative line numbers
set belloff=all " stop the bell
syntax on " turn on syntax highlighting

" Set to use spaces instead of tabs
filetype plugin indent on " enable file type recognition and smart indent support
set tabstop=4 " set the width of tabs to be 4 spaces
set shiftwidth=4 " number of spaces auto indent should use for an indent
set expandtab " input spaces when tab is pressed

" Timestamp shortcut and syntax highlighting
nmap <F1> i<C-R>=strftime("[[%Y-%m-%d %H:%M:%S]] -- ")<CR><Esc>
imap <F1> <C-R>=strftime("[[%Y-%m-%d %H:%M:%S]] -- ")<CR>
syntax region wikilink start=/\[\[/ end=/\]\]/
highlight wikilink ctermfg=5 guifg=SlateBlue " use :highlight for other options

" Cscope Compatibility
" http://vim.wikia.com/wiki/Cscope
if has('cscope')
  set cscopetag cscopeverbose

  if has('quickfix')
    set cscopequickfix=s-,c-,d-,i-,t-,e-
  endif

  cnoreabbrev csa cs add
  cnoreabbrev csf cs find
  cnoreabbrev csk cs kill
  cnoreabbrev csr cs reset
  cnoreabbrev css cs show
  cnoreabbrev csh cs help
endif
