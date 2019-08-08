let s:suite = themis#suite('Test for my plugin')
let s:assert = themis#helper('assert')

function! s:suite.my_test_1()
  call s:assert.equals(4, s:aaa())
endfunction
