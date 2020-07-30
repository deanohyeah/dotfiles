" installs vim plug and does initial install of plugins
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" " Declare the list of plugins.
Plug 'digitaltoad/vim-pug'
Plug 'pangloss/vim-javascript'
Plug 'honza/vim-snippets'
Plug 'dense-analysis/ale'
Plug 'jparise/vim-graphql'
Plug 'kchmck/vim-coffee-script'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'ervandew/supertab'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-ruby/vim-ruby'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
Plug 'sickill/vim-monokai'
Plug 'vim-airline/vim-airline'
Plug 'ap/vim-css-color'
"Typescript Plugins
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

"fgarland/typescript-vim " List ends here. Plugins become visible to Vim after this call.
call plug#end()

set path+=~/repos/PortalDev/src/
set path+=~/repos/frontend-style-service/src/

syntax on
colorscheme monokai
let g:airline#extensions#tabline#enabled = 1
filetype plugin indent on
" Tab navigation like Firefox.
nnoremap ]] :tabnext<CR>
nnoremap [[ :tabprev<CR>
nnoremap tn :tabnew<CR>

" copy selected to mac clipboard
" As noted, this requires +clipboard out of vim --version, which indicate the
" availability of clipboard support, -clipboard means no.
vmap <C-c> "*y

" filer explorer seetings
nnoremap - :Vexplore<CR>
nnoremap  <C-P> :GFiles<CR>
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15
augroup ProjectDrawer
    autocmd!
      autocmd VimEnter * :Vexplore
    augroup END

" fzf options
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_action = {
  \ 'Enter': 'tabedit',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
" gq use prettier https://github.com/jlongster/prettier
autocmd FileType javascript set formatprg=prettier\ --stdin

:inoremap ;; <ESC>
set vb
set number
set ruler
set showcmd
set showmatch
set smartcase
set mouse=a
" nice font, https://github.com/adobe/source-code-pro
set guifont=SourceCodePro-Medium:h14

" ruby-friendly tab defaults
set tabstop=2
set smarttab
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent
set expandtab
set backspace=indent,eol,start
" Add full file path to your existing statusline
set statusline+=%F
" clears highlight on escape
nnoremap <CR> :noh<CR><esc>
let mapleader = ","
nnoremap <Leader>c :noh<cr>
nnoremap <Leader>r :e ~/repos/rum/package.json<cr>
nnoremap <Leader>p :e ~/repos/PortalDev/package.json<cr>
noremap <Leader>, @a

set autoread
" sets haml syntax for hamlc files
au BufRead,BufNewFile *.hamlc set ft=haml
autocmd BufNewFile,BufRead *.scss set ft=scss.css
" removes whitespace on save
au BufWritePre * :%s/\s\+$//e
" saves session of open tabs
let g:session_autosave = 'yes'
let g:session_autoload = 'yes'
" adds blank space
nnoremap <C-CR> O<Esc>j
" nnoremap <CR> o<Esc>k
nnoremap <CR> i<CR><Esc>
nmap \\ gcc
vmap \\ gc
function! DisplayName(name)
  exe 'visual y'
  exe ':Ag \<C-R>"'
endfunction
vnoremap xl :call DisplayName('bl')<cr>
nmap gf <c-w>gf
" stops cw at .
set iskeyword-=.
"get rid of psky swap files
set noswapfile
" shortcut to edit vimrc
nnoremap ev :vsplit $MYVIMRC<cr>
nnoremap sv :source $MYVIMRC<cr>

"  search options
set incsearch
set hlsearch
highlight Search ctermfg=cyan
hi IncSearch guibg=yellow
hi IncSearch guifg=yellow
hi IncSearch guibg=yellow

function! ModifiedGF()
  let files = []
  let line = getline('.')
  let fullPath = split(line)[3]
  let hasMatch = fullPath !~ '@skytap'
  if hasMatch
    execute "normal! \<c-w>gf"
    return
  endif

  let packagesPath = substitute(fullPath, '@skytap', 'packages', 'g')
  let packagesPath = substitute(packagesPath, "'", '', 'g')
  let packagesPath = substitute(packagesPath, "lib", 'src', 'g')
  execute "tabfind" packagesPath
endfunction

" set path to current file dir
set autochdir
" allows gf to open files without extensions
set suffixesadd+=.coffee
set suffixesadd+=.js
set suffixesadd+=.jade
set suffixesadd+=.gql
set suffixesadd+=.ts
set suffixesadd+=.d.ts
set suffixesadd+=reducer.ts
set suffixesadd+=.html

" https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
