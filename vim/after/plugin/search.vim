" after/plugin/search.vim
"
" This is an after/plugin since some plugins (in testing, like vim-searchant)
" might set their own mappings.
"
" @TODO maybe unmap before mapping in case some other plugin tries something
" fishy

let s:cpo_save = &cpoptions
set cpoptions&vim

" - incsearch.vim   highlighting all matches
" - vim-anzu        show number of matches, with status integration
" - vim-asterisk    don't move on first search with *
" - vim-searchant   highlight CURRENT search item differently

" Get vim-asterisk, vim-anzu, and incsearch.vim to play nicely
" @param {String} op
" @return {String} <expr>
function! s:DKO_Search(op) abort
  let l:long_op = a:op ==# '*' ? 'star' : 'sharp'

  let l:ops = ''

  " Move or don't move?
  if dko#IsPlugged('vim-asterisk')
    let l:ops = l:ops . "\<Plug>(asterisk-z" . a:op . ")"
  endif

  " Highlight matches?
  if dko#IsPlugged('incsearch.vim')
    " no CursorMoved event if using vim-asterisk
    if dko#IsPlugged('vim-asterisk')
      let l:ops = l:ops . "\<Plug>(incsearch-nohl0)"
    else
      let l:ops = l:ops . "\<Plug>(incsearch-nohl)"
    endif
  endif

  " Show count of matches
  if dko#IsPlugged('vim-anzu')
    if dko#IsPlugged('vim-asterisk')
      let l:ops = l:ops . "\<Plug>(anzu-update-search-status)"
    else
      let l:ops = l:ops . "\<Plug>(anzu-" . l:long_op . ")"
    endif
  endif

  return l:ops
endfunction

if !empty(s:DKO_Search('*'))
  nmap <silent><special><expr>  *   <SID>DKO_Search('*')
  nmap <silent><special><expr>  #   <SID>DKO_Search('#')
endif

if dko#IsPlugged('incsearch.vim')
  nmap  <silent><special> /   <Plug>(incsearch-forward)
  nmap  <silent><special> ?   <Plug>(incsearch-backward)
  nmap  <silent><special> g/  <Plug>(incsearch-stay)
  nmap  <silent><special> n   <Plug>(incsearch-nohl)
  nmap  <silent><special> N   <Plug>(incsearch-nohl)
  nmap  <silent><special> #   <Plug>(incsearch-nohl)
endif

if dko#IsPlugged('vim-anzu')
  " Support other search modes like `gd`
  let g:anzu_enable_CursorMoved_AnzuUpdateSearchStatus = 1
  nmap <silent><special> n <Plug>(anzu-n)
  nmap <silent><special> N <Plug>(anzu-N)
endif

let &cpoptions = s:cpo_save
unlet s:cpo_save
