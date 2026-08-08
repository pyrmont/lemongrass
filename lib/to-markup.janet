(import ./elements)

(defn- inline-child?
  ```
  Checks whether whitespace beside `child` would be rendered

  Text is always rendered as-is. An element is only significant in this way in
  HTML, where it takes part in the surrounding line of text rather than
  starting a block of its own.
  ```
  [child format]
  (or (not (indexed? child))
      (and (= :html format)
           (elements/inline? (first child)))))

(defn- breakable?
  ```
  Checks whether the children of an element can be put on separate lines

  In HTML, an element can be broken open if it starts a block of its own and
  at least one of its children from `start` onwards does too: whitespace at
  the beginning and end of such a block is discarded when the markup is
  rendered. An element whose children are all text or inline elements is left
  alone, since every space inside it counts.

  In XML no element has a rendering, so the conventional rule applies instead:
  an element can be broken open if it has no text among its children.
  ```
  [ds start format]
  (if (= :xml format)
    (all indexed? (slice ds start))
    (and (not (elements/inline? (first ds)))
         (truthy? (some (fn [child] (not (inline-child? child format)))
                        (slice ds start))))))

(defn- break-before?
  ```
  Checks whether a newline can be put between the children `prev` and `child`

  Whitespace between two children is discarded if either of them starts a
  block of its own, but is rendered if both take part in the same line of
  text.
  ```
  [prev child format]
  (or (= :xml format)
      (not (inline-child? prev format))
      (not (inline-child? child format))))

(defn- node->markup
  ```
  Renders `ds` as markup, appending the result to `res`

  `prefix` is the whitespace that precedes the node on its line. `pad` is the
  whitespace added for each level of nesting, or nil for compact output, in
  which case no newline is introduced anywhere. `pre?` is true if the node
  sits inside an element whose contents are reproduced verbatim.
  ```
  [ds res format prefix pad pre?]
  (cond
    (bytes? ds)
    (buffer/push res ds)

    (number? ds)
    (buffer/push res (string ds))

    # a declaration has no attributes, children or closing tag: whatever
    # followed the name in the source is reproduced after it
    (and (indexed? ds) (elements/declaration? (first ds)))
    (do
      (buffer/push res "<" (first ds))
      (for i 1 (length ds)
        (buffer/push res " " (get ds i)))
      (buffer/push res ">"))

    (indexed? ds)
    (let [name (first ds)
          pre? (or pre?
                   (and (= :html format)
                        (elements/preformatted? name)))]
      (buffer/push res "<" name)
      (var i 1)
      (when (dictionary? (get ds i))
        (each [k v] (pairs (get ds i))
          (buffer/push res " " k `="` v `"`))
        (++ i))
      (if (= i (length ds))
        (cond
          (elements/instruction? name) (buffer/push res "?>")
          (= :xml format) (buffer/push res "/>")
          (elements/void? name) (buffer/push res ">")
          # an HTML element that is not void still needs its closing tag,
          # whether or not it has any children
          (buffer/push res "></" name ">"))
        (do
          (buffer/push res ">")
          (def break? (and pad (not pre?) (breakable? ds i format)))
          (def child-prefix (if pad (string prefix pad) prefix))
          (var prev nil)
          (while (< i (length ds))
            (def child (get ds i))
            (when (and break?
                       (or (nil? prev) (break-before? prev child format)))
              (buffer/push res "\n" child-prefix))
            (node->markup child res format
                          (if break? child-prefix prefix) pad pre?)
            (set prev child)
            (++ i))
          (when break? (buffer/push res "\n" prefix))
          (buffer/push res "</" name ">"))))

    (error "invalid data structure")))

(defn hiccup->markup
  ```
  Converts a Hiccup data structure to markup

  This function takes a Hiccup data structure and converts it to markup. By
  default, the markup is HTML. If not, `:format` can be set to `:xml`.

  If `:indent` is a number, the markup is laid out over several lines, each
  level of nesting indented by that many repetitions of `:step` (a single
  space by default). A newline is only introduced between two nodes where it
  cannot change how the markup is interpreted, so the contents of elements
  like `<p>` and `<pre>` are left alone. If `:indent` is nil, the markup is
  put on one line.

  `:inset` is a string put at the start of every line, whether or not the
  markup is laid out. It shifts the whole document across without taking any
  part in the indentation of one level relative to another.

  A `<!doctype html>` declaration is added ahead of a top-level `:html`
  element unless `:add-doctype?` is set to false or the data structure
  already carries a declaration of its own.
  ```
  [ds &keys {:format format
             :indent indent
             :step step
             :inset inset
             :tab tab
             :add-doctype? add-doctype?}]
  (default format :html)
  (default step " ")
  (default inset "")
  (default add-doctype? true)
  (when tab
    (error "`:tab` has been replaced by `:step` and `:indent`"))
  (unless (or (= :html format) (= :xml format))
    (error "unsupported format"))
  (def res @"")
  (def nodes (if (indexed? (first ds)) ds [ds]))
  (def pad (when indent (string/repeat step indent)))
  (def declared?
    (truthy? (some (fn [node]
                     (and (indexed? node) (elements/declaration? (first node))))
                   nodes)))
  (var prev nil)
  (each node nodes
    # the whitespace between two top-level nodes is subject to the same rule
    # as the whitespace between two children, and is only added at all when
    # the markup is being laid out
    (if (nil? prev)
      (buffer/push res inset)
      (when (and pad (break-before? prev node format))
        (buffer/push res "\n" inset)))
    (when (and add-doctype?
               (not declared?)
               (= :html format)
               (indexed? node)
               (= :html (first node)))
      (buffer/push res "<!doctype html>")
      (when pad (buffer/push res "\n" inset)))
    (node->markup node res format inset pad false)
    (set prev node))
  res)

(defn janet->markup
  ```
  A deprecated conversion of a Hiccup data structure to markup

  This function is kept for code written before `:step` and `:inset` were
  introduced, when `:indent` was the number of spaces every line was shifted
  across by and each level of nesting was indented by a further two. It takes
  `:indent` that way and passes the rest of its arguments along unchanged.

  New code should call `hiccup->markup`, where `:indent` is the number of
  steps added for each level of nesting and the shift across is `:inset`.
  ```
  :deprecated
  [ds &keys {:format format :indent indent :add-doctype? add-doctype?}]
  (default format :html)
  (default add-doctype? true)
  (hiccup->markup ds
                  :format format
                  :add-doctype? add-doctype?
                  # two spaces for each level of nesting was not adjustable
                  :indent (when indent 2)
                  :inset (when indent (string/repeat " " indent))))
