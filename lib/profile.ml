include Ranking

type ('agent, 'good) t = {
  goods: 'good list;
  tbl: ('agent, 'good Ranking.t) Hashtbl.t
}

exception Invalid_ranking
exception Unknown_agent

let create (goods: 'good list) : ('agent, 'good) t =
  { goods = goods ; tbl = Hashtbl.create 0 }

let add (p: ('agent, 'good) t) (a: 'agent) (r: 'good Ranking.t) : unit =
  if Ranking.is_ranking r p.goods then
    Hashtbl.add p.tbl a r
  else raise Invalid_ranking

let ranking_of (p: ('agent, 'good) t) (a: 'agent) : 'good Ranking.t =
  match Hashtbl.find_opt p.tbl a with
  | None   -> raise Unknown_agent
  | Some r -> r

let rank (p: ('agent, 'good) t) (a: 'agent) (g: 'good) : int =
  Ranking.rank (ranking_of p a) g

(*****************************************************************************)
(*                                 to_string                                 *)
(*****************************************************************************)

let rec longest_length (ss: string list) : int =
  match ss with
  | []       -> -1
  | s :: ss' -> max (String.length s) (longest_length ss')

let space (n: int) : string =
  String.make n ' '

let line_to_string (f: 'agent -> string) (g: 'good -> string) (len: int) (a, r: 'agent * 'good Ranking.t) : string =
  let name = f a in
  let padding = space (len - String.length name) in
  f a ^ padding ^ ": " ^ Ranking.to_string g r

let padding (f: 'agent -> string) (p: ('agent, 'good) t) : int =
  p.tbl
  |> Hashtbl.to_seq_keys
  |> List.of_seq
  |> List.map f
  |> longest_length

let to_string (f: 'agent -> string) (g: 'good -> string) (p: ('agent, 'good) t) : string =
  p.tbl
  |> Hashtbl.to_seq
  |> List.of_seq
  |> List.map (line_to_string f g (padding f p))
  |> List.sort String.compare
  |> String.concat "\n"
