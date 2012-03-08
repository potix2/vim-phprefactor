" phprefactor - Refactoring browser for PHP
" Version: 0.1.0
" Copyright (C) 2012 Katsunori Kanda <https://github.com/potix2/>
" License: MIT License

" Interfaces {{{1
function! phprefactor#command(config, use_range, line1, line2) "{{{2
    call phprefactor#rename_local_variable()
endfunction

function! phprefactor#get_variable_name() "{{{2
    return expand('<cword>')
endfunction

function! phprefactor#in_comment_block() "{{{2
    let cursor_position = getpos(".")
    try
        if search('\/\/', 'b', line('.')) > 0
            return 1
        endif

        call setpos(".", cursor_position)
        if search('\/\*', 'b', line("w0")) <= 0
            return 0
        endif

        if search('\*\/', '', line("w")) <= 0
            return 1
        endif

        let end_of_comment_pos = getpos(".")
        if (cursor_position[1] < end_of_comment_pos[1])
                    \ || (cursor_position[1] == end_of_comment_pos[1]
                    \ &&  cursor_position[2] <  end_of_comment_pos[2])
            return 1
        endif

        return 0
    catch
    finally
        call setpos(".", cursor_position)
    endtry

endfunction

function! s:move_to_left_brace_of_current_function_block() "{{{2
    let cursor_position = getpos(".")
    while search('function', 'b', line('w0')) > 0
        if !phprefactor#in_comment_block()

            while search('{', '', cursor_position[0]) > 0
                if !phprefactor#in_comment_block()
                    let retpos = getpos(".")
                    return retpos[1]
                endif
            endwhile

            call setpos(".",cursor_position) 
            return 0
        endif
    endwhile

    call setpos(".",cursor_position) 
    return 0
endfunction

function! phprefactor#get_range_for_function() "{{{2
    let cursor_position = getpos(".")
    try
        let block_start = s:move_to_left_brace_of_current_function_block()
        if block_start <= 0
            return [-1,-1]
        endif

        normal %
        let block_end = line(".")
        return [block_start, block_end]
    catch
    finally
        call setpos(".",cursor_position) 
    endtry
endfunction

function! phprefactor#rename_local_variable() "{{{2
    let name = input("Rename to: ")
    if name == ""
        return
    endif

    call s:rename_local_variable(name)
endfunction

" Internals {{{1
function! s:rename_local_variable(name) " {{{2
    if a:name == ""
        return
    endif

    let original_var_name = phprefactor#get_variable_name()
    " TODO: verify whether the returned variable is a local variable or not.

    let [block_start, block_end] = phprefactor#get_range_for_function()

    " Rename the variable within the range of the block
    let lnum = block_start
    while lnum <= block_end
        let oldline = getline(lnum)
        let newline = substitute(oldline,'\($' . original_var_name . '\)\(\W\+\)','$' . a:name . '\2','g')
        call setline(lnum, newline)
        let lnum = lnum + 1
    endwhile
endfunction

" for vspec {{{1
function! phprefactor#sid() "{{{2
    return maparg('<SID>', 'n')
endfunction
nnoremap <SID> <SID>

function! phprefactor#scope() "{{{2
    return s:
endfunction

" __END__ "{{{1
" vim: foldmethod=marker
