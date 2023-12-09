(defn- key-name [x &opt c]
  (keyword c (string/ascii-lower x)))


(defn- key-slash [x]
  (key-name x "/"))


(defn- key-qmark [x]
  (key-name x "?"))


(defn- key-emark [x]
  (key-name x "!"))


(defn- tag-attrs [& x]
  (apply table x))


(def- g
  (peg/compile ~{:main (* (+ :tag-open :tag-close :cmnt :decl :inst :text) ($))
                 :name '(* :a (any (+ :w (set ":-"))))
                 :tag-open (group (* "<"
                                     :s*
                                     (cmt :name ,key-name)
                                     (any (cmt (* :s+ :tag-attrs) ,tag-attrs))
                                     :s*
                                     (? (/ '"/" true))
                                     ">"))
                 :tag-close (* "</"
                               :s*
                               (cmt :name ,key-slash)
                               :s*
                               ">")
                 :tag-attrs (* (cmt :name ,key-name)
                               "="
                               (+ (* `"` '(to `"`) `"`)
                                  (* "'" '(to "'") "'")
                                  (some (+ :w (set "/:_.")))))
                 :cmnt (* "<!--" (thru "-->") (constant nil))
                 :decl (group (* "<!"
                                 (cmt :name ,key-emark)
                                 :s*
                                 '(to ">")
                                 ">"))
                 :inst (group (* "<?"
                                 (cmt :name ,key-qmark)
                                 (? (cmt (any (* :s+ :tag-attrs)) ,tag-attrs))
                                 "?>"))
                 :text '(to (+ "<" ">" -1))
                 }))


(def void-elements
  [:area :base :basefont :bgsound :br :col :command :embed :frame :hr :image
   :img :input :keygen :link :meta :param :source :track :wbr])


(defn- void?
  ```
  Checks if element is void

  Checks if the element is a void element, either because it's marked as
  such by the final item in the element or because `html?` is true and the
  element's name matches one of the defined void elements.

  This function mutates the element to remove the void marker (if present).
  ```
  [el html?]
  (def end (dec (length el)))
  (if (true? (get el end))
    (array/remove el end)
    (let [name (first el)]
      (or (has-value? [33 63] (first name))
          (and html? (has-value? void-elements (first el)))))))


(defn markup->janet
  ```
  Converts a string of markup to a Janet data structure

  This function takes a string of markup and converts it to a Hiccup-style
  data structure in Janet. By default, the string is assumed to be HTML. If
  not, `:html?` can be set to false.
  ```
  [s &keys {:html? html?}]
  (default html? true)
  (def res @[])
  (def path @[])
  (var curr-node res)
  (var curr-name nil)
  (var pos 0)
  (while (< pos (length s))
    (def [val adv] (peg/match g (string/slice s pos)))
    (when (zero? adv)
      (def start (if (> pos 5) (- pos 5) 0))
      (def end (if (< (length s) (+ pos 5)) (+ pos 5) -1))
      (error (string "cannot parse around '" (string/slice s start end) "'")))
    (+= pos adv)
    (case (type val)
      :string
      (unless (string/check-set " \n\r\t\v" val)
        (array/push curr-node val))

      :keyword
      (let [name (keyword/slice val 1)]
        (if (= curr-name name)
          (do
            (array/pop path)
            (set curr-node (get-in res path))
            (set curr-name (first curr-node)))
          (error (string "closing tag </" name "> doesn't match opening tag <" curr-name ">"))))

      :array
      (let [name (first val)]
        (array/push curr-node val)
        (unless (void? val html?)
          (array/push path (dec (length curr-node)))
          (set curr-name name)
          (set curr-node val)))

      :nil
      nil))
  (if (one? (length res))
    (first res)
    res))
