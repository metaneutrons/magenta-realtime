# AUv3 Presets and Notarized macOS Release Plan

## Purpose

Deliver the Jam preset experience in the AUv3 host and distribute the macOS
applications and AUv3 plugin as verified, notarized GitHub Release assets.

## Scope

- Factory and user-preset behaviour in the AUv3 host.
- Verification in Logic Pro and Ableton Live.
- A protected, draft-first GitHub Release pipeline for Standalone, AUv3, Jam,
  Collider, Max, Pure Data, and SuperCollider artifacts.

PyPI publication is out of scope. The repository remains a fork of the Magenta
upstream; upstream licence notices and Python package identity are unchanged.

## Milestones

### P1 — Factory preset catalogue

Issue: <https://github.com/metaneutrons/magenta-realtime/issues/1>

The AUv3 host reads the same factory catalogue as Jam and exposes it through
its custom interface. The catalogue verifier must pass and a preset selection
must update only the documented host state.

### P2 — DAW qualification

Issue: <https://github.com/metaneutrons/magenta-realtime/issues/2>

Logic Pro and Ableton Live load the AUv3 extension after a clean rescan. The
factory and user-preset paths restore state across project reload, and MIDI
input produces audio without stuck notes.

### P3 — Solo-preset semantics

Issue: <https://github.com/metaneutrons/magenta-realtime/issues/3>

Record an explicit decision whether solo presets reproduce Jam performance
mode. If accepted, document the state mapping and add a regression test; if
rejected, document the intentional difference.

### P4 — GitHub Release qualification

The release is created by Release Please as a draft. The protected release
workflow must validate the tag and credentials, notarize all seven app and
plug-in payloads,
generate SPDX SBOMs, create Sigstore bundles and GitHub attestations, verify a
downloaded draft inventory byte-for-byte, and only then promote it to latest.

## Dependencies and evidence

P2 depends on P1. P4 depends on a repository-scoped Release Please App and a
successful planned prerelease qualification run. A merged pull request is not
evidence of DAW qualification or publication; issue updates record the exact
test run, artifact identities, and any remaining limitation.
