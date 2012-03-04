" phprefactor - Refactoring browser for PHP
" Version: 0.0.0
" Copyright (C) 2012 Katsunori Kanda <https://github.com/potix2/>
" License:

function! phprefactor#command(config, use_range, line1, line2)
    call phprefactor#rename_local_variable()
endfunction

function! phprefactor#get_visual_selection()
  try
    let a_save = @a
    if a:0 >= 1 && a:1 == 1
      normal! gv"ad
    else
      normal! gv"ay
    endif
    return @a
  finally
    let @a = a_save
  endtry
endfunction

function! phprefactor#get_range_for_function()
  " matchit.vim required 
  if !exists("g:loaded_matchit") 
    throw("matchit.vim (http://www.vim.org/scripts/script.php?script_id=39) required")
  endif

  let cursor_position = getpos(".")

  let block_start = search(a:pattern_start, a:flags)

  if (match(getline("."), "^\\s*it\\s\\+") == 0)
    normal $
  endif

  normal %
  let block_end = line(".")

  " Restore the cursor
  call setpos(".",cursor_position) 

  return [block_start, block_end]
endfunction

" Synopsis:
"   Rename the selected local variable 
function! phprefactor#rename_local_variable()
  try
    let selection = phprefactor#get_visual_selection()

    " If @ at the start of selection, then abort
    if match( selection, "@" ) != -1
      throw "Selection '" . selection . "' is not a local variable"
    endif

    let name = input("Rename to: ")
  catch
    echo v:exception
    return
  endtry

  " Find the start and end of the current block
  let [block_start, block_end] = phprefactor#get_range_for_function()

  " Rename the variable within the range of the block
"  call common#gsub_all_in_range(block_start, block_end, '[^@]\<\zs'.selection.'\>\ze\([^\(]\|$\)', name)
endfunction

" Misc. {{{1
" function! phprefactor#scope() "{{{2
"     return s:
" endfunction
" 
" function! phprefactor#sid() "{{{2
"     return maparg('<SID>', 'n')
" endfunction
" nnoremap <SID>  <SID>

" __END__ "{{{1
" vim: foldmethod=marker
