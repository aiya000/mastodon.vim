command! -bar -nargs=* MastodonAddAccount call mastodon#add_account(<f-args>)
command! -bar -nargs=* MastodonHome call mastodon#open_home(<f-args>)
command! -bar -nargs=0 MastodonSay call mastodon#open_say_buffer()

let g:mastodon_instances = get(g:, 'mastodon_instances', {})

"TODO: Use my cilent_id and client_secret
let g:mastodon#APP_CLIENT_ID     = '9766a3780217ee179c18dfb9aa234566ff3dfb3dd495f0d3669acfadd9a696d1' | lockvar g:mastodon#APP_CLIENT_ID
let g:mastodon#APP_CLIENT_SECRET = 'b38cebc9235edb15db12320866c4258606f0172ce5aafa6768f4fb0a4973bf61' | lockvar g:mastodon#APP_CLIENT_SECRET

"TODO: xdg dir
let g:mastodon#CONFIG_FILE_PATH = $HOME . '/.vim-mastodon.json' | lockvar g:mastodon#CONFIG_FILE_PATH


" In mastodon-say buffer (See say.vim)
nmap <silent> <Plug>(mastodon-execute-say) :<C-u>call mastodon#say#execute()<CR>
