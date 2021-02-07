# S3 Practical Guide (French Version)

The French translation of "Sociocracy 3.0 Practical Guide""

## Build Process

-   add translated files from [S3 Practical Guide Crowdin project](https://crowdin.com/project/sociocracy-30) 
-   check with English repository for changes to:
    -   `config/*`
    -  ` templates/*`
    -   `makefile` and `build.sh`
    -   the contents of all the subfolders inside docs (but not the file inside docs )
-    add translated illustrations to `img`
-   update version number in `config/project.yaml`
-   run buildscript (`source build.sh`) to build all formats or only build the website:
	-   `make clean` clan temporary files and web pages
	-   `make setup` to copy images and ensure all temp folders are created
	-   `make site` to build the website
