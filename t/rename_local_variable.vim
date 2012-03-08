call vspec#hint({'sid': 'phprefactor#sid()', 'scope': 'phprefactor#scope()'})

describe 's:rename_local_variable'
    it 'should replace the name of local variables to new one in the current function'
        call setline(1, 'function foo() {')
        call setline(2, '  $exp = 1 + $this->exp();')
        call setline(3, '  if ( $exponent > 0 ) { ')
        call setline(4, '    $exp *= 2;')
        call setline(5, '  }')
        call setline(6, '}')
        normal! ggjwl
        call vspec#call('s:rename_local_variable', 'bar')

        Expect getline(2) ==# '  $bar = 1 + $this->exp();'
        Expect getline(3) ==# '  if ( $exponent > 0 ) { '
        Expect getline(4) ==# '    $bar *= 2;'
    end
end
