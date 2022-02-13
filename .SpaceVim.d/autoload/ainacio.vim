function! ainacio#before() abort
  if !empty($VIM_DOTFILES_DIR)
    let g:vim_dotfiles_dir = $VIM_DOTFILES_DIR
  else
    let g:vim_dotfiles_dir = '~/.config/vim'
  endif

  let g:coc_config_home = '~/.SpaceVim.d/'

lua << EOF
  -- allows importing lua packages from the dotfiles-vim folder
  package.path = ";" .. vim.g['vim_dotfiles_dir'] .. "/lua/?.lua;" .. package.path
EOF

  exe 'source' g:vim_dotfiles_dir . "/init.vim"
endfunction
