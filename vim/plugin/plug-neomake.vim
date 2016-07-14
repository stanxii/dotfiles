" plugin/plug-neomake.vim
scriptencoding utf-8

if !exists('g:plugs["neomake"]') | finish | endif

augroup dkoneomake
  autocmd!
augroup END

" ============================================================================
" Output
" ============================================================================

" No output on :wq
" @see https://github.com/benekastah/neomake/issues/309
" @see https://github.com/benekastah/neomake/issues/329
autocmd dkoneomake VimLeave * let g:neomake_verbose = 0

" loclist
let g:neomake_open_list   = 0
let g:neomake_list_height = g:dko_loc_list_height

" aggregate errors
let g:neomake_serialize = 0

" disable airline integration
let g:neomake_airline = 0

" ----------------------------------------------------------------------------
" Signs column
" ----------------------------------------------------------------------------

let g:neomake_error_sign    = { 'text': '⚑' }
let g:neomake_warning_sign  = { 'text': '⚑' }

" ============================================================================
" Define makers
" ============================================================================

" For using local NPM based makers (e.g. eslint):
" Resolve the maker's exe relative to the project of the file in buffer, as
" opposed to using the result of `system('npm bin')` since that executes
" relative to vim's working path (and gives a fake result of not in a node
" project). Lotta people doin` it wrong ಠ_ಠ

" @TODO re-enable linter selection by rc file presence
" Need to set the var on the hook BufReadPre, BufWinEnter is too late
" So caveat is that we can't catch when ft is set by modeline (there's
" probably another way)
" autocmd dkoneomake BufReadPre  *.js
"       \ let g:neomake_javascript_enabled_makers = dkoproject#JsLinters()

" settings is a dict { ft, maker, local }
function! s:AddLocalMaker(settings) abort
  " Use local binary
  let l:bin = dkoproject#GetProjectConfigFile(a:settings['local'])
  if !empty(l:bin)
    let b:neomake_{a:settings['ft']}_{a:settings['maker']}_exe = l:bin
  endif

  " Enable the maker
  if !empty(l:bin)
    let b:neomake_{a:settings['ft']}_enabled_makers = get(
          \   b:,
          \   'neomake_' . a:settings['ft'] . '_enabled_makers',
          \   []
          \ )
    call add(b:neomake_{a:settings['ft']}_enabled_makers, a:settings['maker'])
  endif
endfunction

" ----------------------------------------------------------------------------
" JavaScript
" ----------------------------------------------------------------------------

let g:neomake_javascript_enabled_makers = [ 'eslint' ]

let s:local_maker_eslint = {
      \ 'ft':     'javascript',
      \ 'maker':  'eslint',
      \ 'local':  'node_modules/.bin/eslint',
      \ }

let s:local_maker_jshint = {
      \ 'ft':     'javascript',
      \ 'maker':  'jshint',
      \ 'local':  'node_modules/.bin/jshint',
      \ }

autocmd dkoneomake FileType javascript
      \ call s:AddLocalMaker(s:local_maker_eslint)
      \| call s:AddLocalMaker(s:local_maker_jshint)

" ----------------------------------------------------------------------------
" Markdown
" ----------------------------------------------------------------------------

" Let pandoc use markdownlint as well
let g:neomake_pandoc_markdownlint_maker = neomake#GetMaker('markdownlint')

let g:neomake_markdown_enabled_makers = []
if executable('markdownlint')
  call add(g:neomake_markdown_enabled_makers, 'markdownlint')
endif
let g:neomake_pandoc_enabled_makers = g:neomake_markdown_enabled_makers

function! s:SetupMarkdownlint()
  " This is totally different from using local eslint -- don't like what
  " neomake has by default.

  let l:maker = { 'errorformat':  '%f: %l: %m' }

  " Use markdownlint in local node_modules/ if available
  let l:bin = dkoproject#GetProjectConfigFile('node_modules/.bin/markdownlint')
  let l:maker.exe = !empty(l:bin) ? 'markdownlint' : l:bin

  " Bail if not installed either locally or globally
  if !executable(l:maker.exe)
    return
  endif

  " Use config local to project if available
  let l:config = dkoproject#GetProjectConfigFile('markdownlint.json')
  if empty(l:config)
    let l:config = dkoproject#GetProjectConfigFile('.markdownlintrc')
  endif
  if empty(l:config)
    let l:config = glob(expand('$DOTFILES/markdownlint/config.json'))
  endif
  let l:maker.args = empty(l:config) ? [] : [ '--config', l:config ]

  let b:neomake_markdown_markdownlint_maker = l:maker
  let b:neomake_pandoc_markdownlint_maker = l:maker
endfunction
autocmd dkoneomake BufNewFile,BufRead *.md call s:SetupMarkdownlint()

" ----------------------------------------------------------------------------
" PHP: phpcs, phpmd
" ----------------------------------------------------------------------------

function! s:SetPhpcsStandard()
  " WordPress
  if expand('%:p') =~? 'content/(mu-plugins\|plugins\|themes)'
    let b:neomake_php_phpcs_args = neomake#makers#ft#php#phpcs().args
          \ + [ '--standard=WordPress-Extra' ]
  endif
endfunction

function! s:SetPhpmdRuleset()
  let l:ruleset_file = dkoproject#GetProjectConfigFile('ruleset.xml')

  if !empty(l:ruleset_file)
    " source, format, ruleset(xml file or comma sep list of default rules)
    let b:neomake_php_phpmd_args = [
          \   '%:p',
          \   'text',
          \   l:ruleset_file,
          \ ]
  endif
endfunction

autocmd dkoneomake FileType php
      \ call s:SetPhpcsStandard()
      \| call s:SetPhpmdRuleset()

" ----------------------------------------------------------------------------
" Python
" ----------------------------------------------------------------------------

let g:neomake_python_enabled_makers = [
      \   'python', 'pep8', 'pyflakes', 'pylint'
      \ ]

" Add disable to defaults
" @see https://github.com/neomake/neomake/blob/master/autoload/neomake/makers/ft/python.vim#L26
let g:neomake_python_pylint_args = [
      \   '--output-format=text',
      \   '--msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}"',
      \   '--reports=no',
      \   '--disable=locally-disabled',
      \ ]

" ----------------------------------------------------------------------------
" Sass: sasslint
" ----------------------------------------------------------------------------

let g:neomake_scss_sasslint_maker = {
      \   'exe':          'sass-lint',
      \   'args':         [ '--no-exit', '--verbose', '--format=compact' ],
      \   'errorformat':  '%E%f: line %l\, col %c\, Error - %m,' .
      \                   '%W%f: line %l\, col %c\, Warning - %m',
      \ }

let g:neomake_scss_enabled_makers = [ 'sasslint' ]

function! s:SetupSasslint()
  " Use local config if exists
  let l:config = dkoproject#GetProjectConfigFile('.sass-lint.yml')
  if !empty(l:config)
    let b:neomake_scss_sasslint_args = g:neomake_scss_sasslint_maker.args
          \ + [ '--config=' . l:config ]
  endif
endfunction

let s:local_maker_sasslint = {
      \ 'ft':     'scss',
      \ 'maker':  'sasslint',
      \ 'local':  'node_modules/.bin/sass-lint',
      \ }

autocmd dkoneomake FileType scss
      \ call s:SetupSasslint()
      \| call s:AddLocalMaker(s:local_maker_sasslint)

" ============================================================================
" Auto run
" Keep this last so all the other autocmds happen first
" ============================================================================

autocmd dkoneomake      BufWritePost,Filetype,FileChangedShellPost
      \ *
      \ Neomake

autocmd dkostatusline   User
      \ NeomakeMakerFinished
      \ call dkostatus#Refresh()

