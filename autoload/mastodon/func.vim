function! mastodon#func#get_instance_url(mastodon_instance_name) abort
	return 'https://' . g:mastodon_instances[a:mastodon_instance_name].domain
endfunction

function! mastodon#func#render_html(content) abort
	let l:tempname = tempname() . '.html'
	call writefile([a:content], l:tempname)
	return system('w3m -dump ' . l:tempname . ' 2> /dev/null')
endfunction
