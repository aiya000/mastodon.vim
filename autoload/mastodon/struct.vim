function! mastodon#struct#new_job() abort
	let l:CLASS = {
	\	'stdout_result': ''
	\}

	function! l:CLASS.aggregate_stdout(_, data, __) abort dict
		let self.stdout_result .= a:data[0]
	endfunction

	return deepcopy(l:CLASS)
endfunction
