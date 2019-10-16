let s:suite = themis#suite('Test for vim-annotation')
let s:assert = themis#helper('assert')

let s:plugin_path = $HOME.'/.config/nvim/plugged/vim-annotation/'

function! s:suite.exists_json_file()
  call s:assert.equals(annotation#exists_json_file('aaaa'), v:false)
endfunction

function! s:suite.delete_not_exists_json()
  let g:annotation_cache_path = ''
  call s:assert.equals(annotation#delete(), v:false)
endfunction

function! s:suite.reflect_difference_to_json()
  let l:path = s:plugin_path.'test/json/reflect_difference_to_json.json'
  let l:result = annotation#reflect_difference_to_json(1, l:path)
  call s:assert.equals(l:result['annotations'][0].row, 161)
endfunction
