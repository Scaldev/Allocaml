type ('agent, 'good) t

exception Unknown_agent
exception Invalid_ranking

(**
    [create goods] returns a preference profile for the [goods].    
*)
val create : 'good list -> ('agent, 'good) t

(**
    [add p a r] adds the ranking [r] of agent [a] to the profile [p].

    @raises Invalid_ranking if [r] is not a ranking of the goods in [p].
*)
val add : ('agent, 'good) t -> 'agent -> 'good Ranking.t -> unit

(**
    [rank_of p a] returns the ranking of agent [a].
    
    @raises Unknown_agent if [a] is not an agent in [p].
*)
val ranking_of : ('agent, 'good) t -> 'agent -> 'good Ranking.t

(**
    [rank p a g] returns the rank of good [g] in the ranking of agent [a]
    given profile [p].

    @raises Unknown_agent if [a] is not an agent in [p].
    @raises Ranking.Unranked_good if [g] is not ranked by [a].
*)
val rank : ('agent, 'good) t -> 'agent -> 'good -> int

(**
    [to_string f g p] returns the string representation of the profile
    [p] given [f] and [g] two functions that return the string representation
    of agents and goods respectively.    
*)
val to_string : ('agent -> string) -> ('good -> string) -> ('agent, 'good) t -> string