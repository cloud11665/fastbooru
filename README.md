# fastbooru

pip installation may fail due my lack of deep understanding of hy modules.

will try to migrate from a non-official build of hy to a more stable one. this may fix it.

```sh
[anon@computer ~] $ fastbooru --help

usage: fastbooru [options] {tags} {directory}

Fastest gelbooru image downloader.
Made by Cloud11665, under the GNU gplv3 license.
https://github.com/cloud11665/fastbooru

optional arguments:
  -h, --help         show this help message and exit
  -e, --explicit     show explicit images
  -n, --number INT   number of images
  -a, --api STR      use a custom api key
  -w, --workers INT  use a custom amount of download workers
```


## installation
stable
```sh
pip install fastbooru
```
latest
```sh
pip install git+https://github.com/Cloud11665/fastbooru.git@master
```
