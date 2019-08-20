module Main exposing (init, main)

import Browser
import Browser.Dom
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import FormatNumber
import Geolocation
import Json.Decode as JD
import Json.Encode as JE
import Model exposing (..)
import Styles
import Task exposing (Task)
import Time
import View



{-
   main :
     Browser.document :
       { init : flags -> ( model, Cmd msg )
       , view : model -> Document msg
       , update : msg -> model -> ( model, Cmd msg )
       , subscriptions : model -> Sub msg
       }
       -> Program flags model msg
-}


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


init : () -> ( Model, Cmd Msg )
init refLocation =
    ( iniModel, Task.perform GetTimeZone Time.here )



-- VIEW


view model =
    Element.layout []
        (column
            ([ width fill ]
                ++ Styles.unselectable
            )
            [ View.showView model ]
        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Geolocation.changelocation LocationChange
        , Geolocation.errorlocation LocationError
        , Geolocation.watchid WatchGeolocation
        ]



-- UPDATE MODEL


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        GetTimeZone zone ->
            ( { model | timezone = zone }, Cmd.none )

        ToggleProjection proj ->
            if proj == WGS84 then
                ( { model | projection = LV95 }, Cmd.none )

            else
                ( { model | projection = WGS84 }, Cmd.none )

        ToggleMeasuring ->
            if model.watchId == 0 then
                ( { model | measurements = [] }, Geolocation.watch () )

            else
                ( { model | watchId = 0 }, Geolocation.clearWatch (JE.int model.watchId) )

        LocationChange jslocation ->
            let
                loc : Result JD.Error Location
                loc =
                    JD.decodeValue Geolocation.decodeLocation jslocation

                buildMyLoc : Location -> MyLocation
                buildMyLoc resultLoc =
                    { -- Device location
                      longitude = resultLoc.longitude
                    , latitude = resultLoc.latitude
                    , accuracyPos = resultLoc.accuracyPos
                    , altitude = resultLoc.altitude
                    , accuracyAltitude = resultLoc.accuracyAltitude
                    , movingSpeed = resultLoc.movingSpeed
                    , movingDegrees = resultLoc.movingDegrees
                    , timestamp = resultLoc.timestamp

                    -- LV95
                    , east = 0
                    , north = 0
                    , height = Nothing

                    -- Reference
                    , locationKey = ""
                    , distance = 0
                    }

                newModel : Model
                newModel =
                    case loc of
                        Ok geoloc ->
                            { model
                                | myLocation = Just (wgsToMyLocation model geoloc)
                                , measurements = geoloc :: model.measurements
                                , error = ""

                                --, error = "geoloc: " ++ String.fromFloat geoloc.longitude
                            }

                        Err fehler ->
                            { model
                                | error = "Fehler... " ++ JD.errorToString fehler
                            }
            in
            ( newModel, Cmd.none )

        LocationError jserror ->
            let
                err =
                    JD.decodeValue Geolocation.decodeError jserror

                newModel =
                    case err of
                        Ok error ->
                            { model
                                | error = "Fehler... " ++ error.message
                            }

                        Err fehler ->
                            { model
                                | error = "Fehler... " ++ JD.errorToString fehler
                            }
            in
            ( newModel, Cmd.none )

        WatchGeolocation jswatchid ->
            ( { model | watchId = Geolocation.decodeWatchId jswatchid }, Cmd.none )



-- HELPERS FOR UPDATE


wgsToMyLocation : Model -> Location -> MyLocation
wgsToMyLocation model location =
    let
        φ =
            (location.latitude * 3600 - 169028.66) / 10000

        λ =
            (location.longitude * 3600 - 26782.5) / 10000

        e =
            2600072.37
                + (211455.93 * λ)
                - (10938.51 * λ * φ)
                - (0.36 * λ * φ ^ 2)
                - (44.54 * λ ^ 3)

        n =
            1200147.07
                + (308807.95 * φ)
                + (3745.25 * λ ^ 2)
                + (76.63 * φ ^ 2)
                - (194.56 * λ ^ 2 * φ)
                + (119.79 * φ ^ 3)

        alti =
            case location.altitude of
                Just a ->
                    Just (toFloat (round (a * 100)) / 100)

                Nothing ->
                    Nothing

        altiAcc =
            case location.accuracyAltitude of
                Just a ->
                    Just (toFloat (round (a * 100)) / 100)

                Nothing ->
                    Nothing

        h =
            case alti of
                Just a ->
                    Just
                        (toFloat
                            (round
                                (((a - 49.55)
                                    + (2.73 * λ)
                                    + (6.94 * φ)
                                 )
                                    * 100
                                )
                            )
                            / 100
                        )

                Nothing ->
                    Nothing

        movSpeed =
            case location.movingSpeed of
                Just m ->
                    Just (toFloat (round (m * 3.6)))

                Nothing ->
                    Nothing

        movDegree =
            case location.movingDegrees of
                Just m ->
                    Just (toFloat (round m))

                Nothing ->
                    Nothing
    in
    { longitude = runden location.longitude 1000000
    , latitude = runden location.latitude 1000000
    , accuracyPos = runden location.accuracyPos 100
    , altitude = alti
    , accuracyAltitude = altiAcc
    , movingSpeed = movSpeed
    , movingDegrees = movDegree
    , east = runden e 100
    , north = runden n 100
    , height = h
    , locationKey = Tuple.first model.refLocation
    , distance = distanceToRef e n model.refLocation
    , timestamp = location.timestamp
    }


runden : Float -> Float -> Float
runden zahl factor =
    toFloat (round (zahl * factor)) / factor


distanceToRef : Float -> Float -> ( String, Position ) -> Float
distanceToRef east north refLoc =
    let
        ref =
            Tuple.second refLoc

        dx =
            east - ref.east

        dy =
            north - ref.north
    in
    runden (sqrt (dx * dx + dy * dy)) 10
