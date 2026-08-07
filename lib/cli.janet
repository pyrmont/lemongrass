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
                            :help    "Reverse the polarity and convert from Janet to markup."
                            :kind    :flag
                            :short   "r"}
           "-------------------------------------------"
           "--pretty"      {:default false
                            :help    "Pretty print the output over multiple lines."
                            :kind    :flag
                            :short   "p"}
           "--indent"      {:default 2
                            :help    "The <number> of spaces added for each level of nesting when pretty printing."
                            :kind    :single
                            :proxy   "number"
                            :short   "i"
                            :value   (at-least 0)}
           "--width"       {:default 80
                            :help    "The <number> of columns an element is fitted within when pretty printing to Janet."
                            :kind    :single
                            :proxy   "number"
                            :short   "w"
                            :value   (at-least 1)}
           "-------------------------------------------"]
   :info {:about "Convert from HTML/XML to Janet data structures."}})


(defn convert
  ```
  Converts a string of `input` and returns the result as a string

  By default a string of markup is converted to a Hiccup-style Janet data
  structure. If `to-markup?` is true, the conversion runs the other way and
  `input` is read as Janet source. `html?` selects the markup language and
  `pretty?` lays the output out over several lines rather than one.

  When the output is pretty printed, `indent` is the number of spaces (two by
  default) added for each level of nesting and `width` is the number of columns
  (80 by default) an element is fitted within before it is broken open. Only
  Janet output is fitted to a width, so `width` is ignored if `to-markup?` is
  true.
  ```
  [input &named to-markup? html? pretty? indent width]
  (default html? true)
  (default indent 2)
  (default width 80)
  (def tab (string/repeat " " indent))
  (string
    (if to-markup?
      (lg/janet->markup (eval-string input)
                        :format (if html? :html :xml)
                        :indent (when pretty? 0)
                        :tab tab)
      (lg/janet->source (lg/markup->janet input :html? html?)
                        :tab tab
                        # an unreachable width keeps the output on one line
                        :width (if pretty? width math/inf)))))


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
