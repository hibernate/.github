# Contributing

Contributions from the community are essential in keeping Hibernate (and any Open Source
project really) strong and successful.  

## Legal

You should check the relevant license under which all contributions will be licensed for the specific project you are contributing to.

All contributions are subject to the [Developer Certificate of Origin (DCO)](https://developercertificate.org/).  

The DCO text is available verbatim in the [dco.txt](dco.txt) file.


## Guidelines

While we try to keep requirements for contributing to a minimum, there are a few guidelines 
we ask that you mind.

For code contributions, these guidelines include (**where applicable**):
* Respect the project code style.
* Have a corresponding JIRA [issue](https://hibernate.atlassian.net/) or Github issue and be sure to include the key for this issue in your commit messages.
* Have a set of appropriate tests.
  	
	When submitting bug reports, the tests should reproduce the initially reported bug and illustrate that your solution addresses the issue.
	For features/enhancements, the tests should demonstrate that the feature works as intended.  
    	In both cases, be sure to incorporate your tests into the project to protect against possible regressions.
* If applicable, documentation should be updated to reflect the introduced changes
* Make sure the code compiles and the tests pass

For documentation contributions, mainly to respect the project code style, especially in regard 
to the use of tabs - use the code style templates where available.  Ideally, these contributions would also have a corresponding JIRA/Github issue, although this is less necessary for documentation contributions.


## Getting Started

If you are just getting started with Git, GitHub, and/or contributing to Hibernate via
GitHub there are a few pre-requisite steps to follow:

* Make sure you have a [Hibernate JIRA account](https://hibernate.atlassian.net)
* Make sure you have a [GitHub account](https://github.com/signup/free)
* [Fork](https://help.github.com/articles/fork-a-repo) the relevant Hibernate repository.  As discussed in
the linked page, this also includes:
    * [set up your local git install](https://help.github.com/articles/set-up-git) 
    * clone your fork
* Instruct git to ignore certain commits when using `git blame`. From the directory of your local clone, run this: `git config blame.ignoreRevsFile .git-blame-ignore-revs`


## Create the working (topic) branch

Create a [topic branch](https://git-scm.com/book/en/Git-Branching-Branching-Workflows#Topic-Branches) 
on which you will work.  The convention is to incorporate the issue key in the name of this branch,
although this is more of a mnemonic strategy than a hard-and-fast rule - but doing so helps:
* Remember what each branch is for 
* Isolate the work from other contributions you may be working on

_If there is not already an issue covering the work you want to do, create one._
  
For example, assuming you want to work on ORM JIRA HHH-123, you would typically issue something like: `git checkout -b HHH-123 main`


## Code

Do your thing!


## Commit

* Make commits of logical units
* Be sure to start each commit message using the **JIRA/Github issue key**
* Make sure you have added the necessary tests for your changes
* Run _all_ the tests to ensure nothing else was accidentally broken

_Before committing, if you want to pull in the latest upstream changes (highly
appreciated btw), please use rebasing rather than merging.  Merging creates
"merge commits" that invariably muck up the project timeline._

## Submit

* Push your changes to the topic branch in your fork of the repository
* Initiate a [pull request](https://help.github.com/articles/creating-a-pull-request)
* Once your pull request has been submitted you can verify that the pull request has been properly linked to its corresponding issue.

It is important that this topic branch of your fork:

* Is isolated to just the work on this one issue, or multiple issues if they are
	related and also fixed/implemented by this work.  The main point is to not push
	commits for more than one PR to a single branch - GitHub PRs are linked to
	a branch rather than specific commits
* remain until the PR is closed.  Once the underlying branch is deleted the corresponding
	PR will be closed, if not already, and the changes will be lost
