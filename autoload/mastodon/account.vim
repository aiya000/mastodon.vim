let s:V      = vital#mastodon#new()
let s:Dict   = s:V.import('Data.Dict')
let s:JSON   = s:V.import('Web.JSON')
let s:List   = s:V.import('Data.List')
let s:Option = s:V.import('Data.Optional')


"FIXME: Don't use plain text for password
"TODO: If user chose account is already exists
" Return 'instance' structure
function! mastodon#account#create(args) abort
	"TODO: Rename 'account' to 'accounts'
	" vvv 'instance' structure vvv
	" [                                        <-- instances
	"   { 'instance_domain': 'mastodon.cloud'  <-- the instance domain
	"   , 'account':
	"     [                                    <-- the account list of 'mastodon.cloud'
	"       { 'name': aiya000.develop@gmail'   <-- an account of 'mastodon.cloud'
	"       , 'password': 'gavriil_dropout'
	"       }
	"     ]
	"   }
	" ]

	"TODO: If decoding is failed
	let l:old_instances = filereadable(g:mastodon#CONFIG_FILE_PATH)
	\                   ? s:read_json(g:mastodon#CONFIG_FILE_PATH)
	\                   : []

	let l:instance_domain = exists('a:args[0]')
	\                     ? a:args[0]
	\                     : input('instance domain(ex: mastodon.cloud, mastodon.jp): ')
	let l:account_name = exists('a:args[1]')
	\                  ? a:args[1]
	\                  : input('account name for the domain(ex: aiya000@example.com): ')
	let l:account_password = inputsecret('account password: ')
	let l:account = {
	\	'name': l:account_name,
	\	'password': l:account_password,
	\}

	" Add new account to the file
	let l:instance_is_already_exists = s:List.find(l:old_instances, v:null, {x -> x.instance_domain == l:instance_domain}) isnot v:null
	if l:instance_is_already_exists
		" Append new account
		call insert(l:old_instances[l:instance_domain].account, l:account)
	else
		" Create an item
		call insert(l:old_instances, {
		\	'instance_domain': l:instance_domain,
		\	'account': [l:account],
		\})
	endif
	call writefile([s:JSON.encode(l:old_instances)], g:mastodon#CONFIG_FILE_PATH)

	redraw
	echomsg l:account_name . ' is added ! (' . l:instance_domain . ')'
endfunction


"TODO: If decode is failed
function! mastodon#account#may_read_instances()
	return filereadable(g:mastodon#CONFIG_FILE_PATH)
	\        ? s:Option.some(s:read_json(g:mastodon#CONFIG_FILE_PATH))
	\        : s:Option.none()
endfunction


"TODO: Use serialized file (implement the arround of mastodon#add_account)
" Take 'single_account' structure
function! mastodon#account#auth_default_account(single_account) abort
	let l:instance_url = 'https://' . a:single_account.instance_domain

	let l:parameters = printf(
	\	'client_id=%s&client_secret=%s&grant_type=password&username=%s&password=%s',
	\	g:mastodon#APP_CLIENT_ID,
	\	g:mastodon#APP_CLIENT_SECRET,
	\	a:single_account.account_name,
	\	a:single_account.account_password,
	\)
	let l:request_url = l:instance_url . '/oauth/token?' . l:parameters

	"TODO: I may can use vital's system()
	let l:auth_result = system(printf('curl -X POST --silent "%s"', l:request_url))
	try
		return s:Option.some(s:JSON.decode(l:auth_result))
	catch /E15/
		return s:Option.none()
	endtry
endfunction


" --- Script local --- "

let s:read_json = {x -> s:JSON.decode(join(readfile(x)))}
