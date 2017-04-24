let s:V    = vital#mastodon#new()
let s:Job  = s:V.import('System.Job')
let s:JSON = s:V.import('Web.JSON')


" Open home timeline buffer
function! mastodon#home#show_hometimeline(instance_domain, access_token) abort
	let l:instance_url = 'https://' . a:instance_domain
	let l:request_url  = l:instance_url . '/api/v1/timelines/home?access_token=' . a:access_token

	" Show home timeline
	let l:job_struct = mastodon#struct#new_job()
	call s:Job.start(['curl', '--silent', l:request_url], {
	\	'on_stdout': {x, y, z -> l:job_struct.aggregate_stdout(x, y, z)},
	\	'on_exit': function('s:open_hometimeline_buffer', [l:job_struct]),
	\})
endfunction


" --- Script local --- "

function! s:open_hometimeline_buffer(job_struct, _, __, ___) abort
	let l:toots        = s:JSON.decode(a:job_struct.stdout_result)
	let l:format_toots = []
	for l:toot in l:toots
		let l:account_username     = l:toot.account.username
		let l:account_display_name = l:toot.account.display_name
		let l:toot_detail = mastodon#func#render_html(l:toot.content)
		let l:format_toot = printf("%s(%s)\n%s", l:account_username, l:account_display_name, l:toot_detail)
		call insert(l:format_toots, l:format_toot)
	endfor

	let l:hometimeline = "- - - - -\n" . join(l:format_toots, "- - - - -\n")
	new | setl noreadonly modifiable
	put=l:hometimeline
	setl filetype=mastodon_home buftype=nofile nomodifiable

	normal! gg
endfunction
