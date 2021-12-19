" Settings that must come first
set nocompatible " Use Vim settings instead of the Vi compatibility settings

set encoding=utf-8 " ensure the encoding is set correctly
set hlsearch " highlight search results
set incsearch " enable incremental search with /
set laststatus=2 " always show the status line
set noautoindent " stop vim from autoindenting pasted code
set nowrap " do not wrap long lines
set number " show non-relative line numbers
set visualbell " stop the bell
syntax on " turn on syntax highlighting

" Show or hide whitespace (usage: set list[!])
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<

" Timestamp shortcut and syntax highlighting
nmap <F5> i<C-R>=strftime("[[%Y-%m-%d %H:%M:%S]] -- ")<CR><Esc>
imap <F5> <C-R>=strftime("[[%Y-%m-%d %H:%M:%S]] -- ")<CR>
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