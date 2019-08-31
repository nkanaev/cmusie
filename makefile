build:
	test -e cmusie.app && rm -rf cmusie.app || true
	xcodebuild -scheme cmusie DSTROOT=. INSTALL_PATH=. archive
