module View exposing (showView)

import Browser
import Browser.Dom
import Browser.Events
import Color exposing (Color)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import FormatNumber
import Geolocation
import Html.Attributes as Attr
import Json.Decode as JD
import Json.Encode as JE
import Material.Icons.Toggle exposing (..)
import Model exposing (..)
import Styles
import Svg exposing (Svg)
import Task exposing (Task)
import Time


showView model =
    let
        gpsOn : Bool
        gpsOn =
            if model.watchId == 0 then
                False

            else
                True
    in
    column [ centerX ]
        [ column
            [ padding 10
            , spacing 10
            , width fill
            ]
            [ showHeader
            , showTitle
            , showStartStopGPS gpsOn
            , showError model.error
            , showDistanceTitle
            , showDistanceBox model.myLocation
            , showSubtitle "Projektion"
            , showToggleProjection model.projection
            , showSubtitle "Koordinaten"
            , showCoords model
            , showSubtitle "Genauigkeit"
            , showAccuracy model
            , showSubtitle "Wo stehen Sie?"
            , showLinks model
            , showFooter
            ]
        ]


showSubtitle : String -> Element Msg
showSubtitle title =
    paragraph
        [ Font.bold
        , paddingEach
            { top = 10
            , right = 0
            , bottom = 0
            , left = 0
            }
        ]
        [ text title ]


showHeader : Element Msg
showHeader =
    row
        [ spacing 15 ]
        [ logo
        , el
            [ Font.size (scaled 1)
            , Font.extraBold
            , width (fillPortion 4)
            ]
            (text """Kanton Zürich
Baudirektion
Amt für Raumentwicklung""")
        ]


logo : Element Msg
logo =
    image [ width (fillPortion 1) ] { src = "./img/loewe.png", description = "Logo Kt.ZH" }


showTitle : Element Msg
showTitle =
    el
        [ paddingEach
            { top = 0
            , right = 0
            , bottom = 10
            , left = 0
            }
        ]
        (paragraph
            [ Font.center
            , Font.color colorZhBlue
            , Font.heavy
            , Font.size (scaled 3)
            ]
            [ text "Kontrollpunkt für mobile Geräte"
            ]
        )


showStartStopGPS : Bool -> Element Msg
showStartStopGPS gpsOn =
    let
        showCheckBox =
            if gpsOn then
                el [] (Element.html (radio_button_checked iconColorZhBlue (scaled 1)))

            else
                el [] (Element.html (radio_button_unchecked iconColorZhBlue (scaled 1)))

        showText =
            if gpsOn then
                "Messungen stoppen "

            else
                "Messungen starten"
    in
    el
        [ Background.color (rgb255 212 212 212)
        , Border.color colorZhBlue
        , Border.width 1
        , Border.rounded 10
        , centerX
        , Font.size (scaled 1)
        , onClick ToggleMeasuring
        ]
        (Element.row
            [ width fill
            , paddingXY 10 10
            , Element.spacing 10
            ]
            [ el [ width (px (scaled 1)) ] showCheckBox
            , el [] (text showText)
            ]
        )


showError : String -> Element Msg
showError error =
    if String.length error > 1 then
        el
            [ centerX
            , paddingEach
                { top = 10
                , right = 0
                , bottom = 0
                , left = 0
                }
            ]
            (paragraph
                [ Font.center
                , Font.color (rgb255 255 0 0)
                , Font.heavy
                , Font.size (scaled 1)
                ]
                [ text error
                ]
            )

    else
        none


showDistanceTitle : Element Msg
showDistanceTitle =
    paragraph
        [ Font.center
        , paddingEach
            { top = 10
            , right = 0
            , bottom = 10
            , left = 0
            }
        ]
        [ text "Abweichung vom Kontrollpunkt"
        ]


showDistanceBox : Maybe MyLocation -> Element Msg
showDistanceBox myLocation =
    let
        getDistance =
            case myLocation of
                Just loc ->
                    FormatNumber.format swissNumbers loc.distance ++ " m"

                Nothing ->
                    "?"
    in
    el
        [ paddingXY 35 10

        --, Background.color (rgb255 212 212 212)
        , Border.color colorZhBlue
        , Border.width 5

        --, Font.center
        , centerX
        , Font.heavy
        , Font.size (scaled 4)

        --, onClick ToggleMeasuring
        ]
        (text getDistance)


showToggleProjection : Projection -> Element Msg
showToggleProjection proj =
    column [ width fill ]
        [ showProjLabel
        , showProjSwitch proj
        ]


showProjLabel : Element Msg
showProjLabel =
    row
        [ width fill
        , spacing 20
        , Font.size (scaled -2)
        ]
        [ paragraph
            [ width (fillPortion 3)
            , Font.alignRight
            ]
            [ text """Schweizer Landeskoordinaten""" ]
        , el [ width (fillPortion 1) ] (text "")
        , paragraph
            [ width (fillPortion 3)
            ]
            [ text """Globales geodätisches Referenzsystem""" ]
        ]


showProjSwitch : Projection -> Element Msg
showProjSwitch proj =
    let
        altImage =
            if proj == WGS84 then
                { src = "./img/wgs84.svg", description = "WGS84" }

            else
                { src = "./img/lv95.svg", description = "LV95" }
    in
    row
        [ width fill
        , spacing 20

        --, Font.size (scaled -1)
        ]
        [ paragraph
            [ width (fillPortion 3)
            , Font.alignRight
            , Font.color colorZhBlue
            , Font.extraBold
            ]
            [ text "LV 95" ]
        , el [ width (fillPortion 1) ]
            (image
                [ onClick (ToggleProjection proj)
                , width (fillPortion 1)
                ]
                altImage
            )
        , paragraph
            [ width (fillPortion 3)
            , Font.color colorZhBlue
            , Font.extraBold
            ]
            [ text "WGS 84" ]
        ]


showAccuracy : Model -> Element Msg
showAccuracy model =
    let
        timeString =
            case model.myLocation of
                Just loc ->
                    toLocalTimeString model.timezone loc.timestamp

                Nothing ->
                    ""

        accString =
            case model.myLocation of
                Just loc ->
                    String.fromFloat loc.accuracyPos ++ " m"

                Nothing ->
                    ""
    in
    column
        [ width fill ]
        [ row
            [ width fill
            , spacing 20
            , Font.size (scaled -1)
            ]
            [ column []
                [ text "Zeit der letzten Messung"
                , text "Anzahl Messungen"
                , text "Lagegenauigkeit Gerät"
                ]
            , column []
                [ text timeString
                , text (String.fromInt (List.length model.measurements))
                , text accString
                ]
            ]
        ]


showLinks : Model -> Element Msg
showLinks model =
    let
        rowConfig1 =
            { text1 = ""
            , url = "https://maps.zh.ch/?" ++ gbParams model
            , label = "Kartenansicht"
            , text2 = " Ihres Standortes"
            }

        rowConfig2 =
            { text1 = "Erfahren Sie "
            , url = "https://are.zh.ch/kontrollpunkt"
            , label = "hier"
            , text2 = " mehr über den Kontrollpunkt"

            --, text2 = " mehr über die Standortgenauigkeit Ihres mobilen Gerätes."
            }

        buildRow cfg =
            row
                [ width fill
                , spacing 10
                , Font.size (scaled -1)
                ]
                [ text "-"
                , paragraph []
                    [ text cfg.text1
                    , link
                        [ htmlAttribute (Attr.target "_blank")
                        , Font.color colorZhBlue
                        , Font.underline
                        ]
                        { url = cfg.url
                        , label = text cfg.label
                        }
                    , text cfg.text2
                    ]
                ]
    in
    column
        [ width fill ]
        [ buildRow rowConfig1
        , buildRow rowConfig2
        ]


gbParams model =
    let
        refPos =
            Tuple.second model.refLocation

        pos =
            case model.myLocation of
                Just loc ->
                    buildPos loc

                Nothing ->
                    buildPos refPos

        buildPos myloc =
            { refOst = refPos.east
            , refNord = refPos.north
            , locOst = myloc.east
            , locNord = myloc.north
            }
    in
    "topic=OrthoZH"
        ++ "&scale=1000"
        ++ "&x="
        ++ String.fromFloat pos.refOst
        ++ "&y="
        ++ String.fromFloat pos.refNord
        ++ "&srid=2056"
        ++ "&redlining=GEOMETRYCOLLECTION("
        ++ "POINT("
        ++ String.fromFloat pos.refOst
        ++ "%20"
        ++ String.fromFloat pos.refNord
        ++ ")%2C"
        ++ "POINT("
        ++ String.fromFloat (pos.locOst + 4)
        ++ "%20"
        ++ String.fromFloat pos.locNord
        ++ ")%2C"
        ++ "POINT("
        ++ String.fromFloat (pos.refOst + 4)
        ++ "%20"
        ++ String.fromFloat pos.refNord
        ++ ")%2C"
        ++ "POINT("
        ++ String.fromFloat pos.locOst
        ++ "%20"
        ++ String.fromFloat pos.locNord
        ++ "))%2B%257B%22text%22%3A%257B%221%22%3A%22Standortangabe%20Navigationsger%C3%A4t%22%2C"
        ++ "%222%22%3A%22Kontrollpunkt%22%257D%257D"


showFooter : Element Msg
showFooter =
    el
        [ centerX
        , paddingEach
            { top = 30
            , right = 0
            , bottom = 10
            , left = 0
            }
        ]
        (paragraph
            [ Font.center
            , Font.color colorZhBlue

            -- , Font.heavy
            , Font.size (scaled 1)
            ]
            [ text "maps.zh.ch/kp1"
            ]
        )



{-
   toLocalDateString : Time.Zone -> Time.Posix -> String
   toLocalDateString zone time =
       String.fromInt (Time.toDay zone time)
           ++ "."
           -- ++ String.fromInt (Time.toMonth zone time)
           ++ "."
           ++ String.fromInt (Time.toYear zone time)
-}


toLocalTimeString : Time.Zone -> Time.Posix -> String
toLocalTimeString zone time =
    String.right 2 ("00" ++ String.fromInt (Time.toHour zone time))
        ++ ":"
        ++ String.right 2 ("00" ++ String.fromInt (Time.toMinute zone time))
        ++ ":"
        ++ String.right 2 ("00" ++ String.fromInt (Time.toSecond zone time))


showCoords : Model -> Element msg
showCoords model =
    let
        refPos =
            Tuple.second model.refLocation

        getLocEast =
            case model.myLocation of
                Just loc ->
                    FormatNumber.format swissNumbers loc.east

                Nothing ->
                    ""

        getLocNorth =
            case model.myLocation of
                Just loc ->
                    FormatNumber.format swissNumbers loc.north

                Nothing ->
                    ""

        getLocLon =
            case model.myLocation of
                Just loc ->
                    -- FormatNumber.format wgsNumbers loc.longitude
                    buildDegMinSec loc.longitude

                Nothing ->
                    ""

        getLocLat =
            case model.myLocation of
                Just loc ->
                    -- FormatNumber.format wgsNumbers loc.latitude
                    buildDegMinSec loc.latitude

                Nothing ->
                    ""

        pos =
            if model.projection == LV95 then
                { refOst = FormatNumber.format swissNumbers refPos.east
                , refNord = FormatNumber.format swissNumbers refPos.north
                , locOst = getLocEast
                , locNord = getLocNorth
                }

            else
                { -- refOst = FormatNumber.format wgsNumbers refPos.longitude
                  refOst = buildDegMinSec refPos.longitude

                -- , refNord = FormatNumber.format wgsNumbers refPos.latitude
                , refNord = buildDegMinSec refPos.latitude
                , locOst = getLocLon
                , locNord = getLocLat
                }
    in
    row
        [ width fill
        , spacing 10
        , Font.size (scaled -1)
        ]
        [ column []
            [ text "Kontrollpunkt:"
            , text "Gerät:"
            ]
        , column []
            [ text ("E " ++ pos.refOst)
            , text ("E " ++ pos.locOst)
            ]
        , column []
            [ text ("N " ++ pos.refNord)
            , text ("N " ++ pos.locNord)
            ]
        ]


scaled x =
    round (modular 16 1.25 x)


colorZhBlue : Element.Color
colorZhBlue =
    -- #1396ed
    rgb255 19 150 237


iconColorZhBlue : Color.Color
iconColorZhBlue =
    Color.rgb255 19 150 237


swissNumbers =
    { decimals = 2
    , thousandSeparator = "'"
    , decimalSeparator = "."
    , negativePrefix = "-"
    , negativeSuffix = ""
    , positivePrefix = ""
    , positiveSuffix = ""
    }


wgsNumbers =
    { decimals = 6
    , thousandSeparator = "'"
    , decimalSeparator = "."
    , negativePrefix = "-"
    , negativeSuffix = ""
    , positivePrefix = ""
    , positiveSuffix = ""
    }


secNumbers =
    { decimals = 2
    , thousandSeparator = "'"
    , decimalSeparator = "."
    , negativePrefix = "-"
    , negativeSuffix = ""
    , positivePrefix = ""
    , positiveSuffix = ""
    }


buildDegMinSec : Float -> String
buildDegMinSec decDegree =
    let
        grad =
            truncate decDegree

        min =
            truncate (decDegree * 60 - toFloat (grad * 60))

        sec =
            decDegree * 3600 - toFloat (grad * 3600) - toFloat (min * 60)
    in
    String.fromInt grad
        ++ "° "
        ++ String.right 2 ("0" ++ String.fromInt min)
        ++ "' "
        ++ String.right 5 ("0" ++ FormatNumber.format secNumbers sec)
        ++ "\""



-- ++ String.fromFloat decDegree
{-
   {-| -}
   radio_button_checked : Color -> Int -> Svg msg
   radio_button_checked =
       icon "0 0 48 48" [ Svg.path [ d "M24 14c-5.52 0-10 4.48-10 10s4.48 10 10 10 10-4.48 10-10-4.48-10-10-10zm0-10C12.95 4 4 12.95 4 24s8.95 20 20 20 20-8.95 20-20S35.05 4 24 4zm0 36c-8.84 0-16-7.16-16-16S15.16 8 24 8s16 7.16 16 16-7.16 16-16 16z" ] [] ]


   {-| -}
   radio_button_unchecked : Color -> Int -> Svg msg
   radio_button_unchecked =
       icon "0 0 48 48" [ Svg.path [ d "M24 4C12.95 4 4 12.95 4 24s8.95 20 20 20 20-8.95 20-20S35.05 4 24 4zm0 36c-8.84 0-16-7.16-16-16S15.16 8 24 8s16 7.16 16 16-7.16 16-16 16z" ] [] ]
-}
