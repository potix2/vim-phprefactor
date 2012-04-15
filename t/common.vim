call vspec#hint({'sid': 'phprefactor#sid()', 'scope': 'phprefactor#scope()'})

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

    it 'should return [-1,-1] when it is in global scope.'
        call setline(1, '    $val = $this->bar();')
        normal! ggw
        Expect phprefactor#get_range_for_function() ==# [-1,-1]
    end
end

describe 's:get_previous_statement_position'
    it 'should return an empty list when it is in the first statement.'
        call setline(1, '$a = 1 + 2;')
        let actual = vspec#call('s:get_previous_statement_position')
        Expect actual == []
    end

    it 'should return an empty list when it is in the first statement of current block.'
        call setline(1, '$a = 1 + 2;')
        call setline(2, 'if ( $a ) {')
        call setline(3, '$b = 1;')
        call setline(4, '}')
        normal! ggjj
        let actual = vspec#call('s:get_previous_statement_position', 2)
        Expect actual == []
    end

    it 'should return the end position of the previous statment.'
        call setline(1, '$a = 1 + 2;')
        call setline(2, '$b = 2 + 3;')
        call setline(3, '$c = 3 + 4;')
        normal! ggjj
        let actual = vspec#call('s:get_previous_statement_position')
        Expect actual[1] == 2
        Expect actual[2] == 11
    end

    it 'should return the end position of the previous block.'
        call setline(1, 'while( true ) {')
        call setline(2, '$a = 1 + 2;')
        call setline(3, '}')
        call setline(4, '$b = 2 + 3;')
        normal! ggjjj
        let actual = vspec#call('s:get_previous_statement_position')
        Expect actual[1] == 3
        Expect actual[2] == 1
    end

end

describe 's:get_beginning_of_current_block'
    it 'should return an empty list when it is in global scope.'
        call setline(1, '$a = 1;')
        normal! gg5l
        let actual = vspec#call('s:get_beginning_of_current_block')
        Expect actual[1] ==# 1
        Expect actual[2] ==# 1
    end

    it 'should return the beginning position of the current block'
        call setline(1, '$x = 1;')
        call setline(2, 'if ( $x ) {')
        call setline(3, '$a = 1;')
        call setline(4, '}')
        normal! gg2j
        let actual = vspec#call('s:get_beginning_of_current_block')
        Expect actual[1] ==# 2
        Expect actual[2] ==# 11
    end
end
