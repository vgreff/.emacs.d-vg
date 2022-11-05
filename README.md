# .emacs.d-vg

# to install

git submodule update --init --recursive

cd ..
# find . -type l -maxdepth 1 -ls
find . -type l -maxdepth 1 |xargs rm

./.emacs.d-vg/root/bin/mkold .emacs.d

ln -s .emacs.d-vg .emacs.d

for i in ~/.emacs.d/root/.[0-z]* ~/.emacs.d/root/bin
do
	echo linking $i `basename $i` 
	ln -s $i `basename $i` 
done

ls -la

