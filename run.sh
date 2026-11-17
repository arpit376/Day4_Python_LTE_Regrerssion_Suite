#!/usr/bin/env bash
# Shortcuts for the Day 4 lab.   ./run.sh <mode>     Every mode is a plain robot command (see README).
cd "$(dirname "$0")" || exit 1
PY="${PYTHON:-python3}"
R="$PY -m robot -A lab.args"
case "${1:-help}" in
  check)      $PY check_setup.py ;;
  unit)       $PY -m unittest discover tests_py -v ;;
  functional) $R --include functional --include negative --outputdir results/functional suites ;;
  protocol)   $R --outputdir results/protocol suites/05_protocol_checks.robot ;;
  kpi)        $R --outputdir results/kpi suites/06_kpi.robot suites/07_sweep.robot ;;
  smoke)      $R --include smoke --outputdir results/smoke suites ;;
  full)       $R --exclude long --outputdir results/full suites ;;
  fault)      [ -n "$2" ] || { echo "Usage: ./run.sh fault <name>   (no_ip dup_ip bad_order erab_mismatch teid_mismatch low_tput high_latency flaky core_down)"; exit 1; }
              LAB_FAULT="$2" $R --outputdir "results/fault_$2" suites ;;
  triage)     $R --outputdir results/triage demos/triage_demo.robot ;;
  trace)      $PY tools/trace_matrix.py ${2:-results/full/output.xml} ;;
  mine)       $R --outputdir results/mine exercises/my_functional_tests.robot ;;
  dryrun)     $R --dryrun --outputdir results/dryrun suites demos exercises ;;
  *) echo "Usage: ./run.sh check|unit|functional|protocol|kpi|smoke|full|fault <name>|triage|trace [output.xml]|mine|dryrun"; exit 1 ;;
esac
