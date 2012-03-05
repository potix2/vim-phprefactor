describe 'phprefactor#in_comment_block'
    after
        normal! ggdG
    end

    it 'should return true in the line comment.'
        call setline(1, 'ab //function foo() {')
        normal! gg5l
        Expect phprefactor#in_comment_block() != 0
    end

    it 'should return true in the comment block'
        call setline(1, 'ab /* ')
        call setline(2, 'function foo() {'
        call setline(3, '*/')
        normal! ggj
        Expect phprefactor#in_comment_block() != 0
    end

    it 'should return true in the comment block'
        call setline(1, 'ab /* function */')
        normal! gg5l
        Expect phprefactor#in_comment_block() != 0
    end

    it 'should return false without comments.'
        call setline(1, 'public function foo() {')
        normal! gg5l
        Expect phprefactor#in_comment_block() == 0
    end

    it 'should return false when the current position is before a comment line.'
        call setline(1, 'ab // function')
        normal! gg
        Expect phprefactor#in_comment_block() == 0
    end

    it 'should return false when the current position is after the end of comment block.'
        call setline(1, 'a /* aa */ function')
        normal! gg11l
        Expect phprefactor#in_comment_block() == 0
    end
end

describe 'phprefactor#get_variable_name'
    it 'should return a variable name.'
        call setline(1, '$val = $this->bar();')
        normal! gg2l
        Expect phprefactor#get_variable_name() ==# "val"

        call setline(1, '$val= $this->bar();')
        normal! gg2l
        Expect phprefactor#get_variable_name() ==# "val"

        call setline(1, '$_val1 = $this->bar();')
        normal! gg2l
        Expect phprefactor#get_variable_name() ==# "_val1"

        call setline(1, '      $val = $this->bar();')
        normal! gg2l
        Expect phprefactor#get_variable_name() ==# "val"
    end
end

describe 'phprefactor#get_range_for_function'
    it 'should return a range of the function block'
        call setline(1, 'function foo() {')
        call setline(2, '    $val = $this->bar();')
        call setline(3, '    if ( $val ) {')
        call setline(4, '        //do something')
        call setline(5, '    }')
        call setline(6, '}')
        call setline(7, '// end of script')
        Expect phprefactor#get_range_for_function() ==# [1,6]
    end
end
