(declare-project
  :name "Lemongrass"
  :description "A converter in Janet for markup languages like HTML and XML"
  :author "Michael Camilleri"
  :license "MIT"
  :url "https://github.com/pyrmont/lemongrass"
  :repo "git+https://github.com/pyrmont/lemongrass"
  :dependencies []
  :dev-dependencies ["https://github.com/pyrmont/testament"])

(declare-source
  :source ["lemongrass"])

(task "dev-deps" []
  (if-let [deps ((dyn :project) :dependencies)]
    (each dep deps
      (bundle-install dep))
    (do
      (print "no dependencies found")
      (flush)))
  (if-let [deps ((dyn :project) :dev-dependencies)]
    (each dep deps
      (bundle-install dep))
    (do
      (print "no dev-dependencies found")
      (flush))))
