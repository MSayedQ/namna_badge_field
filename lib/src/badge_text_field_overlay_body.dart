import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namna_badge_field/namna_badge_field.dart';

class BadgeTextFelidOverlayBody extends StatefulWidget {
  const BadgeTextFelidOverlayBody({
    super.key,
    this.body,
    required this.top,
    required this.left,
    required this.width,
    required this.onClose,
    required this.onSelected,
    required this.overlayNode,
    this.optionsHintList,
    required this.order,
  });

  final double width;
  final Widget? body;
  final double top, left;
  final Function() onClose;
  final FocusScopeNode overlayNode;
  final List<OptionData>? optionsHintList;
  final Function(OptionData option) onSelected;

  final double order;

  @override
  State<BadgeTextFelidOverlayBody> createState() => __OptionTextFelidOverlay();
}

class __OptionTextFelidOverlay extends State<BadgeTextFelidOverlayBody> {
  List<OptionData> options = [];

  Future<List<OptionData>> initList() async {
    var list = widget.optionsHintList;
    return options = list ?? [];
  }

  List<FocusNode> nodes = [];

  @override
  void initState() {
    initList();
    nodes = List.generate(options.length, (index) => FocusNode());
    super.initState();
  }

  @override
  void dispose() {
    for (var n in nodes) {
      n.dispose();
    }
    super.dispose();
  }

  sendFocus({bool nextFocus = true}) {
    var focused = 1;
    if (nextFocus) {
      setState(() {
        nodes[focused].nextFocus();
      });
    } else {
      setState(() {
        nodes[focused].previousFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Align(
          alignment: AlignmentDirectional.topEnd,
          child: Material(
            color: Colors.transparent,
            child: Stack(children: [
              Positioned(
                top: widget.top,
                left: widget.left,
                child: widget.body ?? _buildOverlayBody(),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  _buildOverlayBody() {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.grey),
        ),
        child: SingleChildScrollView(
          child: FocusTraversalOrder(
            order: NumericFocusOrder(widget.order),
            child: FocusScope(
              node: widget.overlayNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
                    sendFocus(nextFocus: true);
                    return KeyEventResult.handled;
                  }
                  if (event.physicalKey == PhysicalKeyboardKey.backspace) {
                    widget.onClose();
                    return KeyEventResult.handled;
                  }
                  if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
                    sendFocus(nextFocus: false);

                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ...List.generate(
                  options.length,
                  (index) {
                    var color = (index % 2 != 0 ? Colors.grey : Colors.white);

                    return _buildOverlayItem(
                      color,
                      context: context,
                      option: options[index],
                      index: index,
                    );
                  },
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  _buildOverlayItem(
    Color color, {
    required BuildContext context,
    required OptionData option,
    required int index,
  }) {
    //?
    return Focus(
      focusNode: nodes[index],
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.physicalKey == PhysicalKeyboardKey.enter) {
            widget.onSelected.call(option);
            widget.onClose.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: () {
          widget.onSelected.call(option);
          widget.onClose();
        },
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.all(21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text(option.name)],
          ),
        ),
      ),
    );
  }
}
