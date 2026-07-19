# Benchmark tools

Performance test harness for the Sodium module. Requires PowerShell 7+ and the
[Profiler](https://github.com/nohwnd/Profiler) module (for `Invoke-ProfilerTrace.ps1` only).

| Script | Purpose |
| ------ | ------- |
| `Build-LocalModule.ps1` | Assembles an importable module from `src/` (same order as the PSModule build pipeline). Returns the path to the built `Sodium.psd1`. |
| `Invoke-PerformanceBenchmark.ps1` | Stopwatch micro-benchmarks for every public action showcased in the test suite (key pairs, sealed boxes, pipeline variants, error paths, parallel runspaces). Writes `bench-<Label>.json`. |
| `Invoke-ImportBenchmark.ps1` | Cold `Import-Module` time in fresh `pwsh` processes — the dominant cost for multi-session usage. Writes `import-<Label>.json`. |
| `Invoke-ProfilerTrace.ps1` | Profiler line-level trace of a representative workload; prints top self-duration lines. |

All scripts build the module from `src/` into a temp folder automatically when `-ModulePath` is omitted.

## Typical flow

```powershell
# Baseline numbers
.\Invoke-PerformanceBenchmark.ps1 -Label baseline
.\Invoke-ImportBenchmark.ps1 -Label baseline

# ...make changes to src/...

# Compare
.\Invoke-PerformanceBenchmark.ps1 -Label change
.\Invoke-ImportBenchmark.ps1 -Label change
```
