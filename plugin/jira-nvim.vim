" in plugin/whid.vim
if exists('g:loaded_whid') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults
lua require('jira-nvim').init()
" command to run our plugin
command! JiraTest lua require('jira-nvim').test()
command! -nargs=1 JiraGetIssueByKey call v:lua.require'jira-nvim'.get_issue_by_key(<args>)
command! -nargs=* JiraGetIssueByText call v:lua.require'jira-nvim'.get_issue_by_text(<f-args>)
let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_whid = 1
