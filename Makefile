rtp := ~/.vim .

spec:
	for t in t/*.vim; do \
		echo $$t; \
		vspec $(rtp) $$t; \
	done
