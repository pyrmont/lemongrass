(use ../deps/testament)

(import ../lib/to-hiccup :as lg)

(deftest basic-html
  (def html
    `<html>
      <head>
        <title>Hello HTML!</title>
      </head>
      <body>
        <h1>Hello world!</h1>
      </body>
    </html>`)
  (def actual (lg/markup->hiccup html))
  (def expect [:html
               [:head
                [:title "Hello HTML!"]]
               [:body
                [:h1 "Hello world!"]]])
  (is (== expect actual)))

(deftest basic-html-with-spaces
  (def html
    `<html>
      <head>
        <title>Hello HTML!</title>
      </head>
      <body>
        <h1>Hello <em>to</em> <strong>the</strong> world!</h1>
      </body>
    </html>`)
  (def actual (lg/markup->hiccup html))
  (def expect [:html
               [:head
                [:title "Hello HTML!"]]
               [:body
                [:h1 "Hello " [:em "to"] " " [:strong "the"] " world!"]]])
  (is (== expect actual)))

(deftest basic-xml
  (def xml
    `<?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>Hello RSS!</title>
      </channel>
      <item>
        <description>Hello world!</description>
      </item>
    </rss>`)
  (def actual (lg/markup->hiccup xml))
  (def expect [[:?xml {:version "1.0" :encoding "UTF-8"}]
               [:rss {:version "2.0"}
                [:channel
                 [:title "Hello RSS!"]]
                [:item
                 [:description "Hello world!"]]]])
  (is (== expect actual)))

(deftest multiple-attrs
  (def html
    `<a href="http://example.com/" rel="nofollow">Foo</a>`)
  (def actual (lg/markup->hiccup html))
  (def expect [:a {:href "http://example.com/" :rel "nofollow"} "Foo"])
  (is (== expect actual)))

(deftest doctype
  (def html `<!doctype html><html><body></body></html>`)
  (def actual (lg/markup->hiccup html))
  (def expect [[:!doctype "html"]
               [:html
                [:body]]])
  (is (== expect actual)))

(deftest unparsable-input-reports-a-short-window
  (def html (string "<ok>fine</ok><" (string/repeat "x" 500)))
  (def [ok? err] (protect (lg/markup->hiccup html)))
  (is (false? ok?))
  (is (== `cannot parse around '</ok><xxxx'` err)))

(run-tests!)
