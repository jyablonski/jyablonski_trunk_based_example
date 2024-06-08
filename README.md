# jyablonski Trunk Based Example

Version: 0.0.6

## Dev Deployment
Go to the Actions Tab on the Repo and click on the Development Environment Deployment [Workflow](https://github.com/jyablonski/jyablonski_trunk_based_example/actions/workflows/dev_environment.yaml) to trigger a Deploy to a Dev Environment.  

One of the 10 Dev Environments from `dev-1` through `dev-10` must be selected.  Check [here](google.com) to see what Dev Environments are available for use.

## "True" Trunk Based

Lots of people believe Trunk Based means merging commits directly into `main` and deploying to Production with no Pull Requests.  I have a lot of issues with that approach & mentality.

1. Where's the non-prod environment ?  Dev, Staging, QA ?
2. Where's the CI Pipeline getting ran for tests to run ?
   1. If It's ran after you've already deployed your code and the CI Pipeline fails, now `main` is in a bad state and you have to manually go revert commits to get it fixed again.
   2. Any dev pulling `main` in between this time while it's borked is fucked.
3. Where is the Code / Peer Review in this process ?
4. Where is the Code Approval Step in this process ?
5. Race conditions - What if Dev #1 pushed to `main` at 12:03 PM and Dev #2 pushed to `main` at 12:06 PM and their changes are incompatible with Dev #1 Changes?

## My Version of Trunk Based Development

1. `main` is a Protected Branch
2. Short Lived Feature branches are created that must be code reviewed & approved in order to be merged into `main`
3. CI Runs on every commit on a PR; you cannot merge the PR if CI doesn't pass
4. Deploys to `main` trigger a Deploy to a Staging Environment, not a Production Environment (otherwise when / where / how would your non-prod environment be getting deployed to & used?)
   1. If a dedicated non-prod environment is completely unnecessary or too expensive for your use case, then this step can deploy directly to the Production Environment
5. Deploys from `main` to Production happen manually either via Git Tags or Release Branches. This can happen at any cadence such as multiple times a week or just once a month.

## Trunk Based Workflow with Git Tags

1. Short Lived Branches are created for new Feature Work or Bug Fixes by branching off the existing version of `main`
2. Once work is feature-complete, PRs for Feature Branches are created to merge them into `main`
3. CI runs on those PRs
4. *Optional* - A Pipeline could run here either automatically or triggered manually to deploy the Feature Branch code onto a Dev Server for further QA testing.
   1. See [`.github/workflows/dev_deployment.yaml`](https://github.com/jyablonski/jyablonski_trunk_based_example/blob/main/.github/workflows/dev_environment.yaml)
5. Once tested, code reviewed, QA'd, and the PR is approved - the PR can be squash merged into `main`
6. Every PR Merge into `main` triggers a Deploy to a Staging Environment
7. When ready for a Production Deploy, push new Git Tags

``` sh
git tag v1.10.14
git push origin v1.10.14
```

Notes:

* Step 5 could be rebased onto `main` instead of Squash Merge.  But, fuck having 50+ dumbass commits for 1 feature deployment clogging up the commit history.
  * Testing was done on the entire PR branch at the moment of the latest commit; if you deploy a Feature branch with 50+ commits on it then that's the only state in which you'd want those commits in `main`.
  * In other words, when would you ever want to keep 49/50 of the commits but revert the #32 commit that was made or something?
  * If you need to rollback then it's all or nothing, always.  Revert the entire PR and the entire feature at once which is made much easier when it's 1 commit after the squash merge.
  * The Pull Request History still exists.
  * IMO if you're work is complex enough where you'd *ever* rollback half the commits after 1 PR Push then you need to break down your work into smaller tasks

* Step 6 could be replaced to just automatically deploy to the Production Deployment, but I don't know how or where you'd be maintain a Staging environment in that case.

The Downsides with this approach are when you're close to a Production Deploy, you have to stop Devs from commiting to `main` because maybe you tested everything on the Staging Environment for 3+ days and want to push to Production with that, and don't want a new PR to get merged which may not be compatible.  This is where the Release Branch option comes into play.


## Trunk Based Workflow with Release Branches

The Release Branch strategy involves more stable and controlled releases if your application requires it. This strategy follows the same Workflow as above, but instead of using Git Tags you use release branches to deploy to production.

When ready for a deploy to production, you branch off of `main` and create a Release Branch.  This could deploy to a final QA environment or something for final testing. This allows devs to continue working on and merging their work into `main` without being blocked by a pending release

## Rollbacks

``` sh
git log

git revert <bad_commit_hash>

git push origin main
```
