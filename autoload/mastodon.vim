"TODO: Write comments for functions

let s:V      = vital#mastodon#new()
let s:List   = s:V.import('Data.List')
let s:Option = s:V.import('Data.Optional')


function! mastodon#add_account(...) abort
	call mastodon#account#create(a:000)
endfunction


function! mastodon#open_home(...) abort
	" Read account information from serialized file (See mastodon#add_account())
	let l:maybe_accounts = mastodon#account#may_read_accounts()
	if s:Option.empty(l:maybe_accounts)
		echohl Error
		echo 'The config file reading (' . g:mastodon#CONFIG_FILE_PATH . ') is failed.'
		echo 'Do you executed :MastodonAddAccount ?'
		echohl None
		return
	endif
	let l:accounts = s:Option.get(l:maybe_accounts)

	" Confirm target account for logging in
	let l:chosen_account         = s:input_account_choice(a:000)
	let l:chosen_instance_domain = keys(l:chosen_account)[0]
	VimConsoleLog l:accounts
	" l:chosen_account.keys ∈ l:chosen_instance_domain ?
	if !s:List.has(map(l:accounts, {x -> keys(x)}), l:chosen_instance_domain)
		echohl Error
		echo l:chosen_instance_domain . ' cannot be found in ' . g:mastodon#CONFIG_FILE_PATH
		echohl None
		return
	endif

	let l:maybe_account = s:Option.lookup(l:chosen_instance_domain, l:accounts)
	if !l:Option.empty(l:maybe_account)
		echohl Error
		echo l:chosen_account.name . ' of ' l:chosen_instance_domain . ' cannot be found in ' . g:mastodon#CONFIG_FILE_PATH
		echohl None
		return
	endif
	let l:account = s:Option.get(l:maybe_account)
	let l:account.password = l:chosen_account[l:chosen_instance_domain].password

	" Request access token for this app
	let l:maybe_auth_info = mastodon#account#auth_default_account(l:account)
	if s:Option.empty(l:maybe_auth_info)
		redraw
		echohl Error
		echomsg 'Sorry, your account authentication is failed'
		echohl None
		return
	endif

	" Send results
	call mastodon#home#show_hometimeline(l:chosen_instance_domain, l:account.access_token)
endfunction


" --- Scritp local --- "

function! s:input_account_choice(args) abort
	let l:instance_domain = exists('a:args[0]')
	\                     ? a:args[0]
	\                     : input('input instance domain(ex: mastodon.cloud, mastodon.jp): ')
	let l:account_name = exists('a:args[1]')
	\                  ? a:args[1]
	\                  : exists(printf('g:mastodon_instances["%s"].default_account', l:instance_domain))
	\                    ? g:mastodon_instances[l:instance_domain].default_account
	\                    : input('input account name for the domain(ex: aiya000@example.com): ')
	return {
	\	l:instance_domain: {
	\		'name': l:account_name,
	\		'password': v:null,
	\	}
	\}
endfunction
