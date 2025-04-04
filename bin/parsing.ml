(* Module with parsing functions *)

open Types

(** [parse_orderOrigin s] parses the string [s] into an [orderOrigin].
    - Returns [Ok Physical] if [s] is "P".
    - Returns [Ok Online] if [s] is "O".
    - Otherwise, returns [Error "Invalid order origin"]. *)
let parse_orderOrigin = function
  | "P" -> Ok Physical
  | "O" -> Ok Online
  | _ -> Error "Invalid order origin"

(** [show_orderOrigin origin] converts an [orderOrigin] into its string representation.
    - Returns "P" for [Physical].
    - Returns "O" for [Online]. *)
let show_orderOrigin = function
  | Physical -> "P"
  | Online -> "O"

(** [parse_orderStatus s] parses the string [s] into an [orderStatus].
    - Returns [Ok Pending] if [s] is "Pending".
    - Returns [Ok Complete] if [s] is "Complete".
    - Returns [Ok Cancelled] if [s] is "Cancelled".
    - Otherwise, returns [Error "Invalid order status"]. *)
let parse_orderStatus = function 
  | "Pending" -> Ok Pending
  | "Complete" -> Ok Complete
  | "Cancelled" -> Ok Cancelled
  | _ -> Error "Invalid order status"

(** [show_orderStatus status] converts an [orderStatus] into its string representation.
    - Returns "Pending" for [Pending].
    - Returns "Complete" for [Complete].
    - Returns "Cancelled" for [Cancelled]. *)
let show_orderStatus = function
  | Pending -> "Pending"
  | Complete -> "Complete"
  | Cancelled -> "Cancelled"

(** [parse_id raw_id] converts the string [raw_id] into an integer.
    - If conversion succeeds, returns [Ok int].
    - Otherwise, returns [Error "Invalid id"]. *)
let parse_id raw_id =
  raw_id
  |> int_of_string_opt
  |> Option.to_result ~none:"Invalid id"


