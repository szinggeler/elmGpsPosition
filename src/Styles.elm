module Styles exposing (paddingScale, scaled, unselectable)

{-
   copied from
   https://github.com/Zinggi/NoKey/blob/master/web/src/Styles.elm
-}

import Element
import Html.Attributes as Attr


scaled =
    Element.modular 12 1.25 >> round


paddingScale =
    Element.modular 6 1.25 >> round


unselectable : List (Element.Attribute msg)
unselectable =
    let
        theStyles =
            [ "-webkit-touch-callout"
            , "-webkit-user-select"
            , "-khtml-user-select"
            , "-moz-user-select"
            , "-ms-user-select"
            , "user-select"
            ]
    in
    List.map (\s -> Element.htmlAttribute (Attr.style s "none")) theStyles



{-
   (Attr.style
       [ ( "-webkit-touch-callout", "none" )
       , ( "-webkit-user-select", "none" )
       , ( "-khtml-user-select", "none" )
       , ( "-moz-user-select", "none" )
       , ( "-ms-user-select", "none" )
       , ( "user-select", "none" )
       ]
   )
-}
{-
   selectable : Element.Attribute msg
   selectable =
       Element.htmlAttribute
           (Attr.style
               [ ( "-webkit-touch-callout", "all" )
               , ( "-webkit-user-select", "all" )
               , ( "-khtml-user-select", "all" )
               , ( "-moz-user-select", "all" )
               , ( "-ms-user-select", "all" )
               , ( "user-select", "all" )
               ]
           )
-}
