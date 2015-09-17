"                    __ ____    _____        _    __ _ _
"                   /_ |___ \  |  __ \      | |  / _(_) |
"            ___ __ _| | __) | | |  | | ___ | |_| |_ _| | ___  ___
"           / __/ _` | ||__ <  | |  | |/ _ \| __|  _| | |/ _ \/ __|
"          | (_| (_| | |___) | | |__| | (_) | |_| | | | |  __/\__ \
"           \___\__,_|_|____/  |_____/ \___/ \__|_| |_|_|\___||___/
"

" Skip initialisation for Vim Tiny/Small
if !1 | finish | endif

" =============================================================================
" ENVIRONMENT
" =============================================================================

silent function! OSX()
  return (has('macunix')  || has('mac') || has('gui_macvim'))
endfunction

silent function! LINUX()
  return has('unix') && !has('macunix') && !has('win32unix')
endfunction

silent function! WINDOWS()
  return (has('win16') || has('win32') || has('win64'))
endfunction

silent function! CYGWIN()
  return (has('win32unix') || has('win64unix'))
endfunction

silent function! MSYSGIT()
  return (has('win32') || has('win64')) && $TERM ==? 'cygwin'
endfunction

silent function! GUI()
  return (has('gui_running') || strlen(&term) == 0 || &term ==? 'builtin_gui')
endfunction

silent function! NVIM()
  return has('nvim')
endfunction

set nocompatible
set encoding=utf-8
set fileencoding=utf-8
scriptencoding utf-8

if WINDOWS()
  set shell=c:\windows\system32\cmd.exe
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
else
  set shell=/bin/sh
endif

" =============================================================================
" VARIABLES
" =============================================================================
let s:bundle_dir = '~/.vim/plugged'
let s:cache_dir = '~/.cache/vim'
let s:is_msys = ($MSYSTEM =~? 'MINGW\d\d')

" =============================================================================
" NVIM
" =============================================================================

if NVIM()
  if (!filereadable(expand("~/.nvimrc", 1)) || (!isdirectory(expand("~/.nvim", 1))))
    echoerr "Missing .nvim/ or .nvimrc"
  endif

  tnoremap <esc><esc> <c-\><c-n>
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
else
  " required for alt/meta mappings  https://github.com/tpope/vim-sensible/issues/69
  set encoding=utf-8

  set listchars=tab:>\ ,trail:-,nbsp:+

  if has('vim_starting') && WINDOWS()
    set runtimepath+=~/.vim/
  endif

  set ttyfast

  " avoid sourcing stupid menu.vim (saves ~100ms)
  let g:did_install_default_menus = 1

  if CYGWIN() || !empty($TMUX)
    " Mode-dependent cursor   https://code.google.com/p/mintty/wiki/Tips
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
  endif

  if CYGWIN()
    " use separate viminfo to avoid weird permissions issues
    set viminfo+=n~/.viminfo_cygwin

    " set escape key to an unambiguous keycode, to avoid escape timeout delay.
    let &t_ti.="\e[?7727h"
    let &t_te.="\e[?7727l"
    noremap  <Esc>O[ <Esc>
    noremap! <Esc>O[ <C-c>
  endif
endif

" =============================================================================
" BEFORE CONFIG
" =============================================================================
" To override all the included bundles : let g:override_ca13_bundles = 1
" let g:ca13_bundle_groups=[ 'general', 'programming', 'neocomplete', 'blade', 'c', 'csv', 'docker', 'go', 'html', 'javascript', 'nginx', 'php', 'python', 'ruby', 'scala', 'sql', 'writting' ]
let s:vimrc_before = fnamemodify(resolve(expand('<sfile>')), ':p:h').'/.vimrc.before'
if filereadable(s:vimrc_before)
  execute 'source' s:vimrc_before
endif

" =============================================================================
" VIM-PLUG
" =============================================================================
" Automatic installaion of vim-plug
" ---------------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !mkdir -p ~/.vim/autoload
  silent !curl -fLo ~/.vim/autoload/plug.vim
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.vim/plugged')

" Core
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if executable('ag')
  Plug 'mileszs/ack.vim'
  let g:ackprg = 'ag --nogroup --color --column --smart-case'
elseif executable('ack-grep')
  let g:ackprg="ack-grep -H --color --nogroup --column"
  Plug 'mileszs/ack.vim'
elseif executable('ack')
  Plug 'mileszs/ack.vim'
endif

if executable('tmux')
  Plug 'tpope/vim-tbone'
  Plug 'wellle/tmux-complete.vim'
  let g:tmuxcomplete#trigger = ''
endif

if !exists('g:ca13_bundle_groups')
    let g:ca13_bundle_groups=[ 'general', 'programming', 'neocomplete', 'blade', 'c', 'csv', 'docker', 'go', 'html', 'javascript', 'nginx', 'php', 'python', 'ruby', 'scala', 'sql', 'writting' ]
endif


if !exists("g:override_ca13_bundles")
  " General
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'general')
    " Colorscheme
    Plug 'tomasr/molokai'
    Plug 'altercation/vim-colors-solarized'
    Plug 'whatyouhide/vim-gotham'
    Plug 'morhetz/gruvbox'

    Plug 'bling/vim-airline'
    Plug 'MattesGroeger/vim-bookmarks'
    Plug 'kien/ctrlp.vim' | Plug 'tacahiroy/ctrlp-funky'
    Plug 'ervandew/supertab'
    Plug 'kyuhi/vim-emoji-complete'
    Plug 'junegunn/vim-emoji'
    Plug 'tpope/vim-sensible'
  endif

  " General Programming
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'programming')
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'tomtom/tcomment_vim'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'joonty/vim-sauce'
    Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' }
    Plug 'tpope/vim-surround'

    " Syntax related plugins
    Plug 'sheerun/vim-polyglot'
    Plug 'Scrooloose/Syntastic'

    " Git/VCS related plugins
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'

    if v:version >= 703
      Plug 'mhinz/vim-signify'
      let g:signify_vcs_list = [ 'git' ]
    endif

    if executable('ctags')
      Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
      nnoremap <C-t> :TlistToggle<CR>
    endif
  endif

  " Snippets & AutoComplete
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'snipmate')
    Plug 'garbas/vim-snipmate'
    Plug 'honza/vim-snippets'
    " Source support_function.vim to support vim-snippets.
    if filereadable(expand(expand(s:bundle_dir, 1) . '/vim-snippets/snippets/support_functions.vim'))
      source expand(s:bundle_dir, 1) . '/vim-snippets/snippets/support_functions.vim'
    endif
  elseif count(g:ca13_bundle_groups, 'youcompleteme')
    Plug 'Valloric/YouCompleteMe', { 'do': './install.sh --clang-completer' } " Code Completion and Inline errors
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
  elseif count(g:ca13_bundle_groups, 'neocomplcache')
    Plug 'Shougo/neocomplcache'
    Plug 'Shougo/neosnippet'
    Plug 'Shougo/neosnippet-snippets'
    Plug 'honza/vim-snippets'
  elseif count(g:ca13_bundle_groups, 'neocomplete')
    Plug 'Shougo/neocomplete.vim.git'
    Plug 'Shougo/neosnippet'
    Plug 'Shougo/neosnippet-snippets'
    Plug 'honza/vim-snippets'
  endif

  " Blade
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'blade')
    Plug 'xsbeats/vim-blade', { 'for': 'blade' }
  endif

  " C
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'c')
    Plug 'vim-jp/cpp-vim', { 'for': ['c', 'cpp'] }
    Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }
  endif

  " Csv
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'csv')
    Plug 'chrisbra/csv.vim', { 'for': 'csv' }
  endif

  " Docker
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'docker')
    Plug 'honza/Dockerfile.vim', { 'for': 'dockerfile' }
  endif

  " Go
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'go')
    if exists("$GOPATH")
      Plug 'fatih/vim-go', { 'for': 'go' }
      Plug 'Blackrush/vim-gocode', { 'for': 'go' }
    endif
  endif

  " Html
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'html')
    Plug 'mattn/emmet-vim'
    Plug 'othree/html5.vim', { 'for': 'html' }
    Plug 'mustache/vim-mustache-handlebars', { 'for': [ 'html', 'mustache', 'hbs' ] }
    Plug 'groenewege/vim-less', { 'for': ['less', 'css'] }
    Plug 'wavded/vim-stylus', { 'for' :['sass', 'scss', 'css'] }
    Plug 'tpope/vim-haml', { 'for': ['haml', 'sass', 'scss'] }
    Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
  endif

  " Javascript
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'javascript')
    Plug 'jelera/vim-javascript-syntax'
    Plug 'pangloss/vim-javascript'
    Plug 'elzr/vim-json', { 'for': 'json' }
    Plug 'briancollins/vim-jst'
    Plug 'kchmck/vim-coffee-script', { 'for': [ 'coffee', 'haml' ] }
    if executable('npm')
      Plug 'marijnh/tern_for_vim' , {'do': 'npm install'}
    endif
  endif

  " Nginx
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'nginx')
    Plug 'evanmiller/nginx-vim-syntax', { 'for': 'nginx' }
  endif

  " PHP
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'php')
    Plug 'spf13/PIV'
    Plug 'arnaud-lb/vim-php-namespace'
    Plug 'beyondwords/vim-twig'
    Plug 'joonty/vim-phpqa'
  endif

  " Python
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'python')
    Plug 'klen/python-mode'
    Plug 'yssource/python.vim'
    Plug 'python_match.vim'
    Plug 'pythoncomplete'
  endif

  " Ruby
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'ruby')
    Plug 'tpope/vim-rails', { 'for': 'ruby' }
    let g:rubycomplete_buffer_loading = 1
    "let g:rubycomplete_classes_in_global = 1
    "let g:rubycomplete_rails = 1
  endif

  " Scala
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'scala')
    Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
  endif

  " SQL
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'sql')
    Plug 'dbext.vim', { 'for': 'sql' }
  endif

  " Writing
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'writing')
    Plug 'reedes/vim-litecorrect'
    Plug 'reedes/vim-textobj-sentence'
    Plug 'reedes/vim-textobj-quote'
    Plug 'reedes/vim-wordy'
    Plug 'reedes/vim-pencil'
  endif

  " Yaml
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'yaml')
    Plug 'chase/vim-ansible-yaml', { 'for': 'yaml' }
  endif

endif

call plug#end()

" =============================================================================
" HELPERS
" =============================================================================
" Create directory
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! CreateDir(path)
  "trim
  let l:path = expand(substitute(a:path,  '\s\+', '', 'g'), 1)

  if empty(l:path)
    echom "CreateDir(): invalid path: ".a:path
    return 0 "path is empty/blank.
  endif

  if !isdirectory(l:path)
    call mkdir(l:path, 'p')
  endif
  return isdirectory(l:path)
endfunction

" Create file
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! CreateFile(path)
  let l:path = expand(a:path, 1)
  if !filereadable(l:path) && -1 == writefile([''], l:path)
    echoerr "failed to create file: ".l:path
  endif
endfunction

" =============================================================================
" BASIC SETTINGS
" =============================================================================
" Core settings
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
let mapleader = ','
let g:mapleader = ','
set mouse=a
set mousehide
set autoread " You can manually type :edit to reload open files

" Background
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set background=dark

function! ToggleBG()
  let s:tbg = &background
  " Inversion
  if s:tbg == "dark"
    set background=light
  else
    set background=dark
  endif
endfunction
noremap <leader>bg :call ToggleBG()<CR>

" Clipboard
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if has('clipboard')
  if has('unnamedplus')  " When possible use + register for copy-paste
    set clipboard=unnamed,unnamedplus
  else         " On mac and Windows, use * register for copy-paste
    set clipboard=unnamed
  endif
endif

" Number
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set number numberwidth=3
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
    set number
  else
    set number
    set relativenumber
  endif
endfunc
nnoremap <leader>; :call NumberToggle()<cr>

" Format
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set tabstop=2
set shiftwidth=2
set expandtab smarttab " Use 'shiftwidth' when using <Tab>

nmap <leader>fef :call Preserve("normal gg=G")<CR>

" :Chomp
" ------
command! Chomp silent! normal! :%s/\s\+$//<cr>

vmap <leader>s :sort<CR>

" Indent
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set autoindent smartindent
" Keep visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" Search
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set confirm
set ignorecase
set infercase
set smartcase
set hlsearch
set incsearch
set magic
set showmatch
set matchtime=2
set matchpairs+=<:>

nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
cnoremap s/ s/\v

noremap <silent> <leader><space> :set hlsearch! hlsearch?<cr>
map <space> :noh<cr>

" Map <leader>ff to display all lines with keyword under cursor
" and ask which one to jump to
nmap <leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

" Normal mode pressing * or # searches for the current selection
" --------------------------------------------------------------
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz

" Visual mode pressing * or # searches for the current selection
" --------------------------------------------------------------
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>

if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --column
else
  set grepprg=grep\ -rnH\ --exclude=tags\ --exclude-dir=.git\ --exclude-dir=node_modules
endif

" Folds
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Folding is enabled by default
" -----------------------------
set foldenable
function! NeatFoldText()
  let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
set foldtext=NeatFoldText()

" Code folding options
" --------------------
noremap <leader>f0 :set foldlevel=0<CR>
noremap <leader>f1 :set foldlevel=1<CR>
noremap <leader>f2 :set foldlevel=2<CR>
noremap <leader>f3 :set foldlevel=3<CR>
noremap <leader>f4 :set foldlevel=4<CR>
noremap <leader>f5 :set foldlevel=5<CR>
noremap <leader>f6 :set foldlevel=6<CR>
noremap <leader>f7 :set foldlevel=7<CR>
noremap <leader>f8 :set foldlevel=8<CR>
noremap <leader>f9 :set foldlevel=9<CR>

" Statusline
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set backspace=indent,eol,start
set hidden
set ttyfast
set showcmd
set scrolloff=5
set laststatus=2

if has('cmdline_info')
  set ruler                   " Show the ruler
  set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
  set showcmd                 " Show partial commands in status line and
                              " Selected characters/lines in visual mode
endif

if $TERM =~? 'linux'
  if has('statusline')

    " Broken down into easily includeable segments
    set statusline=%<%f\                     " Filename
    set statusline+=%w%h%m%r                 " Options
    if !exists('g:override_ca13_bundles')
        set statusline+=%{fugitive#statusline()} " Git Hotness
    endif
    set statusline+=\ [%{&ff}/%Y]            " Filetype
    set statusline+=\ [%{getcwd()}]          " Current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
  endif
endif

" Returns true if paste mode is enabled
" -------------------------------------
function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  en
  return ''
endfunction

" Best vim-airline display
" ------------------------
"set ambiwidth=double
set noshowmode
set lazyredraw

" Tab completion
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set wildmenu
set wildmode=list:longest,full
set ofu=syntaxcomplete#Complete

" List
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set list
set listchars=tab:›\ ,trail:•,extends:›,precedes:‹,nbsp:+,eol:$
set fillchars=diff:-
set showbreak=↪\
nmap <leader>l :set list! list?<cr>

" PasteToggle
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
map ;; :set invpaste<CR>:set paste?<CR>
map <leader>, :set invpaste<CR>:set paste?<CR>

" Errors
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set noerrorbells
set novisualbell
set timeoutlen=500
set t_vb=

" Windows navigation
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set splitbelow
set splitright

nnoremap + <C-W>+
nnoremap _ <C-W>-
nnoremap = <C-W>>
nnoremap - <C-W><

map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_

" Buffer
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Move between buffers
" --------------------
nnoremap <left> :bn<CR>
nnoremap <right> :bp<CR>

nnoremap ct  :tabnew<cr>
nnoremap dt  :tabclose<cr>
nnoremap at  :tabmove +1<cr>
nnoremap bt  :tabmove -1<cr>

" Move Tab to Nth position
" ------------------------
nnoremap <expr> gT (v:count > 0 ? ':<c-u>tabmove '.(v:count - 1).'<cr>' : 'gT')

" Quick buffer open
" -----------------
nnoremap <leader>bl :ls<cr>:e #

" Close current buffer
" --------------------
map <leader>bd :Bclose<cr>

" Close all buffers
" -----------------
map <leader>ba :1,1000 bd!<cr>

" Remember info about open buffers on close
" -----------------------------------------
set viminfo^=%

" #! | Shebang
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
inoreabbrev <expr> #!! "#!/usr/bin/env" . (empty(&filetype) ? '' : ' '.&filetype)

" EX | chmod +x
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
command! EX if !empty(expand('%'))
   \|   write
   \|   call system('chmod +x '.expand('%'))
   \| else
   \|   echohl WarningMsg
   \|   echo 'Save the file first'
   \|   echohl None
   \| endif

" AutoSave
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! s:autosave(enable)
  augroup autosave
    autocmd!
    if a:enable
      autocmd TextChanged,InsertLeave <buffer>
        \  if empty(&buftype) && !empty(bufname(''))
        \|   silent! update
        \| endif
    endif
  augroup END
endfunction

command! -bang AutoSave call s:autosave(<bang>1)

" ConnectChrome
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if OSX()
  function! s:connect_chrome(bang)
    augroup connect-chrome
      autocmd!
      if !a:bang
        autocmd BufWritePost <buffer> call system(join([
          \ "osascript -e 'tell application \"Google Chrome\"".
          \               "to tell the active tab of its first window\n",
          \ "  reload",
          \ "end tell'"], "\n"))
      endif
    augroup END
  endfunction
  command! -bang ConnectChrome call s:connect_chrome(<bang>0)
endif

" <leader>? | Google it
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! s:goog(pat)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
    \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system('open https://www.google.co.kr/search?q='.q)
endfunction

nnoremap <leader>? :call <SID>goog(expand("<cWORD>"))<cr>
xnoremap <leader>? "gy:call <SID>goog(@g)<cr>gv

" <leader>I/A | Prepend/Append to all adjacent lines with same indentation
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
nmap <silent> <leader>I ^vio<C-V>I
nmap <silent> <leader>A ^vio<C-V>$A

" <F8> | Switch Colorscheme
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
call matchadd('ColorColumn', '\%81v', 100)

if s:is_msys
  let &t_Co = 256
endif

if (!GUI() && &t_Co <= 88) || findfile('colors/molokai.vim', &rtp) ==# ''
  silent! colorscheme ron
else
  let s:color_override_dark = '
    \ if &background == "dark"
    \ | hi StatusLine    guifg=#000000 guibg=#ffffff gui=NONE  ctermfg=16 ctermbg=15     cterm=NONE
    \ | hi CursorLine    guibg=#293739 ctermbg=236
    \ | hi PmenuSel      guibg=#0a9dff guifg=white   gui=NONE  ctermbg=39 ctermfg=white  cterm=NONE
    \ | hi PmenuSbar     guibg=#857f78
    \ | hi PmenuThumb    guifg=#242321
    \ | hi WildMenu      gui=NONE cterm=NONE guifg=#f8f6f2 guibg=#0a9dff ctermfg=255 ctermbg=39
    \ | hi DiffAdd       guifg=#ffffff guibg=#006600 gui=NONE  ctermfg=231  ctermbg=22   cterm=NONE
    \ | hi DiffChange    guifg=#ffffff guibg=#007878 gui=NONE  ctermfg=231  ctermbg=30   cterm=NONE
    \ | hi DiffDelete    guifg=#ff0101 guibg=#9a0000 gui=NONE  ctermfg=196  ctermbg=88   cterm=NONE
    \ | hi DiffText      guifg=#000000 guibg=#ffb733 gui=NONE  ctermfg=000  ctermbg=214  cterm=NONE
    \ | hi MatchParen    guifg=NONE   guibg=NONE gui=underline ctermfg=NONE ctermbg=NONE cterm=underline
    \ | endif
    \'

  if has('vim_starting') "only on startup
    exe 'autocmd ColorScheme * '.s:color_override_dark
    " expects &runtimepath/colors/{name}.vim.
    silent! colorscheme molokai
  endif
endif

" Cursorline
" ----------
function! s:set_CursorLine()
  if MSYSGIT() | return | endif

  hi clear CursorLine
  if &diff
    hi CursorLine gui=underline cterm=underline
  else
    hi CursorLine guibg=#293739 ctermbg=236
  endif
endfunction

" Create swap, backup, undo dirs
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
let s:dir = empty($XDG_DATA_HOME) ? '~/.cache/vim' : $XDG_DATA_HOME.'/vim'
call CreateDir(s:dir)

if isdirectory(expand(s:dir, 1))
  call CreateDir(s:dir . '/swap/')
  call CreateDir(s:dir . '/backup/')
  call CreateDir(s:dir . '/undo/')

  if &directory =~# '^\.,'
    let &directory = expand(s:dir, 1) . '/swap//,' . &directory
  endif
  if &backupdir =~# '^\.,'
    let &backupdir = expand(s:dir, 1) . '/backup//,' . &backupdir
  endif
  if has("persistent_undo") && &undodir =~# '^\.\%(,\|$\)'
    let &undodir = expand(s:dir, 1) . '/undo//,' . &undodir
    set undofile
  endif
endif

" =============================================================================
" GUI
" =============================================================================
if has('gui_running')
  set go-=mr
  set go-=T
  set guifont=Sauce\ Code\ Powerline\ 13
  colorscheme solarized
  set background=light
endif

" =============================================================================
" MAPPINGS
" =============================================================================
" Arrow keys
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Keep hands on keyboard
" ----------------------
inoremap jj <ESC>
inoremap kk <ESC>
inoremap hh <ESC>
inoremap jk <ESC>
inoremap kj <ESC>

" Edit vimrc
" ----------
nnoremap <silent> <leader>vi :e $MYVIMRC<CR>
nnoremap <silent> <leader>sv :so $MYVIMRC<CR>

" Edit files mode
" ---------------
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Insert line
" -----------
inoremap <C-i> <CR><Esc>O

" Allow using the repeat operator with a visual selection (!)
" -----------------------------------------------------------
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
" ----------------------------------------------------
cmap w!! w !sudo tee % >/dev/null

" Change Working Directory to that of the current file
" ----------------------------------------------------
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" Switch CWD to the directory of the open buffer
" ----------------------------------------------
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Make Y consistent with C and D.
" -------------------------------
nnoremap Y y$

" Copy selection to gui-clipboard
" -------------------------------
xnoremap Y "+y

" Copy entire file contents (to gui-clipboard if available)
" ---------------------------------------------------------
nnoremap yY :let b:winview=winsaveview()<bar>exe 'norm ggVG'.(has('clipboard')?'"+y':'y')<bar>call winrestview(b:winview)<cr>
inoremap <insert> <C-r>+

" Easier horizontal scrolling
" ---------------------------
map zl zL
map zh zH

" Easier formatting
" -----------------
nnoremap <silent> <leader>q gwip

" Fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
" ----------------------------------------------------------------
map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>

" Visual selection of various text objects
" ----------------------------------------
nnoremap VV V
nnoremap Vit vitVkoj
nnoremap Vat vatV
nnoremap Vab vabV
nnoremap VaB vaBV

" Remove Windows ^M
" -----------------
noremap <leader>mm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" =============================================================================
" FUNCTIONS
" =============================================================================

" <F8> | Color scheme selector
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! s:rotate_colors()
  if !exists('s:colors_list')
    let s:colors_list =
      \ sort(map(
      \   filter(split(globpath(&rtp, "colors/*.vim"), "\n"), 'v:val !~ "^/usr/"'),
      \   "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')"))
  endif
  if !exists('s:colors_index')
    let s:colors_index = index(s:colors_list, g:colors_name)
  endif
  let s:colors_index = (s:colors_index + 1) % len(s:colors_list)
  let name = s:colors_list[s:colors_index]
  execute 'colorscheme' name
  redraw
  echo name
endfunction
nnoremap <F8> :call <SID>rotate_colors()<cr>

" =============================================================================
" COMMANDS
" =============================================================================

" Automatically reload the vimrc config
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
augroup vimrc_myvimrc
  autocmd!
  autocmd BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

" Remember cursor position
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
augroup vimrc_cursor
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END

" Help in new Tabs
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! s:helptab()
  if &buftype == 'help'
    wincmd T
    nnoremap <buffer> q :q<cr>
  endif
endfunction

augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt call s:helptab()
augroup END

" Auto-create directories for new files
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if exists("*mkdir") "auto-create directories for new files
  au BufWritePre,FileWritePre * call CreateDir('<afile>:p:h')
endif

" :Se SearchItem scss
"command -nargs=+ Search execute 'vimgrep /' . [<f-args>][0] . '/ **/*.' . [<f-args>][1]

" =============================================================================
" PLUGINS
" =============================================================================

" Ack
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/ack.vim/'))
  nnoremap <leader>a :Ag
endif

" Airline
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-airline/'))
  let g:airline_powerline_fonts = 1

  if !exists('g:airline_symbols')
      let g:airline_symbols = {}
  endif

  let g:airline_theme = 'badwolf'
  let g:airline_symbols.paste = 'ρ'
  let g:airline_symbols.space = "\ua0"

  let g:airline#extensions#tabline#enabled = 1
  "let g:airline#extensions#tabline#tab_nr_type = 1
  let g:airline#extensions#branch#enabled = 1
  let g:airline#extensions#syntastic#enabled = 1
  ""let g:airline#extensions#tagbar#enabled = 1
  let g:airline#extensions#csv#enabled = 1
  let g:airline#extensions#hunks#enabled = 1
  let g:airline#extensions#whitespace#enabled = 1

  " Show total amount of lines in the airline
  function! AirlineInit()
    let g:airline_section_z = airline#section#create_right(['%L'])
  endfunction
  autocmd VimEnter * call AirlineInit()
endif

" Bookmarks
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-bookmarks/'))

  highlight BookmarkSign ctermbg=NONE ctermfg=208
  highlight BookmarkLine ctermbg=NONE ctermfg=154
  highlight BookmarkAnnotationSign ctermbg=NONE ctermfg=208
  highlight BookmarkAnnotationLine ctermbg=NONE ctermfg=154

  let g:bookmark_sign = '⚑'
  let g:bookmark_annotation_sign = '♥'
  let g:bookmark_highlight_lines = 1
  let g:bookmark_auto_save = 1
  let g:bookmark_save_per_working_dir = 1

  if isdirectory(expand(s:cache_dir, 1))
    call CreateDir(s:cache_dir . '/bookmarks/')
    let g:bookmark_auto_save_file = expand(s:cache_dir, 1) . '/bookmarks/.vim-bookmarks'
  endif

endif

" Ctrlp
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/ctrlp.vim/'))
  let g:ctrlp_working_path_mode = 'ra'
  nnoremap <silent> <D-t> :CtrlP<CR>
  nnoremap <silent> <D-r> :CtrlPMRU<CR>
  let g:ctrlp_custom_ignore = {
    \ 'dir':  '\.git$\|\.hg$\|\.svn$',
    \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

  if executable('ag')
    let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
  elseif executable('ack-grep')
    let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
  elseif executable('ack')
    let s:ctrlp_fallback = 'ack %s --nocolor -f'
  " On Windows use "dir" as fallback command.
  elseif WINDOWS()
    let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
  else
    let s:ctrlp_fallback = 'find %s -type f'
  endif
  if exists("g:ctrlp_user_command")
    unlet g:ctrlp_user_command
  endif
  let g:ctrlp_user_command = {
    \ 'types': {
      \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
      \ 2: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
    \ 'fallback': s:ctrlp_fallback
  \ }

  if isdirectory(expand(expand(s:bundle_dir, 1) . '/ctrlp-funky/'))
    " CtrlP extensions
    let g:ctrlp_extensions = ['funky']

    "funky
    nnoremap <Leader>fu :CtrlPFunky<Cr>
  endif
endif

" Emmet
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/emmet-vim/'))
  let g:user_emmet_leader_key='<c-e>'
  let g:user_emmet_install_global = 0
  autocmd FileType html,css EmmetInstall
endif

" Figlet
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! InsertFiglet()
  let text = input("Text: ")
  let font = input("Font: ", "big")
  let lineBegin = input("Begin of line: ", " " ")
  execute "r!figlet -w 150 ".shellescape(text)." -f ".shellescape(font)."|sed -e 's/\\(.*\\)/".lineBegin."\\1/'|sed -e 's/ \\+$//'"
endfunction
if executable('figlet')
  nmap <leader>f :call InsertFiglet()<CR>
endif

" Fugitive
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-fugitive/'))
  nnoremap <silent> <leader>gs :Gstatus<CR>
  nnoremap <silent> <leader>gd :Gdiff<CR>
  nnoremap <silent> <leader>gc :Gcommit<CR>
  nnoremap <silent> <leader>gb :Gblame<CR>
  nnoremap <silent> <leader>gl :Glog<CR>
  nnoremap <silent> <leader>gp :Git push<CR>
  nnoremap <silent> <leader>gr :Gread<CR>
  nnoremap <silent> <leader>gw :Gwrite<CR>
  nnoremap <silent> <leader>ge :Gedit<CR>
  nnoremap <silent> <leader>gi :Git add -p %<CR>
  nnoremap <silent> <leader>gg :SignifyToggle<CR>
endif

" IndentLine
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/indentLine/'))
  autocmd! User indentLine doautocmd indentLine Syntax
endif

" Indent-guides
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-indent-guides/'))
  let g:indent_guides_start_level = 2
  let g:indent_guides_guide_size = 1
  let g:indent_guides_enable_on_vim_startup = 1
endif

" Markdown
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-markdown/'))
  nnoremap <leader>1 m`yypVr=``
  nnoremap <leader>2 m`yypVr-``
  nnoremap <leader>3 m`^i### <esc>``4l
  nnoremap <leader>4 m`^i#### <esc>``5l
  nnoremap <leader>5 m`^i##### <esc>``6l
endif

" NERDTree
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/nerdtree/'))
  nnoremap <C-n> :NERDTreeToggle<CR>
  map <leader>e :NERDTreeFind<CR>
  nmap <leader>nt :NERDTreeFind<CR>

  let NERDTreeShowBookmarks=1
  let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
  let NERDTreeChDirMode=0
  let NERDTreeQuitOnOpen=1
  let NERDTreeMouseMode=2
  let NERDTreeShowHidden=1
  let NERDTreeKeepTreeInNewTab=1
  let g:nerdtree_tabs_open_on_gui_startup=0
endif

" PIV
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/PIV/'))
  let g:DisableAutoPHPFolding = 0
  let g:PIVAutoClose = 0
endif

" Polyglot
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-polyglot/'))
  "let g:polyglot_disabled = ['css']
endif

" Sauce
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(s:cache_dir, 1))
  call CreateDir(s:cache_dir . '/vimsauce/')
  let g:sauce_path = expand(s:cache_dir, 1) . '/vimsauce/'
endif

" Session
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
if isdirectory(expand(expand(s:bundle_dir, 1) . '/sessionman.vim/'))
  nmap <leader>sl :SessionList<CR>
  nmap <leader>ss :SessionSave<CR>
  nmap <leader>sc :SessionClose<CR>
endif

" Solarized
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-colors-solarized/'))
  let g:solarized_termcolors=256
  let g:solarized_termtrans=1
  let g:solarized_contrast="normal"
  let g:solarized_visibility="normal"
endif

" Supertab
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/supertab/'))
  let g:SuperTabDefaultCompletionType="context"
endif

" Syntastic
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/Syntastic/'))
  let g:syntastic_scss_checkers = ['scss_lint']
  let g:syntastic_javascript_checkers = ['jshint']
  let g:syntastic_check_on_open = 1
  let g:syntastic_error_symbol='✗'
  let g:syntastic_warning_symbol='⚠'
  let g:syntastic_style_error_symbol = '✗'
  let g:syntastic_style_warning_symbol = '⚠'
endif

" TextObj
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if count(g:ca13_bundle_groups, 'writing')
  augroup textobj
  autocmd!
  autocmd FileType markdown,mkd,text,textile  call pencil#init()
                                          \ | call lexical#init()
                                          \ | call litecorrect#init()
                                          \ | call textobj#quote#init()
                                          \ | call textobj#sentence#init()
  augroup END
endif

" Tabular
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/tabular/'))
  nmap <Leader>a& :Tabularize /&<CR>
  vmap <Leader>a& :Tabularize /&<CR>
  nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
  vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
  nmap <Leader>a=> :Tabularize /=><CR>
  vmap <Leader>a=> :Tabularize /=><CR>
  nmap <Leader>a: :Tabularize /:<CR>
  vmap <Leader>a: :Tabularize /:<CR>
  nmap <Leader>a:: :Tabularize /:\zs<CR>
  vmap <Leader>a:: :Tabularize /:\zs<CR>
  nmap <Leader>a, :Tabularize /,<CR>
  vmap <Leader>a, :Tabularize /,<CR>
  nmap <Leader>a,, :Tabularize /,\zs<CR>
  vmap <Leader>a,, :Tabularize /,\zs<CR>
  nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
  vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
endif

" TagBar
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/tagbar/'))
  nnoremap <silent> <leader>tt :TagbarToggle<CR>
endif

" UndoTree
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/undotree/'))
endif

" YouCompleteMe
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Install on linux
" ----------------
" $ > sudo apt-get install build-essential cmake
" $ > sudo apt-get install python-dev
if count(g:ca13_bundle_groups, 'youcompleteme')
  let g:ycm_global_ycm_extra_conf = "~/.ycm_extra_conf.py"
  let g:ycm_confirm_extra_conf = 0
  nnoremap <leader>o :YcmCompleter GoToDefinition<CR>
  nnoremap <leader>g :YcmDigs<CR>

  let g:acp_enableAtStartup = 0

  " enable completion from tags
  let g:ycm_collect_identifiers_from_tags_files = 1

  " remap Ultisnips for compatibility for YCM
  let g:UltiSnipsExpandTrigger = '<C-j>'
  let g:UltiSnipsJumpForwardTrigger = '<C-j>'
  let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

  " Haskell post write lint and check with ghcmod
  " $ `cabal install ghcmod` if missing and ensure
  " ~/.cabal/bin is in your $PATH.
  if !executable("ghcmod")
    autocmd BufWritePost *.hs GhcModCheckAndLintAsync
  endif

  " For snippet_complete marker.
  if has('conceal')
    set conceallevel=2 concealcursor=i
  endif

  " Disable the neosnippet preview candidate window
  " When enabled, there can be too much visual noise
  " especially when splits are used.
  set completeopt-=preview
endif

" NeoComplete
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if count(g:ca13_bundle_groups, 'neocomplete')
  let g:acp_enableAtStartup = 0
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#enable_auto_delimiter = 1
  let g:neocomplete#max_list = 15
  let g:neocomplete#force_overwrite_completefunc = 1

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : expand(s:cache_dir, 1) . '/.vimshell_hist',
    \ 'scheme' : expand(s:cache_dir, 1) . '/.gosh_completions'
    \ }

  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  " Plugin key-mappings
  " These two lines conflict with the default digraph mapping of <C-K>
  if !exists('g:ca13_no_neosnippet_expand')
    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)
  endif
  if exists('g:ca13_noninvasive_completion')
    inoremap <CR> <CR>
    " <ESC> takes you out of insert mode
    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
    " <CR> accepts first, then sends the <CR>
    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    " <Down> and <Up> cycle like <Tab> and <S-Tab>
    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
    " Jump up and down the list
    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
  else
    " <C-k> Complete Snippet
    " <C-k> Jump to next snippet point
    imap <silent><expr><C-k> neosnippet#expandable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
      \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

    inoremap <expr><C-g> neocomplete#undo_completion()
    inoremap <expr><C-l> neocomplete#complete_common_string()
    "inoremap <expr><CR> neocomplete#complete_common_string()

    " <CR>: close popup
    " <s-CR>: close popup and save indent.
    inoremap <expr><s-CR> pumvisible() ? neocomplete#smart_close_popup()."\<CR>" : "\<CR>"

    function! CleverCr()
      if pumvisible()
        if neosnippet#expandable()
          let exp = "\<Plug>(neosnippet_expand)"
          return exp . neocomplete#smart_close_popup()
        else
          return neocomplete#smart_close_popup()
        endif
      else
        return "\<CR>"
      endif
    endfunction

    " <CR> close popup and save indent or expand snippet
    imap <expr> <CR> CleverCr()
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplete#smart_close_popup()
  endif

  " <TAB>: completion.
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

  " Courtesy of Matteo Cavalleri
  function! CleverTab()
    if pumvisible()
      return "\<C-n>"
    endif
    let substr = strpart(getline('.'), 0, col('.') - 1)
    let substr = matchstr(substr, '[^ \t]*$')
    if strlen(substr) == 0
      " nothing to match on empty string
      return "\<Tab>"
    else
      " existing text matching
      if neosnippet#expandable_or_jumpable()
        return "\<Plug>(neosnippet_expand_or_jump)"
      else
        return neocomplete#start_manual_complete()
      endif
    endif
  endfunction

  imap <expr> <Tab> CleverTab()

  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif

  let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'

" NeoComplete
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
elseif count(g:ca13_bundle_groups, 'neocomplcache')
  let g:acp_enableAtStartup = 0
  let g:neocomplcache_enable_at_startup = 1
  let g:neocomplcache_enable_camel_case_completion = 1
  let g:neocomplcache_enable_smart_case = 1
  let g:neocomplcache_enable_underbar_completion = 1
  let g:neocomplcache_enable_auto_delimiter = 1
  let g:neocomplcache_max_list = 15
  let g:neocomplcache_force_overwrite_completefunc = 1

  " Define dictionary.
  let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : expand(s:cache_dir, 1) . '/.vimshell_hist',
    \ 'scheme' : expand(s:cache_dir, 1) . '/.gosh_completions'
    \ }

  " Define keyword.
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns._ = '\h\w*'

  " Plugin key-mappings {
  " These two lines conflict with the default digraph mapping of <C-K>
  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  if exists('g:ca13_noninvasive_completion')
    inoremap <CR> <CR>
    " <ESC> takes you out of insert mode
    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
    " <CR> accepts first, then sends the <CR>
    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    " <Down> and <Up> cycle like <Tab> and <S-Tab>
    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
    " Jump up and down the list
    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
  else
    imap <silent><expr><C-k> neosnippet#expandable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
      \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

    inoremap <expr><C-g> neocomplcache#undo_completion()
    inoremap <expr><C-l> neocomplcache#complete_common_string()
    "inoremap <expr><CR> neocomplcache#complete_common_string()

    function! CleverCr()
      if pumvisible()
        if neosnippet#expandable()
          let exp = "\<Plug>(neosnippet_expand)"
          return exp . neocomplcache#close_popup()
        else
          return neocomplcache#close_popup()
        endif
      else
        return "\<CR>"
      endif
    endfunction

    " <CR> close popup and save indent or expand snippet
    imap <expr> <CR> CleverCr()

    " <CR>: close popup
    " <s-CR>: close popup and save indent.
    inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup()."\<CR>" : "\<CR>"
    "inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplcache#close_popup()
  endif
  " <TAB>: completion.
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

  " Enable heavy omni completion.
  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif

  let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.go = '\h\w*\.\?'

" Normal Vim omni-completion
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" To disable omni complete, add the following to your .vimrc.before file:
" let g:ca13_no_omni_complete = 1
elseif !exists('g:ca13_no_omni_complete')
  " Enable omni-completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

endif

" =============================================================================
" LOCAL CONFIG
" =============================================================================
" Override ONLY Vim parameters and NOT Bundles
let s:vimrc_local = fnamemodify(resolve(expand('<sfile>')), ':p:h').'/.vimrc.local'
  if filereadable(s:vimrc_local)
  execute 'source' s:vimrc_local
endif
