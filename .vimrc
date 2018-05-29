" Use Vim settings, rather then Vi settings. This setting must be as early as
" possible, as it has side effects.
set nocompatible

set cursorline " highlight the current line
set visualbell " stop the bell

" To show/hide whitespace:
" set list
" set unlist
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<

"" Cscope Compatibility
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

  " command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src
endif

"Toggle relative numbering, and set to absolute on loss of focus or insert mode
set rnu
function! ToggleNumbersOn()
    set nu!
    set rnu
endfunction
function! ToggleRelativeOn()
    set rnu!
    set nu
endfunction
autocmd FocusLost * call ToggleRelativeOn()
autocmd FocusGained * call ToggleRelativeOn()
autocmd InsertEnter * call ToggleRelativeOn()
autocmd InsertLeave * call ToggleRelativeOn()

"" Plugins
" vim-pathogen
execute pathogen#infect()
" vim-colors-solarized
syntax enable
set background=dark
colorscheme solarized
" vim-airline
set laststatus=2 " Always display the status line
set timeoutlen=1000 ttimeoutlen=0
let g:bufferline_echo = 0
" NERDTree
let NERDTreeShowHidden=1
" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0 " Change back to 1
let g:syntastic_check_on_wq = 0
command -nargs=0 Errors Errors | set rnu
