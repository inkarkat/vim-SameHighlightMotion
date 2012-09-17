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
"	001	18-Sep-2012	file creation

function! HlgroupMotion#SearchFirstHlgroup( hlgroupPattern, flags )
    let l:originalPosition = getpos('.')[1:2]
    let l:hasLeft = 0

    while 1
	let l:matchPosition = searchpos('.', a:flags.'W')
	if l:matchPosition == [0, 0]
	    " We've arrived at the buffer's border.
	    call setpos('.', [0] + l:originalPosition + [0])
	    return l:matchPosition
	endif

	let l:currentHlgroupName = synIDattr(synIDtrans(synID(l:matchPosition[0], l:matchPosition[1], 1)), 'name')
	if l:currentHlgroupName =~# a:hlgroupPattern
	    " We're still / again inside the same-highlighted area.
	    if l:hasLeft
		" We've found a place in the next syntax area with the same
		" highlighting.
		return l:matchPosition
	    endif
	else
	    " We've just left the same-highlighted area.
	    let l:hasLeft = 1
	    " Keep on searching for the next same-highlighted area.
	endif
    endwhile
endfunction
function! HlgroupMotion#Jump( count, hlgroupPattern, isBackward )
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
"   a:isBackward    Flag whether the jump should be backward, not forward.
"* RETURN VALUES:
"   List with the line and column position, or [0, 0], like searchpos().
"******************************************************************************
    return CountJump#CountJumpFunc(a:count, function('HlgroupMotion#SearchFirstHlgroup'), a:hlgroupPattern, (a:isBackward ? 'b' : ''))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
