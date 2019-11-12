scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if !exists(':OpenAnnotation')
	command! -range OpenAnnotation call annotation#open_dialog()
endif

if !exists(':DeleteAnnotation')
	command! -range DeleteAnnotation call annotation#delete()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
