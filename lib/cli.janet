(import ../deps/argy-bargy/argy-bargy :as argy)
(import ../init :as lg)


(defn- at-least
  ```
  Returns a converter for an integer no smaller than `min`
  ```
  [min]
  (fn [x]
    (let [[ok? n] (protect (scan-number x))]
      (when (and ok? (int? n) (<= min n)) n))))


(def config
  ```
  The configuration for Argy-Bargy
  ```
  {:rules [:input          {:default :stdin
                            :help    "The <path> for the input file."}
           "--format"      {:default "html"
                            :help    "The <format> of the markup, either html or xml."
                            :kind    :single
                            :proxy   "format"
                            :short   "f"}
           "--output"      {:default :stdout
                            :help    "The <path> for the output file."
                            :kind    :single
                            :proxy   "path"
                            :short   "o"}
           "--reverse"     {:default false
                            :help    "Reverse the polarity and convert from Hiccup to markup."
                            :kind    :flag
                            :short   "r"}
           "-------------------------------------------"
           "--pretty"      {:default false
                            :help    "Pretty print the output over multiple lines."
                            :kind    :flag
                            :short   "p"}
           # neither of these carries a `:default`, since a default is filled
           # in whether or not the option is given and would leave no way to
           # tell that the output has been asked to be pretty printed
           "--indent"      {:help    "The <number> of spaces added for each level of nesting. Implies --pretty. (Default: 2)"
                            :kind    :single
                            :proxy   "number"
                            :short   "i"
                            :value   (at-least 0)}
           "--width"       {:help    "The <number> of columns an element is fitted within when pretty printing Hiccup. Implies --pretty. (Default: 80)"
                            :kind    :single
                            :proxy   "number"
                            :short   "w"
                            :value   (at-least 1)}
           "-------------------------------------------"]
   :info {:about "Convert from HTML/XML to Hiccup data structures."}})


(defn convert
  ```
  Converts a string of `input` and returns the result as a string

  By default a string of markup is converted to a Hiccup data structure. If
  `to-markup?` is true, the conversion runs the other way and `input` is read
  as the Janet source of a Hiccup data structure. `html?` selects the markup
  language.

  The output is laid out over several lines if `pretty?` is true or if either
  of `indent` and `width` is given, and is otherwise put on one line. `indent`
  is the number of spaces (two by default) added for each level of nesting and
  `width` is the number of columns (80 by default) an element is fitted within
  before it is broken open. Only Hiccup output is fitted to a width, so `width`
  is ignored if `to-markup?` is true.
  ```
  [input &named to-markup? html? pretty? indent width]
  (default html? true)
  # asking for either of the measurements is a way of asking for the output to
  # be laid out, so neither is ignored when it is given on its own
  (def laid-out? (or (truthy? pretty?) (truthy? indent) (truthy? width)))
  (def indent (when laid-out? (or indent 2)))
  (def width (or width 80))
  (string
    # in either direction a nil indent keeps the output on one line
    (if to-markup?
      (lg/hiccup->markup (eval-string input)
                         :format (if html? :html :xml)
                         :indent indent)
      (lg/hiccup->source (lg/markup->hiccup input :html? html?)
                         :indent indent
                         :width width))))


(defn run []
  (def parsed (argy/parse-args "lg" config))
  (def err (parsed :err))
  (def help (parsed :help))

  (cond
    (not (empty? help))
    (do
      (prin help)
      (os/exit (if (get-in parsed [:opts "help"]) 0 1)))

    (not (empty? err))
    (do
      (eprin err)
      (os/exit 1))

    (do
      (def opts (parsed :opts))
      (def params (parsed :params))
      (def i-path (params :input))
      (def input (if (= :stdin i-path)
                   (file/read stdin :all)
                   (slurp i-path)))
      (def output (convert input
                           :to-markup? (opts "reverse")
                           :html? (= "html" (opts "format"))
                           :pretty? (opts "pretty")
                           :indent (opts "indent")
                           :width (opts "width")))
      (def o-path (opts "output"))
      (if (= :stdout o-path)
        (print output)
        (spit o-path output)))))


(defn main [&] (run))
