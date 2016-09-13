has_app_changes = !git.modified_files.grep(/app/).empty?

if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

declared_trivial = github.pr_title.include?("#trivial") || github.pr_body.include?("#trivial") || !has_app_changes
if !git.modified_files.include?("CHANGELOG.md") && !declared_trivial
  fail "Please include a CHANGELOG entry to credit yourself! \nYou can find it at [CHANGELOG.md](https://github.com/CocoaPods/CocoaPods-app/blob/master/CHANGELOG.md)."

  pr = github.pr_json
  markdown <<-MARKDOWN
Here's an example of your CHANGELOG entry:

```
* #{pr.title}  
  [#{pr.user.login}](#{pr.user.html_url})
  [##{pr.number}](#{pr.html_url})
```
MARKDOWN
end
