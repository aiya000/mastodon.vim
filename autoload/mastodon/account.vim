let s:V      = vital#mastodon#new()
let s:Dict   = s:V.import('Data.Dict')
let s:JSON   = s:V.import('Web.JSON')
let s:List   = s:V.import('Data.List')
let s:Option = s:V.import('Data.Optional')


"FIXME: Don't use plain text for password
"TODO: If user chose account is already exists
function! mastodon#account#create(args) abort
	" vvv g:mastodon#CONFIG_FILE_PATH structure example vvv
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

	"TODO: xdg dir
	"TODO: If decoding is failed
	let l:old_instances = filereadable(g:mastodon#CONFIG_FILE_PATH)
	\                   ? s:JSON.decode(readfile(g:mastodon#CONFIG_FILE_PATH))
	\                   : {}
	if !has_key(l:old_instances, l:instance_domain)
		" Create an item
		let l:old_instances[l:instance_domain] = [l:account]
		let l:new_instances = l:old_instances
	else
		let l:new_instances = insert(l:old_instances[l:instance_domain], l:account)
	endif
	call writefile([s:JSON.encode(l:new_instances)], g:mastodon#CONFIG_FILE_PATH)

	redraw
	echomsg l:account_name . ' is added ! (' . l:instance_domain . ')'
endfunction


function! mastodon#account#may_read_accounts() abort
	"TODO: If decode is failed
	if filereadable(g:mastodon#CONFIG_FILE_PATH)
		return s:Option.some(s:JSON.decode(g:mastodon#CONFIG_FILE_PATH))
	else
		return s:Option.none()
	endif
endfunction


"TODO: Use serialized file (implement the arround of mastodon#add_account)
function! mastodon#account#auth_default_account(acount) abort
	let l:instance_url     = mastodon#func#get_instance_url(a:account.mastodon_instance_name)
	let l:account_password = inputsecret('input password for ' . a:account.mastodon_account_name . ': ')

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
