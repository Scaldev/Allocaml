(*****************************************************************************)
(*                             of_list, to_list                              *)
(*****************************************************************************)

let test_list_1 () =
  let xs = ['b'; 'd'; 'a'; 'c'] in
  let expected = xs in
  let obtained = Ranking.to_list (Ranking.of_list xs) in
  Alcotest.(check (list char)) "" expected obtained

let tests_list = "list", [test_list_1]

(*****************************************************************************)
(*                                    length                                 *)
(*****************************************************************************)

let test_length_1 () =
  let xs = Ranking.of_list ['b'; 'd'; 'a'; 'c'] in
  let expected = 4 in
  let obtained = Ranking.length xs in
  Alcotest.(check int) "" expected obtained

let tests_length = "length", [test_length_1]

(*****************************************************************************)
(*                                   to_string                               *)
(*****************************************************************************)

let test_to_string_1 () =
  let ranking = Ranking.of_list ['b'; 'd'; 'a'; 'c'] in
  let f c = String.make 1 c in 
  let expected = "b > d > a > c" in
  let obtained = Ranking.to_string f ranking in
  Alcotest.(check string) "" expected obtained

  let test_to_string_2 () =
    let ranking  = Ranking.of_list ["Bob"; "Alice"; "Charlie"] in
    let expected = "Bob > Alice > Charlie" in
    let obtained = Ranking.to_string Fun.id ranking in
    Alcotest.(check string) "" expected obtained

let tests_to_string = "to_string", [test_to_string_1 ; test_to_string_2]

(*****************************************************************************)
(*                                is_ranking                                 *)
(*****************************************************************************)

let test_is_ranking_1 () =
  let goods    = ['a'; 'b'; 'c'; 'd'] in
  let ranking  = Ranking.of_list ['b'; 'd'; 'a'; 'c'] in
  let obtained = Ranking.is_ranking ranking goods in
  Alcotest.(check bool) "" true obtained

let test_is_ranking_2 () =
  let goods    = ['a'; 'b'; 'c'; 'd'] in
  let ranking  = Ranking.of_list ['b'; 'e'; 'a'; 'c'] in
  let obtained = Ranking.is_ranking ranking goods in
  Alcotest.(check bool) "" false obtained

let tests_is_ranking = "is_ranking", [
  test_is_ranking_1;
  test_is_ranking_2
]

(*****************************************************************************)
(*                                   rank                                    *)
(*****************************************************************************)

let test_rank_1 () =
  let ranking  = Ranking.of_list ['b'; 'd'; 'a'; 'c'] in
  let obtained = Ranking.rank ranking 'a' in
  Alcotest.(check int) "" 3 obtained

let test_rank_2 () =
  let ranking  = Ranking.of_list ['b'; 'd'; 'a'; 'c'] in
  let f () =
    let _ = Ranking.rank ranking 'z' in ()
  in
  Alcotest.match_raises "" ((=) Ranking.Unranked_good) f
  
let tests_rank = "rank", [
  test_rank_1;
  test_rank_2
]

(*****************************************************************************)
(*****************************************************************************)
(*****************************************************************************)

let tests = [
  tests_list;
  tests_length;
  tests_to_string;
  tests_is_ranking;
  tests_rank
]

let () = Test_allocaml.run "Ranking" tests