import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ChipsFormField extends StatefulWidget {
  final Color autoCompleteColor;
  final double autoCompletePadding;
  final Color chipBackgroundColor;
  final Color chipIconColor;
  final Color cursorColor;
  final FocusNode focusNode;
  final String hintText;
  final TextStyle hintTextStyle;
  final List<String> initialValue;
  final InputDecoration inputDecoration;
  final int maxChips;
  final int minimalQueryLength;
  final List<String> Function(String) onAutoComplete;
  final void Function(String) onAddChip;
  final void Function(String) onRemoveChip;
  final TextStyle textStyle;

  /// A [TextFormField] widget that allows the user to input multiple values
  /// which are visualized as [InputChip]s.
  /// 
  /// Whenever the user presses the enter key on his keyboard, then the current
  /// text input is added as another [ChipInput]. The list of [ChipInput]s is
  /// visualized before / preprended to the actual [TextFormField]. This widget
  /// also comes with an autocomplete feature which shows suggested values to the
  /// user while typing.
  ChipsFormField({
    this.autoCompleteColor = Colors.transparent,
    this.autoCompletePadding = 32,
    this.chipBackgroundColor,
    this.chipIconColor,
    this.cursorColor = Colors.white,
    this.hintText = '',
    this.initialValue,
    this.inputDecoration = const InputDecoration.collapsed(hintText: ''),
    this.minimalQueryLength = 2,
    this.maxChips,
    this.textStyle,
    @required this.focusNode,
    @required this.hintTextStyle,
    @required this.onAutoComplete,
    @required this.onAddChip,
    @required this.onRemoveChip,
  }) : assert(maxChips == null ||
            (maxChips > 0 && initialValue.length <= maxChips));

  @override
  State<StatefulWidget> createState() => _ChipsFormFieldState();
}

class _ChipsFormFieldState extends State<ChipsFormField> {
  final _textEditingController = TextEditingController();
  final _rawKeyboardListenerFocusNode = FocusNode(skipTraversal: true);
  final _suggestionsScrollController = ScrollController();
  final _chips = <String>[];

  bool get _hasReachedMaxChips =>
      widget.maxChips != null && this._chips.length >= widget.maxChips;

  OverlayEntry _overlayEntry;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      this._chips.addAll(widget.initialValue);
    }

    // Remove overlay if input field loses focus
    widget.focusNode.addListener(() {
      if (!widget.focusNode.hasFocus) {
        this._removeAutocompleteOverlay();
      }
    });

    this._textEditingController.addListener(() {
      final query = this._textEditingController.text.toLowerCase();
      if (query.isEmpty ||
          query.length < widget.minimalQueryLength ||
          this._hasReachedMaxChips) {
        this._removeAutocompleteOverlay();
      } else if (widget.focusNode.hasFocus) {
        setState(() {
          this._suggestions = <String>[this._textEditingController.text] +
              widget.onAutoComplete(query);
        });
        this._addAutocompleteOverlay();
      }
    });
  }

  void _addAutocompleteOverlay() {
    // if (widget.maxChips != null && this._chips.length == widget.maxChips) {
    //   return;
    // }

    if (this._overlayEntry != null) {
      this._overlayEntry.markNeedsBuild();
    } else {
      this._overlayEntry = this._createOverlayEntry();
      Overlay.of(context).insert(this._overlayEntry);
    }
  }

  void _removeAutocompleteOverlay() {
    this._suggestions.clear();
    if (this._overlayEntry != null) {
      this._overlayEntry.remove();
      this._overlayEntry = null;
    }
  }

  void _addTextAsChip(String tag) {
    setState(() {
      this._chips.add(tag);
      this._suggestions.clear();
      this._textEditingController.clear();
    });
    widget.onAddChip(tag);

    this._removeAutocompleteOverlay();
    Future.delayed(Duration(milliseconds: 10), () {
      widget.focusNode.requestFocus();
    });
  }

  void _onKeyboardEvent(RawKeyEvent keyEvent) {
    if (keyEvent.runtimeType != RawKeyDownEvent) {
      return;
    }

    // Add current text as chip if user presses the enter key
    if ((keyEvent.physicalKey == PhysicalKeyboardKey.enter ||
            keyEvent.physicalKey == PhysicalKeyboardKey.numpadEnter) &&
        this._textEditingController.text.isNotEmpty &&
        !this._hasReachedMaxChips) {
      this._addTextAsChip(this._textEditingController.text);
    }

    // Delete existing chips if the user presses the backspace key
    if ((keyEvent.physicalKey == PhysicalKeyboardKey.backspace) &&
        this._textEditingController.text.isEmpty &&
        this._chips.isNotEmpty) {
      setState(() {
        final chip = this._chips.removeLast();
        widget.onRemoveChip(chip);
      });
    }

    // Remove autocomplete list if user presses the escape key
    if (keyEvent.physicalKey == PhysicalKeyboardKey.escape) {
      this._removeAutocompleteOverlay();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + widget.autoCompletePadding,
        top: offset.dy + size.height,
        width: size.width - 2 * widget.autoCompletePadding,
        child: Material(
          elevation: 2.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 150,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              controller: this._suggestionsScrollController,
              padding: EdgeInsets.zero,
              itemCount: this._suggestions.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => this._addTextAsChip(this._suggestions[index]),
                  child: ListTile(
                    tileColor: widget.autoCompleteColor,
                    title: Text(
                      this._suggestions[index],
                      style: widget.textStyle,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var chipWidgets = this
        ._chips
        .map<Widget>(
          (chip) => Padding(
            padding: EdgeInsets.only(top: 10),
            child: InputChip(
              elevation: 2,
              onDeleted: () => setState(() {
                this._chips.remove(chip);
                widget.onRemoveChip(chip);
              }),
              deleteIcon: Icon(
                Icons.clear,
                color: widget.chipIconColor ??
                    widget.textStyle.color ??
                    Colors.black,
              ),
              label: Text(
                chip,
                style: widget.textStyle,
              ),
              backgroundColor: widget.chipBackgroundColor,
            ),
          ),
        )
        .toList();

    chipWidgets.add(
      IntrinsicWidth(
        stepWidth: 20,
        child: RawKeyboardListener(
          focusNode: this._rawKeyboardListenerFocusNode,
          onKey: this._onKeyboardEvent,
          child: Align(
            alignment: Alignment.center,
            child: TextFormField(
              autofocus: true,
              controller: this._textEditingController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintTextStyle,
                contentPadding: EdgeInsets.only(
                  left: 8.0,
                ),
                border: InputBorder.none,
              ),
              focusNode: widget.focusNode,
              style: widget.textStyle ?? Theme.of(context).textTheme.bodyText1,
              cursorColor: widget.cursorColor,
            ),
          ),
        ),
      ),
    );

    return Material(
      child: InputDecorator(
        decoration: widget.inputDecoration,
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => widget.focusNode.requestFocus(),
            child: Wrap(
              children: chipWidgets,
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.start,
            ),
          ),
        ),
      ),
    );
  }
}
