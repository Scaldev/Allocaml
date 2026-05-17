type 'good t = {
    sample : unit -> 'good Ranking.t;
    chance : 'good Ranking.t -> float;
}

let space (n: int) : string =
    String.make n ' '

let rec longest_length (ss: string list) : int =
    match ss with
    | []       -> -1
    | s :: ss' -> max (String.length s) (longest_length ss')
  
let print_header (len: int) (n: int) : unit = 
    Printf.printf "| good%s |" (space (len - 4)) ;
    List.iter (fun i -> Printf.printf "  #%-2i |" i) (List.init n ((+) 1)) ;
    print_newline () ;
    String.make (len + 4 + n * 7) '-' |> print_endline

let print_row (len: int) (f: 'good -> string) (n_samples: int) (counts: ('good, int array) Hashtbl.t) (good: 'good) = 
    let name = f good in
    Printf.printf "| %s%s |" name (space (len - String.length name)) ;
    Array.iter (fun count ->
        let freq = float_of_int count /. float_of_int n_samples in
        Printf.printf " %.2f |" freq
    ) (Hashtbl.find counts good) ;
    print_newline ()

let simulate (model: 'good t) (goods: 'good list) (f: 'good -> string) (n_samples: int) : unit =
    let m      = List.length goods in
    let len    = longest_length (List.map f goods) in
    let counts = goods
        |> List.map (fun r -> r, Array.make m 0)
        |> List.to_seq
        |> Hashtbl.of_seq
    in
    for _ = 1 to n_samples do
        model.sample ()
        |> Ranking.to_list
        |> List.iteri (fun rank good ->
            let table = Hashtbl.find counts good in
            table.(rank) <- table.(rank) + 1
        )
    done ;
    print_header len m ;
    List.iter (print_row len f n_samples counts) goods ;