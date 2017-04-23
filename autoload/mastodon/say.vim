let s:V       = vital#mastodon#new()
let s:List    = s:V.import('Data.List')
let s:Option  = s:V.import('Data.Optional')
let s:Message = s:V.import('Vim.Message')


function! mastodon#say#open_buffer() abort
	"NOTE: Can I set bufname by the way of other than :file ?
	botright 10new | setl filetype=mastodon-say | file mastodon-say
	setl noreadonly modifiable buftype=nofile
	"TODO: Add g:mastodon_no_default_keymaps
	call s:define_default_keymaps()
	normal! i
endfunction


function! mastodon#say#execute() abort
	let l:maybe_mastodon_say_bufnr = s:find_mastdon_say_bufnr_in_currenet_tab()
	if s:Option.empty(l:maybe_mastodon_say_bufnr)
		redraw | call s:Message.error('Error: mastodon-say buffer is not found !')
		return
	endif
	"TODO: Implement to view of 500 characters limit
	let l:maston_say_bufnr = s:Option.get(l:maybe_mastodon_say_bufnr)
	let l:toot_detail      = s:with_buffer(l:maston_say_bufnr, {-> join(getline(1, '$'), "\n")})
	VimConsoleLog l:toot_detail
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
