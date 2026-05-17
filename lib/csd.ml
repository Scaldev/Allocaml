type csd = int array

type ('agent, 'good) alloc = ('agent * 'good list) list

let fold_righti (f: int -> 'a -> 'b -> 'b) (xs: 'a list) (acc: 'b) =
  let rec aux (i: int) (xs: 'a list) : 'b =
    match xs with
    | []      -> acc
    | y :: ys -> f i y (aux (i+1) ys)
  in aux 0 xs

(**
  [allocate_agent k i (a, r) (alloc, goods)] returns the pair [((a, taken) :: alloc, remaining)]
  such that agent [a] took their [k.(i)] most prefered goods in [goods] according to [r], which
  are in [taken], leaving the [remaining] items.
*)
let allocate_agent (k: csd) (i: int) (a, r: 'agent * 'good Ranking.t) (alloc, goods: ('agent, 'good) alloc * 'good list) =
  let (taken, goods) = Ranking.take r goods k.(i) in
  (a, taken) :: alloc, goods

let allocate (k: csd) (p: ('agent, 'good) Profile.t) : ('agent, 'good) alloc =
  let prefs      = Profile.to_list p in
  let acc        = (([], Profile.goods_of p)) in
  let (alloc, _) = (fold_righti (allocate_agent k) prefs acc) in
  alloc