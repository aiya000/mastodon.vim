"TODO: Write comments for functions

let s:V    = vital#mastodon#new()
let s:Job  = s:V.import('System.Job')
let s:JSON = s:V.import('Web.JSON')

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

	"TODO: Split logging in and fetch home timeline
	"try
		"TODO: Improve a way of getting properties for happening of exceptions
		let l:instance_url = mastodon#stateful#get_instance_url(a:mastodon_instance_name)
		"TODO: If default_account is not set
		let l:account_name = g:mastodon_instances[a:mastodon_instance_name].default_account
		"TODO: Use serialized file (implement the arround of mastodon#add_account)
		let l:account_password = input('password for ' . l:account_name . ': ')


		" Request authentication and get access_token for this app
		let l:access_token = mastodon#auth(l:instance_url, l:account_name, l:account_password).access_token
		let l:request_url  = l:instance_url . '/api/v1/timelines/home' . '?access_token=' . l:access_token

		" Show home timeline
		let l:job_struct = mastodon#struct#new_job()
		"TODO: Remove dirty closure when neovim supported closure and lambda (job safety cannot be saved if this closure is exist)
		let s:job_struct = l:job_struct
		function! s:refer_to_job_struct_aggregate_stdout(x, y, z) abort
			call s:job_struct.aggregate_stdout(a:x, a:y, a:x)
		endfunction
		function! s:show_hometimeline_closure(x, y, z) abort
			call mastodon#show_hometimeline(s:job_struct, a:x, a:y, a:z)
		endfunction
		call s:Job.start('curl ' . l:request_url, {
		\	'on_stdout': function('s:refer_to_job_struct_aggregate_stdout'),
		\	'on_exit': function('s:show_hometimeline_closure'),
		\})
	"catch
	"	"TODO: Use a way other than 'try-catch'
	"	echohl Error
	"	echomsg v:exception
	"	echomsg 'The error is occured (you may have not configured g:mastodon_instances)'
	"	echohl None
	"endtry
endfunction


function! mastodon#auth(instance_url, account_name, account_password) abort
	"TODO: Use my cilent_id and client_secret
	let l:app_client_id     = '9766a3780217ee179c18dfb9aa234566ff3dfb3dd495f0d3669acfadd9a696d1'
	let l:app_client_secret = 'b38cebc9235edb15db12320866c4258606f0172ce5aafa6768f4fb0a4973bf61'

	let l:parameters = printf(
	\	'client_id=%s&client_secret=%s&grant_type=password&username=%s&password=%s',
	\	l:app_client_id,
	\	l:app_client_secret,
	\	a:account_name,
	\	a:account_password
	\)
	let l:request_url = a:instance_url . '/oauth/token?' . l:parameters

	"TODO: I may can use vital's system()
	let l:result = system(printf('curl -X POST --silent "%s"', l:request_url))
	return s:JSON.decode(l:result)

	"TODO: Throw exception if s:JSON.decode(l:result) hasn't access_token property
endfunction

function! mastodon#show_hometimeline(job_struct, _, __, ___) abort
	echo a:job_struct.stdout_result
endfunction
