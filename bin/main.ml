open Types
open FileParsing
open Io
open Lwt.Infix

(** [to_fullOrder o] converts a raw [order] into a [fullOrder] with an empty [items] list. *)
let to_fullOrder (o : order) : fullOrder =
  { id = o.id;
    status = o.status;
    origin = o.origin;
    items = [] }

(** [filter_orders orders (status_opt, origin_opt)] returns a filtered list of [fullOrder]
    based on the optional [orderStatus] and [orderOrigin] criteria. *)
let filter_orders (orders : fullOrder list) (status_opt, origin_opt) =
  match (status_opt, origin_opt) with
  | (Some status, Some origin) ->
      List.filter (fun order -> order.status = status && order.origin = origin) orders
  | (Some status, None) ->
      List.filter (fun order -> order.status = status) orders
  | (None, Some origin) ->
      List.filter (fun order -> order.origin = origin) orders
  | (None, None) -> orders

(** [group_processed_items items orders] groups a list of [processedOrderedItem] by their
    [order_id] and then builds a [fullOrder] by matching with the given [orders]. *)
let group_processed_items (items : processedOrderedItem list) (orders: fullOrder list) : fullOrder list =
  let tbl = Hashtbl.create (List.length orders) in
  List.iter (fun item ->
    let key = item.order_id in
    let current = try Hashtbl.find tbl key with Not_found -> [] in
    Hashtbl.replace tbl key (item :: current)
  ) items;
  Hashtbl.fold (fun order_id items acc ->
    match List.find_opt (fun o -> o.id = order_id) orders with
    | Some order ->
        { id = order_id;
          status = order.status;
          origin = order.origin;
          items = items } :: acc
    | None ->
        acc
  ) tbl []

(** [calculateTotal order] computes the total amount and total taxes for a [fullOrder]
    based on its list of [processedOrderedItem]. *)
let calculateTotal order =
  let total_amount = List.fold_left (fun acc item -> acc +. item.item_total) 0.0 order.items in 
  let total_taxes = List.fold_left (fun acc item -> acc +. item.total_tax) 0.0 order.items in
  { order_id = order.id; total_amount; total_taxes }

(** [processItem orderItem] computes the total price and total tax for a single [orderItem],
    returning its [processedOrderedItem] representation. *)
let processItem orderItem =
  let item_total = orderItem.price *. float_of_int orderItem.quantity in
  { order_id = orderItem.order_id; item_total; total_tax = orderItem.tax *. item_total }

(** Main entry point. Downloads CSV files, parses and processes orders, and outputs totals.
    It writes the computed totals to "order_total.csv". *)
let () =
  Lwt_main.run (
    download (Uri.of_string "https://raw.githubusercontent.com/arieltl/etl/refs/heads/main/order_item.csv") "order_item.csv" >>= fun () ->
    download (Uri.of_string "https://raw.githubusercontent.com/arieltl/etl/refs/heads/main/order.csv") "order.csv" >>= fun () ->
    
    (* Now that both files are downloaded, continue processing *)
    let orderItems = read_orderItems "order_item.csv" in
    let orders = read_orders "order.csv" in
    let fullOrders = List.map to_fullOrder orders in
    let processedItems = List.map processItem orderItems in
    let ordersWithItems = group_processed_items processedItems fullOrders in
    let filteredOrders = filter_orders ordersWithItems (Sys.argv |> parse_args) in
    let totals = List.map calculateTotal filteredOrders in

    List.iter (fun (total: orderTotal) ->
      Printf.printf "Order ID: %d\n" total.order_id;
      Printf.printf "Total: %.2f\n" total.total_amount;
      Printf.printf "--------------------------------\n";
      Printf.printf "\n"
    ) totals;

    write_order_total_csv totals "order_total.csv";
    Lwt.return_unit
  )