# Day 4 Lab Kit: The LTE Regression Suite

Everything for the Day 4 labs of *Telecom Testing (4G) Using Python & Robot Framework*
(Module 10): functional suites, negative tests, protocol-level checks, KPI measurements,
data-driven sweeps and a requirement-to-result matrix.

It runs on a laptop or on the lab VM with **no network hardware**: a simulated lab (the same
stand-in idea as Day 3) behaves like a small LTE network and can break in nine different ways.
On the real VM you replace one file with your Day 2 code (see
[Moving to the real lab](#moving-to-the-real-lab)).

## 1. Setup (5 minutes)

Python 3.8+ and Robot Framework 6+. If you did the Day 3 kit you already have everything.

```bash
git clone https://github.com/arpit376/Day4_Python_LTE_Regrerssion_Suite.git
cd day4_lte_regression
python3 -m venv .venv && source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python check_setup.py                                     # must print READY
```

`tshark` and `iperf3` are only needed on the real VM; the kit simulates both.

## 2. What is in the folder

| Path | What it is | Module |
|---|---|---|
| `suites/01_attach_detach.robot` | Attach and detach, written as complete test cases | 4.1, 4.2 |
| `suites/02_auth_failure.robot` | Negative tests: wrong key, unknown IMSI, recovery | 4.2 |
| `suites/03_bearer_idle_tau.robot` | Default bearer, service request after idle, TAU | 4.2 |
| `suites/04_multi_ue.robot` | Ten UEs attach together, unique IPs | 4.2 |
| `suites/05_protocol_checks.robot` | Decode a capture and assert order, E-RAB ID, TEIDs, GTP-U | 4.3 |
| `suites/06_kpi.robot` | Attach success rate, setup p95, throughput after warm-up, latency | 4.4 |
| `suites/07_sweep.robot` | One test body, three rows: bandwidth and UE count | 4.4 |
| `demos/triage_demo.robot` | Three red results to classify (fail on purpose) | 4.2 |
| `resources/` | `network`, `procedures`, `protocol` and `kpi` resource files | all |
| `libraries/LteLib.py` | Procedure keywords: attach, bearer, idle, TAU, multi-UE | all |
| `libraries/ProtocolLib.py` | Capture and message-level assertions | 4.3 |
| `libraries/KpiLib.py` | Attach cycles, median, p95, throughput, latency | 4.4 |
| `libraries/capture_backend.py` | Reads a capture: simulated JSON, or a real pcap through tshark | 4.3 |
| `libraries/day2_lte.py` | Stand-in for your Day 2 code, with fault injection | all |
| `env/lab01.py`, `env/lab02.py` | Variable files with hosts, expected causes and KPI thresholds | all |
| `data/requirements.csv` | Requirement IDs for the traceability matrix | 4.1 |
| `tools/trace_matrix.py` | Requirement, test, result table and coverage gaps | 4.1 |
| `tests_py/` | Plain Python tests of the NAS-order logic (no Robot, no tshark) | 4.3 |
| `exercises/` | Test case template and your own tests to write | 4.1, 4.2 |
| `run.sh`, `lab.args`, `check_setup.py` | Shortcuts and setup check | all |

Results go to `results/<run>/`. Open `report.html` for the summary and `log.html` for the trace.
`./run.sh` is a thin wrapper; the plain command is `python3 -m robot -A lab.args ...`.

## 3. Quick start

```bash
./run.sh full       # 21 tests, all green
./run.sh trace      # requirement-to-result matrix, with coverage gaps
```

## 4. Module 4.1: Designing LTE tests

Open `suites/01_attach_detach.robot`. Each test states precondition, stimulus, pass criteria
and a requirement tag, in its `[Documentation]` and `[Tags]`.

1. Fill in `exercises/test_case_template.md` for the wrong-key test (Exercise 1).
2. Run `./run.sh full`, then `./run.sh trace`. The matrix lists tests per requirement and ends
   with **GAPS**: requirements that no test covers. Pick one (`REQ-DETACH-02`) and design it
   with the template before you write any code (Exercise 2).

## 5. Lab 4.2: Functional suites (~65 min)

**Step 1. Baseline.** Run the pre-built functional suites and read the report.

```bash
python3 -m robot -A lab.args --include functional --include negative --outputdir results/functional suites
```

**Step 2. Add a negative test.** Open `exercises/my_functional_tests.robot`, replace the `Fail`
line of *My Wrong Key Authentication Test* and run it:

```bash
python3 -m robot -A lab.args --outputdir results/mine exercises/my_functional_tests.robot
```

A good negative test asserts the **specific** rejection: status, cause, and that no bearer exists.
"Attach failed" is not a pass.

**Step 3. Add multi-UE.** Write *My Concurrent Attach Test* (5 UEs) in the same file. Then raise
the count in `suites/04_multi_ue.robot` (`${UE_COUNT}`). The simulated VM holds 32 UEs; set
`LAB_MAX_UES=8` before the run to see the limit.

**Step 4. Triage.** Run the three red results and classify each *before* debugging:

```bash
python3 -m robot -A lab.args --outputdir results/triage demos/triage_demo.robot
```

Each is a **product defect** (network wrong), **test defect** (test wrong) or **environment**
(lab wrong). Open `log.html` and the `artefacts/lab.log` link for evidence.

## 6. Module 4.3: Protocol-level checks

```bash
python3 -m robot -A lab.args --outputdir results/protocol suites/05_protocol_checks.robot
python3 -m unittest discover tests_py -v
```

`05_protocol_checks.robot` captures an attach plus a ping, then asserts on **messages, not log
text**: NAS order (Attach Request, Authentication, Security Mode, Attach Accept, Attach Complete),
Security Mode before Attach Accept, E-RAB ID equals EPS bearer ID, uplink and downlink TEIDs match
the setup, a ping inside GTP-U, and for a rejected attach: the right cause and no context setup.
Captures are kept in `results/protocol/captures/`.

`tests_py/` shows the same order check as plain Python on tshark-style output, the code from the
slide. Break it: edit `data/attach_decoded_tshark.txt` so Attach Accept (`0x42`) comes before
Security Mode Command (`0x5d`) and watch the test fail.

## 7. Lab 4.4: KPI and data-driven tests (~60 min)

```bash
python3 -m robot -A lab.args --outputdir results/kpi suites/06_kpi.robot suites/07_sweep.robot
```

* `06_kpi.robot`: 40 attach cycles give success rate, median and **p95**; throughput is the mean
  **after a 2 s warm-up** is excluded; latency is the p95 of 30 pings. Thresholds come from
  `env/lab01.py`, not from the tests. A JSON summary is written to the results folder.
* `07_sweep.robot`: a **test template**. Three rows (5, 10, 20 MHz with 1, 1 and 2 UEs) run one
  keyword. **Add a row, not a test**: add `15 MHz, 1 UE    15    1    25.0` and run again.

## 7b. Make it fail on purpose: fault injection

```bash
./run.sh fault <name>        # or:  LAB_FAULT=<name> python3 -m robot -A lab.args suites
```

| Fault | What the network does wrong | First test that goes red |
|---|---|---|
| `no_ip` | Attach works, no IP allocated | Attach With A Valid Subscriber |
| `dup_ip` | Two UEs get the same IP | Ten UEs Attach Concurrently |
| `bad_order` | Security Mode arrives after Attach Accept | NAS Messages Appear In The Specified Order |
| `erab_mismatch` | E-RAB ID differs from the bearer ID | E-RAB ID Matches The EPS Bearer ID |
| `teid_mismatch` | Downlink GTP-U uses another TEID | Tunnel IDs Are Consistent... |
| `low_tput` | Throughput 60% too low | Throughput test and the sweep rows |
| `high_latency` | +60 ms per ping | Latency Of Many Pings |
| `flaky` | 15% of attaches randomly rejected | Attach Success Rate And Setup Time |
| `core_down` | Core never answers | everything (environment) |

For each, read the failure message first: does it name the next step?

## 8. Trainer notes: triage answers

| Red result | Class | Evidence | Fix |
|---|---|---|---|
| A | **Product defect** | `lab.log` shows `Attach Complete ... ip=none`: attach worked, no IP | Raise a defect, link the test |
| B | **Test defect** | `Attach Reject` cause 8: the subscriber was never provisioned | Provision first, then fix the test |
| C | **Environment** | `TIMEOUT`, `no response`: the core is not running | Fix the setup, rerun |

## Cheat sheet

| I want to | Command |
|---|---|
| Run everything | `python3 -m robot -A lab.args suites` |
| Smoke set only | `--include smoke` |
| One requirement | `--include REQ-AUTH-01` |
| Skip long runs | `--exclude long` |
| Matrix of results | `python tools/trace_matrix.py results/full/output.xml` |
| One test | `--test "Attach With Wrong Key Is Rejected"` |

## Moving to the real lab

Replace the function bodies in `libraries/day2_lte.py` with your Day 2 code and keep the names
and the `AttachResult` fields (`imsi`, `status`, `cause`, `ip`, `setup_ms`). The suites,
resources and the three libraries keep working.

Real captures: give `Stop Capture` a `.pcap` path. NAS order is decoded with tshark out of the
box (`capture_backend.tshark_nas_sequence`). **Stretch exercise:** extend `tshark_events()` to
S1AP IEs and GTP-U TEIDs (`-e s1ap.*`, `-e gtp.teid`) so the other protocol checks also run on
real pcaps. Check the field names of your tshark version. NAS is readable only without ciphering.

## Troubleshooting

| Problem | Fix |
|---|---|
| `No keyword with name 'Attach UE' found` | Run with `-A lab.args` and from inside this folder |
| `ModuleNotFoundError: robot` | Activate the venv and `pip install -r requirements.txt` |
| Everything fails after a fault test | `unset LAB_FAULT` (Windows: `Remove-Item Env:LAB_FAULT`) |
| `Ten UEs` times out | `LAB_MAX_UES` is set too low, or raise it |
| Sweep rows fail by a small margin | Thresholds are in `env/lab01.py`; thresholds depend on the environment |
