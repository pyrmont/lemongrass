(use ../deps/testament)

(import ../lib/to-source :as lg)

(deftest no-indent-gives-one-line
  (def janet @[:div @[:ul @[:li "One"] @[:li "Two"]]])
  (is (== `@[:div @[:ul @[:li "One"] @[:li "Two"]]]`
          (lg/hiccup->source janet)))
  # the width has nothing to fit when everything is on one line
  (is (== `@[:div @[:ul @[:li "One"] @[:li "Two"]]]`
          (lg/hiccup->source janet :width 10))))

(deftest fits-on-one-line
  (def janet @[:p "Hello " @[:em "world"] "!"])
  (def actual (lg/hiccup->source janet :indent 2))
  (is (== `@[:p "Hello " @[:em "world"] "!"]` actual)))

(deftest breaks-when-too-wide
  (def janet @[:main @[:div @[:h1 "Bottom Navbar example"] @[:p "Foo."]]])
  (def actual (lg/hiccup->source janet :indent 2 :width 40))
  (def expect
    `@[:main
      @[:div
        @[:h1 "Bottom Navbar example"]
        @[:p "Foo."]]]`)
  (is (== expect actual)))

(deftest attributes-stay-on-opening-line
  (def janet @[:div {:class "wrapper"} @[:p "One"] @[:p "Two"]])
  (def actual (lg/hiccup->source janet :indent 2 :width 30))
  (def expect
    `@[:div {:class "wrapper"}
      @[:p "One"]
      @[:p "Two"]]`)
  (is (== expect actual)))

(deftest custom-indent
  (def janet @[:main @[:p "One"] @[:p "Two"]])
  (def actual (lg/hiccup->source janet :width 20 :indent 4))
  (def expect
    `@[:main
        @[:p "One"]
        @[:p "Two"]]`)
  (is (== expect actual)))

(deftest custom-step
  (def janet @[:main @[:p "One"] @[:p "Two"]])
  (def actual (lg/hiccup->source janet :width 20 :indent 1 :step "\t"))
  (is (== "@[:main\n\t@[:p \"One\"]\n\t@[:p \"Two\"]]" actual)))

(deftest an-inset-shifts-every-line
  (def janet @[:main @[:p "One"] @[:p "Two"]])
  (def actual (lg/hiccup->source janet :indent 2 :width 30 :inset "    "))
  (def expect
    (string `    @[:main` "\n"
            `      @[:p "One"]` "\n"
            `      @[:p "Two"]]`))
  (is (== expect actual)))

(deftest an-inset-counts-against-the-width
  (def janet @[:p "One"])
  # the value fits within 20 columns on its own but not once inset by 10
  (is (== `@[:p "One"]` (lg/hiccup->source janet :indent 2 :width 20)))
  (is (== (string "          @[:p\n            \"One\"]")
          (lg/hiccup->source janet :indent 2 :width 20 :inset "          "))))

(deftest a-retired-tab-is-rejected
  (def janet @[:main @[:p "One"]])
  (is (thrown? (lg/hiccup->source janet :tab "    "))))

(deftest tuples-keep-their-delimiters
  (def janet [:p "One" "Two"])
  (def actual (lg/hiccup->source janet :indent 2 :width 10))
  (def expect
    `[:p
      "One"
      "Two"]`)
  (is (== expect actual)))

(deftest block-children-are-always-broken-open
  (def janet @[:ul @[:li "One"] @[:li "Two"]])
  (def expect
    `@[:ul
      @[:li "One"]
      @[:li "Two"]]`)
  (is (== expect (lg/hiccup->source janet :indent 2))))

(deftest inline-children-are-kept-together
  (def janet @[:p "A " @[:em "short"] " note."])
  (is (== `@[:p "A " @[:em "short"] " note."]`
          (lg/hiccup->source janet :indent 2))))

(deftest unknown-elements-are-treated-as-inline
  (def janet @[:config @[:host "localhost"] @[:port "8080"]])
  (is (== `@[:config @[:host "localhost"] @[:port "8080"]]`
          (lg/hiccup->source janet :indent 2))))

(deftest an-unreachable-width-gives-the-compact-form
  (def janet @[:div @[:ul @[:li "One"] @[:li "Two"]]])
  (is (== `@[:div @[:ul @[:li "One"] @[:li "Two"]]]`
          (lg/hiccup->source janet :indent 2 :width math/inf))))

(deftest source-evaluates-back-to-the-data-structure
  (def janet
    @[:html
      @[:head @[:title "Hello HTML!"]]
      @[:body
        @[:div {:class "wrapper"}
          @[:h1 "Hello world!"]
          @[:p "Hello " @[:em "there"] " friend."]]]])
  (def actual (eval-string (lg/hiccup->source janet :indent 2 :width 40)))
  (is (== janet actual)))

(run-tests!)
