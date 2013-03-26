" Vim syntax file
" Language: reStructuredText documentation format
" Maintainer:   Zvezdan Petkovic <zpetkovic@acm.org>
" Last Change:  $Date$
" Version:  $Id$
"
" Based on rst.vim from Vim 7.0 distribution
" by Nikolai Weibull <now@bitwi.se>

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn spell toplevel

" XXX: This list is incomplete!
"      OK.  I added rstCitationReference and rstStandaloneHyperlink.
"      Also, rstInterpretedText was corrected to
"      rstInterpretedTextOrHyperlinkReference.
"      Check if there's anything else to add.
syn cluster rstInline contains=rstEmphasis,rstStrongEmphasis,
      \ rstInterpretedTextOrHyperlinkReference,rstInlineLiteral,
      \ rstSubstitutionReference,rstInlineInternalTargets,
      \ rstFootnoteReference,rstCitationReference,
      \ rstHyperlinkReference,rstStandaloneHyperlink

" The literal block ends only when the indentation returns to the same level
" as the line it was indented from.  This is not the same as the quoted block
" below.
"
" The indentation is tricky, though.  We must take into account the bulleted,
" and enumerated lists when finding the indentation.  The solution would be to
" get the space before a list item as \z1, followed by the item counter or
" bullet match length and the space after it as \z2.  Then the end would be
" \z1, followed by a number of spaces equal to the length of the
" counter/bullet match, followed by the \z2 and non-space.
"
" Unfortunately, AFAIK, there's no way to find a length of a match with Vim
" regular expressions.  Thus we either must list all possible combinations of
" enumeration counters (impossible) or use some sort of trade-off.
" The trade-offs used here are:
"   - The enumeration counters are limited to double digits, which is probably
"     reasonable.
"   - The option lists are ignored assuming that they are short descriptions
"     of an option, rather then lines followed by a literal block.
"
" normal paragraph + literal block
syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\).*\)\@<=::\(\s*$\)\@='
      \ skip='^$' end='^\(\z1\s\+\)\@!'
      \ contains=@NoSpell,rstDoctestBlock
" bulleted list item + literal block
syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\)[-+*]\z(\s\+\).*\)\@<=::\(\s*$\)\@='
      \ skip='^$' end='^\(\z1 \z2\s\+\)\@!'
      \ contains=@NoSpell,rstDoctestBlock
" enumerated list item of the type "1.", "a)", "i.", or "#)" + literal block
syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\)[1-9A-Za-z#][.)]\z(\s\+\).*\)\@<=::\(\s*$\)\@='
      \ skip='^$' end='^\(\z1  \z2\s\+\)\@!'
      \ contains=@NoSpell,rstDoctestBlock
" enumerated list item of the type "10.", "14)", or "iv." + literal block
syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\)\%([1-9]\d\|[ivxlcdmIVXLCDM]\{2}\)[.)]\z(\s\+\).*\)\@<=::\(\s*$\)\@='
      \ skip='^$' end='^\(\z1   \z2\s\+\)\@!'
      \ contains=@NoSpell,rstDoctestBlock
" enumerated list item of the type "(1)" + literal block
syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\)([1-9A-Za-z#])\z(\s\+\).*\)\@<=::\(\s*$\)\@='
      \ skip='^$' end='^\(\z1   \z2\s\+\)\@!'
      \ contains=@NoSpell,rstDoctestBlock
" enumerated list item of the type "(14)" + literal block
syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\)(\%([1-9]\d\|[ivxlcdmIVXLCDM]\{2}\))\z(\s\+\).*\)\@<=::\(\s*$\)\@='
      \ skip='^$' end='^\(\z1    \z2\s\+\)\@!'
      \ contains=@NoSpell,rstDoctestBlock

syn region  rstQuotedLiteralBlock   matchgroup=rstDelimiter
      \ start="::\_s*\n\ze\z([!\"#$%&'()*+,-./:;<=>?@[\]^_`{|}~]\)"
      \ end='^\z1\@!' contains=@NoSpell

" Use python syntax in doctest blocks.
let python_highlight_all = 1
syntax include @Python syntax/python.vim
syntax region rstDoctestBlock
      \ start="^\s*>>>\s" end="^\s*$"
      \ contains=@Python,@NoSpell,rstDoctestValue
syntax region rstDoctestValue
      \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
      \ contained

syn region  rstTable                transparent start='^\n\s*+[-=+]\+' end='^$'
      \ contains=rstTableLines,@rstInline
syn match   rstTableLines           contained display '|\|+\%(=\+\|-\+\)\='

syn region  rstSimpleTable          transparent
      \ start='^\n\%(\s*\)\@>\%(\%(=\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(=\+\)\@>\%(\s*\)\@>\)\+\)\@>$'
      \ end='^$'
      \ contains=rstSimpleTableLines,@rstInline
syn match   rstSimpleTableLines     contained display
      \ '^\%(\s*\)\@>\%(\%(=\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(=\+\)\@>\%(\s*\)\@>\)\+\)\@>$'
syn match   rstSimpleTableLines     contained display
      \ '^\%(\s*\)\@>\%(\%(-\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(-\+\)\@>\%(\s*\)\@>\)\+\)\@>$'

syn cluster rstDirectives           contains=rstFootnote,rstCitation,
      \ rstHyperlinkTarget,rstExDirective

" XXX: This must be rewritten to cover the case when .. is indented.
syn match   rstExplicitMarkup       '\.\. \+' contained
      \ nextgroup=@rstDirectives,rstComment,rstSubstitutionDefinition
syn match   rstExplicitMarkup       '\.\.\n' contained
      \ nextgroup=rstCommentBlock

let s:ReferenceName = '[[:alnum:]]\+\%([_.-][[:alnum:]]\+\)*'

syn case ignore
syn keyword rstBibliographicField contained
      \ Abstract Address Author Authors Contact Copyright Date
      \ Dedication Organization Status Version
syn case match
syn match rstFieldList '^\s*:[^:]\+:\_s\@=' contains=rstBibliographicField

syn keyword     rstTodo             contained FIXME NOTE NOTES TODO XXX

syn match rstCommentBlock /^\s\+/ contained nextgroup=rstComment
execute 'syn region rstComment contained' .
      \ ' start=/\S/' .
      \ ' skip=/^$/' .
      \ ' end=/^\s\@!/ contains=rstTodo,@Spell'

execute 'syn region rstFootnote contained matchgroup=rstDirective' .
      \ ' start=+\[\%(\d\+\|#\%(' . s:ReferenceName . '\)\=\|\*\)\]\_s+' .
      \ ' skip=+^$+' .
      \ ' end=+^\s\@!+ contains=@rstInline,@Spell,rstDoctestBlock'

execute 'syn region rstCitation contained matchgroup=rstDirective' .
      \ ' start=+\[' . s:ReferenceName . '\]\_s+' .
      \ ' skip=+^$+' .
      \ ' end=+^\s\@!+ contains=@rstInline,@Spell'

syn region rstHyperlinkTarget contained matchgroup=rstDirective
      \ start='_\%(_\|[^:\\]*\%(\\.[^:\\]*\)*\):\_s' skip=+^$+ end=+^\s\@!+

syn region rstHyperlinkTarget contained matchgroup=rstDirective
      \ start='_`[^`\\]*\%(\\.[^`\\]*\)*`:\_s' skip=+^$+ end=+^\s\@!+

syn region rstHyperlinkTarget matchgroup=rstDirective
      \ start=+^\z(\s*\)__\_s+ skip=+^$+ end=+^\%(\z1\s\+\)\@!+

execute 'syn region rstExDirective contained matchgroup=rstDirective' .
      \ ' start=+' . s:ReferenceName . '::\_s+' .
      \ ' skip=+^$+' .
      \ ' end=+^\s\@!+ contains=@rstInline,@Spell'

" XXX: This is wrong because the substitution can have more than one word.
" execute 'syn match rstSubstitutionDefinition contained' .
"       \ ' /|' . s:ReferenceName . '|\_s\+/ nextgroup=@rstDirectives'
" The replacement below is the equivalent of docutils code.
execute 'syn match rstSubstitutionDefinition contained' .
      \ ' /|.\{-1,}\%([ \n\x00]\)\@!|\_s\+/ nextgroup=@rstDirectives'

function! s:DefineOneInlineMarkup(name, start, middle, end, char_left, char_right)
  execute 'syn region rst' . a:name .
        \ ' start=+' . a:char_left . '\zs' . a:start .
        \ '[^[:space:]' . a:char_right . a:start[strlen(a:start) - 1] . ']+' .
        \ a:middle .
        \ ' end=+\%(\S\)\@<=' . a:end . '\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)+' .
    \ ' contains=@Spell'
endfunction

function! s:DefineInlineMarkup(name, start, middle, end)
  let middle = a:middle != "" ?
        \ (' skip=+\\\\\|\\' . a:middle . '+') :
        \ ""

  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, "'", "'")
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '"', '"') 
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '(', ')') 
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '\[', '\]') 
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '{', '}') 
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '<', '>') 

  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '\%(^\|\s\|[/:]\)', '')

  " XXX: There's a missing . before a:end line and this whole expression
  " probably never matches.
  "execute 'syn match rst' . a:name .
  "      \ ' +\%(^\|\s\|[''"([{</:]\)\zs' . a:start .
  "      \ '[^[:space:]' . a:start[strlen(a:start) - 1] . ']'
  "      \ a:end . '\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)+'

  execute 'hi def link rst' . a:name . 'Delimiter' . ' rst' . a:name
endfunction

call s:DefineInlineMarkup('Emphasis', '\*', '\*', '\*')
call s:DefineInlineMarkup('StrongEmphasis', '\*\*', '\*', '\*\*')
call s:DefineInlineMarkup('InterpretedTextOrHyperlinkReference', '`', '`', '`_\{0,2}')
call s:DefineInlineMarkup('InlineLiteral', '``', "", '``')
call s:DefineInlineMarkup('SubstitutionReference', '|', '|', '|_\{0,2}')
call s:DefineInlineMarkup('InlineInternalTargets', '_`', '`', '`')

" TODO: Can’t remember why these two can’t be defined like the ones above.
execute 'syn match rstFootnoteReference contains=@NoSpell' .
      \ ' +\[\%(\d\+\|#\%(' . s:ReferenceName . '\)\=\|\*\)\]_+'

execute 'syn match rstCitationReference contains=@NoSpell' .
      \ ' +\[' . s:ReferenceName . '\]_+'

execute 'syn match rstHyperlinkReference' .
      \ ' /\<' . s:ReferenceName . '__\=\w\@!/'

syn match   rstStandaloneHyperlink  contains=@NoSpell
      \ "\<\%(\%(\%(https\=\|file\|ftp\|gopher\)://\|\%(mailto\|news\):\)[^[:space:]'\"<>]\+\|www[[:alnum:]_-]*\.[[:alnum:]_-]\+\.[^[:space:]'\"<>]\+\)[[:alnum:]/]"

" XXX: There's something truly messy about the above definitions of inline
" text elements which throws the match for the text role off.
" The role is matched, but the interpreted text after it isn't.
" This must be fixed to enable matching of colons surrounding the quotes.
syn match rstInterpretedTextRole /:\w[^:]*:\%(`\w\)\@=/ms=s+1,me=e-1
syn match rstInterpretedTextRole /\%(\w`\)\@<=:\w[^:]*:/ms=s+1,me=e-1

" Keep this first, otherwise it overrides rstSections!
syn match   rstTransition /^\s*\n[^[:alnum:][:space:][:cntrl:]]\{4,}\s*\n\s*$/

" The patterns containing newline must be anchored very carefully!
" This must be *after* the inline markup.
" Otherwise the inline markup match at the beginning of the section title
" takes over and the section would not match.
syn match   rstSections
      \ /^[^.]*\w\+.*\n[^[:alnum:][:space:][:cntrl:]]\{2,}\s*$/
      \ contains=@Spell
"      \ contains=@rstInline,@Spell
syn match   rstSections
      \ /^\([^[:alnum:][:space:][:cntrl:]]\{2,}\)\n[^.]*\w\+.*\n\1\s*$/
      \ contains=@Spell
"      \ contains=@rstInline,@Spell

syn region rstExplicitBlock
      \ start=+^\z(\s*\)\.\. + skip=+^$+ end=+^\%(\z1\s\+\)\@!+
      \ contains=rstExplicitMarkup

" XXX: The synchronization probably can be done better.
"syn sync minlines=50
syn sync fromstart
" Re-sync for section title underlines.
syn sync linebreaks=2

hi def link rstTodo                         Todo
hi def link rstComment                      Comment
hi def link rstSections                     Type
hi def link rstTransition                   Type
hi def link rstLiteralBlock                 String
hi def link rstQuotedLiteralBlock           String
hi def link rstDoctestBlock                 Special
hi def link rstDoctestValue                 Define
hi def link rstTableLines                   rstDelimiter
hi def link rstSimpleTableLines             rstTableLines
hi def link rstExplicitMarkup               rstDirective
hi def link rstDirective                    Keyword
hi def link rstFootnote                     String
hi def link rstCitation                     String
hi def link rstHyperlinkTarget              String
hi def link rstExDirective                  String
hi def link rstSubstitutionDefinition       rstDirective
hi def link rstDelimiter                    Delimiter
hi def link rstEmphasis                     Statement
"hi def      rstEmphasis    term=underline cterm=underline gui=italic
hi def link rstStrongEmphasis               Special
"hi def      rstStrongEmphasis  term=bold cterm=bold gui=bold
hi def link rstInterpretedTextOrHyperlinkReference  Identifier
hi def link rstInlineLiteral                String
hi def link rstSubstitutionReference        PreProc
hi def link rstInlineInternalTargets        Identifier
hi def link rstFootnoteReference            Identifier
hi def link rstCitationReference            Identifier
hi def link rstHyperLinkReference           Identifier
hi def link rstStandaloneHyperlink          Identifier
" XXX: Added recently.  Do we want them highlighted?
hi def link rstFieldList            Statement
hi def link rstBibliographicField       Statement
hi def link rstInterpretedTextRole      Special

let b:current_syntax = "rst"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
