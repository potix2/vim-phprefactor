" describe 'phprefactor#rename_local_variable'
"     it 'should replace the name of local variables to new one in the current function'
"         call setline(1, 'function foo() {')
"         call setline(2, '  $exp = 1 + 2;')
"         call setline(2, '  $exp = 1 + 2;')
"         call setllne(3, '  if ( $exp > 0 ) { ')
"         call setline(4, '    $exp *= 2;')
"         call setline(5, '  }')
"         call setline(6, '}')
"         normal! ggjwl
"         call phprefactor#rename_local_variable()
"     end
" end
