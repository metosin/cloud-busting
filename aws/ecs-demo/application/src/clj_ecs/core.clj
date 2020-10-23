(ns clj-ecs.core
  (:require [ring.adapter.jetty :as jetty]
            [timbre-json-appender.core :as tas]
            [taoensso.timbre :as timbre]))

(defn handler [version {:keys [uri]}]
  (timbre/info :uri uri :git-sha version)
  {:status  200
   :headers {"Content-Type" "text/plain"}
   :body    (str "Hello World!"
                 (when version
                   (str " Running at " version)))})

(defn -main [& _]
  (tas/install)
  (jetty/run-jetty (partial handler (System/getenv "IMAGE_TAG"))
                   {:port (or (some-> (System/getenv "PORT")
                                      (Integer/parseInt))
                              4000)}))
