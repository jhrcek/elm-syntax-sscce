module Tree exposing (drawExpressionTree)

import Elm.Syntax.Expression exposing (Expression(..), RecordSetter)
import Elm.Syntax.Node as Node exposing (Node)


drawExpressionTree : Expression -> String
drawExpressionTree =
    exprToTee >> drawTree


type Tree a
    = Node a (List (Tree a))


leaf : a -> Tree a
leaf a =
    Node a []


nodeToTree : Node Expression -> Tree String
nodeToTree =
    Node.value >> exprToTee



-- Convert expression to tree


exprToTee : Expression -> Tree String
exprToTee expression =
    case expression of
        UnitExpr ->
            leaf "()"

        Application listNodeExpression ->
            Node "Application" <| List.map nodeToTree listNodeExpression

        OperatorApplication string infixDirection nodeExpressionL nodeExpressionR ->
            Node string {- TODO maybe add direction -} [ nodeToTree nodeExpressionL, nodeToTree nodeExpressionR ]

        FunctionOrValue moduleName string ->
            leaf <|
                case moduleName of
                    [] ->
                        string

                    _ ->
                        String.join "." moduleName ++ "." ++ string

        IfBlock nodeEx1 nodeEx2 nodeEx3 ->
            Node "if-then-else" <| [ nodeToTree nodeEx1, nodeToTree nodeEx2, nodeToTree nodeEx3 ]

        PrefixOperator string ->
            leaf string

        Operator string ->
            leaf string

        Integer int ->
            leaf (String.fromInt int)

        Hex int ->
            leaf (String.fromInt int)

        Floatable float ->
            leaf (String.fromFloat float)

        Negation nodeExpression ->
            Node "-" [ nodeToTree nodeExpression ]

        Literal string ->
            leaf <| "\"" ++ string ++ "\""

        CharLiteral char ->
            leaf <| "'" ++ String.fromChar char ++ "'"

        TupledExpression listNodeExpression ->
            Node ("(" ++ String.fromList (List.repeat (List.length listNodeExpression - 1) ',') ++ ")") <| List.map nodeToTree listNodeExpression

        ParenthesizedExpression nodeExpression ->
            Node "(...)" [ nodeToTree nodeExpression ]

        LetExpression letBlock ->
            Node "let ... in" [ nodeToTree letBlock.expression ]

        CaseExpression caseBlock ->
            Node "case ... of ..." <| nodeToTree caseBlock.expression :: List.map (nodeToTree << Tuple.second) caseBlock.cases

        LambdaExpression lambda ->
            Node "lambda .." [ nodeToTree lambda.expression ]

        RecordExpr listNodeRecordSetter ->
            Node "record expr" <| List.map (recordSetterToTree << Node.value) listNodeRecordSetter

        ListExpr listNodeExpression ->
            Node "[..]" <| List.map nodeToTree listNodeExpression

        RecordAccess nodeExpression nodeString ->
            Node ("." ++ Node.value nodeString) [ nodeToTree nodeExpression ]

        RecordAccessFunction string ->
            leaf <| "." ++ string

        RecordUpdateExpression nodeString listNodeRecordSetter ->
            Node ("{ " ++ Node.value nodeString ++ " | ... }") <| List.map (recordSetterToTree << Node.value) listNodeRecordSetter

        GLSLExpression string ->
            leaf "GLSLExpression"


recordSetterToTree : RecordSetter -> Tree String
recordSetterToTree ( nodeString, nodeExpression ) =
    Node (Node.value nodeString) [ nodeToTree nodeExpression ]



-- Tree drawing function taken from Haskell's containers:
-- http://hackage.haskell.org/package/containers-0.6.2.1/docs/src/Data.Tree.html#drawTree


drawTree : Tree String -> String
drawTree =
    String.join "\n" << draw


draw : Tree String -> List String
draw (Node x ts0) =
    let
        drawSubTrees trees =
            case trees of
                [] ->
                    []

                [ t ] ->
                    "│" :: shift "└─ " "   " (draw t)

                t :: ts ->
                    "│" :: shift "├─ " "│  " (draw t) ++ drawSubTrees ts

        shift first other nested =
            List.map2 (++) (first :: List.repeat (List.length nested) other) nested
    in
    x :: drawSubTrees ts0
