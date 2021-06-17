#!/usr/bin/env hy

(import json
        os
        shutil
        re
        [subprocess [check-output]]
        [functools [partial]])
(import requests)
(import [fastbooru.meta [HAS_CURL :as curl?]])

(import [hy.contrib.pprint [*]])

(setv gbooru-url "https://gelbooru.com/index.php?page=dapi&q=index&json=1")

(defn download [^str url ^str fname]
  (if curl?
      (os.system f"curl -so {fname} {url}")
      (with [resp (requests.get url :stream True)]
            (setv resp.raw.read (partial resp.raw.read :decode-content True))
            (with [fh (open fname "wb")]
                  (shutil.copyfileobj resp.raw fh)))))

(defn request [^str url ^bool [json? False]]
  (if curl?
      (setv out (check-output ["curl" "-s" url] :text True))
      (setv out ((-> (requests.get url)
                     (. content)
                     (. decode)))))
  (if json?
      (return (json.loads out))
      (return out)))

(defn tagname-from-url [^str url]
  (setv name (.(re.findall r"&name=[a-z_'A-Z]+" url) [0]))
  (return (.(re.findall r"[^&name=]{1}[a-z_'A-Z]+$" name) [0])))

(defn list-tags [^str tag ^bool [ascending False] ^int [limit 100]
                ^str  [apikey "&api_key=anonymous&user_id=9455"] ^str [orderby "count"]]
  (setv tag (tag.replace "*" "%"))
  (return (request (+ gbooru-url apikey
                      f"&s=tag"
                      f"&limit={limit}"
                      f"&order={(lif ascending 'DESC 'ASC)}"
                      f"&orderby={orderby}"
                      f"&name_pattern={tag}")
                   :json? True)))

(defn list-images [^str tags ^int [limit 100]
                   ^str [apikey "&api_key=anonymous&user_id=9455"]]
  (return (request (+ gbooru-url apikey
                      f"&s=post"
                      f"&limit={limit}"
                      f"&tags={tags}")
                   :json? True)))
