(* This module encapsulates impure functions for reading and writing CSV files *)

open FileParsing
open Cohttp_lwt
open Cohttp_lwt_unix

(** [download uri dest] downloads data from the HTTP [uri] and writes it to the file at [dest]. *)
let download (uri : Uri.t) (dest : string) =
  let ( let* ) = Lwt.bind in
  let* _resp, body = Client.get uri in
  let stream = Body.to_stream body in
  Lwt_io.with_file ~mode:Lwt_io.output dest (fun chan ->
      Lwt_stream.iter_s (Lwt_io.write chan) stream)

(** [load_csv file] loads CSV data from the given [file]. *)
let load_csv file =
  Csv.load file

(** [read_orders file] reads the CSV data from [file], converts each row into a list of (header * value) pairs,
    and then parses each row using [parse_order_row]. *)
let read_orders file =
  let csv_data = load_csv file in
  let headers = List.hd csv_data in
  let data = List.tl csv_data in
  let rows = List.map (fun row -> List.combine headers row) data in
  List.map parse_order_row rows

(** [read_orderItems file] reads the CSV data from [file], converts each row into a list of (header * value) pairs,
    and then parses each row using [parse_orderItem_row]. *)
let read_orderItems file =
  let csv_data = load_csv file in
  let headers = List.hd csv_data in
  let data = List.tl csv_data in
  let rows = List.map (fun row -> List.combine headers row) data in
  List.map parse_orderItem_row rows

(** [write_order_total_csv totals filename] writes the list of [totals] (of type [Types.orderTotal list])
    as CSV file data to [filename]. The CSV file header is "order_id", "total_amount", and "total_taxes". *)
let write_order_total_csv (totals : Types.orderTotal list) (filename : string) : unit =
  let header = [ "order_id"; "total_amount"; "total_taxes" ] in
  let rows =
    List.map (fun (total : Types.orderTotal) ->
      [ string_of_int total.order_id; Printf.sprintf "%.2f" total.total_amount; Printf.sprintf "%.2f" total.total_taxes ]
    ) totals
  in
  let csv_data = header :: rows in
  Csv.save filename csv_data