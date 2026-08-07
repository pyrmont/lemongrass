(use ../deps/testament)

(import ../lib/cli :as lg)

(deftest markup-to-janet-on-one-line
  (def actual (lg/convert `<div><p>Hi</p><p>Bye</p></div>`))
  (is (== `@[:div @[:p "Hi"] @[:p "Bye"]]` actual)))

(deftest markup-to-janet-pretty
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

(deftest janet-to-markup-on-one-line
  (def actual (lg/convert `[:div [:p "Hi"] [:p "Bye"]]` :to-markup? true))
  (is (== "<div><p>Hi</p><p>Bye</p></div>" actual)))

(deftest janet-to-markup-pretty
  (def actual (lg/convert `[:div [:p "Hi"] [:p "Bye"]]`
                          :to-markup? true :pretty? true))
  (def expect
    `<div>
      <p>Hi</p>
      <p>Bye</p>
    </div>`)
  (is (== expect actual)))

(deftest janet-to-markup-honours-the-format
  (def actual (lg/convert `[:root [:leaf]]` :to-markup? true :html? false))
  (is (== "<root><leaf/></root>" actual)))

(deftest markup-to-janet-honours-the-format
  # in XML nothing is void, so the element has to close itself
  (def actual (lg/convert `<root><br/></root>` :html? false))
  (is (== `@[:root @[:br]]` actual)))

(deftest output-is-always-a-string
  (is (string? (lg/convert `<p>Hi</p>`)))
  (is (string? (lg/convert `[:p "Hi"]` :to-markup? true))))

(run-tests!)
