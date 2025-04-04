(* This module encapsulates impure functions for reading CSV files *)

(* A helper to load CSV data *)

open FileParsing
open Cohttp_lwt
open Cohttp_lwt_unix
open Lwt.Syntax



let download (uri : Uri.t) (dest : string) =

  let ( let* ) = Lwt.bind in
  let* _resp, body = Client.get uri in
  let stream = Body.to_stream body in
  Lwt_io.with_file ~mode:Lwt_io.output dest (fun chan ->
      Lwt_stream.iter_s (Lwt_io.write chan) stream)

let load_csv file =
  Csv.load file;;

let read_orders file =
  let csv_data = load_csv file in
  let headers = List.hd csv_data in
  let data = List.tl csv_data in
  let rows = List.map (fun row -> List.combine headers row) data in
  List.map parse_order_row rows;;

let read_orderItems file =
  let csv_data = load_csv file in
  let headers = List.hd csv_data in
  let data = List.tl csv_data in
  let rows = List.map (fun row -> List.combine headers row) data in
  List.map parse_orderItem_row rows;;


let write_order_total_csv (totals : Types.orderTotal list) (filename : string) : unit =
  let header = [ "order_id"; "total" ] in
  let rows =
    List.map (fun (total : Types.orderTotal) ->
      [ string_of_int total.order_id; Printf.sprintf "%.2f" total.total ]
    ) totals
  in
  let csv_data = header :: rows in
  Csv.save filename csv_data