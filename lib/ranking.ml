(* Because our rankings are linear, we will represent them as a list. *)
type 'good t = 'good list

exception Unranked_good

let of_list (xs: 'good list) : 'good t = xs

let to_list (r: 'good t): 'good list = r

let length (r: 'good t): int = List.length r

let to_string (f: 'good -> string) (r: 'good t) : string =
  String.concat " > " (List.map f r)

let is_ranking (r: 'good t) (xs: 'good list) : bool =
  List.length r = List.length xs
    && xs
    |> List.map (fun x -> (x, true))
    |> List.to_seq
    |> Hashtbl.of_seq
    |> fun tbl -> List.for_all (fun g -> Hashtbl.find_opt tbl g <> None) r

let rank (r: 'good t) (a: 'good) : int =
  match List.find_index ((=) a) r with
  | Some i -> i+1
  | None   -> raise Unranked_good

let nth (r: 'good t) (i: int) : 'good =
  List.nth r (i-1)