:source ./.skytap-vimrc
execute pathogen#infect()
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*


let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'
let g:syntastic_javascript_checkers = ['eslint']
syntax on
filetype plugin indent on
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

:colorscheme monokai
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
" Add full file path to your existing statusline
set statusline+=%F
" clears highlight on escape
nnoremap <CR> :noh<CR><esc>
let mapleader = ","
nnoremap <Leader>, :noh<cr>

set autoread
" sets haml syntax for hamlc files
au BufRead,BufNewFile *.hamlc set ft=haml
autocmd BufNewFile,BufRead *.scss set ft=scss.css
" removes whitespace on save
au BufWritePre * :%s/\s\+$//e
" sets tabs for scss files
autocmd FileType scss setlocal tabstop=4|set shiftwidth=4|set expandtab|set softtabstop=4
" saves session of open tabs
let g:session_autosave = 'yes'
let g:session_autoload = 'yes'
" adds blank space
nnoremap <C-CR> O<Esc>j
nnoremap <CR> o<Esc>k
nnoremap [[ :tabprevious<CR>
nnoremap ]] :tabnext<CR>
function! DisplayName(name)
  exe 'visual y'
  exe ':Ag \<C-R>"'
endfunction
vnoremap xl :call DisplayName('bl')<cr>
nmap gf <c-w>gf
" stops cw at .
set iskeyword-=.
" set path to current file dir
set autochdir
" allows gf to open files without extensions
set suffixesadd+=.coffee
set suffixesadd+=.js
set suffixesadd+=.jade
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

"cucumber step  Script-----------------------------
if exists("b:cuke_root")
  let b:cuke_steps_glob = b:cuke_root.'/**/*'
endif

function! s:getallsteps()
  let step_pattern =  '\/\^.*$\/'
  let steps = []
  for file in split(glob(b:cuke_steps_glob),"\n")
    let lines = readfile(file)
    let num = 0
    for line in lines
      let num += 1
      if line =~ step_pattern
        let type = matchstr(line,'Given\|When\|Then')
        let steps += [[file, num, type, matchstr(line,step_pattern)]]
      endif
    endfor
  endfor
  return steps
endfunction

function! s:stepmatch(pattern,step)
  if a:pattern =~ '^/.*/$'
    let pattern = a:pattern[1:-2]
  else
    return 0
  endif
  try
    " convert to vim pattern
    let vimpattern = substitute(substitute(pattern,'\\\@<!(?:','%(','g'),'\\\@<!\*?','{-}','g')
    " vim doesn't support +?
    let vimpattern = substitute(vimpattern, '+?', '+', 'g')
    " \v is for very magic for more normal regex suppot
    if a:step =~# '\v'.vimpattern
      return 1
    endif
  catch
    echo vimpattern
    echo 'Pattern not supported'
  endtry
endfunction

let g:cucumberStepPatterns = s:getallsteps()

function! FindStep()
  let files = []
  let line = getline('.')
  " strip whitespace and type
  let lineTypeStripped = matchend(line, 'Given \|When \|Then ')
  let line  =  strpart(line, lineTypeStripped)
  for stepPattern in g:cucumberStepPatterns
    let hasMatch = s:stepmatch(stepPattern[3],line)
    if hasMatch
      let files = add(files, stepPattern)
    endif
  endfor
  if len(files) == 1
    execute "tabe +" . files[0][1] . " " . files[0][0]
  else
    for file in files
      " only open the zombie one for now
      " make extensible in the future
      if file[0] =~ 'zombie'
        execute "tabe +" . file[1] . " " . file[0]
      endif
      echo file
    endfor
  endif
endfunction

nmap ds :call FindStep()<cr>
"end cucumber step  Script-----------------------------

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.vim/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('~/.vim/')
  call dein#begin('~/.vim/')

  " Let dein manage dein
  " Required:
  call dein#add('~/.vim/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')

  " You can specify revision/branch/tag.
  call dein#add('Shougo/vimshell', { 'rev': '3787e5' })
  call dein#add('scrooloose/nerdtree',
      \{'on_cmd': 'NERDTreeToggle'})

  call dein#add('rking/ag.vim',
      \{'on_cmd': 'Ag'})

  call dein#add('junegunn/fzf', { 'build': './install', 'merged': 0 })
  call dein#add('junegunn/fzf.vim')
  call dein#add('digitaltoad/vim-pug')
  call dein#add('vim-syntastic/syntastic')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------
