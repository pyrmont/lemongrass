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

(def- inline-elements
  ```
  Elements for which surrounding whitespace is significant

  Whitespace between these elements (or between one of them and adjacent text)
  is rendered, so it cannot be added or removed without changing the document.
  ```
  {:a true :abbr true :acronym true :audio true :b true :bdi true :bdo true
   :big true :br true :button true :canvas true :cite true :code true
   :data true :datalist true :del true :dfn true :em true :embed true :i true
   :iframe true :img true :input true :ins true :kbd true :label true
   :map true :mark true :meter true :noscript true :object true :output true
   :picture true :progress true :q true :ruby true :s true :samp true
   :select true :slot true :small true :span true :strong true :sub true
   :sup true :svg true :template true :textarea true :time true :tt true
   :u true :var true :video true :wbr true})

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

(defn inline?
  ```
  Checks whether `name` is the name of an element that whitespace is
  significant beside
  ```
  [name]
  (truthy? (get inline-elements name)))

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
