(ns clj-ecs.core
  (:require [ring.adapter.jetty :as jetty]
            [timbre-json-appender.core :as tas]
            [taoensso.timbre :as timbre]
            [hikari-cp.core :as hikari]
            [next.jdbc :as jdbc]))

(defn handler [db version {:keys [uri]}]
  (timbre/info :uri uri :version version)
  {:status  200
   :headers {"Content-Type" "text/plain"}
   :body    (str "Hello World!"
                 (when version
                   (str " Running at " version "."))
                 (format " Database has %d connections" (:count (jdbc/execute-one! db ["select count(*) as count from pg_stat_activity"]))))})

(defn -main [& _]
  (tas/install)
  (let [datasource (hikari/make-datasource {:username      (System/getenv "DB_USER")
                                            :password      (System/getenv "DB_PASSWORD")
                                            :database-name (System/getenv "DB_NAME")
                                            :server-name   (System/getenv "DB_HOST")
                                            :port-number   (Integer/parseInt (System/getenv "DB_PORT"))
                                            :pool-name     "db-pool"
                                            :adapter       "postgresql"})]
    (jetty/run-jetty (partial handler datasource (System/getenv "IMAGE_TAG"))
                     {:port (or (some-> (System/getenv "PORT")
                                        (Integer/parseInt))
                                4000)})))
