module Main exposing (main)

import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (Declaration(..))
import Elm.Syntax.Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Html exposing (Html)
import Tree


main : Html a
main =
    Html.pre [] [ Html.text <| printExpressionTree src ]


src =
    """module A exposing (..)

bool1 = True && True || True
bool2 = True || True && True

numeric1 = 1 ^ 2 * 3 + 4
numeric2 = 1 + 2 * 3 ^ 4
"""


printExpressionTree : String -> String
printExpressionTree elmSource =
    case Parser.parse elmSource of
        Err e ->
            "Failed to parse elm source : " ++ Debug.toString e

        Ok rawFile ->
            let
                file =
                    Processing.process Processing.init rawFile
            in
            file.declarations
                |> getFunctionBodies
                |> List.map Tree.drawExpressionTree
                |> String.join "\n\n"


getFunctionBodies : List (Node Declaration) -> List Expression
getFunctionBodies =
    List.filterMap
        (\decl ->
            case Node.value decl of
                FunctionDeclaration function ->
                    function.declaration
                        |> Node.value
                        |> .expression
                        |> Node.value
                        |> Just

                _ ->
                    Nothing
        )
