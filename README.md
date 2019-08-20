# elmGpsPosition
Measure distance to control point (Landesmuseum)




##Entwicklung:
    > elm reactor src/Main.elm

    oder besser mit
    > elm-live src/Main.elm -- --output=build/gpspositionDebug.js --debug

    > starten mit http://localhost:8000/gpspositionDebug.html

##Produktiv-Version erstellen:
    > ./optimize.sh src/Main.elm

    =>  Files werden erstellt:
    * ./build/gpsposition.js
    * ./build/gpsposition.min.js
