let s:V      = vital#mastodon#new()
let s:JSON   = s:V.import('Web.JSON')
let s:Option = s:V.import('Data.Optional')

"TODO: Use serialized file (implement the arround of mastodon#add_account)
function! mastodon#account#auth_default_account(mastodon_instance_name) abort
	let l:instance_url = mastodon#func#get_instance_url(a:mastodon_instance_name)

	"TODO: If default_account is not set
	let l:account_name     = g:mastodon_instances[a:mastodon_instance_name].default_account
	let l:account_password = input('input password for ' . l:account_name . ': ')

	let l:parameters = printf(
	\	'client_id=%s&client_secret=%s&grant_type=password&username=%s&password=%s',
	\	g:mastodon#APP_CLIENT_ID,
	\	g:mastodon#APP_CLIENT_SECRET,
	\	l:account_name,
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
