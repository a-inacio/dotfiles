function! ainacio#before() abort
  let g:coc_config_home = '~/.SpaceVim.d/'

lua << EOF
  -- allows importing lua packages from the dotfiles-vim folder
  package.path = ";" .. os.getenv("VIM_DOTFILES_DIR") .. "/lua/?.lua;" .. package.path
EOF

  "  for fpath in split(globpath('~/.vimrc.d/', '*.vim'), '\n')
  "    exe 'source' fpath
  " endfor

  " TODO remove hardcoded basepath
  source ~/.config/vim/init.vim
endfunction
