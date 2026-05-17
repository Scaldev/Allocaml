val ( << ) : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b
type resource = int
type agent = resource
type bundle = agent list
type allocation = bundle array
type value = agent
type opinion = First | Second | Both
type preference = bundle -> bundle -> opinion
type pref_prop = Linear | Weakly_Separable | Separable | Additively_Separable
type pref_props = pref_prop list
type utility = bundle -> value
type util_prop = Modular | Additively_Independant
type util_props = util_prop list
type _ mode =
    Ord : preference * pref_props -> [ `Ord ] mode
  | Card : utility * util_props -> [ `Card ] mode
type 'm profile = 'm mode array
type 'm setting = {
  nb_agents : value;
  nb_resources : value;
  profile : 'm profile;
}
val create_setting : int -> int -> 'm profile -> 'm setting
val bundle_of_agent : allocation -> int -> bundle
val gen_of_add : (resource -> value) -> bundle -> value
val add_of_gen : (bundle -> value) -> resource -> value
val util_of_card : [ `Card ] setting -> int -> utility
val pref_of_ord : [ `Ord ] setting -> int -> preference
val mark_occurences : int array -> int list -> unit
val is_complete : 'm setting -> allocation -> bool
val max_resource_bundle : bundle -> resource
val max_resource : allocation -> int
val is_nonshareable : allocation -> bool
val is_proportional_for_agent :
  [ `Card ] setting -> allocation -> agent -> bool
val is_proportional : [ `Card ] setting -> allocation -> bool
val is_envy_free_for_agent : [ `Card ] setting -> allocation -> agent -> bool
val is_envy_free : [ `Card ] setting -> allocation -> bool
val pareto_dominates : [ `Ord ] setting -> allocation -> allocation -> bool
val strongly_pareto_dominates :
  [ `Ord ] setting -> allocation -> allocation -> bool
