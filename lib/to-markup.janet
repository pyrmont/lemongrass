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

  `indent` is nil for compact output or, otherwise, the whitespace that
  precedes the node on its line. `tab` is the whitespace added for each level
  of nesting. `pre?` is true if the node sits inside an element whose contents
  are reproduced verbatim.
  ```
  [ds res format indent tab pre?]
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
          (def break? (and indent (not pre?) (breakable? ds i format)))
          (def child-indent (when indent (string indent tab)))
          (var prev nil)
          (while (< i (length ds))
            (def child (get ds i))
            (when (and break?
                       (or (nil? prev) (break-before? prev child format)))
              (buffer/push res "\n" child-indent))
            (node->markup child res format
                          (if break? child-indent indent) tab pre?)
            (set prev child)
            (++ i))
          (when break? (buffer/push res "\n" indent))
          (buffer/push res "</" name ">"))))

    (error "invalid data structure")))

(defn hiccup->markup
  ```
  Converts a Hiccup data structure to markup

  This function takes a Hiccup data structure and converts it to markup. By
  default, the markup is HTML. If not, `:format` can be set to `:xml`.

  If `:indent` is a number, the markup is pretty printed with that many spaces
  of leading indentation and `:tab` (two spaces by default) added for each
  level of nesting. A newline is only introduced between two nodes where it
  cannot change how the markup is interpreted, so the contents of elements
  like `<p>` and `<pre>` are left alone. If `:indent` is nil, no whitespace is
  added at all.

  A `<!doctype html>` declaration is added ahead of a top-level `:html`
  element unless `:add-doctype?` is set to false or the data structure
  already carries a declaration of its own.
  ```
  [ds &keys {:format format
             :indent indent
             :tab tab
             :add-doctype? add-doctype?}]
  (default format :html)
  (default tab "  ")
  (default add-doctype? true)
  (unless (or (= :html format) (= :xml format))
    (error "unsupported format"))
  (def res @"")
  (def nodes (if (indexed? (first ds)) ds [ds]))
  (def prefix (when indent (string/repeat " " indent)))
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
      (when prefix (buffer/push res prefix))
      (when (and prefix (break-before? prev node format))
        (buffer/push res "\n" prefix)))
    (when (and add-doctype?
               (not declared?)
               (= :html format)
               (indexed? node)
               (= :html (first node)))
      (buffer/push res "<!doctype html>")
      (when prefix (buffer/push res "\n" prefix)))
    (node->markup node res format prefix tab false)
    (set prev node))
  res)

(def janet->markup
  ```
  An alias for `hiccup->markup`
  ```
  hiccup->markup)
