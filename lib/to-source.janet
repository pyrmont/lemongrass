(defn- compact
  ```
  Renders `x` as Janet source on a single line
  ```
  [x]
  (cond
    (indexed? x)
    (string (if (array? x) "@[" "[")
            (string/join (map compact x) " ")
            "]")

    (dictionary? x)
    (string (if (table? x) "@{" "{")
            (string/join (seq [[k v] :in (pairs x)]
                          (string (compact k) " " (compact v)))
                         " ")
            "}")

    (string/format "%j" x)))

(defn- value->source
  ```
  Renders `x` as Janet source, appending the result to `res`

  `indent` is the whitespace that precedes `x` on its line, `tab` the
  whitespace added for each level of nesting and `width` the column the output
  tries to stay within. A value is put on one line if it fits; otherwise its
  first element stays on the opening line and the rest are placed beneath it.
  ```
  [x res indent tab width]
  (def flat (compact x))
  (def child-indent (string indent tab))
  (cond
    (<= (+ (length indent) (length flat)) width)
    (buffer/push res flat)

    (indexed? x)
    (do
      (buffer/push res (if (array? x) "@[" "["))
      (var i 0)
      # the tag stays on the opening line, as does an attribute dictionary
      # that fits alongside it
      (when (< i (length x))
        (def head (compact (get x i)))
        (buffer/push res head)
        (++ i)
        (when (dictionary? (get x i))
          (def attrs (compact (get x i)))
          (when (<= (+ (length indent) 2 (length head) 1 (length attrs)) width)
            (buffer/push res " " attrs)
            (++ i))))
      (while (< i (length x))
        (buffer/push res "\n" child-indent)
        (value->source (get x i) res child-indent tab width)
        (++ i))
      (buffer/push res "]"))

    (dictionary? x)
    (do
      (buffer/push res (if (table? x) "@{" "{"))
      (var first? true)
      (each [k v] (pairs x)
        (if first?
          (set first? false)
          (buffer/push res "\n" child-indent))
        (buffer/push res (compact k) " ")
        (value->source v res child-indent tab width))
      (buffer/push res "}"))

    # an atom that is too long to fit has to overrun
    (buffer/push res flat)))

(defn janet->source
  ```
  Converts a Janet data structure to a string of Janet source

  This function takes a Hiccup-style Janet data structure and pretty prints it
  as Janet source. An element is put on one line if it fits within `:width`
  columns (80 by default); otherwise its tag (and its attributes, if they fit
  too) stay on the opening line and its children are placed beneath it,
  indented by `:tab` (two spaces by default) for each level of nesting.
  ```
  [ds &keys {:tab tab :width width}]
  (default tab "  ")
  (default width 80)
  (def res @"")
  (value->source ds res "" tab width)
  res)
