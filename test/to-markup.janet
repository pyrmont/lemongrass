(use ../deps/testament)

(import ../lib/to-markup)
(import ../lib/to-janet)

(deftest basic-html
  (def janet
    @[:html
      @[:head
        @[:title "Hello HTML!"]]
      @[:body
        @[:h1 "Hello world!"]]])
  (def actual (to-markup/janet->markup janet :indent 0))
  (def expect
    `<!doctype html>
    <html>
      <head>
        <title>Hello HTML!</title>
      </head>
      <body>
        <h1>Hello world!</h1>
      </body>
    </html>`)
  (is (== expect actual)))

(deftest basic-xml
  (def janet [[:?xml {:version "1.0" :encoding "UTF-8"}]
               [:rss {:version "2.0"}
                [:channel
                 [:title "Hello RSS!"]]
                [:item
                 [:description "Hello world!"]]]])
  (def actual (to-markup/janet->markup janet :format :xml :indent 0))
  (def expect
    `<?xml encoding="UTF-8" version="1.0"?>
    <rss version="2.0">
      <channel>
        <title>Hello RSS!</title>
      </channel>
      <item>
        <description>Hello world!</description>
      </item>
    </rss>`)
  (is (== expect actual)))

(deftest inline-content
  (def janet
    @[:div
      @[:p "Hello " @[:em "there"] " friend."]
      @[:p "Bye."]])
  (def actual (to-markup/janet->markup janet :indent 0))
  (def expect
    `<div>
      <p>Hello <em>there</em> friend.</p>
      <p>Bye.</p>
    </div>`)
  (is (== expect actual)))

(deftest preformatted-content
  (def janet
    @[:div
      @[:pre @[:code "one\n  two"]]
      @[:p "after"]])
  (def actual (to-markup/janet->markup janet :indent 0))
  (def expect
    `<div>
      <pre><code>one
      two</code></pre>
      <p>after</p>
    </div>`)
  (is (== expect actual)))

(deftest nested-xml
  (def janet [:root [:branch [:leaf] [:leaf {:n "2"}]]])
  (def actual (to-markup/janet->markup janet :format :xml :indent 0))
  (def expect
    `<root>
      <branch>
        <leaf/>
        <leaf n="2"/>
      </branch>
    </root>`)
  (is (== expect actual)))

(deftest custom-tab
  (def janet @[:div @[:section @[:p "hi"]]])
  (def actual (to-markup/janet->markup janet :indent 0 :tab "\t"))
  (def expect "<div>\n\t<section>\n\t\t<p>hi</p>\n\t</section>\n</div>")
  (is (== expect actual)))

(deftest mixed-inline-and-block-children
  (def janet
    @[:main
      @[:h1 "Title"]
      @[:img {:src "x.png"}]
      @[:br]
      @[:p "End."]])
  (def actual (to-markup/janet->markup janet :indent 0))
  (def expect
    `<main>
      <h1>Title</h1>
      <img src="x.png"><br>
      <p>End.</p>
    </main>`)
  (is (== expect actual)))

(deftest indenting-preserves-the-document
  (def src
    (string "<div><p>Hello <em>there</em> friend.</p>"
            "<ul><li>One</li><li>Two</li></ul>"
            `<p>A <a href="#">link</a> and an <img src="x.png"> image.</p>`
            "<pre>  keep\n  me</pre></div>"))
  (def janet (to-janet/markup->janet src))
  (def indented (string (to-markup/janet->markup janet :indent 0)))
  (is (== janet (to-janet/markup->janet indented))))

(deftest declaration
  (def janet @[:!doctype "html"])
  (is (== "<!doctype html>" (to-markup/janet->markup janet))))

(deftest declaration-suppresses-the-added-doctype
  (def janet [@[:!doctype "html"] @[:html @[:body @[:p "hi"]]]])
  (def actual (to-markup/janet->markup janet :indent 0))
  (def expect
    `<!doctype html>
    <html>
      <body>
        <p>hi</p>
      </body>
    </html>`)
  (is (== expect actual)))

(deftest instruction-closes-as-an-instruction
  (def janet [:?xml {:version "1.0"}])
  (is (== `<?xml version="1.0"?>` (to-markup/janet->markup janet))))

(deftest full-document-round-trip
  (def src
    (string "<!doctype html><html><head><title>T</title></head>"
            `<body><p>A <em>note</em>.</p><img src="x.png"><br><p>End.</p>`
            "</body></html>"))
  (def janet (to-janet/markup->janet src))
  (def indented (string (to-markup/janet->markup janet :indent 0)))
  (is (== janet (to-janet/markup->janet indented))))

(deftest empty-elements-are-closed
  (is (== "<div></div>" (to-markup/janet->markup @[:div])))
  (is (== `<div class="x"></div>` (to-markup/janet->markup @[:div {:class "x"}]))))

(deftest void-elements-are-not-closed
  (is (== "<br>" (to-markup/janet->markup @[:br])))
  (is (== `<img src="x.png">` (to-markup/janet->markup @[:img {:src "x.png"}]))))

(deftest empty-elements-round-trip
  (def janet @[:html @[:body]])
  (def markup (string (to-markup/janet->markup janet :add-doctype? false)))
  (is (== janet (to-janet/markup->janet markup))))

(deftest inline-top-level-nodes-are-not-separated
  (def janet [[:span "a"] [:span "b"]])
  (is (== "<span>a</span><span>b</span>"
          (to-markup/janet->markup janet :indent 0))))

(deftest block-top-level-nodes-are-separated
  (def janet [[:div "a"] [:div "b"]])
  (is (== "<div>a</div>\n<div>b</div>"
          (to-markup/janet->markup janet :indent 0))))

(deftest no-indent-adds-no-whitespace
  (def janet @[:div @[:p "a"] @[:p "b"]])
  (def actual (to-markup/janet->markup janet))
  (is (== "<div><p>a</p><p>b</p></div>" actual)))

(deftest compact-output-reproduces-the-source
  (def src
    (string "<!doctype html><html><head><title>T</title></head>"
            `<body><div></div><p>A <em>note</em>.</p><img src="x.png"><br>`
            "</body></html>"))
  (def janet (to-janet/markup->janet src))
  (is (== src (string (to-markup/janet->markup janet)))))

(run-tests!)
