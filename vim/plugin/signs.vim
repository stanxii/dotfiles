" plugin/signs.vim
scriptencoding utf-8

if dkoplug#IsLoaded('vim-signature')
  " disable mappings
  let g:SignatureMap = {
        \   'Leader': 'm',
        \   'PlaceNextMark': '',
        \   'ToggleMarkAtLine': '',
        \   'PurgeMarksAtLine': 'M',
        \   'DeleteMark': '',
        \   'PurgeMarks': 'gM',
        \   'PurgeMarkers': '',
        \   'GotoNextLineAlpha': '',
        \   'GotoPrevLineAlpha': '',
        \   'GotoNextSpotAlpha': '',
        \   'GotoPrevSpotAlpha': '',
        \   'GotoNextLineByPos': '',
        \   'GotoPrevLineByPos': '',
        \   'GotoNextSpotByPos': ']`',
        \   'GotoPrevSpotByPos': '[`',
        \   'GotoNextMarker': '',
        \   'GotoPrevMarker': '',
        \   'GotoNextMarkerAny': '',
        \   'GotoPrevMarkerAny': '',
        \   'ListBufferMarks': '',
        \   'ListBufferMarkers': '',
        \ }

elseif dkoplug#IsLoaded('quickfixsigns_vim')
  call dkoplug#quickfixsigns#Setup()
endif

if dkoplug#Exists('vim-gitgutter')
  call dkoplug#gitgutter#Setup()

elseif dkoplug#Exists('vim-signify')
  let g:signify_vcs_list = [ 'git' ]
  let g:signify_sign_change = '·'
  let g:signify_sign_show_count = 0 " don't show number of deleted lines
  let g:signify_realtime = 0
endif
