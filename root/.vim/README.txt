mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim


cd .vim/bundle
git submodule init
git submodule add  https://github.com/vim-airline/vim-airline
git submodule add  https://github.com/jreybert/vimagit
git submodule add  https://github.com/ctrlpvim/ctrlp.vim.git

