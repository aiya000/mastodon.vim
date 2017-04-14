"command -bar MastodonAddAccount call mastodon#add_account()
command -bar -nargs=? MastodonHome call mastodon#open_home(<q-args>)

let g:mastodon_instances = get(g:, 'mastodon_instances', {})

"TODO: Use my cilent_id and client_secret
let g:mastodon#APP_CLIENT_ID     = '9766a3780217ee179c18dfb9aa234566ff3dfb3dd495f0d3669acfadd9a696d1' | lockvar g:mastodon#APP_CLIENT_ID
let g:mastodon#APP_CLIENT_SECRET = 'b38cebc9235edb15db12320866c4258606f0172ce5aafa6768f4fb0a4973bf61' | lockvar g:mastodon#APP_CLIENT_SECRET
