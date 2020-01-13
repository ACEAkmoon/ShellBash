cd //Users/creativetrendadmin/Library/Developer/Xcode && \
	find . \( -name "#*#" -o -name "*/" -o -name "*~" \) -print -delete && \
	find . \( -name "Unity-iPhone-*" \) -print | xargs rm -Rf

