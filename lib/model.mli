type 'good t = {
    sample : unit -> 'good Ranking.t;
    chance : 'good Ranking.t -> float;
}

val simulate : 'good t -> 'good list -> ('good -> string) -> int -> unit