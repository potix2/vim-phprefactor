call vspec#hint({'sid': 'phprefactor#sid()', 'scope': 'phprefactor#scope()'})

describe 's:extract_local_variable'
    it 'should extract selected expression to a local variable'
        call setline(1, '$a = 1 + 2 * 3;')
        normal! gg3wv4l
        call vspec#call('s:extract_local_variable', 'v')

        Expect getline(1) ==# '$v = 1 + 2;'
        Expect getline(2) ==# '$a = $v * 3;'
    end

    it 'should extract selected expression to a local variable and insert it at the previous statement.'
        call setline(1, '$x = 1;')
        call setline(2, '$this->somefunc(')
        call setline(3, '2 + 3')
        call setline(4, ');')
        normal! ggjjv4l
        call vspec#call('s:extract_local_variable', 'v')

        Expect getline(2) ==# '$v = 2 + 3;'
        Expect getline(4) ==# '$v'
    end

    it 'should extract selected expression to a local variable and insert it after beginning of the current block.'
        call setline(1, '$x = 1;')
        call setline(2, 'if ( $x ) {')
        call setline(3, '$y = 1 + 2 * 3;')
        call setline(4, '}')

        normal! gg2j3wv4l

        call vspec#call('s:extract_local_variable', 'v')
        Expect getline(3) ==# '$v = 1 + 2;'
        Expect getline(4) ==# '$y = $v * 3;'
    end
end
