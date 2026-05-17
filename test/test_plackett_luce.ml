(*****************************************************************************)
(*                                   sample                                  *)
(*****************************************************************************)

let test_sample_1 () =
  let model = Plackett_luce.create ['a', 10e9; 'b', 1.0; 'c', 10e-9] in
  let expected = ['a'; 'b'; 'c'] in 
  let obtained = Ranking.to_list (model.sample ()) in
  Alcotest.(check (list char)) "" expected obtained

let tests_sample = "sample", [test_sample_1]

(*****************************************************************************)
(*****************************************************************************)
(*****************************************************************************)

let tests = [
  tests_sample
]

let () = Test_allocaml.run "Plackett-luce" tests