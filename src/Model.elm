module Model exposing (GeoLocState(..), JSGeoError, Location, Model, Msg(..), MyLocation, Position, Projection(..), Settings, iniMeanPosition, iniMeasurements, iniModel, iniMyLocation, iniSettings, platzspitz, winti)

import Dict
import Element
import Json.Decode as JD
import Time



-- MESSAGES


type Msg
    = GetTimeZone Time.Zone
    | ToggleProjection Projection
    | ToggleMeasuring
    | LocationChange JD.Value
    | LocationError JD.Value
    | WatchGeolocation JD.Value



-- MODEL


type alias Model =
    { error : String
    , projection : Projection
    , watchId : Int
    , myLocation : Maybe MyLocation
    , measurements : List Location
    , refLocation : ( String, Position )
    , meanPosition : Position
    , meanPositions : List Position
    , locations : Dict.Dict String Position

    --, windowSize : Window.Size
    , settings : Settings

    --, device : Element.Device
    , zoomLevel : Int
    , geoLocState : GeoLocState

    --, activePage : Page
    , timezone : Time.Zone
    }



-- INITIALIZE MODEL


iniModel : Model
iniModel =
    { error = ""
    , projection = LV95
    , watchId = 0
    , myLocation = Nothing -- Just iniMyLocation
    , measurements = iniMeasurements
    , refLocation = platzspitz
    , meanPosition = iniMeanPosition
    , meanPositions = []
    , locations = Dict.fromList [ winti, platzspitz ]
    , settings = iniSettings
    , zoomLevel = 1
    , geoLocState = Pause

    --, activePage = AboutPage
    , timezone = Time.utc
    }


iniMeanPosition : Position
iniMeanPosition =
    { latitude = 0
    , longitude = 0
    , altitude = 0
    , east = 0
    , north = 0
    }


platzspitz : ( String, Position )
platzspitz =
    ( "Platzspitz"
    , { latitude = 47.378631
      , longitude = 8.541108
      , altitude = 408.36
      , east = 2683256.46
      , north = 1248117.48
      }
    )


winti : ( String, Position )
winti =
    ( "Winterthur"
    , { latitude = 47.507765
      , longitude = 8.7542368
      , altitude = 475.2
      , east = 2699109
      , north = 1262721
      }
    )


iniSettings =
    { meanMeasures = 5
    , checkDistance = True
    , showDiagram = False
    }


iniMyLocation : MyLocation
iniMyLocation =
    { accuracyAltitude = Nothing
    , accuracyPos = 22
    , altitude = Nothing
    , distance = 10.61
    , east = 2699100.41
    , height = Nothing
    , latitude = 47.5078218
    , locationKey = "Winterthur"
    , longitude = 8.7541178
    , movingDegrees = Nothing
    , movingSpeed = Nothing
    , north = 1262727.23
    , timestamp = Time.millisToPosix 1530867187430
    }


iniMeasurements : List Location
iniMeasurements =
    []


type Projection
    = LV95
    | WGS84


type GeoLocState
    = Track
    | Pause
    | Reset


type alias Settings =
    { meanMeasures : Int
    , checkDistance : Bool
    , showDiagram : Bool
    }



-- CONST
{-
   highAccuracyOptions : Geolocation.Options
   highAccuracyOptions =
       { enableHighAccuracy = True
       , timeout = Nothing
       , maximumAge = Nothing
       }
-}
-- GEOLOCATION


type alias JSGeoError =
    { errcode : String
    , message : String
    }


type alias Location =
    { longitude : Float
    , latitude : Float
    , accuracyPos : Float
    , altitude : Maybe Float
    , accuracyAltitude : Maybe Float
    , movingSpeed : Maybe Float
    , movingDegrees : Maybe Float
    , timestamp : Time.Posix
    }


type alias Position =
    { latitude : Float
    , longitude : Float
    , altitude : Float
    , east : Float
    , north : Float
    }


type alias MyLocation =
    { longitude : Float
    , latitude : Float
    , accuracyPos : Float
    , altitude : Maybe Float
    , accuracyAltitude : Maybe Float
    , movingSpeed : Maybe Float
    , movingDegrees : Maybe Float
    , timestamp : Time.Posix
    , east : Float
    , north : Float
    , height : Maybe Float
    , locationKey : String
    , distance : Float
    }
