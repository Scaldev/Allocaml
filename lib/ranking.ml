(* Because our rankings are linear, we will represent them as a list. *)
type 'good t = 'good list

let (<<) = Fun.compose

exception Unranked_good

let of_list (xs: 'good list) : 'good t = xs

let to_list (r: 'good t): 'good list = r

let length (r: 'good t): int = List.length r

let set_of_goods (goods: 'good list) : ('good, unit) Hashtbl.t =
  let n = List.length goods in
  let set = Hashtbl.create n in
  List.iter (fun g -> Hashtbl.add set g ()) goods ;
  set

let is_ranking (r: 'good t) (goods: 'good list) : bool =
  let set = set_of_goods goods in
  List.length r = List.length goods && List.for_all (Hashtbl.mem set) r

let rank (r: 'good t) (a: 'good) : int =
  match List.find_index ((=) a) r with
  | Some i -> i+1
  | None   -> raise Unranked_good

let nth (r: 'good t) (i: int) : 'good =
  List.nth r (i-1)

let take (r: 'good t) (goods: 'good list) (n: int) : 'good list * 'good list =
  let set       = set_of_goods goods in
  let filtered  = List.filter (Hashtbl.mem set) (to_list r) in
  let taken     = List.take n filtered in
  let set       = set_of_goods taken in
  let remaining = List.filter (not << Hashtbl.mem set) goods in
  (taken, remaining)

let to_string (f: 'good -> string) (r: 'good t) : string =
  String.concat " > " (List.map f r)