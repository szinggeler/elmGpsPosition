#!/bin/sh

# Aufruf: ./optimize.sh src/Main.elm and get out ./build/gpsposition.js and ./build/gpsposition.min.js
# Infos : https://elm-lang.org/0.19.0/optimize

# js="elm.js"
# min="elm.min.js"
set -e

js="./build/gpsposition.js"
min="./build/gpsposition.min.js"

elm make --optimize --output=$js $@

uglifyjs $js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=$min

echo "Initial size: $(cat $js | wc -c) bytes  ($js)"
echo "Minified size:$(cat $min | wc -c) bytes  ($min)"
echo "Gzipped size: $(cat $min | gzip -c | wc -c) bytes"