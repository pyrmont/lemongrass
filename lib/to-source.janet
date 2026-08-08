(import ./elements)

(defn- block-child?
  ```
  Checks whether any child of `x` is an element that starts a block of its own

  Such a child is given a line of its own however short it is, so that the
  shape of the source follows the shape of the markup it stands for. An
  element whose children are all text or inline elements is laid out on one
  line where it fits, exactly as the markup would be.
  ```
  [x]
  (and (indexed? x)
       (truthy? (some (fn [child]
                        (and (indexed? child)
                             (not (elements/inline? (first child)))))
                      x))))

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

  `prefix` is the whitespace that precedes `x` on its line, `pad` the
  whitespace added for each level of nesting and `width` the column the output
  tries to stay within. A value is put on one line if it fits; otherwise its
  first element stays on the opening line and the rest are placed beneath it.
  ```
  [x res prefix pad width]
  (def flat (compact x))
  (def child-prefix (string prefix pad))
  # an unreachable width asks for the compact form, so nothing is broken open
  (def laid-out? (not= math/inf width))
  (cond
    (and (<= (+ (length prefix) (length flat)) width)
         (not (and laid-out? (block-child? x))))
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
          (when (<= (+ (length prefix) 2 (length head) 1 (length attrs)) width)
            (buffer/push res " " attrs)
            (++ i))))
      (while (< i (length x))
        (buffer/push res "\n" child-prefix)
        (value->source (get x i) res child-prefix pad width)
        (++ i))
      (buffer/push res "]"))

    (dictionary? x)
    (do
      (buffer/push res (if (table? x) "@{" "{"))
      (var first? true)
      (each [k v] (pairs x)
        (if first?
          (set first? false)
          (buffer/push res "\n" child-prefix))
        (buffer/push res (compact k) " ")
        (value->source v res child-prefix pad width))
      (buffer/push res "}"))

    # an atom that is too long to fit has to overrun
    (buffer/push res flat)))

(defn hiccup->source
  ```
  Converts a Hiccup data structure to a string of Janet source

  This function takes a Hiccup data structure and pretty prints it as Janet
  source. An element is put on one line if it fits within `:width` columns (80
  by default) and none of its children starts a block of its own; otherwise its
  tag (and its attributes, if they fit too) stay on the opening line and its
  children are placed beneath it, indented by `:indent` (2 by default)
  repetitions of `:step` (a single space by default) for each level of
  nesting.

  `:inset` is a string put at the start of every line. It shifts the whole
  data structure across without taking any part in the indentation of one
  level relative to another, and counts against `:width` like any other
  leading whitespace.

  Setting `:width` to `math/inf` asks for the compact form, which is the whole
  data structure on a single line. Unlike `hiccup->markup`, this function is a
  pretty printer by default, so it is `:width` rather than `:indent` that asks
  for one line.
  ```
  [ds &keys {:indent indent :step step :inset inset :tab tab :width width}]
  (default indent 2)
  (default step " ")
  (default inset "")
  (default width 80)
  (when tab
    (error "`:tab` has been replaced by `:step` and `:indent`"))
  (def res @"")
  (buffer/push res inset)
  (value->source ds res inset (string/repeat step indent) width)
  res)

(def janet->source
  ```
  An alias for `hiccup->source`
  ```
  hiccup->source)
