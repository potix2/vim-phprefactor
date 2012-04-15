tests := common.vim extract_local_variable.vim rename_local_variable.vim
rtp := ~/.vim .

spec:
	for t in t/*.vim; do \
		echo $$t; \
		vspec $(rtp) $$t; \
	done
