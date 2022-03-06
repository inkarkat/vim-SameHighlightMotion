" SameHighlightMotion.vim: Motions to text highlighted with a particular group.
"
" DEPENDENCIES:
"   - CountJump.vim plugin
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_SameHighlightMotion') || (v:version < 700)
    finish
endif
let g:loaded_SameHighlightMotion = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:SameHighlightMotion_BeginMapping')
    let g:SameHighlightMotion_BeginMapping = 'h'
endif
if ! exists('g:SameHighlightMotion_EndMapping')
    let g:SameHighlightMotion_EndMapping = 'H'
endif
if ! exists('g:SameHighlightMotion_TextObjectMapping')
    let g:SameHighlightMotion_TextObjectMapping = 'h'
endif



"- mappings --------------------------------------------------------------------

call CountJump#Motion#MakeBracketMotionWithJumpFunctions('', g:SameHighlightMotion_BeginMapping, g:SameHighlightMotion_EndMapping,
\   function('SameHighlightMotion#BeginForward'),
\   function('SameHighlightMotion#BeginBackward'),
\   function('SameHighlightMotion#EndForward'),
\   function('SameHighlightMotion#EndBackward'),
\   1)
call CountJump#TextObject#MakeWithJumpFunctions('', g:SameHighlightMotion_TextObjectMapping, 'aI', 'v',
\   function('SameHighlightMotion#TextObjectBegin'),
\   function('SameHighlightMotion#TextObjectEnd')
\)

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
