let s:V    = vital#mastodon#new()
let s:Job  = s:V.import('System.Job')
let s:JSON = s:V.import('Web.JSON')

function! mastodon#home#show_hometimeline(mastodon_instance_name, access_token) abort
	let l:instance_url = mastodon#func#get_instance_url(a:mastodon_instance_name)
	let l:request_url  = l:instance_url . '/api/v1/timelines/home?access_token=' . a:access_token

	" Show home timeline
	let l:job_struct = mastodon#struct#new_job()
	call s:Job.start(printf('curl --silent "%s"', l:request_url), {
	\	'on_stdout': function({x, y, z -> l:job_struct.aggregate_stdout(x, y, z)}),
	\	'on_exit': function('s:open_result_buffer', [l:job_struct]),
	\})
endfunction


" --- Script local --- "

function! s:open_result_buffer(job_struct, _, __, ___) abort
	let l:toots = s:JSON.decode(a:job_struct.stdout_result)
	for l:toot in l:toots
		let l:account = l:toot.account
		let l:account_username     = l:account.username
		let l:account_display_name = l:account.display_name
		VimConsoleLog l:account_username
	endfor
endfunction
