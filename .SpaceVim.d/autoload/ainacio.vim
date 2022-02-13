function! ainacio#before() abort
  let g:coc_config_home = '~/.SpaceVim.d/'

lua << EOF
  -- allows importing lua packages from the dotfiles-vim folder
  package.path = ";" .. os.getenv("VIM_DOTFILES_DIR") .. "/lua/?.lua;" .. package.path
EOF

  source ~/.config/vim/core.vim
  source ~/.config/vim/preferences.vim
endfunction
