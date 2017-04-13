"command -bar MastodonAddAccount call mastodon#add_account()
command -bar -nargs=? MastodonHome call mastodon#open_home(<q-args>)

let g:mastodon_instances = get(g:, 'mastodon_vim_instances', {})
