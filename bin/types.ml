(* A module defining main types for this project *)



type orderStatus = Pending | Complete | Cancelled;;
type orderOrigin = Physical | Online;;




type orderItem = {
  order_id: int;
  quantity: int;
  price: float;
  tax: float;
};;




type order = {
  id: int;
  status: orderStatus;
  origin: orderOrigin;
};;

type orderTotal = {
  order_id: int;
  total_amount: float;
  total_taxes: float;

};;

type processedOrderedItem = {
  order_id: int;
  item_total: float;
  total_tax: float;
};;

type fullOrder = {
  id: int;
  status: orderStatus;
  origin: orderOrigin;
  items: processedOrderedItem list;
};;