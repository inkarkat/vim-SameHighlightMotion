" HlgroupMotion.vim: Motions to text highlighted with a particular group.
"
" DEPENDENCIES:
"   - CountJump.vim autoload script, version 1.80 or higher
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	18-Sep-2012	Handle highlight groups at the beginning and end
"				of the buffer; in those cases, the wrap-around
"				ends the syntax area, and for backward motion,
"				we must only search for the beginning of the
"				syntax area without wrapping.
"				FIX: Wrong long jump when directly before the
"				syntax area; must first do a check before moving
"				on.
"	002	18-Sep-2012	Support wrapped search through
"				HlgroupMotion#JumpWithWrapMessage() overload.
"	001	18-Sep-2012	file creation

function! HlgroupMotion#SearchFirstHlgroup( hlgroupPattern, flags )
    let l:isBackward = (a:flags =~# 'b')
    let l:flags = a:flags
    let l:originalPosition = getpos('.')[1:2]
    let l:goodPosition = []
    let l:matchPosition = l:originalPosition
    let l:hasLeft = 0

    while 1
	if l:matchPosition == [0, 0]
	    " We've arrived at the buffer's border.
	    if l:isBackward && ! empty(l:goodPosition)
		" For a backward search that already found the same-highlighted
		" area, this means we're done.
		call setpos('.', [0] + l:goodPosition + [0])
		return l:goodPosition
	    else
		" Otherwise, we've failed.
		call setpos('.', [0] + l:originalPosition + [0])
		return l:matchPosition
	    endif
	endif

	let l:currentHlgroupName = synIDattr(synIDtrans(synID(l:matchPosition[0], l:matchPosition[1], 1)), 'name')
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
		if l:isBackward
		    " For a backward search, go on (without wrapping now!) until
		    " we've reached the start of the same-highlighted area.
		    let l:goodPosition = l:matchPosition
		    let l:flags = substitute(l:flags, '[wW]', '', 'g') . 'W'
		else
		    " For a forward search, we're done.
		    return l:matchPosition
		endif
	    endif

	    if l:isBackward && l:matchPosition == [1, 1]
		" This is no circular buffer; text at the buffer start is
		" separate from the end. Break up the syntax area to correctly
		" handle matches at both beginning and end of the buffer.
		let l:hasLeft = 1
	    endif
	else
	    " We've just left the same-highlighted area.
	    let l:hasLeft = 1

	    if l:isBackward && ! empty(l:goodPosition)
		" For a backward search that already found the same-highlighted
		" area, this means we're done.
		call setpos('.', [0] + l:goodPosition + [0])
		return l:goodPosition
	    endif

	    " Keep on searching for the next same-highlighted area.
	endif

	let l:matchPosition = searchpos('.', l:flags)
	if l:matchPosition == l:originalPosition
	    " We've wrapped around and arrived at the original position without a match.
	    return [0, 0]
	endif
    endwhile
endfunction
function! HlgroupMotion#JumpWithWrapMessage( count, hlgroupPattern, searchName, isBackward )
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
    return CountJump#CountJumpFuncWithWrapMessage(a:count, a:searchName, a:isBackward, function('HlgroupMotion#SearchFirstHlgroup'), a:hlgroupPattern, (a:isBackward ? 'b' : '') . (empty(a:searchName) ? 'W' : ''))
endfunction
function! HlgroupMotion#Jump( count, hlgroupPattern, isBackward )
    return HlgroupMotion#JumpWithWrapMessage(a:count, a:hlgroupPattern, '', a:isBackward)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
