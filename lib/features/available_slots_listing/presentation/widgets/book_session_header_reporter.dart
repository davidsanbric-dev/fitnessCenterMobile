import 'package:flutter/widgets.dart';

/// Callback used by the embeddable "Book a Session" flow to report its current
/// header state up to a host that renders the page-level header itself (instead
/// of letting each stage render its own [PageHeader]).
///
/// The host uses [stageKey] to de-duplicate redundant reports: it only adopts a
/// new [secondarySubtitle]/[backHandler] when the key changes, which keeps the
/// stage-aware back button stable even though some stages rebuild a fresh
/// handler closure on every frame.
///
/// - [stageKey] uniquely identifies the current stage and its back behaviour
///   (e.g. `'mode'`, `'cap:group'`, `'disc:availability'`).
/// - [secondarySubtitle]/[secondarySubtitleIcon] describe the second-level
///   subtitle for the stage (null on the initial scheduling-mode selection).
/// - [backHandler] is the stage-aware action to run when the header back button
///   is pressed (null falls back to the host's own "close flow" action).
typedef BookSessionHeaderReporter =
    void Function(
      String stageKey,
      String? secondarySubtitle,
      IconData? secondarySubtitleIcon,
      VoidCallback? backHandler,
    );
