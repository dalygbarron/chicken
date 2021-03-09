(import kowari)

(def pngs (mapcat (fn [item] (if (string/has-suffix? ".png" item)
                               (string "sprites/" item)
                               []))
                  (os/dir "sprites")))
(def atlas (kowari/make-atlas 1024 1024 ;pngs))
(kowari/render-atlas-to-file atlas "assets/sprites.png")
(with [file (file/open "assets/sprites.csv" :w)]
  (kowari/each-atlas atlas
                     (fn [x y pic]
                       (file/write file (string/format "%s,%d,%d,%d,%d\n"
                                                       (pic :name)
                                                       x
                                                       y
                                                       (pic :width)
                                                       (pic :height))))))
