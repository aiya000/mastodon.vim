let s:V      = vital#mastodon#new()
let s:JSON   = s:V.import('Web.JSON')
let s:Option = s:V.import('Data.Optional')

"TODO: Don't use plain text for password
"TODO: If user chose account is already exists
function! mastodon#account#create(args) abort
	let l:instance_domain = exists('a:args[0]')
	\                     ? a:args[0]
	\                     : input('instance domain(ex: mastodon.cloud, mastodon.jp): ')
	let l:account_name = exists('a:args[1]')
	\                  ? a:args[1]
	\                  : input('account name for the domain(ex: aiya000@example.com): ')
	let l:account_password = inputsecret('account password: ')
	let l:account = {
	\	'instance_domain': l:instance_domain,
	\	'account_name': l:account_name,
	\	'account_password': l:account_password,
	\}

	"TODO: xdg dir
	"TODO: If decoding is failed
	let l:old_accounts = filereadable(g:mastodon#CONFIG_JSON)
	\                  ? s:JSON.decode(readfile(g:mastodon#CONFIG_JSON))
	\                  : []

	let l:serialized_accounts = s:JSON.encode(insert(l:old_accounts, l:account))
	call writefile([l:serialized_accounts], g:mastodon#CONFIG_JSON)

	redraw
	echomsg l:account_name . ' is added ! (' . l:instance_domain . ')'
endfunction


"TODO: Use serialized file (implement the arround of mastodon#add_account)
function! mastodon#account#auth_default_account(mastodon_instance_name, mastodon_account_name) abort
	let l:instance_url     = mastodon#func#get_instance_url(a:mastodon_instance_name)
	let l:account_password = inputsecret('input password for ' . a:mastodon_account_name . ': ')

	let l:parameters = printf(
	\	'client_id=%s&client_secret=%s&grant_type=password&username=%s&password=%s',
	\	g:mastodon#APP_CLIENT_ID,
	\	g:mastodon#APP_CLIENT_SECRET,
	\	a:mastodon_account_name,
	\	l:account_password
	\)
	let l:request_url = l:instance_url . '/oauth/token?' . l:parameters

	"TODO: I may can use vital's system()
	let l:result = system(printf('curl -X POST --silent "%s"', l:request_url))
	try
		return s:Option.some(s:JSON.decode(l:result))
	catch /E15/
		return s:Option.none()
	endtry
endfunction
