scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if !exists(':JumpAnnotation')
	command! -range JumpAnnotation call annotation#refer()
endif

if !exists(':EditAnnotation')
	command! -range EditAnnotation call annotation#edit()
endif



" test
let &cpo = s:save_cpo
unlet s:save_cpo
