type 'good value_vect = ('good * float) list

type 'good planckett_luce = {
  nu: ('good * float) list ; (* value vector *)
}

(*****************************************************************************)
(*                                    SAMPLING                               *)
(*****************************************************************************)

(**
  [total nu] returns the sum of values in [nu].    
*)
let total (nu: ('good * float) list) : float =
  List.fold_left (fun acc p -> acc +. (snd p)) 0.0 nu

(**
  [sample_good_aux u cumul nu] returns a pair [chosen, gs'] such that
  [chosen] is a good from [nu] and [gs'] are the remaining.
*)
let rec sample_good_aux (u: float) (cumul: float) =
  function
  | []             -> failwith "plackett_luce sample_good"
  | (g, _) :: []   -> (g, [])
  | (g, v) :: rest ->
    if u <= (cumul +. v) then (g, rest)
    else
      let chosen, nu = sample_good_aux u (cumul +. v) rest in
      (chosen, (g, v) :: nu)
  
let sample_good  (nu: 'good value_vect) : 'good * 'good value_vect =
  let u = Random.float (total nu) in
  sample_good_aux u 0.0 nu

let rec sample_aux acc nu =
  match nu with
  | [] -> List.rev acc
  | _  -> let (chosen, rest) = sample_good nu in
          sample_aux (chosen :: acc) rest
    
let sample (param: 'good planckett_luce) : unit -> 'good Ranking.t =
  fun () -> Ranking.of_list (sample_aux [] param.nu)

(*****************************************************************************)
(*                                     CHANCE                                *)
(*****************************************************************************)

let rec chance_aux (param: 'good planckett_luce) (p: float) (goods: 'good list) =
  match goods with
  | []      -> p
  | g :: gs ->
    let p' = p *. (List.assoc g param.nu /. total param.nu) in
    chance_aux param p' gs

let chance (param: 'good planckett_luce) (r: 'good Ranking.t) : float =
  chance_aux param 1.0 (Ranking.to_list r)

(*****************************************************************************)
(*                                   CREATE                                  *)
(*****************************************************************************)

let create (nu: ('good * float) list) : 'good Model.t =
  if List.exists (fun (_, v) -> v < 0.0) nu then
    raise (Invalid_argument "plackett_luce create")
  else
    let param = { nu = nu } in
    { sample = sample param ; chance = chance param }