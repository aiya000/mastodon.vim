"TODO: Write comments for functions

let s:V       = vital#mastodon#new()
let s:List    = s:V.import('Data.List')
let s:Option  = s:V.import('Data.Optional')
let s:Message = s:V.import('Vim.Message')


function! mastodon#add_account(...) abort
	call mastodon#account#create(a:000)
endfunction


function! mastodon#open_home(...) abort
	" Read account information from serialized file (See mastodon#add_account())
	let l:maybe_instances = mastodon#account#may_read_instances()
	if s:Option.empty(l:maybe_instances)
		redraw
		call s:Message.error('The config file reading (' . g:mastodon#CONFIG_FILE_PATH . ') is failed.')
		call s:Message.error('Do you executed :MastodonAddAccount ?')
		return
	endif
	let l:instances = s:Option.get(l:maybe_instances)

	" Confirm target account for logging in
	let l:chosen_single_account = s:input_instance_account_choice(a:000)
	" (?) l:chosen_single_account.instance_domain ∈ l:instances.map({x -> x.instance_domain})
	let l:instance = s:List.find(l:instances, v:null, printf('v:val.instance_domain ==# "%s"', l:chosen_single_account.instance_domain))
	if l:instance is v:null
		redraw | call s:Message.error(l:chosen_single_account.instance_domain . ' cannot be found in ' . g:mastodon#CONFIG_FILE_PATH)
		return
	endif

	let l:account = s:List.find(l:instance.account, v:null, printf('v:val.name ==# "%s"', l:chosen_single_account.account_name))
	if l:account is v:null
		redraw | call s:Message.error(l:chosen_account.account.name . ' of ' l:chosen_single_account.instance_domain . ' cannot be found in ' . g:mastodon#CONFIG_FILE_PATH)
		return
	endif
	let l:determined_single_account = {
	\	'instance_domain': l:chosen_single_account.instance_domain,
	\	'account_name': l:chosen_single_account.account_name,
	\	'account_password': l:account.password,
	\}
	" Don't putting off to kill (for code ability)
	unlet l:account l:instance l:chosen_single_account l:instances l:maybe_instances

	" Request access token for this app
	let l:maybe_auth_result = mastodon#account#auth_default_account(l:determined_single_account)
	if s:Option.empty(l:maybe_auth_result)
		redraw | call s:Message.error('Sorry, your account authentication is failed')
		return
	endif
	let l:auth_result = s:Option.get(l:maybe_auth_result)

	" Send results
	call mastodon#home#show_hometimeline(l:determined_single_account.instance_domain, l:auth_result.access_token)
endfunction


function! mastodon#open_say_buffer() abort
	call mastodon#say#open_buffer()
endfunction


" --- Scritp local --- "

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
