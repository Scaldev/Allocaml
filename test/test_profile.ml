(*****************************************************************************)
(*                              create, goods_of                             *)
(*****************************************************************************)

let test_goods_of_1 () =
  let goods    = ['a'; 'b'; 'c'; 'd'] in
  let p        = Profile.create goods in
  let expected = goods in
  let obtained = Profile.goods_of p in
  Alcotest.(check (list char)) "" expected obtained

let tests_goods_of = "goods_of", [test_goods_of_1]

(*****************************************************************************)
(*                                    add                                    *)
(*****************************************************************************)

let test_add_1 () =
  let goods = ['a'; 'b'; 'c'; 'd'] in
  let p = Profile.create goods in
  Profile.add p "Alice" (Ranking.of_list ['b'; 'd'; 'a'; 'c']) ;
  let f () =
    let _ = Profile.add p "Bob" (Ranking.of_list ['b'; 'e'; 'a'; 'c']) in ()
  in
  Alcotest.match_raises "aaa" ((=) Profile.Invalid_ranking) f

let tests_add = "add", [test_add_1]

(*****************************************************************************)
(*                                    to_list                                *)
(*****************************************************************************)

let test_to_list_1 () =

  let p = Profile.create ['a'; 'b'; 'c'; 'd'] in
  Profile.add p "Alice" (Ranking.of_list ['b'; 'd'; 'a'; 'c'] ) ;
  Profile.add p "Bob"   (Ranking.of_list ['a'; 'c'; 'd'; 'b'] ) ;

  let obtained = p
    |> Profile.to_list
    |> List.map  (fun (a, r) -> a, Ranking.to_list r)
    |> List.sort (fun (a, _) (b, _) -> String.compare a b)
  in

  let expected = [
    ("Alice", ['b'; 'd'; 'a'; 'c']) ;
    ("Bob"  , ['a'; 'c'; 'd'; 'b'])
  ] in

  Alcotest.(check (list (pair string (list char)))) "" expected obtained

let tests_to_list = "to_list", [test_to_list_1]

(*****************************************************************************)
(*                                  ranking_of                               *)
(*****************************************************************************)

let test_ranking_of_1 () =
  let p = Profile.create ['a'; 'b'; 'c'; 'd'] in
  let ranking = ['b'; 'd'; 'a'; 'c'] in
  Profile.add p "Alice" (Ranking.of_list ranking) ;
  let expected = ranking in
  let obtained = Ranking.to_list (Profile.ranking_of p "Alice") in
  Alcotest.(check (list char)) "" expected obtained

let test_ranking_of_2 () =
  let p = Profile.create ['a'; 'b'; 'c'; 'd'] in
  let ranking = ['b'; 'd'; 'a'; 'c'] in
  Profile.add p "Alice" (Ranking.of_list ranking) ;
  let f () =
    let _ = Ranking.to_list (Profile.ranking_of p "Bob") in ()
  in
  Alcotest.match_raises "" ((=) Profile.Unknown_agent) f

let tests_ranking_of = "ranking_of", [test_ranking_of_1; test_ranking_of_2]

(*****************************************************************************)
(*                                     rank                                  *)
(*****************************************************************************)

let test_rank_1 () =
  let p = Profile.create ['a'; 'b'; 'c'; 'd'] in
  Profile.add p "Alice" (Ranking.of_list ['b'; 'd'; 'a'; 'c'] ) ;
  let expected = 2 in
  let obtained = Profile.rank p "Alice" 'd' in
  Alcotest.(check int) "" expected obtained

let tests_rank = "rank", [test_rank_1]

(*****************************************************************************)
(*                                  to_string                                 *)
(*****************************************************************************)

let test_to_string_1 () =
  let p = Profile.create ['a'; 'b'; 'c'; 'd'] in
  Profile.add p "Alice"   (Ranking.of_list ['b'; 'd'; 'a'; 'c'] ) ;
  Profile.add p "Bob"     (Ranking.of_list ['a'; 'c'; 'd'; 'b'] ) ;
  Profile.add p "Charlie" (Ranking.of_list ['c'; 'b'; 'b'; 'a'] ) ;
  let expected = 
    "Alice  : b > d > a > c\n" ^
    "Bob    : a > c > d > b\n" ^
    "Charlie: c > b > b > a"
  in
  let obtained = Profile.to_string Fun.id (String.make 1) p in
  Alcotest.(check string) "" expected obtained

let tests_to_string = "to_string", [test_to_string_1]

(*****************************************************************************)
(*****************************************************************************)
(*****************************************************************************)

let tests = [
  tests_goods_of;
  tests_add;
  tests_to_list;
  tests_ranking_of;
  tests_rank;
  tests_to_string
]

let () = Test_allocaml.run "Profile" tests