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

" Link jump
function! annotation#refer() abort "{{{1

	if filereadable(s:json_path)
		let l:json = json_decode(readfile(s:json_path)[0])
	else
		echo "Annotation fils is nothing"
		return
	endif

	let l:line = getline('.')
	call filter(l:json['annotations'], 'l:line =~ v:val.title')

	" 候補チェック
	if empty(l:json['annotations'])
		echo "Annotation is nothing."
		return
	endif

	if len(l:json['annotations']) == 1
		call annotation#open(l:json['annotations'][0])
		return
	endif

	" 2以上: 候補ダイアログ後jump
	if len(l:json['annotations']) > 1
		let num = input(annotation#make_candidate_text(l:json['annotations']).'Select annotation: ')
		
		" let candidate_annotation = annotation#select(l:json['annotations'][0])
		" call annotation#open(l:json['annotations'][0])
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

function! annotation#open(json) abort "{{{1
	" ファイルパスがあればジャンプ
	if !empty(a:json['path'])
		call annotation#jump(a:json)
		return
	endif

	" " メモがあれば注釈表示
	" if exists(a:json.memo)
	" 	annotation#show()
	" endif
  "
	" return
endfunction
" }}}

function! annotation#jump(json) abort "{{{1
	execute ":e ".a:json['path']
  execute a:json['line']
	return
endfunction
" }}}

" Link edit
function! annotation#edit() abort "{{{1
	" ファイルがないときは追加
  if !filereadable(g:annotation_cache_path. expand('%') .'.json')
    call annotation#add()
		return
  endif
  
  " jsonに同じタイトルがないときは追加

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
  "
  " call writefile([l:file_json], 'c:/takeda/aaa.txt')
endfunction
" }}}

function! annotation#add() abort "{{{1
	if filereadable(s:json_path)
		let l:file_json = json_decode(readfile(s:json_path)[0])
	else
		let l:file_json = {'annotations': []}
	endif

  " memoの場合
  " 専用バッファ分割
  execute "sp +buffer annotation"
  call s:set_scratch_buffer()
  
  " jsonに入る情報をバッファに入れる

  " リンクの場合
	" let l:title = input('Annotation title :', s:get_visual_text()) 
  "
	" let l:line = line('.')
	" let l:full_path = expand("%:p")
  "
  " let l:annotation = {'title': l:title, 'path': l:full_path, 'line': l:line}
  "
	" call add(l:file_json['annotations'], l:annotation)
  " let l:file_json = json_encode(l:file_json)
  "
  " call writefile([l:file_json], s:json_path)
endfunction
" }}}1


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
    return selected
  catch
    return ''
  endtry
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
