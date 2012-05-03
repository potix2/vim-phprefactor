call vspec#hint({'sid': 'phprefactor#sid()', 'scope': 'phprefactor#scope()'})

describe 's:inline_local_variable'
    it 'should replace a variable with an inline expression'
        call setline(1, '$x = 1 + 2;')
        call setline(2, '$y = $x + 3;')
        normal gg
        call vspec#call('s:inline_local_variable')

        Expect getline(1) == '$y = 1 + 2 + 3;'
    end
end
