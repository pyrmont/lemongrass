(use ../deps/testament)

(import ../lib/to-source :as lg)

(deftest fits-on-one-line
  (def janet @[:p "Hello " @[:em "world"] "!"])
  (def actual (lg/janet->source janet))
  (is (== `@[:p "Hello " @[:em "world"] "!"]` actual)))

(deftest breaks-when-too-wide
  (def janet @[:main @[:div @[:h1 "Bottom Navbar example"] @[:p "Foo."]]])
  (def actual (lg/janet->source janet :width 40))
  (def expect
    `@[:main
      @[:div
        @[:h1 "Bottom Navbar example"]
        @[:p "Foo."]]]`)
  (is (== expect actual)))

(deftest attributes-stay-on-opening-line
  (def janet @[:div {:class "wrapper"} @[:p "One"] @[:p "Two"]])
  (def actual (lg/janet->source janet :width 30))
  (def expect
    `@[:div {:class "wrapper"}
      @[:p "One"]
      @[:p "Two"]]`)
  (is (== expect actual)))

(deftest custom-tab
  (def janet @[:main @[:p "One"] @[:p "Two"]])
  (def actual (lg/janet->source janet :width 20 :tab "    "))
  (def expect
    `@[:main
        @[:p "One"]
        @[:p "Two"]]`)
  (is (== expect actual)))

(deftest tuples-keep-their-delimiters
  (def janet [:p "One" "Two"])
  (def actual (lg/janet->source janet :width 10))
  (def expect
    `[:p
      "One"
      "Two"]`)
  (is (== expect actual)))

(deftest source-evaluates-back-to-the-data-structure
  (def janet
    @[:html
      @[:head @[:title "Hello HTML!"]]
      @[:body
        @[:div {:class "wrapper"}
          @[:h1 "Hello world!"]
          @[:p "Hello " @[:em "there"] " friend."]]]])
  (def actual (eval-string (lg/janet->source janet :width 40)))
  (is (== janet actual)))

(run-tests!)
