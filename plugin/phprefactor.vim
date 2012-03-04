if exists('g:loaded_php_refactor')
  finish
endif
let g:loaded_php_refactor = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -range=% PHPRefactor call phprefactor#command(<q-args>, <count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
