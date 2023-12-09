(defn- janet->html [ds &keys {:add-doctype? add-doctype?
                              :indent indent}]
  (default add-doctype? false)
  (default indent nil)
  (def res (if (or (nil? indent) (zero? indent))
             @""
             (buffer (string/repeat " " indent))))
  (if add-doctype?
    (buffer/push res "<!doctype html>" (if indent "\n" "")))
  (cond
    (bytes? ds)
    ds

    (number? ds)
    (scan-number ds)

    (indexed? ds)
    (let [name (first ds)]
      (buffer/push res "<")
      (buffer/push res name)
      (if (one? (length ds))
        (buffer/push res ">")
        (do
          (var i 1)
          (when (dictionary? (get ds i))
            (each [k v] (pairs (get ds i))
                (buffer/push res " " k `="` v `"`))
            (++ i))
          (buffer/push res ">")
          (while (< i (length ds))
            (def new-indent (when indent (+ 2 indent)))
            (def child (get ds i))
            (when (and indent (indexed? child))
              (buffer/push res "\n"))
            (buffer/push res (janet->html child :indent new-indent))
            (++ i)
            (when (= i (length ds))
              (when (and indent (indexed? child))
                (buffer/push res "\n" (string/repeat " " indent)))
              (buffer/push res "</" name ">")))))
      res)

    (error "invalid data structure")))


(defn- janet->xml [ds &keys {:indent indent}]
  (default indent nil)
  (def res (if (or (nil? indent) (zero? indent))
             @""
             (buffer (string/repeat " " indent))))
  (cond
    (bytes? ds)
    ds

    (number? ds)
    (scan-number ds)

    (indexed? ds)
    (let [name (first ds)]
      (buffer/push res "<")
      (buffer/push res name)
      (if (one? (length ds))
        (buffer/push res (if (string/has-prefix? "?" name) "?>" "/>"))
        (do
          (var i 1)
          (when (dictionary? (get ds i))
            (each [k v] (pairs (get ds i))
                (buffer/push res " " k `="` v `"`))
            (++ i))
          (buffer/push res
                       (if (= i (length ds))
                         (if (string/has-prefix? "?" name)
                           "?"
                           "/")
                         "")
                       ">")
          (while (< i (length ds))
            (def new-indent (when indent (+ 2 indent)))
            (def child (get ds i))
            (when (and indent (indexed? child))
              (buffer/push res "\n"))
            (buffer/push res (janet->html child :indent new-indent))
            (++ i)
            (when (= i (length ds))
              (when (and indent (indexed? child))
                (buffer/push res "\n" (string/repeat " " indent)))
              (buffer/push res "</" name ">")))))
      res)

    (error "invalid data structure")))


(defn janet->markup
  ```
  Converts a Janet data structure

  This function takes a Hiccup-style Janet datastructure and converts it to
  markup
  ```
  [ds &keys {:format format :indent indent}]
  (default format :html)
  (default indent nil)
  (def res @"")
  (def nodes (if (keyword? (first ds)) [ds] ds))
  (var newline "")
  (each node nodes
    (buffer/push res newline
      (case format
        :html (janet->html node :add-doctype? true :indent indent)
        :xml (janet->xml node :indent indent)
        (error "unsupported format")))
    (unless (and indent (> 1 (length nodes)))
      (set newline "\n")))
  res)
