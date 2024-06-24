import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';

class Button extends AdvancedButtonComponent {
  late String text;

  Button({
    String? text,
    Vector2? size,
    super.position,
    super.onPressed,
  }) {
    super.size = size ?? Vector2(60, 40);
    this.text = text ?? "button";
    super.anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    defaultLabel = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black54,
        ),
      ),
    );

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 200, 0, 1));

    hoverSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 180, 0, 1));

    downSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 140, 0, 1));
  }
}

class RoundedRectComponent extends PositionComponent with HasPaint {
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        width,
        height,
        topLeft: Radius.circular(height),
        topRight: Radius.circular(height),
        bottomRight: Radius.circular(height),
        bottomLeft: Radius.circular(height),
      ),
      paint,
    );
  }
}
