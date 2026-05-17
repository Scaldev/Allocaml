let run (name: string) (tss: 'a) : unit =
  let tests = List.map (fun ts ->
    (fst ts, List.map (fun t -> Alcotest.test_case "" `Quick t) (snd ts))
  ) tss in
  Alcotest.run name tests