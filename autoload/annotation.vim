scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#vital#new()
if has('unix')
  let s:file_name = fnamemodify(expand('%'), ":t")
else
  let s:file_name = fnamemodify(expand('%:p'), ":t")
endif

let s:json_path = g:annotation_cache_path. s:file_name . '.json'

function! annotation#refer() abort "{{{1
  " check exists json
  if !s:exists_json_file()
		echo "Annotation fils is nothing"
    return
  endif

  " routing jump or view
  let l:json = json_decode(readfile(s:json_path)[0])


	" 候補チェック
	if empty(l:json['annotations'])
		echo "Annotation is nothing."
		return
	endif

	if len(l:json['annotations']) == 1
		call annotation#refer_open(l:json['annotations'][0])
		return
	endif

	" 2以上: 候補ダイアログ後jump
	if len(l:json['annotations']) > 1
		let l:num = input(annotation#make_candidate_text(l:json['annotations']).'Select annotation: ')
		call annotation#refer_open(l:json['annotations'][l:num])
	endif

	return
  " let l:str = string(matchstr(getline('.'), '\v\[%<' . col('.') . 'c\[[^\]]{-}%>' . col('.') . 'c\]\]'))
  " let l:str = substitute(l:str, '[[', '', 'g')
  " let l:str = substitute(l:str, ']]', '', 'g')
  " let l:str = substitute(l:str, "'''", "'", 'g')
	" let l:tmp = split(l:str, '|')
  " let l:elm = {}
  " let l:elm.text = substitute(l:tmp[0], "'", "", 'g') 
  " let l:elm.path = substitute(l:tmp[1], "'", "", 'g') 
  " let l:elm.line = substitute(l:tmp[2], "'", "", 'g') 
	" execute ":e ".l:elm.path
  " execute l:elm.line
endfunction
" }}}

function! s:count_candidate(json) abort
	let l:line = getline('.')
	call filter(a:json['annotations'], 'l:line =~ v:val.title')
  return count(a:json)
endfunction

function! s:exists_json_file() abort
	if filereadable(s:json_path)
    return v:true
	else
		return v:false
	endif
endfunction

function! annotation#make_candidate_text(json) abort "{{{1
	let l:word = ''
	let l:candidate_number = 0
	for annotation_setting in a:json
		let l:word = l:word . l:candidate_number . '.' . annotation_setting['title']."\n"
		let l:candidate_number += 1
	endfor

	return l:word
endfunction
" }}}1

function! annotation#refer_open(json) abort "{{{1
	if !empty(a:json['line'])
		call annotation#jump(a:json)
	endif

	if exists(a:json['annotation'])
		call annotation#view()
	endif

	return
endfunction
" }}}

function! annotation#jump(json) abort "{{{1
	execute ":e ".a:json['path']
  execute a:json['line']
	return
endfunction
" }}}

function! annotation#open_dialog() abort "{{{1
  let l:is_file_readable = filereadable(g:annotation_cache_path. s:file_name .'.json')

  if !l:is_file_readable
    call annotation#open_buffer_add_annotation()
		return
  endif

  let l:is_exists_title = s:search_annotation_title(s:get_visual_text())
  if !l:is_exists_title
    call annotation#open_buffer_add_annotation()
		return
  endif

  " 編集用ダイアログを表示
  call annotation#open_buffer_edit_annotation()
endfunction
" }}}

function! s:search_annotation_title(title) abort
  let l:json = json_decode(readfile(s:json_path)[0])
  call filter(l:json['annotations'], 'a:title == v:val.title')

	if empty(l:json)
    return v:false
	else
		return v:true
	endif
endfunction

function! annotation#edit_link() abort "{{{1
	" ファイルがないときは追加
  if !filereadable(g:annotation_cache_path. expand('%') .'.json')
    call annotation#open_buffer_add_annotation()
		return
  endif
  
  " 編集用ダイアログを表示 {{{1

	" ファイルがあるときはannotationに追記
	" let l:file_json = json_decode(readfile(g:annotation_cache_path.'aaa.txt')[0])
	" let l:title = input('Annotation title :', s:get_visual_text()) 
  "
	" let l:line = line('.')
	" let l:full_path = expand("%:p")
  "
  " let l:annotation = {'title': l:title, 'path': l:full_path, 'line': l:line}
  "
	" call add(l:file_json['annotations'], l:annotation)
  " let l:file_json = json_encode(l:file_json)
  " }}}1
endfunction
" }}}


function! annotation#open_buffer_add_annotation() abort "{{{1
	let l:full_path = expand("%:p")
  let l:title = s:get_visual_text()

  let l:wid = bufwinnr(bufnr('__annotation__'))
  if l:wid != -1
    return
  endif
  silent new
  silent file `='__annotation__'`
  call <sid>set_new_template(l:title, l:full_path)
  au! bufwritecmd <buffer> call <sid>save_to_json('add')

endfunction
" }}}1


function! annotation#open_buffer_edit_annotation() abort "{{{1
  let l:wid = bufwinnr(bufnr('__annotation__'))
  if l:wid != -1
    return
  endif

  let l:json =  s:get_edit_json()
  let l:template = s:set_edit_template(l:json)

  silent new
  silent file `='__annotation__'`

  call setline(1, l:template)

  au! bufwritecmd <buffer> call <sid>save_to_json('update')
endfunction
" }}}1

function! annotation#add_link() abort "{{{1
	let l:full_path = expand("%:p")
  let l:title = s:get_visual_text()

  let l:wid = bufwinnr(bufnr('__link__'))
  if l:wid != -1
    return
  endif
  silent new
  silent file `='__link__'`
  call <sid>set_new_template(l:title, l:full_path)
  au! bufwritecmd <buffer> call <sid>save_to_json()
endfunction
" }}}1


function! s:set_edit_template(json) abort
  let l:template = []
  call add(l:template, 'title: '.a:json['annotations'][0].title)
  call add(l:template, 'path: '.a:json['annotations'][0].path)
  call add(l:template, '---------')
  call add(l:template, a:json['annotations'][0].annotation)

  return l:template
endfunction


function! s:get_edit_json() abort
  let l:title = s:get_visual_text()
  let l:json = s:get_annotation_for_edit(l:title)
  
  return l:json
endfunction

function! s:get_annotation_for_edit(title) abort
  let l:json = json_decode(readfile(s:json_path)[0])
  call filter(l:json['annotations'], 'a:title == v:val.title')
  return l:json
endfunction

function! s:set_new_template(title, full_path) abort
  let l:template = []

  call add(l:template, 'title: '.a:title)
  call add(l:template, 'path: '.a:full_path)
  call add(l:template, '---------')

  call setline(1, l:template)
  return
endfunction

function! s:save_to_json(save_mode) abort
  let l:title = s:get_title()
  let l:path  = s:get_path()
  let l:text  = s:get_annotation_text()

  let l:annotation = {'title': l:title, 'path': l:path, 'annotation': l:text}

	if filereadable(s:json_path)
		let l:file_json = json_decode(readfile(s:json_path)[0])
	else
		let l:file_json = {'annotations': []}
	endif

	call add(l:file_json['annotations'], l:annotation)
  let l:file_json = json_encode(l:file_json)

  call writefile([l:file_json], s:json_path)
endfunction

function! s:get_title() abort
  return substitute(getline(1), 'title: ', '', 'g')
endfunction

function! s:get_path() abort
  return substitute(getline(2), 'path: ', '', 'g')
endfunction
 
function! s:get_annotation_text() abort
  return join(getline(4, '$'), "\n")
endfunction

function! s:set_scratch_buffer()
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal buflisted
  setlocal filetype=markdown
endfunction

"ビジュアルモードで選択中のテクストを取得する {{{
function! s:get_visual_text()
  try
    " ビジュアルモードの選択開始/終了位置を取得
    let pos = getpos('')
    normal `<
    let start_line = line('.')
    let start_col = col('.')
    normal `>
    let end_line = line('.')
    let end_col = col('.')
    call setpos('.', pos)

    let tmp = @@
    silent normal gvy
    let selected = @@
    let @@ = tmp
    return selected[0:-2]
  catch
    return ''
  endtry
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
