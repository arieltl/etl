(* Module for parsing input  *)
open Parsing
open Types
let unwrapResult = function
  | Ok value -> value
  | Error msg -> failwith ("Unwrapping failed: " ^ msg) ;;
let parse_order_row row : order =
  let find key = List.assoc key row in
  let id = find "id" |> parse_id |> unwrapResult in
  let status = find "status" |> parse_orderStatus |> unwrapResult in
  let origin = find "origin" |> parse_orderOrigin |> unwrapResult in
  {id ; status; origin} ;;

let parse_orderItem_row row : orderItem =
  let find key = List.assoc key row in
  let order_id = find "order_id" |> parse_id |> unwrapResult in
  let quantity = find "quantity" |> int_of_string in
  let price = find "price" |> float_of_string in
  let tax = find "tax" |> float_of_string in
  {order_id; quantity; price; tax} ;;

let parse_args args =
  let rec parse_helper pos =
    if pos >= Array.length args then (None, None)
    else
      match args.(pos) with
      | "-status" when pos + 1 < Array.length args ->
          let status_opt = 
            match parse_orderStatus args.(pos + 1) with
            | Ok s -> Some s
            | Error _ -> None
          in
          let (prev_status, prev_origin) = parse_helper (pos + 2) in
          (match prev_status with
            | None -> (status_opt, prev_origin)
            | Some _ -> (prev_status, prev_origin))
      | "-origin" when pos + 1 < Array.length args ->
          let origin_opt = 
            match parse_orderOrigin args.(pos + 1) with
            | Ok o -> Some o
            | Error _ -> None
          in
          let (prev_status, prev_origin) = parse_helper (pos + 2) in
          (match prev_origin with
            | None -> (prev_status, origin_opt)
            | Some _ -> (prev_status, prev_origin))
      | _ -> parse_helper (pos + 1)
  in
  parse_helper 0;;