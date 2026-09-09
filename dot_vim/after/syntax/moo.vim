" Give MOO constructs distinct colors while respecting the active colorscheme.
" This file is loaded after the MOO syntax definition, so it can also fill in
" groups that the syntax plugin intentionally leaves unstyled.

highlight link mooVariable               Identifier
highlight link mooIdentifier             Identifier
highlight link mooRegexp                 String
highlight link mooRegexpParentheses      Delimiter
highlight link mooPropRef                Identifier
highlight link mooVerbRef                Function
highlight link mooParentheses            Delimiter
highlight link mooBrackets               Delimiter
highlight link mooBraces                 Delimiter
highlight link mooQuestion               Conditional
highlight link mooCatch                  Exception
highlight link mooCommentSpecialChar     SpecialComment
highlight link mooRangeOperator          Operator
highlight link mooOrOperator             Operator
highlight link mooScattering             StorageClass
