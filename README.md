# Cross Commit

Github action that allows synchronizing parts of repositories. It runs rsync 
between source folder in current repository to destination repository and 
destination folder and creates a commit in destination repository. Typical
usage is for synchronizing to GitOps state repositories from source code.

# Usage

See [action.yml](action.yml)

Example:

```yaml
steps:
- name: Commit to state repository
  uses: drud/action-cross-commit@master
  with:
    source-folder: config
    destination-repository: https://<user>:${{ secrets.user_token }}@github.com/org/dest-repo
    destination-folder: .
    destination-branch: alpha
    git-user: "Git User"
    git-user-email: git-user@email.com
    git-commit-message: "Custom commit message (optional)"
    excludes: README.md:.git:path/deeper/in/the/repo
```

The example above will trigger `rsync` that will synchronize the files in 
`./config` to repository `github.com/org/dest-repo` root using user credentials
(can be stored as Github secrets) and create commit on `alpha` branch. The 
`rsync` will exclude `/.git`, `/README.md` and `/path/deeper/in/the/repo` from 
both repositories during the synchronization.

# License

This project is licensed under Apache 2.0 license. Read the [LICENSE](LICENSE) 
file in the top distribution directory, for the full license text.
