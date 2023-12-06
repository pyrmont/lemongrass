(use testament)


(import ../lemongrass :prefix "")


(deftest convert-basic-html
  (def html
    `<html>
      <head>
        <title>Hello world!</title>
      </head>
      <body>
        <h1>Hello world!</h1>
      </body>
    </html>`)
  (def actual (markup->janet html))
  (def expect [:html [:head [:title "Hello world!"]] [:body [:h1 "Hello world!"]]])
  (is (== expect actual)))


(run-tests!)
