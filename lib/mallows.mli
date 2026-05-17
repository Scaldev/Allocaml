(**
  [create phi r] returns a Mallows model of dispersion [phi] and ranking of
  list [r].
*)
val create : float -> 'good list -> 'good Model.t