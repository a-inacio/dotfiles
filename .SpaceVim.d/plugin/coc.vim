" https://github.com/SpaceVim/SpaceVim/issues/2564

inoremap <silent><expr> <c-space> coc#refresh()

call coc#config('coc.preferences', {
      \ "autoTrigger": "always",
      \ "maxCompleteItemCount": 10,
      \ "codeLens.enable": 1,
      \ "diagnostic.virtualText": 1,
      \})

let s:coc_extensions = [
      \ 'coc-dictionary',
      \ 'coc-json',
      \ 'coc-tag',
      \ 'coc-snippets',
      \ 'coc-ultisnips',
      \ 'coc-prettier',
      \]

for extension in s:coc_extensions
  call coc#add_extension(extension)
endfor

inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
