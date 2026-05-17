type 'good t

exception Unranked_good

(** [of_list [x_1; ...; x_n]] returns the ranking [[x_1 > ... > x_n]]. *)
val of_list : 'good list -> 'good t

(** [to_list [x_1 > ... > x_n]] returns the list [[x_1; ...; x_n]]. *)
val to_list : 'good t -> 'good list

(** [length [x_1 > ... > x_n]] returns [n]. *)
val length : 'good t -> int

(**
  {b Precondition:} [xs] is a list of unique values.

  [is_ranking r xs] returns [true] iff [r] is a permutation of [xs].
    
  {b Complexity:} In [O(|xs| + |r|)] time and space.
*)
val is_ranking :  'good t -> 'good list -> bool

(**
    [rank r g] returns the rank of good [g] in the ranking [r].

    @raises Unranked_good if [g] is not ranked in [r].   	
*)
val rank : 'good t -> 'good -> int

(**
  Return the [n]-th element of the ranking. The top-ranked good is at position 1.

  @raise Failure if the list is too short.

  @raise Invalid_argument if [n] is negative.
*)
val nth : 'good t -> int -> 'good

(**
  {b Precondition:} all goods in [goods] are ranked in [r].

  [take r goods n] returns a pair [(taken, remaining)] such that
  [taken] are the [n] most prefered goods in [goods] according to [r],
  [remaining] the others.
  
  {b Postcondition:} The goods in [taken] are ordered from most prefered to
  least prefered. The order in [remaining] is the same as in [goods].

  {b Complexity:} In [O(|r|)].
*)
val take : 'good t -> 'good list -> int -> 'good list * 'good list

(** [to_string f [x_1 > ... > x_n]] returns [f x_1 > ... > f x_n] as a string. *)
val to_string : ('good -> string) -> 'good t -> string