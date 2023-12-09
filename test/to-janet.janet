(use testament)


(import ../lemongrass/to-janet :prefix "")


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
  (def actual (markup->janet html))
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
  (def actual (markup->janet xml))
  (def expect [[:?xml {:version "1.0" :encoding "UTF-8"}]
               [:rss {:version "2.0"}
                [:channel
                 [:title "Hello RSS!"]]
                [:item
                 [:description "Hello world!"]]]])
  (is (== expect actual)))


(run-tests!)
