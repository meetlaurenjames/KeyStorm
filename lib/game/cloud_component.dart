import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';

class CloudComponent extends SvgComponent {
  CloudComponent({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(220, 120),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    svg = await Svg.load('assets/images/keystorm_cloud.svg');
  }
}