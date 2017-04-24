let s:V      = vital#mastodon#new()
let s:Dict   = s:V.import('Data.Dict')
let s:JSON   = s:V.import('Web.JSON')
let s:List   = s:V.import('Data.List')
let s:Option = s:V.import('Data.Optional')
let s:URI    = s:V.import('Web.URI')


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


" This is composing mastodon#account#read() and mastodon#account#auth_single_account() .
" Return the pair of authorized account ('single account' structure) and authentication information.
function! mastodon#account#auth_default_account(args) abort
	let l:single_account = mastodon#account#read(a:args)
	return s:Option.map(mastodon#account#auth_single_account(l:single_account), {x -> [l:single_account, x]})
endfunction


" Read account information from the config file + (arguments or 'stdin')
" (Please see s:input_instance_account_choice() about 'stdin').
function! mastodon#account#read(args) abort
	" Read account information from serialized file (See mastodon#add_account())
	let l:maybe_instances = s:may_read_instances()
	if s:Option.empty(l:maybe_instances)
		throw 'The config file reading (' . g:mastodon#CONFIG_FILE_PATH . ") is failed.\n"
		\	. 'Do you executed :MastodonAddAccount ?'
	endif
	let l:instances = s:Option.get(l:maybe_instances)

	" Confirm target account for logging in
	let l:chosen_single_account = s:input_instance_account_choice(a:args)
	" (?) l:chosen_single_account.instance_domain ∈ l:instances.map({x -> x.instance_domain})
	let l:instance = s:List.find(l:instances, v:null, printf('v:val.instance_domain ==# "%s"', l:chosen_single_account.instance_domain))
	if l:instance is v:null
		throw l:chosen_single_account.instance_domain . ' cannot be found in ' . g:mastodon#CONFIG_FILE_PATH
	endif

	let l:account = s:List.find(l:instance.account, v:null, printf('v:val.name ==# "%s"', l:chosen_single_account.account_name))
	if l:account is v:null
		throw l:chosen_account.account.name . ' of ' l:chosen_single_account.instance_domain . ' cannot be found in ' . g:mastodon#CONFIG_FILE_PATH
	endif
	let l:determined_single_account = {
	\	'instance_domain': l:chosen_single_account.instance_domain,
	\	'account_name': l:chosen_single_account.account_name,
	\	'account_password': l:account.password,
	\}

	return l:determined_single_account
endfunction


" Authorize the account.
" This function takes 'single_account' structure as an argument.
function! mastodon#account#auth_single_account(single_account) abort
	let l:instance_url = 'https://' . a:single_account.instance_domain

	let l:parameters = printf(
	\	'client_id=%s&client_secret=%s&grant_type=password&username=%s&password=%s&scope=%s',
	\	s:URI.encode(g:mastodon#APP_CLIENT_ID),
	\	s:URI.encode(g:mastodon#APP_CLIENT_SECRET),
	\	s:URI.encode(a:single_account.account_name),
	\	s:URI.encode(a:single_account.account_password),
	\	s:URI.encode('read write follow'),
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


"TODO: If decode is failed
function! s:may_read_instances()
	return filereadable(g:mastodon#CONFIG_FILE_PATH)
	\        ? s:Option.some(s:read_json(g:mastodon#CONFIG_FILE_PATH))
	\        : s:Option.none()
endfunction


" Return 'single_account' structure
function! s:input_instance_account_choice(args) abort
	let l:instance_domain = exists('a:args[0]')
	\                     ? a:args[0]
	\                     : input('input instance domain(ex: mastodon.cloud, mastodon.jp): ')
	let l:account_name = exists('a:args[1]')
	\                  ? a:args[1]
	\                  : exists(printf('g:mastodon_instances["%s"].default_account', l:instance_domain))
	\                    ? g:mastodon_instances[l:instance_domain].default_account
	\                    : input('input account name for the domain(ex: aiya000@example.com): ')
	return {
	\	'instance_domain': l:instance_domain,
	\	'account_name': l:account_name,
	\	'account_password': v:null,
	\}
endfunction
