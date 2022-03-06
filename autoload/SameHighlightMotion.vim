" SameHighlightMotion.vim: Motions to text highlighted with a particular group.
"
" DEPENDENCIES:
"   - CountJump.vim plugin
"   - ingo-library.vim plugin
"
" Copyright: (C) 2012-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:GetHlgroupName( ... ) abort
    let [l:lnum, l:col] = (a:0 ? a:1 : [line('.'), col('.')])
    return synIDattr(synIDtrans(synID(l:lnum, l:col, 1)), 'name')
endfunction
function! s:IsUnhighlightedWhitespaceHere()
    if ! ingo#cursor#IsOnWhitespace()
	return 0
    endif

    let l:currentSyntaxId = synID(line('.'), col('.'), 1)
    if synIDtrans(l:currentSyntaxId) == 0
	" No effective syntax group here.
	return 1
    endif

    if ! ingo#syntaxitem#HasHighlighting(l:currentSyntaxId)
	" The syntax group has no highlighting defined.
	return 1
    endif

    return 0
endfunction

function! SameHighlightMotion#SearchFirstHlgroup( hlgroupPattern, flags, isInner )
    let l:isBackward = (a:flags =~# 'b')
    let l:originalPosition = getpos('.')[1:2]
    let l:matchPosition = []
    let l:hasLeft = 0

    try
	while l:matchPosition != l:originalPosition
	    let l:matchPosition = searchpos('.', a:flags, (a:isInner ? line('.') : 0))
	    if l:matchPosition == [0, 0]
		" We've arrived at the buffer's border.
		call setpos('.', [0] + l:originalPosition + [0])
		return l:matchPosition
	    endif

	    let l:currentHlgroupName = s:GetHlgroupName(l:matchPosition)
	    if l:currentHlgroupName =~# a:hlgroupPattern
		if ! l:isBackward && l:matchPosition == [1, 1] && l:matchPosition != l:originalPosition
		    " This is no circular buffer; text at the buffer start is
		    " separate from the end. Break up the syntax area to correctly
		    " handle matches at both beginning and end of the buffer.
		    let l:hasLeft = 1
		endif

		" We're still / again inside the same-highlighted area.
		if l:hasLeft
		    " We've found a place in the next syntax area with the same
		    " highlighting.
		    return l:matchPosition
		endif

		if l:isBackward && l:matchPosition == [1, 1]
		    " This is no circular buffer; text at the buffer start is
		    " separate from the end. Break up the syntax area to correctly
		    " handle matches at both beginning and end of the buffer.
		    let l:hasLeft = 1
		endif
	    elseif ! a:isInner && s:IsUnhighlightedWhitespaceHere()
		" Tentatively progress; the same syntax area may continue after the
		" plain whitespace. But if it doesn't, we do not include the
		" whitespace.
	    else
		" We've just left the same-highlighted area.
		let l:hasLeft = 1

		" Keep on searching for the next same-highlighted area.
	    endif
	endwhile

	" We've wrapped around and arrived at the original position without a match.
	return [0, 0]
    catch /^Vim\%((\a\+)\)\=:/
	call setpos('.', [0] + l:originalPosition + [0])
	throw ingo#msg#MsgFromVimException()   " Avoid E608: Cannot :throw exceptions with 'Vim' prefix.
    endtry
endfunction
function! SameHighlightMotion#SearchLastHlgroup( hlgroupPattern, flags, isInner )
    let l:flags = a:flags
    let l:originalPosition = getpos('.')[1:2]
    let l:goodPosition = [0, 0]
    let l:matchPosition = []

    try
	while l:matchPosition != l:originalPosition
	    let l:matchPosition = searchpos('.', l:flags, (a:isInner ? line('.') : 0))
	    if l:matchPosition == [0, 0]
		" We've arrived at the buffer's border.
		break
	    endif

	    let l:currentHlgroupName = s:GetHlgroupName(l:matchPosition)
	    if l:currentHlgroupName =~# a:hlgroupPattern
		if a:isInner && ingo#cursor#IsOnWhitespace()
		    " We don't include whitespace around the syntax area in the
		    " inner jump.
		    continue
		endif

		" We're still / again inside the same-highlighted area.
		let l:goodPosition = l:matchPosition
		" Go on (without wrapping now!) until we've reached the start of the
		" syntax area.
		let l:flags = substitute(l:flags, '[wW]', '', 'g') . 'W'
	    elseif ! a:isInner && s:IsUnhighlightedWhitespaceHere()
		" Tentatively progress; the same syntax area may continue after the
		" plain whitespace. But if it doesn't, we do not include the
		" whitespace.
	    elseif l:goodPosition != [0, 0]
		" We've just left the syntax area.
		break
	    endif
	    " Keep on searching for the next same-highlighted area, until we
	    " wrap around and arrive at the original position without a match.
	endwhile

	call setpos('.', [0] + (l:goodPosition == [0, 0] ? l:originalPosition : l:goodPosition) + [0])
	return l:goodPosition
    catch /^Vim\%((\a\+)\)\=:/
	call setpos('.', [0] + l:originalPosition + [0])
	throw ingo#msg#MsgFromVimException()   " Avoid E608: Cannot :throw exceptions with 'Vim' prefix.
    endtry
endfunction
function! SameHighlightMotion#Jump( count, SearchFunction, isBackward )
    let l:hlgroupPattern = '\V\^' . s:GetHlgroupName() . '\$'
    return CountJump#CountJumpFuncWithWrapMessage(a:count, 'same highlight search', a:isBackward, a:SearchFunction, l:hlgroupPattern, (a:isBackward ? 'b' : ''), 0)
endfunction

function! SameHighlightMotion#BeginForward( mode )
    call CountJump#JumpFunc(a:mode, function('SameHighlightMotion#Jump'), function('SameHighlightMotion#SearchFirstHlgroup'), 0)
endfunction
function! SameHighlightMotion#BeginBackward( mode )
    call CountJump#JumpFunc(a:mode, function('SameHighlightMotion#Jump'), function('SameHighlightMotion#SearchLastHlgroup'), 1)
endfunction
function! SameHighlightMotion#EndForward( mode )
    call CountJump#JumpFunc(a:mode, function('SameHighlightMotion#Jump'), function('SameHighlightMotion#SearchLastHlgroup'), 0)
endfunction
function! SameHighlightMotion#EndBackward( mode )
    call CountJump#JumpFunc(a:mode, function('SameHighlightMotion#Jump'), function('SameHighlightMotion#SearchFirstHlgroup'), 1)
endfunction

function! SameHighlightMotion#TextObjectBegin( count, isInner )
    let g:CountJump_TextObjectContext.hlgroupPattern = '\V\^' . s:GetHlgroupName() . '\$'

    " Move one character to the right, so that we do not jump to the previous
    " highlighted area when we're at the start of a syntax area. CountJump will
    " restore the original cursor position should there be no proper text
    " object.
    call search('.', 'W')

    return CountJump#CountJumpFunc(a:count, function('SameHighlightMotion#SearchLastHlgroup'), g:CountJump_TextObjectContext.hlgroupPattern, 'bW', a:isInner)
endfunction
function! SameHighlightMotion#TextObjectEnd( count, isInner )
    return CountJump#CountJumpFunc(a:count, function('SameHighlightMotion#SearchLastHlgroup'), g:CountJump_TextObjectContext.hlgroupPattern, 'W' , a:isInner)
endfunction


function! SameHighlightMotion#JumpToGroupWithWrapMessage( count, SearchFunction, hlgroupPattern, searchName, isBackward )
"******************************************************************************
"* PURPOSE:
"   Jump to the a:count'th next / previous location highlighted with a highlight
"   group whose name matches a:hlgroupPattern.
"* USAGE:
"   Use through CountJump#JumpFunc() to generate jump functions that can then be
"   passed to CountJump#Motion#MakeBracketMotionWithJumpFunctions() to
"   generate motion mappings.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Move cursor.
"* INPUTS:
"   a:count Number of occurrence to jump to.
"   a:SearchFunction    Funcref doing the actual search; takes the following
"                       arguments.
"   a:hlgroupPattern    Regular expression which the highlight group name must
"			match.
"   a:searchName    Object to be searched; used as the subject in the message
"		    when the search wraps: "a:searchName hit BOTTOM, continuing
"		    at TOP". When empty, no wrap message is issued.
"		    When this is empty, the jump becomes non-wrapping;
"		    otherwise, the 'wrapscan' setting applies.
"   a:isBackward    Flag whether the jump should be backward, not forward.
"* RETURN VALUES:
"   List with the line and column position, or [0, 0], like searchpos().
"******************************************************************************
    return CountJump#CountJumpFuncWithWrapMessage(a:count, a:searchName, a:isBackward, a:SearchFunction, a:hlgroupPattern, (a:isBackward ? 'b' : '') . (empty(a:searchName) ? 'W' : ''), 0)
endfunction
function! SameHighlightMotion#JumpToGroup( count, SearchFunction, hlgroupPattern, isBackward )
    return SameHighlightMotion#JumpWithWrapMessage(a:count, a:SearchFunction, a:hlgroupPattern, '', a:isBackward)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
