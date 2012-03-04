runtime! plugin/phprefactor.vim

" call vspec#hint({'scope': 'phprefactor#scope()', 'sid': 'phprefactor#sid()'})

describe 'phprefactor#get_visual_selection'
    it 'should '
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
