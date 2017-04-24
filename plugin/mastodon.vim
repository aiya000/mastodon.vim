" --- Command --- "

" Create or add the cache of a mastodon instance's an account to g:mastodon#CONFIG_FILE_PATH .
" Optionally require two arguments of 1:'mastodon instance name' and 2:'account name'.
" If this wasn't specified, :MastodonAddAccount asks 'mastodon instance name' and 'account name'.
command! -bar -nargs=* MastodonAddAccount call mastodon#add_account(<f-args>)

" Show the buffer of mastodon home timeline.
command! -bar -nargs=* MastodonHome call mastodon#open_home(<f-args>)

" Open the empty nofile buffer for <Plug>(mastodon-execute-say)
command! -bar -nargs=* MastodonSay call mastodon#open_say_buffer(<f-args>)


" --- Global variable --- "

let g:mastodon_instances = get(g:, 'mastodon_instances', {})

let g:mastodon#APP_CLIENT_ID     = '48c18127ac449e905bb70b6ee121e5f1060251368f5fb4faaa2e3279cda24bed' | lockvar g:mastodon#APP_CLIENT_ID
let g:mastodon#APP_CLIENT_SECRET = '9258646f0a19721b28c73c85eafb2140a1a5b401f522c3f8e87bd8f1778ab138' | lockvar g:mastodon#APP_CLIENT_SECRET

"TODO: xdg dir
let g:mastodon#CONFIG_FILE_PATH = $HOME . '/.vim-mastodon.json' | lockvar g:mastodon#CONFIG_FILE_PATH


" --- Keymap --- "

" In mastodon-say buffer (See say.vim)
nmap <silent> <Plug>(mastodon-execute-say) :<C-u>call mastodon#execute_say()<CR>
