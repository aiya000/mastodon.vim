function! mastodon#func#stateful#get_instance_url(mastodon_instance_name) abort
	return 'https://' . g:mastodon_instances[a:mastodon_instance_name].domain
endfunction
