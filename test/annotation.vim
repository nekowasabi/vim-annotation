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

function! s:suite.reflect_difference_to_json_plus()
  let l:path = s:plugin_path.'test/json/reflect_difference_to_json.json'

  let l:result = annotation#reflect_difference_to_json(1, l:path)
  call s:assert.equals(l:result['annotations'][0].row, 161)
endfunction

function! s:suite.reflect_difference_to_json_minus()
  let l:path = s:plugin_path.'test/json/reflect_difference_to_json.json'

  let l:result = annotation#reflect_difference_to_json(-1, l:path)
  call s:assert.equals(l:result['annotations'][0].row, 159)
endfunction

function! s:suite.extract_by_linenum_empty()
  let l:json = s:plugin_path.'test/json/extract_by_linenum_empty.json'
  let l:json = json_decode(readfile(l:json)[0])

  let l:result = annotation#extract_by_linenum(l:json['annotations'])
  call s:assert.empty(l:result)
endfunction

