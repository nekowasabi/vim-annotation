# This plugin sets text annotation in selected word.

## What vim-annotation is
Annotation taking in word, directly.

Show memo in status line without other memo tools.

## Installation

for vim-plug

    Plug 'nekowasabi/vim-annotation'

for dein

    call dein##add('nekowasabi/vim-annotation')

## Quick start
### Annotation taking
1. Select words by visual mode

2. Execute :OpenAnnotation<CR>

3. Write annotation

### Show annotation
1. Move to setting annotation line.

2. Show annotation in status line.

## Settings
### save diretory
Set default cache path.

ex.
    let g:annotation_cache_path = '/home/user_name/.cache/annotation_json/'

### key bindings
ex.
    nnoremap <silent> <Leader>ao :OpenAnnotation<CR>
    nnoremap <silent> <Leader>ad :DeleteAnnotation<CR>

### syntax
Use `AnnotationString`

    autocmd ColorScheme * highlight AnnotationString ctermfg=red ctermbg=white
    hi default link AnnotationString String

## Screenshot
### Annotation taking
![open](https://github.com/nekowasabi/gif/blob/master/vim-annotation/open_annotation.gif)

### Show annotation
![open](https://github.com/nekowasabi/gif/blob/master/vim-annotation/show_annotation.gif)

### Delete annotation
![open](https://github.com/nekowasabi/gif/blob/master/vim-annotation/delete_annotation.gif)

## TODO
* Toggle annotation syntax.

* Show all annotations.

* Denite.nvim integration.

* Show annotation by floatwindow(neovim only).

## Inspired by
Utl.vim(https://github.com/vim-scripts/utl.vim)

## License
MIT License.

## Maintainer
takets(nolifeking00 at gmail.com)
