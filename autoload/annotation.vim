scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#vital#new()

" Link jump
function! annotation#jump() abort "{{{1
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
