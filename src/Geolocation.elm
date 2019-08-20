port module Geolocation exposing (changelocation, clearWatch, decodeError, decodeLocation, decodeWatchId, errorlocation, watch, watchid)

import Json.Decode as JD
import Json.Encode as JE
import Model exposing (..)
import Time as Time



-- TO JAVASCRIPT


port watch : () -> Cmd msg


port clearWatch : JE.Value -> Cmd msg



-- FROM JAVASCRIPT


port watchid : (JD.Value -> msg) -> Sub msg


port changelocation : (JD.Value -> msg) -> Sub msg


port errorlocation : (JD.Value -> msg) -> Sub msg


decodeError : JD.Decoder JSGeoError
decodeError =
    JD.map2 JSGeoError
        (JD.field "errcode" JD.string)
        (JD.field "message" JD.string)


decodeWatchId jsid =
    let
        wId =
            JD.decodeValue JD.int jsid
    in
    case wId of
        Ok id ->
            id

        _ ->
            0


decodeLocation : JD.Decoder Location
decodeLocation =
    let
        timeDecoder t =
            JD.succeed (Time.millisToPosix t)
    in
    JD.map8 Location
        (JD.field "longitude" JD.float)
        (JD.field "latitude" JD.float)
        (JD.field "accuracyPos" JD.float)
        (JD.field "altitude" (JD.maybe JD.float))
        (JD.field "accuracyAltitude" (JD.maybe JD.float))
        (JD.field "movingSpeed" (JD.maybe JD.float))
        (JD.field "movingDegrees" (JD.maybe JD.float))
        (JD.field "timestamp"
            (JD.int
                |> JD.andThen timeDecoder
            )
        )
