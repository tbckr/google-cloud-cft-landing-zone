# Sync this fork from upstream

## Set upstream repo (once)

https://docs.github.com/de/pull-requests/collaborating-with-pull-requests/working-with-forks/configuring-a-remote-repository-for-a-fork

```shell
git remote add upstream https://github.com/terraform-google-modules/terraform-example-foundation.git
```

## Update fork

https://docs.github.com/de/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork#syncing-a-fork-branch-from-the-command-line

```shell
git fetch upstream
git checkout main
git rebase upstream/master
git rebase --continue # only necessary, if merge conflicts occur
```
