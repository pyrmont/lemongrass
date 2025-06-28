(use ../deps/testament)


(import ../lib/to-markup :as lg)


(deftest basic-html
  (def janet
    @[:html
      @[:head
        @[:title "Hello HTML!"]]
      @[:body
        @[:h1 "Hello world!"]]])
  (def actual (lg/janet->markup janet :indent 0))
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
  (def actual (lg/janet->markup janet :format :xml :indent 0))
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



(run-tests!)
