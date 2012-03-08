" phprefactor - Refactoring browser for PHP
" Version: 0.1.0
" Copyright (C) 2012 Katsunori Kanda <https://github.com/potix2/>
" License: MIT License

if exists('g:loaded_php_refactor')
  finish
endif
let g:loaded_php_refactor = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -range=% PHPRefactor
    \ call phprefactor#command(<q-args>, <count>, <line1>, <line2>)
nnoremap <silent> <Plug>(phprefacotr_rename_local_variable) :PHPRefactor -mode rlv -i<CR>

" Default key mappings.
if !hasmapto('<Plug>(phprefacotr_rename_local_variable)')
\  && (!exists('g:phprefactor_no_default_key_mappings')
\      || !g:phprefactor_no_default_key_mappings)
  silent! map <unique> <Leader>prlv <Plug>(phprefacotr_rename_local_variable)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
