---
title: "Lazy Synching"
authors: [ "Fritz Duchardt <fritz.duchardt.ext@gec.io>" ]
status: "draft"
approvers: [ ]
---

# Make vendir lazy: don't sync if the config has not changed

## Problem Statement
We have a rollout mechanism that heavily relies on vendir to pull in upstream sources from Helm Charts, OCI Images, and Git Repositories.
For all of the sources use fixed versions in vendir configs.
Yet, with the current vendir behavior, all the upstream sources have to be re-downloaded even if their versions didn't change.
This significantly slows down the process unnecessarily.

## Proposal
Add a new configuration option to instruct vendir to skip downloading upstream sources if the config was not changed after the last sync.
Users can activate this feature for all sources they deem to use stable versions.

### Goals and Non-goals

Goals:
- to provide a way to skip unnecessary downloads

Non-goals:
- to change the default vendir behavior

### Specification / Use Cases
The feature can be activated in the `vendir.yml` at the `contents` item level, e.g.:

```yaml
apiVersion: vendir.k14s.io/v1alpha1
kind: Config
directories:
- path: vendor
  contents:
  - path: custom-repo-custom-version
    lazy: true                       # the proposed option
    helmChart:
      name: contour
      version: "7.10.1"
      repository:
        url: https://charts.bitnami.com/bitnami
```

If `lazy` is enabled for a `contents` item, the source of the item is downloaded in the following cases:
- When the item's configuration section has changed.
  The logic applies to all types of sources.
  A few examples of such changes to the configuration above follow.
  Changing the helm chart version:
  ```diff
    contents:
    - path: custom-repo-custom-version
      lazy: true                       # the proposed option
      helmChart:
        name: contour
  -     version: "7.10.1"
  +     version: "7.10.2"
        repository:
          url: https://charts.bitnami.com/bitnami
  ```
  Changing the path:
  ```diff
    contents:
  - - path: custom-repo-custom-version
  + - path: better_path
      lazy: true                       # the proposed option
      helmChart:
        name: contour
        version: "7.10.1"
        repository:
          url: https://charts.bitnami.com/bitnami
  ```
  Disable `lazy` option by removing it:
  ```diff
    contents:
    - path: custom-repo-custom-version
  -   lazy: true                       # the proposed option
      helmChart:
        name: contour
        version: "7.10.1"
        repository:
          url: https://charts.bitnami.com/bitnami
  ```
- When the path of the parent `directory` has changed.
  ```diff
    apiVersion: vendir.k14s.io/v1alpha1
    kind: Config
    directories:
  - - path: vendor
  + - path: changed-vendor
      contents:
      - path: custom-repo-custom-version
        lazy: true                       # the proposed option
        helmChart:
          name: contour
          version: "7.10.1"
          repository:
            url: https://charts.bitnami.com/bitnami
  ```

To track changes to the configuration in the `vendir.yml`, the `vendir.lock.yml` is amended with a hash value that represents the state of the corresponding `contents` item configuration section at the last sync.
For example:
```yaml
kind: LockConfig
apiVersion: vendir.k14s.io/v1alpha1
directories:
- path: vendor
  contents:
  - path: custom-repo-custom-version
    hash: e8a5d1511f2eb22b160bb849e5c8be39da1c4ffa5fd56ded71ff095a8b24720b  # the proposed option
    helmChart:
      appVersion: 1.20.1
      version: 7.10.1
```
Hashes are only added if vendir is run with the `lazy` setting. 

To force a sync despite the `lazy` setting, a new option is added to the vendir binary, e.g.
```
vendir sync --eager
vendir sync --force
vendir sync --dont-be-lazy
```

### Other Approaches Considered
A simpler approach could work entirely at the binary level, e.g. a lazy option to enable lazy-syncing on all `contents` of the synced `vendir.yml`:
```
vendir sync --lazy
```
The implementation for this feature would be much simpler since an upfront comparison of `vendir.yml` and `vendir.lock.yml` would simply stop execution.
A modification to the sync implementation that checks for changes individually for each `contents` item, selectively skipping syncs while building a valid lock file would not be required. 

With this approach, one loses the ability to activate `lazy` syncing separately for specific `contents`. 


## Open Questions

- Which name to select for the options and CLI flags?

## Answered Questions
