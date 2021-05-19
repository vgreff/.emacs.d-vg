# .emacs.d-vg

# to install

cd ..
ln -s .emacs.d-vg .emacs.d

for i in ~/.emacs.d/root/.*
do
	echo linking $i
	ln -s $i .
done

