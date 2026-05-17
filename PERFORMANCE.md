# Sodium PowerShell Module — Performance Improvements

This document captures the cumulative performance work landed in the
[`fix/44-harden-sodium-interop`](https://github.com/PSModule/Sodium/tree/fix/44-harden-sodium-interop)
branch (PR #45) that hardens the Sodium interop layer. Each issue listed below
was implemented and benchmarked independently against the previous prerelease,
so the incremental contribution of every change can be attributed precisely.

## Methodology

- Each improvement was committed to the same branch, published to the PowerShell
  Gallery as an incrementing prerelease of `2.2.3-fix44hardensodiuminterop00X`,
  and benchmarked from a clean PowerShell session on Windows 11 (x64).
- Each scenario was executed as **5 trials of 1,000 iterations**; the reported
  number is the median per-iteration time in microseconds (µs).
- Cold start is measured as 5 isolated runs of "import module + generate one
  key pair" in a fresh `pwsh -NoProfile` process; reported number is the
  median total time in microseconds.
- Raw measurements live in `tools/perf/results.jsonl` (git-ignored, local-only).
- Benchmark scenarios:
  - `New-SodiumKeyPair` — generate a random key pair.
  - `New-SodiumKeyPair-Seeded` — generate a deterministic key pair from a UTF-8 seed.
  - `Get-SodiumPublicKey` — derive the public key from a base64 private key.
  - `ConvertTo-SodiumSealedBox` — seal a short plaintext for a recipient.
  - `ConvertFrom-SodiumSealedBox` — open a sealed box (private key only).
  - `ColdStart-Import+OneKeyPair` — full module import + one key pair.

## Cumulative results

All numbers are median µs per iteration. Δ is relative to the **baseline**.

| Scenario                       | Baseline | Final (#52) |     Δ |
| ------------------------------ | -------: | ----------: | ----: |
| New-SodiumKeyPair              |     73.6 |        49.1 | −33 % |
| New-SodiumKeyPair-Seeded       |     94.9 |        48.8 | −49 % |
| Get-SodiumPublicKey            |     66.1 |        46.7 | −29 % |
| ConvertTo-SodiumSealedBox      |    135.8 |       105.4 | −22 % |
| ConvertFrom-SodiumSealedBox    |    196.3 |       109.0 | −44 % |
| ColdStart-Import+OneKeyPair    |  287,076 |     279,362 |  −3 % |

The warm-path scenarios all dropped 20–49 %; the dominant share of that came
from moving conversion and validation work into the C# layer (#52) and from
caching libsodium-reported size constants (#48, #51).

## Per-issue contribution (median µs)

Each row shows the median for the prerelease that *introduced* the change and
its incremental delta versus the previous prerelease.

### [#50 — Use `SHA256.HashData` for seed derivation](https://github.com/PSModule/Sodium/issues/50)

Replaces the allocating `SHA256.Create().ComputeHash(...)` pattern with the
static `SHA256.HashData` API.

| Scenario                       |  Prev |  This |     Δ |
| ------------------------------ | ----: | ----: | ----: |
| New-SodiumKeyPair-Seeded       |  94.9 |  87.6 | −8 %  |
| Others                         |     – |     – | ~noise |

### [#54 — Defer Visual C++ Redistributable probe to first failure](https://github.com/PSModule/Sodium/issues/54)

Moves the (expensive) registry walk that detects `vcruntime140.dll` out of the
module import path; the probe only runs if `sodium_init` actually fails. No
warm-path win on its own (within noise) but reduces import-time risk on
machines without the runtime installed.

| Scenario                       |  Prev |  This |     Δ |
| ------------------------------ | ----: | ----: | ----: |
| ColdStart-Import+OneKeyPair    | 284.8 ms | 300.9 ms | within noise |

### [#49 — Inline `crypto_scalarmult_base` in sealed-box open](https://github.com/PSModule/Sodium/issues/49)

Derives the recipient public key in-place inside `ConvertFrom-SodiumSealedBox`
instead of calling back into `Get-SodiumPublicKey`, eliminating one cmdlet
dispatch + one base64 round-trip per open.

| Scenario                       |  Prev |  This |     Δ |
| ------------------------------ | ----: | ----: | ----: |
| ConvertFrom-SodiumSealedBox    | 219.4 | 167.2 | **−24 %** |

### [#53 — Initialize libsodium at module import](https://github.com/PSModule/Sodium/issues/53)

Calls `sodium_init` once during module load instead of lazily on first cmdlet
invocation. Removes a per-call init check from every code path.

| Scenario                       |  Prev |  This |     Δ |
| ------------------------------ | ----: | ----: | ----: |
| New-SodiumKeyPair              |  75.7 |  66.7 | −12 % |
| New-SodiumKeyPair-Seeded       |  92.0 |  82.5 | −10 % |
| Get-SodiumPublicKey            |  70.2 |  60.3 | −14 % |
| ConvertTo-SodiumSealedBox      | 141.1 | 133.0 |  −6 % |
| ConvertFrom-SodiumSealedBox    | 167.2 | 161.8 |  −3 % |
| ColdStart-Import+OneKeyPair    | 292.9 ms | 280.7 ms | −4 % |

### [#51 — Cache libsodium size constants in C#](https://github.com/PSModule/Sodium/issues/51)

Reads `crypto_box_publickeybytes`, `secretkeybytes`, `sealbytes` and
`seedbytes` once into `static readonly` ints; subsequent allocations avoid the
P/Invoke per call. Also fixes a long-standing bug where `New-SodiumKeyPair
-Seed` validated against `SecretKeyBytes` (32) instead of `SeedBytes` (32 too,
but coincidentally — the validation was conceptually wrong).

| Scenario                       |  Prev |  This |     Δ |
| ------------------------------ | ----: | ----: | ----: |
| New-SodiumKeyPair              |  66.7 |  65.7 |  −1 % |
| New-SodiumKeyPair-Seeded       |  82.5 |  80.0 |  −3 % |
| Get-SodiumPublicKey            |  60.3 |  57.7 |  −4 % |
| ConvertTo-SodiumSealedBox      | 133.0 | 126.7 |  −5 % |
| ConvertFrom-SodiumSealedBox    | 161.8 | 155.4 |  −4 % |

### [#48 — Migrate `DllImport` to `LibraryImport` source generator](https://github.com/PSModule/Sodium/issues/48)

Switches every libsodium binding to `[LibraryImport]` partial methods, lets
the source generator emit the marshalling stubs at compile time, and makes
the assembly AOT-ready. Warm-path change is within measurement noise — the
value is in eliminating runtime IL stub generation and unblocking future AOT
publishing.

| Scenario                       |  Prev |  This |     Δ |
| ------------------------------ | ----: | ----: | ----: |
| New-SodiumKeyPair              |  65.7 |  66.5 | +1 %  |
| Others                         |   ~noise |    |       |

### [#52 — Move base64 conversion into C#](https://github.com/PSModule/Sodium/issues/52)

The PowerShell cmdlets previously called byte-array C# APIs and did all
`Convert.FromBase64String` / `Convert.ToBase64String` work in PS, paying the
PowerShell engine cost for one extra reflective .NET call per cmdlet and
allocating intermediate arrays in two languages. This change adds
`SealBase64`, `OpenSealBase64`, `DerivePublicKeyBase64`, and
`GenerateKeyPairBase64` overloads that take and return base64 strings
directly, so each cmdlet now performs a single C# call.

This is the largest single contribution to the warm path.

| Scenario                       |  Prev |  This |     Δ |
| ------------------------------ | ----: | ----: | ----: |
| New-SodiumKeyPair              |  66.5 |  49.1 | **−26 %** |
| New-SodiumKeyPair-Seeded       |  83.7 |  48.8 | **−42 %** |
| Get-SodiumPublicKey            |  59.1 |  46.7 | **−21 %** |
| ConvertTo-SodiumSealedBox      | 127.6 | 105.4 | **−17 %** |
| ConvertFrom-SodiumSealedBox    | 158.0 | 109.0 | **−31 %** |

## Biggest wins

1. **#52 (base64 in C#)** — single largest contributor, 17–42 % on every warm
   scenario.
2. **#53 (init at import)** — 6–14 % across the board for the first round of
   warm-path savings.
3. **#49 (inline scalarmult)** — a focused 24 % win on the sealed-box open path.

## Verifying locally

The benchmark harness lives in `tools/perf/` (git-ignored). To reproduce:

```powershell
pwsh -NoProfile -File tools/perf/Invoke-Benchmark.ps1 `
    -Version '2.2.3-fix44hardensodiuminterop009' `
    -Label   '#52 base64 C# APIs' `
    -Iterations 1000 -Trials 5 -ColdStartIterations 5
```

Results append to `tools/perf/results.jsonl` for later analysis.
