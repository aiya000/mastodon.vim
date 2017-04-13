"function! mastodon#add_account() abort
"	let l:instance_name    = input('instance name(ex: mastodon.cloud, mastodon.jp): ')
"	let l:account_name     = input('account name: ')
"	let l:account_password = input('account password: ')
"	" Serialize to file
"endfunction

function! mastodon#open_home(mastodon_instance_name) abort
	let l:url = mastodon#func#stateful#get_instance_url(a:mastodon_instance_name)
endfunction
