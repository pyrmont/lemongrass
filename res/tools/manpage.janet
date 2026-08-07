(def- seps {:windows "\\" :mingw "\\" :cygwin "\\"})
(def- s (get seps (os/which) "/"))

(def- paths
  ["man"])

(defn- abspath
  [path]
  (def absolute? (if (= "\\" s)
                   (peg/match ~(* (? (* :a ":")) "\\") path)
                   (string/has-prefix? "/" path)))
  (if absolute?
    path
    (string (os/cwd) s path)))

(defn- parent
  [path level]
  (def parts (string/split s path))
  (string/join (array/slice parts 0 (- -1 level)) s))

(defn- parse-args
  [args]
  (def force? (= "-f" (get args 1)))
  (def begin (if force? 2 1))
  (def pages (array/slice args begin))
  [force? pages])

(defn- special?
  [entry]
  (or (= "." entry) (= ".." entry)))

(defn main
  [& args]
  (def [force? pages] (parse-args args))
  (def bundle-root (-> (dyn :current-file) (abspath) (parent 3)))
  (def entries (map (partial string bundle-root s) paths))
  (each entry entries
    (if (= :directory (os/stat entry :mode))
      (->> (os/dir entry)
           (filter (comp not special?))
           (map (partial string entry s))
           (array/concat entries))
      (when (and (string/has-suffix? ".predoc" entry)
                 (or (empty? pages)
                     (find (fn [p] (string/has-suffix? p entry)) pages)))
        (def src entry)
        (def dest (string/slice src 0 -8))
        (def prefix (string (os/cwd) "/"))
        (when (or force?
                  (< (os/stat dest :modified)
                     (os/stat src :modified)))
          (def rel-src (string/replace prefix "" src))
          (def rel-dest (string/replace prefix "" dest))
          (print "converting " rel-src " to " rel-dest)
          (os/execute ["predoc" src "-o" dest] :px))))))
