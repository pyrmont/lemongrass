(import ../deps/argy-bargy/argy-bargy :as argy)
(import ../init :as lg)


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
           "-------------------------------------------"]
   :info {:about "Convert from HTML/XML to Janet data structures."}})


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
      (def to-markup? (opts "reverse"))
      (def html? (= "html" (opts "format")))
      (def output (if to-markup?
                    (lg/janet->markup (eval-string input))
                    (lg/markup->janet input :html? html?)))
      (def o-path (opts "output"))
      (if (= :stdout o-path)
        (pp output)
        (spit o-path output)))))


(defn- main [& args] (run))
