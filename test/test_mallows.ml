(*****************************************************************************)
(*                                   sample                                  *)
(*****************************************************************************)

let test_sample_1 () =
  let model = Mallows.create 0.0 ['a'; 'b'; 'c'] in
  let expected = ['a'; 'b'; 'c'] in
  let obtained = Ranking.to_list (model.sample ()) in
  Alcotest.(check (list char)) "" expected obtained

let test_sample_2 () =
  let model = Mallows.create 0.5 ['a'; 'b'; 'c'] in
  let obtained = Ranking.is_ranking (model.sample ()) ['a'; 'b'; 'c'] in
  Alcotest.(check bool) "" true obtained

let tests_sample = "sample", [test_sample_1; test_sample_2]

(*****************************************************************************)
(*****************************************************************************)
(*****************************************************************************)

let tests = [
  tests_sample
]

let () = Test_allocaml.run "Mallows" tests