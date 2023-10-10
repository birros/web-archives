VERSION=v0.0.1
URL=https://github.com/birros/web-archives-darkreader/releases/download/${VERSION}/web-archives-darkreader_${VERSION}.js
SHA256=8ee840aacd9e09864a7ab2e75f736f696dcd4b4b8e86a07ba727ff3d10ef32a1
DEST_FILENAME=web-archives-darkreader_${VERSION}.js

all: download

.PHONY: download
download: web-archives-darkreader.js

web-archives-darkreader.js: ${DEST_FILENAME}
	rm -f web-archives-darkreader.js
	cp ${DEST_FILENAME} web-archives-darkreader.js

${DEST_FILENAME}:
	rm -f *.tmp
	curl -L ${URL} --output ${DEST_FILENAME}.tmp
	sha256sum -c <<< '${SHA256}  ${DEST_FILENAME}.tmp'
	mv ${DEST_FILENAME}.tmp ${DEST_FILENAME}
