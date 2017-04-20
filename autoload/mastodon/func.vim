function! mastodon#func#render_html(content) abort
	let l:tempname = tempname() . '.html'
	call writefile([a:content], l:tempname)
	return system('w3m -dump ' . l:tempname . ' 2> /dev/null')
endfunction
