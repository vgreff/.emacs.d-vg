# .emacs.d-vg

# to install

git submodule update --init --recursive

cd ..
ln -s .emacs.d-vg .emacs.d

for i in ~/.emacs.d/root/.*
do
	echo linking $i
	ln -s $i .
done

