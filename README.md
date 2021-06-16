# fastbooru
Because all other cli downloaders suck...

usage: fastbooru [options] [tags] [directory]

optional arguments:
        -e --explicit show explicit images.
        -h --help     show this message.
        -n            number of images. (defaults to 10)
        -c --config   use a custom config file (defaults to ~/.fastbooru)
        -a --api      use a custom api key (defaults to anon)
        -w --workers  use a custom amount of download workers (default to `nproc`*4)
        -s --silent
        -v --verbose