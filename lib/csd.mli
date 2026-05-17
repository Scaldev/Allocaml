type csd = int array

type ('agent, 'good) alloc = ('agent * 'good list) list

val allocate : csd -> ('agent, 'good) Profile.t -> ('agent, 'good) alloc
