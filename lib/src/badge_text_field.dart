import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namna_badge_field/namna_badge_field.dart';

class BadgeTextField extends StatefulWidget {
  const BadgeTextField({
    super.key,
    this.hintText,
    required this.label,
    required this.order,
    required this.labelSVG,
    required this.controller,
    required this.selectedOptions,
    required this.onNewOption,
    required this.onClearOption,
    required this.onSelectOption,
    this.onChange,
    this.child,
    this.customFrame = false,
  });

  final double order;
  final String label;
  final String? hintText;
  final Widget labelSVG;
  final TextEditingController controller;
  final List<BadgeData> selectedOptions;
  final Function() onNewOption;
  final Function(BadgeData option) onClearOption;
  final Function(BadgeData option) onSelectOption;
  final Future<List<BadgeData>> Function(String s)? onChange;

  ///  [ if wanna to use your Custom TextField use 'child: Widget' ]
  final Widget? child;

  ///  [ if wanna to create frame customize use 'customFrame:true' ]
  final bool customFrame;

  @override
  State<BadgeTextField> createState() => _OptionTextFieldWidget();
}

class _OptionTextFieldWidget extends State<BadgeTextField> {
  List<BadgeData> selectedOptions = [];
  List<BadgeData> hintList = [];
  String? error;
  bool? loading;
  FocusNode node = FocusNode();
  FocusScopeNode overlayNode = FocusScopeNode();

  OverlayEntry? suggestionOverlay;

  @override
  void initState() {
    super.initState();
    selectedOptions = widget.selectedOptions;
    findSizeAndPosition();
  }

  @override
  void dispose() {
    node.dispose();
    overlayNode.dispose();
    super.dispose();
  }

  showSuggestOverlay() {
    hideSuggestOptionOverlay();
    findSizeAndPosition();
    assert(suggestionOverlay == null);

    suggestionOverlay = OverlayEntry(
      builder: (context) {
        double width = 418;
        return BadgeTextFelidOverlayBody(
          order: widget.order,
          overlayNode: overlayNode,
          body: (hintList.isEmpty) ? _buildOnNewAction(context, width) : null,
          left: offset.dx,
          top: offset.dy + size.height,
          width: width,
          optionsHintList: hintList,
          onSelected: widget.onSelectOption,
          onClose: () {
            setState(() {
              hideSuggestOptionOverlay();
              node.requestFocus();
            });
          },
        );
      },
    );
    Overlay.of(context, debugRequiredFor: widget).insert(suggestionOverlay!);
  }

  hideSuggestOptionOverlay() {
    suggestionOverlay?.remove();
    suggestionOverlay?.dispose();
    suggestionOverlay = null;
  }

  GlobalKey myKey = GlobalKey();
  late Size size;
  late Offset offset;

  findSizeAndPosition() {
    if (myKey.currentContext != null) {
      final RenderBox renderBox =
          myKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        offset = renderBox.localToGlobal(Offset.zero);
        size = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customFrame) {
      return SizedBox(child: _buildFieldBody(context));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldBadge(label: widget.label, icon: widget.labelSVG),
      InkWell(
        onTap: () => node.requestFocus(),
        child: Focus(
          onKeyEvent: (n, ke) {
            if (ke is KeyDownEvent) {
              if (ke.physicalKey == PhysicalKeyboardKey.backspace &&
                  hintList.isNotEmpty) {
                setState(() {});
                if (widget.controller.text.isEmpty) {
                  widget.selectedOptions.removeLast();
                }
                return KeyEventResult.ignored;
              }
              if (ke.physicalKey == PhysicalKeyboardKey.tab) {
                if (hintList.isNotEmpty) {
                  hideSuggestOptionOverlay();

                  widget.onSelectOption(hintList.first);
                  node.requestFocus();
                  hintList.clear();
                  return KeyEventResult.handled;
                }
                if (hintList.isEmpty) {
                  return KeyEventResult.ignored;
                }
              }

              if (ke.physicalKey == PhysicalKeyboardKey.arrowDown &&
                  hintList.isNotEmpty) {
                showSuggestOverlay();
                overlayNode.requestFocus();
                return KeyEventResult.ignored;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Row(children: [
            Expanded(
                child: FocusTraversalOrder(
              order: NumericFocusOrder(widget.order),
              child: Container(
                key: myKey,
                padding: EdgeInsets.only(
                  bottom: selectedOptions.isEmpty ? 2 : 8,
                  top: selectedOptions.isEmpty ? 2 : 8,
                  left: 8,
                  right: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 1.5,
                    color: node.hasFocus ? Colors.black : Colors.grey,
                  ),
                ),
                child: _buildFieldBody(context),
              ),
            )),
          ]),
        ),
      ),
    ]);
  }

  Wrap _buildFieldBody(BuildContext context) {
    return Wrap(
      runSpacing: 8,
      spacing: 5,
      children: [
        ...selectedOptions.map((e) => Padding(
            padding: const EdgeInsets.all(1), child: badgeItem(listItem: e))),
        _buildTextField(context)
      ],
    );
  }

  Widget badgeItem({required BadgeData listItem}) {
    return HoverBuilder(
      builder: (context, h) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.2),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            5.spaceW,
            Text(listItem.name),
            8.spaceW,
            if (!h) const Icon(Icons.check_sharp, color: Colors.blue, size: 16),
            if (h)
              InkWell(
                  onTap: () {
                    widget.onClearOption.call(listItem);
                  },
                  child: const Icon(Icons.close, color: Colors.red, size: 16)),
          ]),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context) {
    return SizedBox(
      height: 28,
      width: 100,
      child: widget.child ??
          TextFormField(
            focusNode: node,
            controller: widget.controller,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
            onTapOutside: (event) {
              node.unfocus();
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: const OutlineInputBorder(borderSide: BorderSide.none),
            ),
            onChanged: (v) async {
              node.requestFocus();
              setState(() {
                loading = true;
                error = null;
              });
              try {
                var res = await widget.onChange?.call(v);
                hintList = res ?? [];
                if (v.isNotEmpty) {
                  showSuggestOverlay();
                }
              } catch (e) {
                error = e.toString();
              } finally {
                if (v.isEmpty) {
                  setState(() {
                    error = null;
                    loading = false;
                    hideSuggestOptionOverlay();
                  });
                }
              }
            },
          ),
    );
    //   },
    // );
  }

  Widget _buildOnNewAction(BuildContext context, double width) {
    return InkWell(
      onTap: () {
        try {
          widget.onNewOption();
        } catch (e) {
          log(e.toString());
        } finally {
          setState(() {
            hideSuggestOptionOverlay();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(),
        ),
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 35,
        width: width,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Icon(Icons.add, color: Colors.black, size: 22),
          Text('New "${widget.controller.text}"')
        ]),
      ),
    );
  }
}
