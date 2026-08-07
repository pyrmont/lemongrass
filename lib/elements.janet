### Facts about the names of SGML elements
###
### The predicates in this module answer questions about a tag name alone. They
### are shared by the parser and the renderer so that both agree on, say, what
### counts as a void element or how a declaration is spelled.

(def- void-elements
  ```
  Elements that have no closing tag and so cannot have children
  ```
  {:area true :base true :basefont true :bgsound true :br true :col true
   :command true :embed true :frame true :hr true :image true :img true
   :input true :keygen true :link true :meta true :param true :source true
   :track true :wbr true})

(def- block-elements
  ```
  Elements that start a block of their own

  Whitespace beside one of these is discarded when the markup is rendered, so
  it can be added or removed freely. Every other element takes part in the
  surrounding line of text instead, which is also what an element not named
  here does: an element the browser does not recognise is laid out inline.
  ```
  {:address true :article true :aside true :base true :blockquote true
   :body true :caption true :col true :colgroup true :dd true :details true
   :dialog true :div true :dl true :dt true :fieldset true :figcaption true
   :figure true :footer true :form true :h1 true :h2 true :h3 true :h4 true
   :h5 true :h6 true :head true :header true :hgroup true :hr true :html true
   :legend true :li true :link true :main true :menu true :meta true
   :nav true :noframes true :ol true :optgroup true :option true :p true
   :param true :pre true :script true :section true :source true :style true
   :summary true :table true :tbody true :td true :tfoot true :th true
   :thead true :title true :tr true :track true :ul true})

(def- preformatted-elements
  ```
  Elements whose entire contents are reproduced verbatim
  ```
  {:pre true :script true :style true :textarea true})

(defn void?
  ```
  Checks whether `name` is the name of a void element
  ```
  [name]
  (truthy? (get void-elements name)))

(defn preformatted?
  ```
  Checks whether `name` is the name of an element whose contents are
  reproduced verbatim
  ```
  [name]
  (truthy? (get preformatted-elements name)))

(defn declaration?
  ```
  Checks whether `name` is the name of a declaration, like `<!doctype html>`
  ```
  [name]
  (and (bytes? name) (string/has-prefix? "!" name)))

(defn instruction?
  ```
  Checks whether `name` is the name of a processing instruction, like `<?xml?>`
  ```
  [name]
  (and (bytes? name) (string/has-prefix? "?" name)))

(defn inline?
  ```
  Checks whether `name` is the name of an element that whitespace is
  significant beside

  A declaration or a processing instruction never is. Neither is an element
  that starts a block of its own. Anything else is treated as inline, an
  element the browser does not recognise included, because that is how one is
  laid out. Erring this way costs no more than a missed chance to break a
  line, whereas erring the other way would put whitespace into a document
  that renders it.
  ```
  [name]
  (not (or (declaration? name)
           (instruction? name)
           (truthy? (get block-elements name)))))
