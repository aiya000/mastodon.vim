"TODO: Write comments for functions

let s:V      = vital#mastodon#new()
let s:Option = s:V.import('Data.Optional')

"function! mastodon#add_account() abort
"	let l:instance_name    = input('instance name(ex: mastodon.cloud, mastodon.jp): ')
"	let l:account_name     = input('account name: ')
"	let l:account_password = input('account password: ')
"	" Serialize to file
"endfunction

function! mastodon#open_home(mastodon_instance_name) abort
	if empty(a:mastodon_instance_name)
		echohl Error
		echo 'Please specify instance name'
		echohl None
		return
	endif

	" Request authentication and get access_token for this app
	let l:maybe_account = mastodon#account#auth_default_account(a:mastodon_instance_name)
	if s:Option.empty(l:maybe_account)
		redraw
		echohl Error
		echomsg 'account authentication is failed'
		echohl None
		return
	endif

	let l:account = s:Option.get(l:maybe_account)
	call mastodon#home#show_hometimeline(a:mastodon_instance_name, l:account.access_token)	
endfunction
