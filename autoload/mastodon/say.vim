let s:V       = vital#mastodon#new()
let s:JSON    = s:V.import('Web.JSON')
let s:Job     = s:V.import('System.Job')
let s:List    = s:V.import('Data.List')
let s:Message = s:V.import('Vim.Message')
let s:Option  = s:V.import('Data.Optional')
let s:URI     = s:V.import('Web.URI')


" Open the buffer of 'mastodon-say'.
" Apply default keymaps to its buffer
function! mastodon#say#open_buffer(instance_domain, account_name) abort
	"NOTE: Can I set bufname by the way of other than :file ?
	"TODO: Implement to view of 500 characters limit
	botright 10new | setl filetype=mastodon-say | file mastodon-say
	setl noreadonly modifiable buftype=nofile
	let b:mastodon_instance_domain = a:instance_domain
	let b:mastodon_account_name    = a:account_name

	"TODO: Add g:mastodon_no_default_keymaps
	call s:define_default_keymaps()
	startinsert
endfunction


" Send the detail of the buffer as toot !
function! mastodon#say#execute() abort
	let l:maybe_mastodon_say_bufnr = s:find_mastdon_say_bufnr_in_currenet_tab()
	if s:Option.empty(l:maybe_mastodon_say_bufnr)
		throw 'Error: mastodon-say buffer is not found !'
	endif
	let l:maston_say_bufnr = s:Option.get(l:maybe_mastodon_say_bufnr)

	let [l:toot_detail, l:instance_domain, l:account_name] =
	\   s:with_buffer(l:maston_say_bufnr, {-> [ join(getline(1, '$'), "\n"),
	\                                           b:mastodon_instance_domain,
	\                                           b:mastodon_account_name ]
	\   })
	call s:send_toot(l:instance_domain, l:account_name, l:toot_detail)

	execute 'bwipe' l:maston_say_bufnr
	quit
endfunction


" --- Script local --- "

function! s:define_default_keymaps() abort
	nmap <buffer> <C-m> <Plug>(mastodon-execute-say)
endfunction


" If it is found, return bufnr of mastodon-say buffer with Option.some().
" Otherwise, return Option.none()
function! s:find_mastdon_say_bufnr_in_currenet_tab() abort
	let l:maston_say_bufnr = s:List.find(tabpagebuflist(), v:null, 'bufname(v:val) ==# "mastodon-say"')
	return l:maston_say_bufnr is v:null
	\      ? s:Option.none()
	\      : s:Option.some(l:maston_say_bufnr)
endfunction


" Execute a:f in the buffer of a:bufnr, and return the result of a:f.
" a:f takes no argument.
" Without to change current window
function! s:with_buffer(bufnr, f) abort
	let l:current_bufnr = winbufnr('.')
	execute 'buffer' a:bufnr
	let l:result = a:f()
	execute 'buffer' l:current_bufnr
	return l:result
endfunction


" Send toot to instance !
function! s:send_toot(instance_domain, account_name, detail) abort
	let l:maybe_pair_of_auth = mastodon#account#auth_default_account([a:instance_domain, a:account_name])
	if s:Option.empty(l:maybe_pair_of_auth)
		throw 'Sorry, your account authentication is failed'
	endif
	let [l:single_account, l:auth_result] = s:Option.get(l:maybe_pair_of_auth)

	let l:request_url = 'https://' . a:instance_domain . printf('/api/v1/statuses?access_token=%s&status=%s',
	\	s:URI.encode(l:auth_result.access_token),
	\	s:URI.encode(a:detail),
	\)
	let l:job_struct = mastodon#struct#new_job()
	call s:Job.start(['curl', '-X', 'POST', l:request_url], {
	\	'on_stdout': {x, y, z -> l:job_struct.aggregate_stdout(x, y, z)},
	\	'on_exit': function('s:notify_toot_result', [l:job_struct]),
	\})
endfunction


" --- Script local --- "

" Show toot result
function! s:notify_toot_result(job_struct, _, __, ___) abort
	" Regard the result is succeed if stdout_result has 'id' and 'created_at' as key
	let l:result_response = s:JSON.decode(a:job_struct.stdout_result)
	if has_key(l:result_response, 'id') && has_key(l:result_response, 'created_at')
		echo 'mastodon.vim: The toot is send :)'
	else
		call s:Message.error(a:job_struct.stdout_result)
		call s:Message.error('mastodon.vim: Sorry, some problem maybe happend :(')
	endif
endfunction
