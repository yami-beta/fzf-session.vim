if get(g:, 'loaded_autoload_fzf_session')
  finish
endif
let g:loaded_autoload_fzf_session = 1
let s:save_cpo = &cpo
set cpo&vim

let s:session_dir = get(g:, 'fzf_session_dir', '~/.vim/session')
let s:session_path = fnamemodify(expand(s:session_dir), ':p')
let s:current_session_name = ''

function! s:get_session_list() abort
  return glob(s:session_path . '*.vim', 0, 1)
endfunction

function! s:get_session_filepath(session_name) abort
  return fnamemodify(s:session_path . a:session_name . '.vim', ':p')
endfunction

function! s:get_session_name(filepath) abort
  return fnamemodify(a:filepath, ":p:t:r")
endfunction

function! fzf#session#completion(...) abort
  let list =  [getcwd() . '.vim'] + s:get_session_list()
  return map(list, 's:get_session_name(v:val)')
endfunction

function! fzf#session#save(session_name) abort
  let session_name = a:session_name != '' ? a:session_name : s:current_session_name
  if session_name == ''
    let session_name = 'default'
  endif
  let session_file = s:get_session_filepath(session_name)
  if !filereadable(session_file)
    if confirm('Create ' . session_name . '.vim ?', "&No\n&Yes") != 2
      return
    endif
  endif
  execute 'silent mksession! ' . session_file
  let s:current_session_name = session_name
endfunction

function! fzf#session#delete(session_name) abort
  let filepath = s:get_session_filepath(a:session_name)
  if confirm('Delete ' . a:session_name . '.vim ?', "&No\n&Yes") == 2
    call delete(filepath)
  endif
endfunction

function! fzf#session#load(session_name) abort
  " update session name
  let s:current_session_name = a:session_name
  " close all current buffer
  execute 'silent bufdo bwipeout'
  execute 'source ' . s:get_session_filepath(a:session_name)
endfunction

function! s:session_sink(args) abort
  let input = a:args[0]
  let session_name = a:args[1]
  if input == 'ctrl-d'
    call fzf#session#delete(session_name)
  else
    call fzf#session#load(session_name)
  endif
endfunction

function! fzf#session#run() abort
  call fzf#run(
  \ fzf#wrap({
  \   'source': map(s:get_session_list(), 's:get_session_name(v:val)'),
  \   'sink*': function("s:session_sink"),
  \   'options': ['--expect=ctrl-d']
  \ })
  \ )
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
