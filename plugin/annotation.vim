scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if !exists(':JumpAnnotation')
	command! JumpAnnotation call annotation#jump()
endif

" test
let &cpo = s:save_cpo
unlet s:save_cpo
