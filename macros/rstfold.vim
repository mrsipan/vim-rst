" Vim fold functions for reStructuredText files
" Language: reStructuredText
" Maintainer:   Zvezdan Petkovic <zpetkovic@acm.org>
" Last Change:  $Date$
" Version:  $Id$

if exists("loaded_rstfold")
    finish
endif
let loaded_rstfold = 1

let s:save_cpo = &cpo
set cpo&vim

map <silent> <unique> <LocalLeader>r    :call <SID>FoldReSTExpr()<CR>

function ReSTFoldLevel(ln)
    let current_line = getline(a:ln)
    let next_line = getline(a:ln + 1)
    if current_line =~ '^[^.]*\w\+' &&
    \ next_line =~ '^\([^[:alnum:][:space:][:cntrl:]]\)\1\+\s*$'
        " titles with underlines and possibly overlines
        let c = strpart(next_line, 0, 1)
        if getline(a:ln - 1) == next_line
            " underline/overline title
            let c = c . c
            if empty(b:rst_heading_level)
                let b:rst_heading_level[c] = b:rst_current_level
            endif
        endif
        if !has_key(b:rst_heading_level, c)
            let b:rst_heading_level[c] = b:rst_current_level + 1
        endif
        let b:rst_current_level = b:rst_heading_level[c]
        return '>' . b:rst_current_level
    elseif current_line =~ '^\S\+' && current_line =~ '\w\+'
        if next_line =~ '^\s\+\S\+' ||
        \ (next_line =~ '^\s*$' && getline(a:ln + 2) =~ '^\s\+\S\+')
            " line followed by an indented block
            return '>' . string(b:rst_current_level + 1)
        else
            return b:rst_current_level
        endif
    elseif current_line =~ '^\s*=\+\%(\s\+=\+\)\+' && next_line =~ '^\s*$'
        " simple table bottom
        return b:rst_current_level
    else    " everything else folded at current level
        return '='
    endif
endfunction

function s:FoldReSTExpr()
    let b:rst_heading_level = {}
    let b:rst_current_level = 0
    setlocal foldexpr=ReSTFoldLevel(v:lnum)
    setlocal foldmethod=expr
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
