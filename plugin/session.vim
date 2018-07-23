if get(g:, 'loaded_fzf_session')
  finish
endif
let g:loaded_fzf_session = 1
let s:save_cpo = &cpo
set cpo&vim

command! FZFSession call fzf#session#run()
command! -nargs=? -complete=customlist,fzf#session#completion SSave call fzf#session#save(<q-args>)
command! -nargs=? -complete=customlist,fzf#session#completion SDelete call fzf#session#delete(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
