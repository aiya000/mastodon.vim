"TODO: Write comments for functions

let s:V      = vital#mastodon#new()
let s:Option = s:V.import('Data.Optional')

function! mastodon#add_account(...) abort
	call mastodon#account#create(a:000)
endfunction

function! mastodon#open_home(...) abort
	let l:mastodon_instance_name = exists('a:1')
	\                            ? a:1
	\                            : input('input instane name: ')
	let l:mastodon_account_name = exists('a:2')
	\                           ? a:2
	\                           : exists(printf('g:mastodon_instances["%s"].default_account', l:mastodon_instance_name))
	\                             ? g:mastodon_instances[l:mastodon_instance_name].default_account
	\                             : input('input account name: ')

	" Request authentication and get access_token for this app
	let l:maybe_account = mastodon#account#auth_default_account(l:mastodon_instance_name, l:mastodon_account_name)
	if s:Option.empty(l:maybe_account)
		redraw
		echohl Error
		echomsg 'account authentication is failed'
		echohl None
		return
	endif

	let l:account = s:Option.get(l:maybe_account)
	call mastodon#home#show_hometimeline(l:mastodon_instance_name, l:account.access_token)
endfunction
