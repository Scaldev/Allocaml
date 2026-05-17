let (<<) = Fun.compose

type resource = int
type agent = int

type bundle = resource list

(* structure invariant: each resource appears at most once in the array. *)
type allocation = bundle array

type value = int

type opinion = First | Second | Both

type preference = bundle -> bundle -> opinion

type pref_prop =
  | Linear
  | Weakly_Separable
  | Separable
  | Additively_Separable

type pref_props = pref_prop list

(*
  | Lin : (resource -> resource -> bool) -> [`Lin] preference
  | Sep : (resource -> resource -> bool) -> [`Sep] preference
  | Gen : (bundle   -> bundle   -> bool) -> [`Gen] preference
*)

type utility = bundle -> value

type util_prop =
  | Modular
  | Additively_Independant

type util_props = util_prop list
(*
  | Mod : value * (resource -> value) -> [`Mod] utility (* Modular: u(empty_set) and u({r}) *)
  | Add :         (resource -> value) -> [`Add] utility (* Additive: modular + u(empty) = 0 *)
  | Gen :         (bundle   -> value) -> [`Gen] utility (* General: over bundles            *)
*)

type _ mode =
  | Ord  : preference * pref_props -> [`Ord ] mode
  | Card : utility    * util_props -> [`Card] mode

type 'm profile = 'm mode array

(* MultiAgent Resource Allocation setting, or MARA *)
type 'm setting = {
  nb_agents: int ;
  nb_resources: int ;
  profile: 'm profile
}

(*****************************************************************************)
(*                                create_setting                             *)
(*****************************************************************************)

let create_setting (n: int) (m: int) (p: 'm profile) : 'm setting =
  { nb_agents = n ; nb_resources = m ; profile = p }

let bundle_of_agent (alloc: allocation) (i: int) : bundle =
  let n = Array.length alloc in
  if i <= 0 || n < i then
    raise (Invalid_argument ("Agent " ^ string_of_int i ^ " not in allocation."))
  else alloc.(i)

let gen_of_add (add: resource -> value) : bundle -> value =
  fun rs -> List.fold_right ((+) << add) rs 0

let add_of_gen (gen: bundle -> value) : resource -> value =
  fun r -> gen [r]

let util_of_card (s: [`Card] setting) (i: int) : utility =
    match s.profile.(i) with
    | Card (u, _) -> u

let pref_of_ord (s: [`Ord] setting) (i: int) : preference =
    match s.profile.(i) with
    | Ord (r, _) -> r

(*****************************************************************************)
(*                                    is_complete                            *)
(*****************************************************************************)

(**
  [mark_occurences arr inds] increases [arr.(i)] by one for each [i] in
  [inds].
*)
let mark_occurences (arr: int array) (inds: int list) : unit =
  List.iter (fun i -> arr.(i) <- arr.(i) + 1) inds

let is_complete (s: 'm setting) (alloc: allocation) : bool =
  let arr = Array.make s.nb_resources 0 in
  Array.iter (mark_occurences arr) alloc ;
  Array.for_all ((=) 1) arr

(*****************************************************************************)
(*                                 is_nonshareable                           *)
(*****************************************************************************)

(**
  [list_max rs] returns the maximal integer in 0, with [0] by default.
*)
let max_resource_bundle (rs: bundle) : resource =
  List.fold_left max 0 rs

(**
  [max_resource alloc] returns the highest allocated resource in [alloc].    
*)
let max_resource (alloc: allocation) : int =
  Array.fold_right (max << max_resource_bundle) alloc 0

let is_nonshareable (alloc: allocation) : bool =
  let arr = Array.make (max_resource alloc) 0 in
  Array.iter (mark_occurences arr) alloc ;
  Array.for_all ((<=) 1) arr


(*****************************************************************************)
(*                                is_proportional                            *)
(*****************************************************************************)

let ids_to (n: int) : int list =
  List.init n succ

let is_proportional_for_agent (s: [`Card] setting) (alloc: allocation) (i: agent) : bool =
    let v =  util_of_card s i in
    let m = ids_to s.nb_resources in
    let actual  = v alloc.(i) in
    let threshold = v m / s.nb_agents in
    actual >= threshold

let is_proportional (s: [`Card] setting) (alloc: allocation) : bool =
  let ags = ids_to s.nb_agents in
  List.for_all (is_proportional_for_agent s alloc) ags

(*****************************************************************************)
(*                                 is_envy_free                              *)
(*****************************************************************************)

let is_envy_free_for_agent (s: [`Card] setting) (alloc: allocation) (i: agent) : bool =
  let v = util_of_card s i in
  let ags = ids_to s.nb_agents in
  let q = v alloc.(i) in
  List.for_all (fun j -> q >= util_of_card s j alloc.(j)) ags

let is_envy_free (w: [`Card] setting) (alloc: allocation) : bool =
  List.for_all (is_envy_free_for_agent w alloc) (ids_to w.nb_agents)


(*****************************************************************************)
(*                               pareto_dominates                            *)
(*****************************************************************************)

let pareto_dominates (s: [`Ord] setting) (pi1: allocation) (pi2: allocation) : bool =
  assert (Array.length pi1 = s.nb_agents && Array.length pi2 = s.nb_agents) ;
  List.for_all (fun i ->
    let (>>>=) x y = pref_of_ord s i x y <> Second in pi1.(i) >>>= pi2.(i)
  ) (ids_to s.nb_agents)

let strongly_pareto_dominates (s: [`Ord] setting) (pi1: allocation) (pi2: allocation) : bool =
  assert (Array.length pi1 = s.nb_agents && Array.length pi2 = s.nb_agents) ;
  List.for_all (fun i ->
    let (>>>) x y = pref_of_ord s i x y = First in pi1.(i) >>> pi2.(i)
  ) (ids_to s.nb_agents)