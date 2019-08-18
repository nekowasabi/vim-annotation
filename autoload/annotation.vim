scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! annotation#colorize() abort
  augroup annotation_highlight
    au!
    exe 'au BufWinEnter * syn match AnnotationHighlight /\v<(' . join(get(g:,'annotation_keywords', ['ワロス', '直前', '直後']), '|') . ')>/ containedin=ALL'
  augroup END
  hi def link AnnotationHighlight phpConstant
endfunction

function! annotation#refer() abort "{{{1
  let s:json_path = g:annotation_cache_path. annotation#get_file_name() . '.json'
  if !annotation#exists_json_file()
    echo "Annotation file is none"
    return
  endif

  let l:json = json_decode(readfile(s:json_path)[0])
  let l:json_include_title = annotation#extract_title_in_linetext(l:json)

  if empty(l:json['annotations'])
    echo "Annotation is none."
    return
  endif

  if len(l:json['annotations']) == 1
    call annotation#refer_open(l:json['annotations'][0])
    return
  endif

  if len(l:json['annotations']) > 1
    let l:num = input(annotation#make_candidate_text(l:json['annotations']).'Select annotation: ')
    call annotation#refer_open(l:json['annotations'][l:num])
  endif

  return
endfunction
" }}}1

function! annotation#refer_open(json) abort "{{{1
  if a:json.annotation != ""
    call annotation#view(a:json)
  endif

  return
endfunction
" }}}

function! annotation#view(json) abort "{{{1 
  let l:wid = bufwinnr(bufnr('__view__'))
  if l:wid != -1
    return
  endif
  silent new
  silent file `='__view__'`
  call annotation#set_view_template(a:json)
  call annotation#set_view_buffer()

endfunction
" }}}1

function! annotation#jump(json) abort "{{{1
  execute ":e ".a:json['path']
  execute a:json['line']
  return
endfunction
" }}}

function! annotation#open_dialog() abort "{{{1
  let s:json_path = g:annotation_cache_path. annotation#get_file_name() . '.json'
  let l:is_file_readable = filereadable(g:annotation_cache_path. annotation#get_file_name() .'.json')

  if !l:is_file_readable
    call annotation#open_buffer_add_annotation()
    return
  endif

  let l:is_exists_title = annotation#extract_annotation_by_title(s:get_visual_text())
  if !l:is_exists_title
    call annotation#open_buffer_add_annotation()
    return
  endif

  call annotation#open_buffer_edit_annotation()
endfunction
" }}}

function! annotation#open_buffer_add_annotation() abort "{{{1
  let l:full_path = expand("%:p")
  let l:title = s:get_visual_text()
  echo l:title
  let l:row = line('.')
  let l:col = col('.')

  let l:wid = bufwinnr(bufnr('__annotation__'))
  if l:wid != -1
    return
  endif
  silent new
  silent file `='__annotation__'`
  call annotation#set_template_for_add_to(l:title, l:full_path, l:row, l:col)
  au! bufwritecmd <buffer> call annotation#save_to_json('add')

endfunction
" }}}1

function! annotation#open_buffer_edit_annotation() abort "{{{1
  let l:wid = bufwinnr(bufnr('__annotation__'))
  if l:wid != -1
    return
  endif

  let l:json =  annotation#get_json_for_edit()
  let l:template = annotation#set_edit_template(l:json)

  let l:annotations = split(l:json['annotations'][0].annotation, "\r")

  silent new
  silent file `='__annotation__'`
  call annotation#set_scratch_buffer()

  call setline(1, l:template)
  call setline(6, l:annotations)

  " TODO: substituteでうまく変換できないためバッファを書き換えている。修正したい
  " if l:template[5] ~= "\"
    " %s/\/\r
  " endif

  au! bufwritecmd <buffer> call annotation#save_to_json('update')
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
  call annotation#set_template_for_add_to(l:title, l:full_path)
  au! bufwritecmd <buffer> call annotation#save_to_json()
endfunction
" }}}1

function! annotation#edit_link() abort "{{{1
  if !filereadable(g:annotation_cache_path. expand('%') .'.json')
    call annotation#open_buffer_add_annotation()
    return
  endif
endfunction
" }}}

function! annotation#set_edit_template(json) abort
  let l:template = []

  call add(l:template, 'title: '.a:json['annotations'][0].title)
  call add(l:template, 'path: '.a:json['annotations'][0].path)
  call add(l:template, 'row: '.line('.'))
  call add(l:template, 'col: '.line('.'))
  call add(l:template, '---------')
  " call add(l:template,  a:json['annotations'][0].annotation)

  return l:template
endfunction

function! annotation#get_json_for_edit() abort
  let l:title = s:get_visual_text()
  let l:json = s:get_annotation_for_edit(l:title)
  return l:json
endfunction

function! s:get_annotation_for_edit(title) abort
  let l:json = json_decode(readfile(s:json_path)[0])
  call filter(l:json['annotations'], 'a:title == v:val.title')
  return l:json
endfunction

function! annotation#set_template_for_add_to(title, full_path, row, col) abort
  " substitute for Japanese text in Windows.
  let l:template = []
  call add(l:template, 'title: '. substitute(a:title, '縺', '', 'g'))
  call add(l:template, 'path: '.a:full_path)
  call add(l:template, 'row: '.a:row)
  call add(l:template, 'col: '.a:col)
  call add(l:template, '---------')

  call setline(1, l:template)
  return
endfunction

function! annotation#save_to_json(save_mode) abort
  let l:title = annotation#get_title()
  let l:path  = annotation#get_path()
	let l:row = annotation#get_row()
	let l:col = annotation#get_col()
  let l:text  = annotation#get_annotation_text()

  if filereadable(s:json_path)
    let l:file_json = json_decode(readfile(s:json_path)[0])
  else
    let l:file_json = {'annotations': []}
  endif

  if a:save_mode == 'add'
    call add(l:file_json['annotations'], {'title': l:title, 'path': l:path, 'row': l:row, 'col': l:col, 'annotation': l:text})
  else
    let l:index = annotation#search_json_index(l:file_json, l:title)
    let l:file_json['annotations'][l:index].title = l:title
    let l:file_json['annotations'][l:index].path = l:path
    let l:file_json['annotations'][l:index].row = l:row
    let l:file_json['annotations'][l:index].col = l:col
    let l:file_json['annotations'][l:index].annotation = l:text
  endif

  let l:file_json = json_encode(l:file_json)
  call writefile([l:file_json], s:json_path)

  echo "saved."
endfunction

function! annotation#search_json_index(json, title) abort
  let l:cnt = 0
  for annotation in a:json['annotations']
    if annotation.title == a:title
      return l:cnt
    endif
    let l:cnt += 1
  endfor

  return v:false
endfunction

function! annotation#get_title() abort
  return substitute(getline(1), 'title: ', '', 'g')
endfunction

function! annotation#get_path() abort
  return substitute(getline(2), 'path: ', '', 'g')
endfunction

function! annotation#get_row() abort
  return substitute(getline(3), 'row: ', '', 'g')
endfunction

function! annotation#get_col() abort
  return substitute(getline(4), 'col: ', '', 'g')
endfunction

function! annotation#get_annotation_text() abort
  return join(getline(6, "$"), "\r")
endfunction

function! annotation#set_scratch_buffer()
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal buflisted
  setlocal filetype=markdown
  set fenc=utf-8
endfunction

function! annotation#get_file_name() abort
  return has('unix') ? fnamemodify(expand('%'), ":t") : fnamemodify(expand('%:p'), ":t")
endfunction

function! annotation#set_view_buffer()
  setlocal ro
  setlocal filetype=markdown
endfunction

function! annotation#set_view_template(json) abort
  let l:template = []

  " substitute for Japanese text in windows.
  call add(l:template, 'title: '. substitute(a:json.title, '縺', '', 'g'))
  call add(l:template, 'path: '.a:json.path)
  call add(l:template, 'row: '.a:json.row)
  call add(l:template, 'col: '.a:json.col)
  call add(l:template, '---------')
  call add(l:template, a:json.annotation)

  call setline(1, l:template)
  return
endfunction

function! annotation#extract_title_in_linetext(json) abort
  let l:line = getline('.')
  let l:col = col('.')
  return filter(a:json['annotations'], 'l:line =~ v:val.title')	
endfunction

function! s:count_candidate(json) abort
  let l:line = getline('.')
  call filter(a:json['annotations'], 'l:line =~ v:val.title')
  return count(a:json)
endfunction

function! annotation#exists_json_file() abort
  if filereadable(s:json_path)
    return v:true
  else
    return v:false
  endif
endfunction

function! annotation#make_candidate_text(json) abort "{{{1
  echo a:json
  let l:word = ''
  let l:candidate_number = 0
  for annotation_setting in a:json
    let l:word = l:word . l:candidate_number . '.' . annotation_setting['title']. '  '. annotation_setting['path'] . "\n"
    let l:candidate_number += 1
  endfor

  return l:word
endfunction
" }}}1

function! annotation#extract_annotation_by_title(title) abort
  let l:json = json_decode(readfile(s:json_path)[0])
  call filter(l:json['annotations'], 'a:title == v:val.title') 

  return empty(l:json['annotations']) ? v:false : v:true
endfunction


"ビジュアルモードで選択中のテクストを取得する {{{
function! s:get_visual_text()
  try
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
    let splitted = split(selected, '\zs')
    return join(splitted[0:-2], "")
  catch
    return ''
  endtry
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
