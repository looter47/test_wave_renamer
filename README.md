# WaveRenamer (macOS)

A SwiftUI macOS app that classifies `.wav` files by primary instrument and renames files in place using a deterministic naming pattern.

## Current status

This repository currently contains a functional prototype scaffold with:

- Native drag-and-drop UI for files/folders.
- Parallel batch processing with async tasks.
- Confidence thresholding and rename collision handling.
- Pluggable classifier interface (currently deterministic placeholder, not real ML inference yet).

## Prerequisites (macOS)

- macOS 13+
- Xcode 15+ (includes Swift 5.9+ toolchain)

## Download the code

```bash
git clone <YOUR_REPO_URL> wave-renamer
cd wave-renamer
```

## Build and run (recommended: Xcode)

1. Open the package in Xcode:
   - Finder: double-click `Package.swift`, or
   - Terminal:
     ```bash
     open Package.swift
     ```
2. In Xcode, select the **WaveRenamer** scheme.
3. Choose **My Mac** as the run destination.
4. Press **Run** (`⌘R`).

## Build and run from Terminal (macOS only)

```bash
swift build
swift run WaveRenamer
```

## What to expect in the prototype

- You can drop `.wav` files (or folders) into the app.
- The app predicts an instrument using deterministic placeholder logic.
- Files are renamed in place using the current naming pattern (default: `{instrument}_Track_{index}`).

## Limitations right now

- The classifier is a stub (`InstrumentClassifier`) for flow testing only.
- `AudioPreprocessor` is scaffolding; mel-spectrogram extraction and real Core ML integration are still TODO.
- Packaging/signing/notarization workflow is not wired yet.

## Next integration steps

1. Replace `InstrumentClassifier` with a real Core ML model invocation.
2. Add mel-spectrogram extraction in `AudioPreprocessor` using Accelerate.
3. Persist user settings (threshold, naming pattern).
4. Add audit log export and rename rollback support.
