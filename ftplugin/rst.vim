" Vim filetype plugin file local extensions
" Language: reStructuredText
" Maintainer:   Zvezdan Petkovic <zpetkovic@acm.org>    
" Last Change:  $Date$
" Version:  $Id$

if exists("b:did_ftplugin")
    finish
endif
" The global plugin will do this
" let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

iabbrev <buffer> xr ..<Space><Bar>X<Bar><Space>replace::<Space><Esc>5b

if !hasmapto('<Plug>ReSTEnclose')
    map <buffer> <unique> <LocalLeader>[ <Plug>ReSTEnclose
endif
noremap <buffer> <script> <Plug>ReSTEnclose <SID>Enclose

" Can't make it local to the buffer. Comment out if it bothers you!
noremenu <script> &Plugin.&ReST.&Enclose<Tab>\\[ <SID>Enclose

noremap <silent> <buffer> <SID>Enclose :call <SID>Enclose('')<CR>
vnoremap <silent> <buffer> <SID>Enclose :call <SID>Enclose('v')<CR>

if !hasmapto('<Plug>ReSTCommentOut')
    map <buffer> <unique> <LocalLeader>- <Plug>ReSTCommentOut
    map <buffer> <unique> <LocalLeader>+ <Plug>ReSTUncomment
    map <buffer> <unique> <LocalLeader>= <Plug>ReSTUncomment
endif
noremap <buffer> <script> <Plug>ReSTCommentOut <SID>CommentOut
noremap <buffer> <script> <Plug>ReSTUncomment <SID>Uncomment

" Can't make it local to the buffer. Comment out if that bothers you!
noremenu <script> &Plugin.&ReST.&Comment\ Out<Tab>\\- <SID>CommentOut
noremenu <script> &Plugin.&ReST.&Uncomment<Tab>\\+ <SID>Uncomment

noremap <silent> <buffer> <SID>CommentOut :call <SID>CommentOut()<CR>
noremap <silent> <buffer> <SID>Uncomment :call <SID>Uncomment()<CR>

if !exists("*s:Enclose")
    function s:Enclose(mode) range
        let markup = input("Markup to enclose in [`]? ")
        if markup == ""
            let markup = "`"
        endif
        if a:mode == "v"
            execute "normal `>a".markup."\<Esc>`<i".markup."\<Esc>"
        else
            execute "normal diwi".markup."\<Esc>pa".markup."\<Esc>"
        endif
    endfunction
endif

" The range in Enclose is for visual mode selections only.
" Therefore, no <line1>,<line2> is passed to the call.
if !exists(":Enclose")
    command -buffer -range -nargs=1 Enclose :call s:Enclose(<q-args>)
endif

if !exists("*s:CommentOut")
    function s:CommentOut() range
        execute a:firstline . "," . a:lastline . 's!^\(.\+\)$!.. \1!'
    endfunction
endif

if !exists(":CommentOut")
    command -buffer -range CommentOut :<line1>,<line2>call s:CommentOut()
endif

if !exists("*s:Uncomment")
    function s:Uncomment() range
        execute a:firstline . "," . a:lastline . 's!.. \(.*\)!\1!'
    endfunction
endif

if !exists(":Uncomment")
    command -buffer -range Uncomment :<line1>,<line2>call s:Uncomment()
endif

" Folding for reST
runtime macros/rstfold.vim

let &cpo = s:save_cpo
unlet s:save_cpo
