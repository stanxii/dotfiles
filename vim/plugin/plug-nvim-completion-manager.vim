" plugin/plug-nvim-completion-manager.vim

if !dko#IsLoaded('nvim-completion-manager') | finish | endif

augroup dkonvimcompletionmanager
  autocmd!
augroup END

" Refresh list
imap <special><expr> <C-g> pumvisible()
      \ ? "\<Plug>(cm_force_refresh)"
      \ : "\<C-g>"

" Deoplete integration implementation from
" https://github.com/roxma/nvim-completion-manager/issues/50
if dko#IsLoaded('deoplete.nvim')
  " see https://github.com/roxma/nvim-completion-manager/blob/e24352af8a744f75966d7a2358040095e2d0b1f2/doc/nvim-completion-manager.txt#L299
  " for what the source kvs are
  autocmd dkonvimcompletionmanager User CmSetup
        \ call cm#register_source({
        \   'name':         'deoplete',
        \   'priority':     9,
        \   'abbreviation': '',
        \ })

  " forward to ncm
  function! g:DkoNcmDeopleteSource() abort
    call cm#complete(
          \   'deoplete',
          \   cm#context(),
          \   g:deoplete#_context.complete_position + 1,
          \   g:deoplete#_context.candidates
          \ )
    return ''
  endfunction

  " hack deoplete's mapping
  inoremap <silent><special> <Plug>_ <C-r>=g:DkoNcmDeopleteSource()<CR>
endif
