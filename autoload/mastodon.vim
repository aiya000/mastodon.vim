"TODO: Write comments for functions

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
	let l:access_token = mastodon#account#auth_default_account(a:mastodon_instance_name).access_token
	call mastodon#home#show_hometimeline(a:mastodon_instance_name, l:access_token)
endfunction

