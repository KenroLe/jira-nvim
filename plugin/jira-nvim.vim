" in plugin/whid.vim
if exists('g:loaded_whid') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults
" example config
lua require('jira-nvim').init({storypoint_customfield_id = "customfield_10016"})
" command to run our plugin
command! -nargs=* JiraGetIssueByText call v:lua.require'core'.get_issue_by_text(<f-args>)
let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_whid = 1
