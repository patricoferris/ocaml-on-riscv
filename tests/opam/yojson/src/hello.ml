(* Taken from the YOJSON examples https://github.com/ocaml-community/yojson/blob/master/examples/constructing.ml *)

let json_output =
  `Assoc
    [
      ("id", `String "398eb027");
      ("name", `String "John Doe");
      ( "pages",
        `Assoc
          [ ("id", `Int 1); ("title", `String "The Art of Flipping Coins") ] );
    ]

let main () =
  let oc = stdout in
  Yojson.Basic.pretty_to_channel oc json_output;
  output_string oc "\n"

let () = main ()
