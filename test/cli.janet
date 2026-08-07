(use ../deps/testament)

(import ../lib/cli :as lg)

(deftest markup-to-hiccup-on-one-line
  (def actual (lg/convert `<div><p>Hi</p><p>Bye</p></div>`))
  (is (== `@[:div @[:p "Hi"] @[:p "Bye"]]` actual)))

(deftest markup-to-hiccup-pretty
  # only an element too wide to fit on one line is broken open
  (def markup
    (string `<div class="wrap"><h1>Hello</h1>`
            "<p>Some <em>text</em> and more.</p>"
            "<ul><li>One</li><li>Two</li></ul></div>"))
  (def actual (lg/convert markup :pretty? true))
  (def expect
    `@[:div @{:class "wrap"}
      @[:h1 "Hello"]
      @[:p "Some " @[:em "text"] " and more."]
      @[:ul
        @[:li "One"]
        @[:li "Two"]]]`)
  (is (== expect actual)))

(deftest hiccup-to-markup-on-one-line
  (def actual (lg/convert `[:div [:p "Hi"] [:p "Bye"]]` :to-markup? true))
  (is (== "<div><p>Hi</p><p>Bye</p></div>" actual)))

(deftest hiccup-to-markup-pretty
  (def actual (lg/convert `[:div [:p "Hi"] [:p "Bye"]]`
                          :to-markup? true :pretty? true))
  (def expect
    `<div>
      <p>Hi</p>
      <p>Bye</p>
    </div>`)
  (is (== expect actual)))

(deftest hiccup-to-markup-honours-the-format
  (def actual (lg/convert `[:root [:leaf]]` :to-markup? true :html? false))
  (is (== "<root><leaf/></root>" actual)))

(deftest markup-to-hiccup-honours-the-format
  # in XML nothing is void, so the element has to close itself
  (def actual (lg/convert `<root><br/></root>` :html? false))
  (is (== `@[:root @[:br]]` actual)))

(deftest markup-to-hiccup-honours-the-width
  # a narrower width breaks open an element that would otherwise fit
  (def actual (lg/convert `<div><p>Some <em>text</em> and more.</p></div>`
                          :pretty? true :width 20))
  (def expect
    `@[:div
      @[:p
        "Some "
        @[:em "text"]
        " and more."]]`)
  (is (== expect actual)))

(deftest markup-to-hiccup-honours-the-indent
  (def actual (lg/convert `<ul><li>One</li><li>Two</li></ul>`
                          :pretty? true :width 20 :indent 4))
  (def expect
    `@[:ul
        @[:li "One"]
        @[:li "Two"]]`)
  (is (== expect actual)))

(deftest hiccup-to-markup-honours-the-indent
  (def actual (lg/convert `[:div [:p "Hi"] [:p "Bye"]]`
                          :to-markup? true :pretty? true :indent 4))
  (def expect
    `<div>
        <p>Hi</p>
        <p>Bye</p>
    </div>`)
  (is (== expect actual)))

(deftest output-is-always-a-string
  (is (string? (lg/convert `<p>Hi</p>`)))
  (is (string? (lg/convert `[:p "Hi"]` :to-markup? true))))

(run-tests!)
