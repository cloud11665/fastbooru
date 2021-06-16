#!/usr/bin/env hy

(require [hy.extra.anaphoric [*]])
(require [hy.core [*]])

(import [argparse [ArgumentParser]]
        [sys [argv]]
        [concurrent.futures [ThreadPoolExecutor as_completed]]
        [pathlib [Path]]
        sys
        logging
        re
        os)

(import [toolz [*]]
        [colorlog [ColoredFormatter]])

(import [meta [MetaVarlessFormatter]])
(import [api [*]])



(defn main []
  (setv formatter (ColoredFormatter "[%(asctime)s] %(log_color)s%(levelname)-7s%(reset)s {%(name)s:%(funcName)s} - %(message)s"
                     :datefmt "%H:%M:%S"
                     :reset True
                     :log_colors {
                      "DEBUG" "cyan"
                      "INFO" "green"
                      "WARNING" "yellow"
                      "ERROR" "red"
                      "CRITICAL" "red"
                     }))

  (setv logger (logging.getLogger f"fastbooru.{(os.path.basename (. argv[0]))}"))
  (setv handler (logging.StreamHandler))
  (handler.setFormatter formatter)
  (logger.addHandler handler)
  (logger.setLevel logging.DEBUG)

  (setv parser (ArgumentParser
                :description (+ "Fastest gelbooru image downloader.\n"
                                "Made by Cloud11665, under the GNU gplv3 license.\n"
                                "https://github.com/cloud11665/fastbooru")
                :usage (+ (os.path.basename (. argv[0])) " [options] {tags} {directory}")
                :formatter_class MetaVarlessFormatter))

  (parser.add-argument "tags" :type str)
  (parser.add-argument "directory" :type str)

  (parser._action_groups.pop 0) ;;remove the 'required arguments' section

  (parser.add-argument "-e" "--explicit"
                       :action "store_true" :default False
                       :help "show explicit images")
  (parser.add_argument "-n" "--number"
                       :action "store" :type int
                       :metavar "INT" :default 10
                       :help "number of images")
  ;(parser.add_argument "-c" "--config"
  ;                     :action "store" :type str
  ;                     :metavar "PATH" :default "~/.fastbooru"
  ;                     :help "use a custom config file")
  (parser.add_argument "-a" "--api"
                       :action "store" :type str
                       :metavar "STR" :default "&api_key=anonymous&user_id=9455"
                       :help "use a custom api key")
  (parser.add_argument "-w" "--workers"
                       :action "store" :type int
                       :metavar "INT" :default 20
                       :help  "use a custom amount of download workers")

  (setv args (parser.parse_args))

  (os.makedirs args.directory :exist-ok True)
  (setv path (Path args.directory))
  (setv tags (re.findall r"[^\s~{}-]+" args.tags)) ;;remove all of gelbooru's
                                                   ;;logic syntax sugar



  (if (= 1 (len tags))
      (setv tagstr "tag")
      (setv tagstr "tags"))
  (logger.debug f"found {(len tags)} {tagstr}.")

  (setv check-tag (fn [tag] ;;define a anonymous function to validate a tag
        (unless (list-tags tag :apikey args.api :limit 1)
                        (do (ap-if (list-tags f"{tag}*" :apikey args.api) ;;anaphoric
                                   (setv rec f" Did you mean '{(:tag (first it))}' ?")
                                   (setv rec ""))

                            (logger.critical f"'{tag}' is not a valid tag.{rec}")
                            (return 1)))))
  (setv tpool [])
  (with [executor (ThreadPoolExecutor :max-workers args.number)]
        (for [tag tags]
             (tpool.append (executor.submit check-tag :tag tag))))


  (if (any (lfor task (as-completed tpool) (task.result)))
      (do (logger.critical "Exiting...")
          (sys.exit -1)))

  (if (not args.explicit) ;;remove all of the nasty tags
              (+= args.tags
                  " rating:safe"
                  " -swimsuit"
                  " -bikini"
                  " -breasts"
                  " -ass"
                  " -underwear"
                  " -torn_skirt"
                  " -undressing"
                  " -ahegao"
                  " -ass_focus"))

  (setv images (list-images args.tags :limit args.number :apikey args.api))
  (logger.debug f"fetched {(len images)} images.")

  (setv download-image (fn [img]                     ;;redefine the download
        (setv fname (str (/ path (:image img))))     ;;function to include
        (download :url (:file-url img)               ;;logging output
                  :fname fname)
        (logger.debug f"downloaded {(:image img)}")))

  (setv tpool [])
  (with [executor (ThreadPoolExecutor :max-workers args.number)]
        (for [img images]
             (setv fname (str (/ path (:image img))))
             (tpool.append (executor.submit download-image img))))
  (lfor task (as-completed tpool) (task.result)))

;;TODO add verbosity levels
