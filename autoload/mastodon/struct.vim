" Create new instance.
" This instance is aggregated job's results.
"
" Example:
" let l:job_struct = mastodon#struct#new_job()
" call s:Job.start(printf('curl -X POST "%s"', foo), {
" \	'on_stdout': function({x, y, z -> l:job_struct.aggregate_stdout(x, y, z)}),
" \})
function! mastodon#struct#new_job() abort
	let l:CLASS = {
	\	'stdout_result': ''
	\}

	function! l:CLASS.aggregate_stdout(_, data, __) abort dict
		let self.stdout_result .= a:data[0]
	endfunction

	return deepcopy(l:CLASS)
endfunction
