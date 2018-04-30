# S3 Practical Guide (French Version)

The French translation of "Sociocracy 3.0 Practical Guide""

## Build Process

* add translated files from [S3 Practical Guide Crowdin project](https://crowdin.com/project/sociocracy-30) (be sure to merge Jekyll config (docs/_config.yml because Jekyll expects a specific YAML format))
* use [illustration translations](https://crowdin.com/project/sociocracy-30-illustrations) to translate illustrations and copy translated illustrations to `img` and `docs/img`
* update version number in `templates/deckset-template.md`
* run buildscript (`make deckset|revealjs|site`)
* (optional) build pdf (A4 for print and wide for screen)