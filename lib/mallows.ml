type 'good mallows = {
  dispersion: float;
  nb_goods  : int  ;
  ranking   : 'good Ranking.t
}

(*****************************************************************************)
(*                                HELPER FUNCTIONS                           *)
(*****************************************************************************)

(**
  [x ^. n] returns [x] to the power of [n].
  
  {b Precondition:} [n >= 0].
*)
let rec (^.) (x: float) (n: int) : float =
  if n = 0 then 1.0
  else
    let b = x ^. (n / 2) in
    if n mod 2 = 0 then b *. b else x *. b *. b

(**
  [range a b] returns the list [a :: (a + 1) :: ... (b - 1) :: b].

  {b Precondition:} [a <= b].
*)
let range (a: int) (b: int) : int list = (* [a, a + 1, ..., b - 1, b] *)
  assert (a <= b) ;
  List.init (b - a + 1) ((+) a)

(**
  [insert x i xs] inserts [x] at position [i] in [xs].

  {b Example:} [insert 'z' 2 ['a';'b';'c';'d']] = [['a';'b';'z';'c';'d']]
*)
let insert (x: 'a) (i: int) (xs: 'a list) : 'a list =
  let rec aux xs i =
    match xs with
    | []      -> [x]
    | y :: ys -> if i = 0 then x :: y :: ys else y :: aux ys (i-1)
  in aux xs i
  
(*****************************************************************************)
(*                                    SAMPLING                               *)
(*****************************************************************************)

(**
  [sample_diff phi i] returns a pair [(i, v)] such that [i] has
  a probability of [phi^d * (1 - phi) / (1 - phi^i)] for all
  [d] in [0 .. i-1] of being returned.

  {b Complexity.} In [O(i)] time and constant space.

  cdf = cumulative distribution fonction. Here, it is:
  {[
    P[i <= d]
    = sum_(j=0)^d ((phi^j * (1 - phi)) / (1 - phi^i))
    = (1 - phi^(d+1)) / (1 - phi^i)
  ]}
*)
let sample_diff (phi: float) (i: int) : int =
  let phi = if phi >= 1.0 then 1.0 -. 10e-9 else phi in
  let u   = Random.float 1.0 in
  let w   = 1.0 -. (phi ^. i) in
  let rec aux (ret: float) (d: int) : int =
    let v = (1.0 -. ret) /. w in
    if d = i-1 || u <= v then d
    else aux (ret *. phi) (d+1)
  in aux phi 0

(** [insert_step phi r acc i] samples a displacement for the
    [i]-th element of [r] and inserts it into [acc]. *)
let insert_step (phi: float) (r: 'good Ranking.t) (acc: 'good list) (i: int) : 'a list =
  let elt = Ranking.nth r i in
  let d   = sample_diff phi i in
  insert elt d acc

let sample (p: 'good mallows) : unit -> 'good Ranking.t =
  fun () ->
    range 1 p.nb_goods
    |> List.fold_left (insert_step p.dispersion p.ranking) []
    |> List.rev
    |> Ranking.of_list

(*****************************************************************************)
(*                                     CHANCE                                *)
(*****************************************************************************)

(**
  [f hist r g] returns a list of pairs [(g, g')] such that [g' > g] in [r] and
  [g'] is not in [hist].
*)
let divergences (hist: 'good list) (r: 'good Ranking.t) (g: 'good) : ('good * 'good) list =
  r
  |> Ranking.to_list
  |> List.take (Ranking.rank r g - 1)               (* all g' s.t. g' >_1 g              *)
  |> List.filter (fun g' -> not (List.mem g' hist)) (*                  ... and g' <_2 g *)
  |> List.map (fun g' -> (g, g'))

(**
  [dist_kt hist r1 r2] returns a list of pairs [(g, g')] such that [g > g']
  is in a ranking and [g < g'] is in the other.

  In other words, it returns all the pairs [(g, g')] such that [r1] and [r2]
  disagree about whether [g > g'] or [g' > g].
*)
let dist_kt (r1: 'good Ranking.t) (r2: 'good Ranking.t) : int =
  r2
  |> Ranking.to_list
  |> List.fold_left (fun (acc, hist) g -> divergences hist r1 g :: acc, g :: hist) ([], [])
  |> fst
  |> List.flatten
  |> List.length

(**
  [z_norm phi m] returns [(1 + phi) * (1 + phi + phi^2) * ... * (1 + ... + phi^m)].
*)
let z_norm (phi: float) (m: int) : float =
  let rec aux (i: int) : float * float =
    if i = 0 then (1.0, 1.0)
    else
      let (prod, prev) = aux (i - 1) in
      let term = prev +. (phi ^. i) in
      (prod *. term, term)
  in fst (aux m)

let chance (p: 'good mallows) (r: 'good Ranking.t) : float =
  let z = z_norm p.dispersion p.nb_goods in
  (1.0 /. z) *. (p.dispersion ^. dist_kt p.ranking r)

(*****************************************************************************)
(*                                   CREATE                                  *)
(*****************************************************************************)

let create (dispersion: float) (ranking: 'good list) : 'good Model.t =
  if 0.0 > dispersion || dispersion > 1.0 then
    raise (Invalid_argument "mallows create")
  else
    let param = {
      dispersion = dispersion;
      nb_goods   = List.length ranking;
      ranking    = Ranking.of_list ranking
    } in
    { sample = sample param ; chance = chance param }