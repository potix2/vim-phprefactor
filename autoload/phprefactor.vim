" phprefactor - Refactoring browser for PHP
" Version: 0.2.0
" Copyright (C) 2012 Katsunori Kanda <https://github.com/potix2/>
" License: MIT License

" Interfaces {{{1
function! phprefactor#command(config, use_range, line1, line2) "{{{2
    let args = split(a:config)
    let expect_mode = 0
    for arg in args
        if expect_mode == 1
            let expect_mode = 0
            let mode = arg
        elseif arg =~ '^\(-m\|--mode\)$'
            let expect_mode = 1
        elseif len(arg) > 0
            echohl ErrorMsg | echomsg 'Invalid arguments' | echohl None
            unlet args
            return 0
        endif
    endfor
    unlet args
    "echo "mode=".mode

    if l:mode == "rlv"
        call phprefactor#rename_local_variable()
    elseif l:mode == "elv"
        call phprefactor#introduce_local_variable()
    else
        echohl ErrorMsg | echomsg 'Unknown mode' | echohl None
        return 0
    endif
    return 1
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

function! phprefactor#introduce_local_variable() "{{{2
    normal `>
    let end = getpos(".")
    normal `<v
    call setpos(".", end)
    if mode() != "v"
        echohl WarningMsg | echo "Select a expression." | echohl None
        return
    endif

    let name = input("Extract to: ")
    if name == ""
        return
    endif
    call s:extract_local_variable(name)
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

function! s:backward_search(symbol, stop) "{{{2
    let prevpos = getpos('.')
    try
        if search(a:symbol, 'b', a:stop) == 0
            return []
        else
            return getpos('.')
        endif
    catch
    finally
        call setpos('.', prevpos)
    endtry
endfunction

function! s:compare_position(pos1, pos2)
    if a:pos1[1] > a:pos2[1]
        return 1
    elseif a:pos1[1] < a:pos2[1]
        return -1
    elseif a:pos1[2] > a:pos2[2]
        return 1
    elseif a:pos1[2] < a:pos2[2]
        return -1
    else
        return 0
endfunction

function! s:get_previous_statement_position(...) " {{{2
    if a:0 == 0
        let stop = line('w0')
    else
        let stop = a:1
    endif

    let pos_semicolon = s:backward_search(';', stop)
    let pos_right_brace = s:backward_search('}', stop)
    if empty(pos_semicolon) && empty(pos_right_brace)
        return []
    elseif empty(pos_right_brace)
        \ || s:compare_position(pos_semicolon, pos_right_brace) > 0
        return pos_semicolon
    else
        return pos_right_brace
    endif
    
endfunction

function! s:get_beginning_of_current_block() " {{{2
    let cursor_position = getpos(".")
    try
        while search('{', 'b', cursor_position[0]) > 0
            if !phprefactor#in_comment_block()
                return getpos(".")
            endif
        endwhile

        normal! gg
        return getpos(".")
    catch
    finally
        call setpos(".",cursor_position) 
    endtry
endfunction

function! s:extract_local_variable(name) " {{{2
    let m = mode()
    if m != "v"
        echoerr "Not visual mode!"
        return
    endif

    exec 'normal! c$' . a:name
    let beginning_of_current_block = s:get_beginning_of_current_block()
    let previous_statement_position = s:get_previous_statement_position(beginning_of_current_block[1])
    if empty(previous_statement_position) 
        if beginning_of_current_block[1] == 1 && beginning_of_current_block[2] == 1
            exec "normal! ggO$" . a:name . " = "
        else
            call setpos(".", beginning_of_current_block)
            exec "normal! o$" . a:name . " = "
        endif
    else
        call setpos(".", previous_statement_position)
        exec "normal! o$" . a:name . " = "
    endif

    normal! $pa;
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
