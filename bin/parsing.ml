(* module with parsing fucntions *)

open Types

let parse_orderOrigin = function
  | "P" -> Ok Physical
  | "O" -> Ok Online
  | _ -> Error "Invalid order origin";;

let show_orderOrigin = function
  | Physical -> "P"
  | Online -> "O";;



let parse_orderStatus = function 
  | "Pending" -> Ok Pending
  | "Complete" -> Ok Complete
  | "Cancelled" -> Ok Cancelled
  | _ -> Error "Invalid order status";;

let show_orderStatus = function
  | Pending -> "Pending"
  | Complete -> "Complete"
  | Cancelled -> "Cancelled";;

let parse_id raw_id =
  raw_id
  |> int_of_string_opt
  |> Option.to_result ~none:"Invalid id";;


