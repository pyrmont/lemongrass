(use /deps/testament/src/testament)


(import ../lib/to-janet :as lg)


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
  (def actual (lg/markup->janet html))
  (def expect [:html
               [:head
                [:title "Hello HTML!"]]
               [:body
                [:h1 "Hello world!"]]])
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
  (def actual (lg/markup->janet xml))
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
  (def actual (lg/markup->janet html))
  (def expect [:a {:href "http://example.com/" :rel "nofollow"} "Foo"])
  (is (== expect actual)))


(run-tests!)
