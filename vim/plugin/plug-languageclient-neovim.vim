" plugin/plug-languageclient-neovim.vim

if !dkoplug#IsLoaded('LanguageClient-neovim') | finish | endif

augroup dkolangclient
  autocmd!
augroup END

" ============================================================================
" Plugin settings
" ============================================================================

"let g:LanguageClient_loggingLevel = 'INFO'
" Don't populate lists since it overrides Neomake lists
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_diagnosticsSignsMax = 0
let g:LanguageClient_diagnosticsList = 'Disabled'
let g:LanguageClient_hoverPreview = 'Never'
let g:LanguageClient_settingsPath = expand('$DOTFILES/languageclient')
let g:LanguageClient_hasSnippetSupport = 0

" ============================================================================
" Mappings
" ============================================================================

let s:cpo_save = &cpoptions
set cpoptions&vim

nnoremap <silent> <Leader>d
      \ :<C-U>call LanguageClient#textDocument_definition()<CR>

nnoremap <silent> <leader>k
      \ :<C-U>call LanguageClient#textDocument_hover()<CR>

" Symbols in current document (like tagbar)
nnoremap <silent><special> <A-s>
      \ :<C-U>call LanguageClient#textDocument_documentSymbol()<CR>

let &cpoptions = s:cpo_save
unlet s:cpo_save

" ============================================================================
" Language Server Setup
" ============================================================================

let g:LanguageClient_serverCommands = {}

" Disabled for now
if 0 && executable('flow-language-server')
  let g:LanguageClient_serverCommands['javascript'] = [
        \   'flow-language-server',
        \   '--stdio'
        \ ]
elseif g:dko_use_js_langserver
  let g:LanguageClient_serverCommands['javascript'] = [
        \   'javascript-typescript-stdio'
        \ ]
  let g:LanguageClient_serverCommands['typescript'] =
        \ g:LanguageClient_serverCommands['javascript']
endif

if executable('luacheck')
  let g:LanguageClient_serverCommands['lua'] = [
        \   'lua-lsp'
        \ ]
endif

" @TODO
" python pyls
" go go-langserver
