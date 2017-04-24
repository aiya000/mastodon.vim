let s:V       = vital#mastodon#new()
let s:List    = s:V.import('Data.List')
let s:Option  = s:V.import('Data.Optional')
let s:Message = s:V.import('Vim.Message')

"
" 'mastodon#' for main rootine.
" 'mastodon#' functions catches exceptions.
" 'mastodon#some#' functions throws exceptions.
" The commands and keymaps calls 'mastodon#' functions.
" The commands and keymaps doesn't call 'mastodon#some#' functions directly.
"


" Pass the arguments to mastodon#account#create()
function! mastodon#add_account(...) abort
	call mastodon#account#create(a:000)
endfunction


" Authorize an account of an instance.
" And show the buffer of mastodon home timeline
function! mastodon#open_home(...) abort
	try
		let l:maybe_pair_of_auth = mastodon#account#auth_default_account(a:000)
		if s:Option.empty(l:maybe_pair_of_auth)
			throw 'Sorry, your account authentication is failed'
		endif
	catch
		redraw | call s:Message.error(v:exception)
		return
	endtry
	let [l:single_account, l:auth_result] = s:Option.get(l:maybe_pair_of_auth)

	" Send results
	call mastodon#home#show_hometimeline(l:single_account.instance_domain, l:auth_result.access_token)
endfunction


" Call mastodon#say#open_buffer()
function! mastodon#open_say_buffer(...) abort
	if len(a:000) isnot 2
		redraw | call s:Message.error("mastodon#open_say_buffer() requires two arguments of 'instance name' and 'account name'")
		return
	endif
	call mastodon#say#open_buffer(a:1, a:2)
endfunction


function! mastodon#execute_say() abort
	call mastodon#say#execute()
endfunction
