# stream-sdk-docs-push-action

This action is responsible for pushing the documentation files from the source SDK code to the [central repository](https://github.com/GetStream/stream-sdk-docs).

This is designed in a way that it works for all the products of [Stream](https://www.getstream.io).

## Input Variables

| Name                          | Description                                                                             | Required | Default                   |
| ----------------------------- | --------------------------------------------------------------------------------------- | -------- | ------------------------- |
| `commit-message`              | [Optional] commit message for the output repository.                                    | `false`  | Update from ORIGIN_COMMIT |
| `destination-github-username` | Name of the destination repository owner(username/organization)                         | `false`  | GetStream                 |
| `destination-repository-name` | Destination repository name                                                             | `false`  | stream-sdk-docs           |
| `source-directory`            | Source directory from the origin(SDK) repository                                        | `false`  | docusaurus                |
| `product-directory`           | Product directory where the documentation should go. Eg: chat, video, etc.              | `true`   |                           |
| `target-branch`               | [Optional] set target branch name for the destination repository. Defaults to "staging" | `false`  | staging                   |
| `git-username`                | [Optional] Name for the git commit. Defaults to the CI Bot name                         | `false`  | stream-public-bot         |
| `git-email`                   | [Optional] Email for the git commit. Defaults to ''                                     | `false`  | ""                        |

**Note**: `product-directory` is a required input variable and must be provided for the action to push the docs in the appropriate product directory.

All the SDKs must have `SDK_DOCS_GH_TOKEN` added to their secrets.

## Example Usage

```yml
      - name: Push SDK Docs to Central Repo
        uses: GetStream/stream-sdk-docs-push-action@main
        with:
          product-directory: ${{ 'chat' }}
        env:    
          SDK_DOCS_GH_TOKEN: ${{ secrets.SDK_DOCS_GH_TOKEN }}
```