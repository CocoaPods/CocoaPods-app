has_app_changes = !modified_files.grep(/app/).empty?

if pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

declared_trivial = pr_title.include?("#trivial") || pr_body.include?("#trivial") || !has_app_changes
if !modified_files.include?("CHANGELOG.md") && !declared_trivial
  fail "Please include a CHANGELOG entry to credit yourself! \nYou can find it at [CHANGELOG.md](https://github.com/CocoaPods/CocoaPods-app/blob/master/CHANGELOG.md)."

  pr = env.request_source.pr_json
  markdown <<-MARKDOWN
Here's an example of your CHANGELOG entry:

```
* #{pr.title}
  [#{pr.author}](https://github.com/#{pr.author})
  [##{pr.number}](https://github.com/#{pr.base.repo.full_name}/pull/#{pr.number})
```
MARKDOWN
end
