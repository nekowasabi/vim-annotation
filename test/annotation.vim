let s:suite = themis#suite('Test for vim-annotation')
let s:assert = themis#helper('assert')

function! s:suite.exists_json_file()
  call s:assert.equals(v:false, annotation#exists_json_file('aaaa'))
endfunction
