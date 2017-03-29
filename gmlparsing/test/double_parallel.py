rules = [
  ({'Init'},{'ParallelUpA','ParallelDownA'}),
  ({'ParallelUpA'},{'ParallelUpAA','ParallelDownAA'}),
  ({'ParallelUpAA'},{'ParallelUpAB'}),
  ({'ParallelDownAA'},{'ParallelDownAB'}),
  ({'ParallelDownA'},{'ParallelDownB'}),
  ({'ParallelUpAB', 'ParallelDownAB', 'ParallelDownB'},{'Finish'}),
  ]
  
traces = [[{'Init'}]]
changed = True
while changed:
  new_traces = []
  for t in traces:
    changed2 = False
    for (inp, out) in rules:
      if inp <= t[-1]:
        changed2=True
        new_traces.append(t + [t[-1].difference(inp).union(out)])
    if not changed2:
      new_traces.append(t)
  changed = not (new_traces == traces)
  traces = new_traces

# Order results and remove equal traces (should not occur - but better save than sound)
traces = sorted(list({tuple([tuple(sorted(s)) for s in t]) for t in traces}))
print("Number of traces:", len(traces))
for t in traces:
  print(t)
