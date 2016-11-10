module Visualize exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http exposing (..)

import String

main =
  App.program
  { init = init
  , view = view
  , update = update
  , subscriptions = \_ -> Sub.none
  }

-- MODEL

type alias Model =
  { fail_opt : Int
  , fail_man : Int
  , pass_opt : Int
  , pass_man : Int
  }

-- UPDATE

type Msg
  = Increment Int
  | Request String
  | FetchSucceed String
  | FetchFailed Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Increment value ->
      (model, Cmd.none)
    Request url ->
      (model, request url)
    FetchSucceed str ->
      ({model | results = {}}, Cmd.none)
    FetchFailed code ->
      (model, Cmd.none)

-- REQUEST

request: String -> Cmd Msg
request sub =
  let
    url = "http://bugs-data.thomasdufour.fr:2847/modules/" ++ sub
  in
    Task.perform FetchFailed FetchSucceed (Http.get url)

-- INIT

init: (Model, Cmd Msg)
init = (Model 0 0 0 0, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
  div []
  [ text "Coucou"
  ]
