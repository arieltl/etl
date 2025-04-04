open Types
open FileParsing
open Io

(* functions *)
let to_fullOrder (o : order) : fullOrder =
  { id = o.id;
    status = o.status;
    origin = o.origin;
    items = [] }
let filter_orders (orders : fullOrder list) (status_opt, origin_opt) =
  match (status_opt, origin_opt) with
  | (Some status, Some origin) ->
      List.filter (fun order -> order.status = status && order.origin = origin) orders
  | (Some status, None) ->
      List.filter (fun order -> order.status = status) orders
  | (None, Some origin) ->
      List.filter (fun order -> order.origin = origin) orders
  | (None, None) -> orders


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

let calculateTotal order =
  let total = List.fold_left (fun acc item -> acc +. item.item_total) 0.0 order.items in 
  let total_taxes = List.fold_left (fun acc item -> acc +. item.total_tax) 0.0 order.items in
  { order_id = order.id; total; total_taxes }

let processItem orderItem =
  let item_total = orderItem.price *. float_of_int orderItem.quantity in
  { order_id = orderItem.order_id; item_total; total_tax = orderItem.tax *. item_total }

let args = Sys.argv |> parse_args
let orderItems = read_orderItems "order_item.csv"
let orders = read_orders "order.csv" 
let fullOrders = List.map to_fullOrder orders

  
let processedItems = List.map processItem orderItems 
let ordersWithItems = group_processed_items processedItems fullOrders
let filteredOrders = filter_orders ordersWithItems args 
let totals = List.map calculateTotal filteredOrders;;
  
  List.iter (fun (total: orderTotal) ->
    Printf.printf "Order ID: %d\n" total.order_id;
    Printf.printf "Total: %.2f\n" total.total;
    Printf.printf "--------------------------------\n";
    Printf.printf "\n"
  ) totals;;

  
write_order_total_csv totals "order_total.csv" 
