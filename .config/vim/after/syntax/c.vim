" C++ loads C syntax too. Existing strings/comments and keywords retain priority.
syntax match masterCFunction /\<\h\w*\>\ze\s*(/ display
highlight default link masterCFunction Function
