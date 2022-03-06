SAME HIGHLIGHT MOTION
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

Vim offers many different powerful motions to position the cursor, but none
leverages the syntactic analysis of the built-in syntax highlighting.

This plugin provides mappings to jump to the borders and next [count]
occurrences of text highlighted in the same effective highlight group as under
the cursor. So you can use the easily discernible distinction of color and
style to navigate and select text. The plugin's functionality can also power
other plugins that provide motions to certain artifacts, like errors or TODO
items.

### SEE ALSO

- The SameSyntaxMotion.vim plugin ([vimscript #4338](http://www.vim.org/scripts/script.php?script_id=4338)) provides almost
  identical mappings but looks at the syntax ID. So it includes other
  contained sub-syntaxes (like escape sequences in a string), but stops at an
  adjacent different syntax that is highlighted the same way.

### RELATED WORKS

- The SyntaxMotion plugin ([vimscript #2965](http://www.vim.org/scripts/script.php?script_id=2965)) by Dominique Pellé provides very
  similar motions for normal and visual mode, but no operator-pending and text
  objects. It uses same color as the distinguishing property.

USAGE
------------------------------------------------------------------------------

    "Same highlighting" in the context of the mappings and text objects means that
    the same highlight group is used to highlight the text. Transparent syntax
    groups are ignored, highlight links are followed.
    Unhighlighted whitespace between identically highlighted items is skipped. So
    when there are multiple keywords in a row (FOO BAR BAZ), they are treated as
    one area, even though the whitespace between them is not covered by the
    highlighting.

    ]h                      Go to [count] next start of the same highlighting.
    ]H                      Go to [count] next end of the same highlighting.
    [h                      Go to [count] previous start of the same highlighting.
    [H                      Go to [count] previous end of the same highlighting.
                            The 'wrapscan' setting applies.

    ah                      "a highlighting" text object, select [count] same
                            highlighting areas.
    ih                      "inner highlighting" text object, select [count] same
                            highlighting areas within the same line. Whitespace
                            around the highlighting area is not included.
                            Unhighlighted whitespace delimits same syntax items
                            here, so this selects individual keywords.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-SameHighlightMotion
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim SameHighlightMotion*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.044 or
  higher.
- Requires the CountJump plugin ([vimscript #3130](http://www.vim.org/scripts/script.php?script_id=3130)), version 1.90 or higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

To change the default motion mappings, use:

    let g:SameHighlightMotion_BeginMapping = 'h'
    let g:SameHighlightMotion_EndMapping = 'H'

To also change the [ / ] prefix to something else, follow the instructions for
CountJump-remap-motions.

To change the default text object mappings, use:

    let g:SameHighlightMotion_TextObjectMapping = 'h'

To also change the a prefix to something else, follow the instructions for
CountJump-remap-text-objects.

LIMITATIONS
------------------------------------------------------------------------------

- Because the algorithm has to sequentially inspect every character's
  highlight groups, movement (especially when there's no additional match and
  the search continues to the buffer's border or wraps around) can be
  noticeably slow.

### CONTRIBUTING

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-SameHighlightMotion/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### GOAL
First published version.

##### 0.01    03-Mar-2022
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
