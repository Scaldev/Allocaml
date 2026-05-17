include Mallow

let () = Random.self_init ()


let () =
  let dispersion = 0.1 in
  let goods = ["Alice"; "Bob"; "Charlie"; "Denise"; "Eve"; "Fabien"] in
  let model = Mallows.create dispersion goods in
  let f = Fun.id in
  let n_samples = 100_000 in
  Model.simulate model goods f n_samples ;
  print_newline ()

let () =
  let mm = 10e6 in
  let (^.) = Float.pow in
  let value_vector = ["Alice", mm ^. 5.; "Bob", mm ^. 4.; "Charlie", mm ^. 3.; "Denise", mm ^. 2.; "Eve", mm ^. 1.; "Fabien", 1.] in
  let goods = List.map fst value_vector in
  let model = Plackett_luce.create value_vector in
  let f = Fun.id in
  let n_samples = 100_000 in
  Model.simulate model goods f n_samples ;
  print_newline ()