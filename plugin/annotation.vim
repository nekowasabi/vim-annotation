scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if !exists(':ReferAnnotation')
	command! -range ReferAnnotation call annotation#refer()
endif

if !exists(':EditAnnotation')
	command! -range EditAnnotation call annotation#edit#annotation()
endif


if !exists(':EditLink')
	command! -range EditLink call annotation#edit#link()
endif


let &cpo = s:save_cpo
unlet s:save_cpo
