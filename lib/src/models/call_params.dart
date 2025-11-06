/// Parameters for customizing call initialization
class CallParams {
  /// The caller name to display
  final String? callerName;

  /// The caller number to use
  final String? callerNumber;

  /// The destination number to call
  final String? destinationNumber;

  /// Custom client state data
  final String? clientState;

  /// Custom headers to include with the call
  ///
  /// These headers need to start with the X- prefix and will be mapped to dynamic variables in the AI assistant (e.g., X-Account-Number becomes {{account_number}}).
  /// Hyphens in header names are converted to underscores in variable names.
  final Map<String, String>? customHeaders;

  const CallParams({
    this.callerName,
    this.callerNumber,
    this.destinationNumber,
    this.clientState,
    this.customHeaders,
  });

  /// Create a copy of this CallParams with some fields replaced
  CallParams copyWith({
    String? callerName,
    String? callerNumber,
    String? destinationNumber,
    String? clientState,
    Map<String, String>? customHeaders,
  }) {
    return CallParams(
      callerName: callerName ?? this.callerName,
      callerNumber: callerNumber ?? this.callerNumber,
      destinationNumber: destinationNumber ?? this.destinationNumber,
      clientState: clientState ?? this.clientState,
      customHeaders: customHeaders ?? this.customHeaders,
    );
  }

  @override
  String toString() {
    return 'CallParams('
        'callerName: $callerName, '
        'callerNumber: $callerNumber, '
        'destinationNumber: $destinationNumber, '
        'clientState: $clientState, '
        'customHeaders: $customHeaders'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CallParams &&
        other.callerName == callerName &&
        other.callerNumber == callerNumber &&
        other.destinationNumber == destinationNumber &&
        other.clientState == clientState &&
        _mapEquals(other.customHeaders, customHeaders);
  }

  @override
  int get hashCode {
    return Object.hash(
      callerName,
      callerNumber,
      destinationNumber,
      clientState,
      customHeaders,
    );
  }

  /// Helper method to compare maps for equality
  bool _mapEquals(Map<String, String>? a, Map<String, String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}